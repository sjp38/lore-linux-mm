Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3A96B0037
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 17:57:57 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so529976pde.34
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 14:57:56 -0800 (PST)
Received: from psmtp.com ([74.125.245.180])
        by mx.google.com with SMTP id m9si62187pba.53.2013.11.14.14.57.54
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 14:57:55 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id a41so739168yho.13
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 14:57:53 -0800 (PST)
Date: Thu, 14 Nov 2013 14:57:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add memory.oom_control notification for system
 oom
In-Reply-To: <20131114032508.GL707@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com> <20131031054942.GA26301@cmpxchg.org> <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com> <20131113233419.GJ707@cmpxchg.org> <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 13 Nov 2013, Johannes Weiner wrote:

> > > Somebody called out_of_memory() after they
> > > failed reclaim, the machine is OOM.
> > 
> > While momentarily oom, the oom notifiers in powerpc and s390 have the 
> > ability to free memory without requiring a kill.
> 
> So either
> 
> 1) they should be part of the regular reclaim process, or
> 
> 2) their invocation is severe enough to not be part of reclaim, at
>    which point we should probably tell userspace about the OOM
> 

(1) is already true, we can avoid oom by freeing memory for subsystems 
using register_oom_notifier(), so we're not actually oom.  It's a late 
callback into the kernel to free memory in a sense of reclaim.  It was 
added directly into out_of_memory() purely for simplicity; it could be 
moved to the page allocator if we move all of the oom_notify_list helpers 
there as well.

The same is true of silently setting TIF_MEMDIE for current so that it has 
access to memory reserves and may exit when it has a pending SIGKILL or is 
already exiting.

In both cases, we're not actually oom because either (a) the kernel can 
still free memory and avoid actually killing a process, or (b) current 
simply needs access to memory reserves so it may die.

We don't want to invoke the userspace oom handler when we first enter 
direct reclaim, for example, for the same reason.

> > I think you're misunderstanding the kernel oom notifiers, they exist 
> > solely to free memory so that the oom killer actually doesn't have to kill 
> > anything.  The fact that they use kernel notifiers is irrelevant and 
> > userspace oom notification is separate.  Userspace is only going to want a 
> > notification when the oom killer has to kill something, the EXACT same 
> > semantics as the non-root-memcg memory.oom_control.
> 
> That's actually not true, we invoke the OOM notifier before calling
> mem_cgroup_out_of_memory(), which then may skip the kill in favor of
> letting current exit.  It does this for when the kernel handler is
> enabled, which would be the equivalent for what you are implementing.
> 

Good point, I don't think we should be notifying userspace for memcg oom 
conditions when current simply needs access to memory reserves to exit: 
the memcg isn't actually oom since TIF_MEMDIE implies memcg bypass.  I 
think we should do that in mem_cgroup_handle_oom() rather than 
mem_cgroup_out_of_memory().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
