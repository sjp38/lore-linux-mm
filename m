Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 31D666B0031
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 23:08:49 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so416726pad.5
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 20:08:48 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so261055pbb.38
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 20:08:46 -0700 (PDT)
Date: Tue, 1 Oct 2013 20:08:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.12] mm, memcg: protect mem_cgroup_read_events for
 cpu hotplug
In-Reply-To: <20131002022227.GR856@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1310011958440.31300@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1310011629350.27758@chino.kir.corp.google.com> <20131002022227.GR856@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 1 Oct 2013, Johannes Weiner wrote:

> On Tue, Oct 01, 2013 at 04:31:23PM -0700, David Rientjes wrote:
> > for_each_online_cpu() needs the protection of {get,put}_online_cpus() so
> > cpu_online_mask doesn't change during the iteration.
> 
> There is no problem report here.
> 
> Is there a crash?
> 

No.

> If it's just accuracy of the read, why would we care about some
> inaccuracies in counters that can change before you even get the
> results to userspace?  And care to the point where we hold up CPU
> hotplugging for this?
> 

cpu_hotplug.lock is held while a cpu is going down, it's a coarse lock 
that is used kernel-wide to synchronize cpu hotplug activity.  Memcg has 
a cpu hotplug notifier, called while there may not be any cpu hotplug 
refcounts, which drains per-cpu event counts to memcg->nocpu_base.events 
to maintain a cumulative event count as cpus disappear.  Without 
get_online_cpus() in mem_cgroup_read_events(), it's possible to account 
for the event count on a dying cpu twice, and this value may be 
significantly large.

In fact, all memcg->pcp_counter_lock use should be nested by 
{get,put}_online_cpus().

This fixes that issue and ensures the reported statistics are not vastly 
over-reported during cpu hotplug.

> Also, the fact that you directly sent this to Linus suggests there is
> some urgency for this fix.  What's going on?
> 

I believe users of cpu hotplug still want event counts that are 
approximate to the real value and that this is 3.12 material.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
