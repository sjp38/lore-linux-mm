Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17E1A6B02F4
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 10:46:47 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so8767369wrc.8
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 07:46:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d101si1766330wma.156.2017.06.09.07.46.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 07:46:45 -0700 (PDT)
Date: Fri, 9 Jun 2017 16:46:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170609144642.GH21764@dhcp22.suse.cz>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-3-mhocko@kernel.org>
 <20170608143606.GK19866@dhcp22.suse.cz>
 <20170609140853.GA14760@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170609140853.GA14760@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 09-06-17 10:08:53, Johannes Weiner wrote:
> On Thu, Jun 08, 2017 at 04:36:07PM +0200, Michal Hocko wrote:
> > Does anybody see any problem with the patch or I can send it for the
> > inclusion?
> > 
> > On Fri 19-05-17 13:26:04, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > Any allocation failure during the #PF path will return with VM_FAULT_OOM
> > > which in turn results in pagefault_out_of_memory. This can happen for
> > > 2 different reasons. a) Memcg is out of memory and we rely on
> > > mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> > > normal allocation fails.
> > > 
> > > The later is quite problematic because allocation paths already trigger
> > > out_of_memory and the page allocator tries really hard to not fail
> > > allocations. Anyway, if the OOM killer has been already invoked there
> > > is no reason to invoke it again from the #PF path. Especially when the
> > > OOM condition might be gone by that time and we have no way to find out
> > > other than allocate.
> > > 
> > > Moreover if the allocation failed and the OOM killer hasn't been
> > > invoked then we are unlikely to do the right thing from the #PF context
> > > because we have already lost the allocation context and restictions and
> > > therefore might oom kill a task from a different NUMA domain.
> > > 
> > > An allocation might fail also when the current task is the oom victim
> > > and there are no memory reserves left and we should simply bail out
> > > from the #PF rather than invoking out_of_memory.
> > > 
> > > This all suggests that there is no legitimate reason to trigger
> > > out_of_memory from pagefault_out_of_memory so drop it. Just to be sure
> > > that no #PF path returns with VM_FAULT_OOM without allocation print a
> > > warning that this is happening before we restart the #PF.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> I don't agree with this patch.
> 
> The warning you replace the oom call with indicates that we never
> expect a VM_FAULT_OOM to leak to this point. But should there be a
> leak, it's infinitely better to tickle the OOM killer again - even if
> that call is then fairly inaccurate and without alloc context - than
> infinite re-invocations of the #PF when the VM_FAULT_OOM comes from a
> context - existing or future - that isn't allowed to trigger the OOM.

I disagree. Retrying the page fault while dropping all the locks
on the way and still being in the killable context should be preferable
to a system wide disruptive action like the OOM killer. If something
goes wrong the admin can kill the process easily and keep the problem
isolated to a single place which to me sounds like much better than a
random shooting...

As I've already pointed out to Tetsuo. If we have an allocation which is
not allowed to trigger the OOM killer and still fails for some reason
and gets up to pagefault_out_of_memory then we basically break that
do-not-trigger-oom-killer promise which is an incorrect behavior as well.

> I'm not a fan of defensive programming, but is this call to OOM more
> expensive than the printk() somehow? And how certain are you that no
> VM_FAULT_OOMs will leak, given how spread out page fault handlers and
> how complex the different allocation contexts inside them are?

Yes, checking this will be really unfeasible. On the other hand a leaked
VM_FAULT_OOM will become a PF retry (maybe endless which is a fair
point) but the same leak would mean shutting down a large part of the
system (until the current context itself is killed) and that sounds more
dangerous to me.

I am not insisting on this patch but to me it sounds like it implements
a more sensible and less dangerous system wide behavior.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
