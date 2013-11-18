Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 73D146B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 10:55:01 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5160319pdj.16
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 07:55:01 -0800 (PST)
Received: from psmtp.com ([74.125.245.111])
        by mx.google.com with SMTP id qj1si9956908pbc.354.2013.11.18.07.54.59
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 07:55:00 -0800 (PST)
Date: Mon, 18 Nov 2013 10:54:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: add memory.oom_control notification for
 system oom
Message-ID: <20131118155450.GB3556@cmpxchg.org>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com>
 <20131031054942.GA26301@cmpxchg.org>
 <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com>
 <20131113233419.GJ707@cmpxchg.org>
 <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu, Nov 14, 2013 at 02:57:51PM -0800, David Rientjes wrote:
> On Wed, 13 Nov 2013, Johannes Weiner wrote:
> 
> > > > Somebody called out_of_memory() after they
> > > > failed reclaim, the machine is OOM.
> > > 
> > > While momentarily oom, the oom notifiers in powerpc and s390 have the 
> > > ability to free memory without requiring a kill.
> > 
> > So either
> > 
> > 1) they should be part of the regular reclaim process, or
> > 
> > 2) their invocation is severe enough to not be part of reclaim, at
> >    which point we should probably tell userspace about the OOM
> > 
> 
> (1) is already true, we can avoid oom by freeing memory for subsystems 
> using register_oom_notifier(), so we're not actually oom.  It's a late 
> callback into the kernel to free memory in a sense of reclaim.  It was 
> added directly into out_of_memory() purely for simplicity; it could be 
> moved to the page allocator if we move all of the oom_notify_list helpers 
> there as well.

If they can easily free it without any repercussions, they should
really be part of regular reclaim.  Maybe convert them to shrinkers.

And then you can use OOM notifiers to be notified about OOM.

> The same is true of silently setting TIF_MEMDIE for current so that it has 
> access to memory reserves and may exit when it has a pending SIGKILL or is 
> already exiting.
> 
> In both cases, we're not actually oom because either (a) the kernel can 
> still free memory and avoid actually killing a process, or (b) current 
> simply needs access to memory reserves so it may die.
> 
> We don't want to invoke the userspace oom handler when we first enter 
> direct reclaim, for example, for the same reason.

Reclaim is an option the kernel always has, the current task exiting
is a coincidence.

And accessing the emergency reserves means we are definitely no longer
A-OK, this is not comparable to the first direct reclaim invocation.

We exhausted our options and we got really lucky.  It should not be
considered the baseline and a user listening for "OOM conditions"
should be informed about this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
