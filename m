Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 665D26B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:51:06 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so12484204wrd.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:51:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y60si4424206wrc.42.2017.06.23.05.51.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:51:05 -0700 (PDT)
Date: Fri, 23 Jun 2017 14:50:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, oom: do not trigger out_of_memory from the
 #PF
Message-ID: <20170623125056.GY5308@dhcp22.suse.cz>
References: <20170519112604.29090-1-mhocko@kernel.org>
 <20170519112604.29090-3-mhocko@kernel.org>
 <20170608143606.GK19866@dhcp22.suse.cz>
 <20170609140853.GA14760@cmpxchg.org>
 <20170609144642.GH21764@dhcp22.suse.cz>
 <20170610084901.GB12347@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170610084901.GB12347@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 10-06-17 10:49:01, Michal Hocko wrote:
> On Fri 09-06-17 16:46:42, Michal Hocko wrote:
> > On Fri 09-06-17 10:08:53, Johannes Weiner wrote:
> > > On Thu, Jun 08, 2017 at 04:36:07PM +0200, Michal Hocko wrote:
> > > > Does anybody see any problem with the patch or I can send it for the
> > > > inclusion?
> > > > 
> > > > On Fri 19-05-17 13:26:04, Michal Hocko wrote:
> > > > > From: Michal Hocko <mhocko@suse.com>
> > > > > 
> > > > > Any allocation failure during the #PF path will return with VM_FAULT_OOM
> > > > > which in turn results in pagefault_out_of_memory. This can happen for
> > > > > 2 different reasons. a) Memcg is out of memory and we rely on
> > > > > mem_cgroup_oom_synchronize to perform the memcg OOM handling or b)
> > > > > normal allocation fails.
> > > > > 
> > > > > The later is quite problematic because allocation paths already trigger
> > > > > out_of_memory and the page allocator tries really hard to not fail
> > > > > allocations. Anyway, if the OOM killer has been already invoked there
> > > > > is no reason to invoke it again from the #PF path. Especially when the
> > > > > OOM condition might be gone by that time and we have no way to find out
> > > > > other than allocate.
> > > > > 
> > > > > Moreover if the allocation failed and the OOM killer hasn't been
> > > > > invoked then we are unlikely to do the right thing from the #PF context
> > > > > because we have already lost the allocation context and restictions and
> > > > > therefore might oom kill a task from a different NUMA domain.
> > > > > 
> > > > > An allocation might fail also when the current task is the oom victim
> > > > > and there are no memory reserves left and we should simply bail out
> > > > > from the #PF rather than invoking out_of_memory.
> > > > > 
> > > > > This all suggests that there is no legitimate reason to trigger
> > > > > out_of_memory from pagefault_out_of_memory so drop it. Just to be sure
> > > > > that no #PF path returns with VM_FAULT_OOM without allocation print a
> > > > > warning that this is happening before we restart the #PF.
> > > > > 
> > > > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > I don't agree with this patch.
> > > 
> > > The warning you replace the oom call with indicates that we never
> > > expect a VM_FAULT_OOM to leak to this point. But should there be a
> > > leak, it's infinitely better to tickle the OOM killer again - even if
> > > that call is then fairly inaccurate and without alloc context - than
> > > infinite re-invocations of the #PF when the VM_FAULT_OOM comes from a
> > > context - existing or future - that isn't allowed to trigger the OOM.
> > 
> > I disagree. Retrying the page fault while dropping all the locks
> > on the way and still being in the killable context should be preferable
> > to a system wide disruptive action like the OOM killer.
> 
> And just to clarify a bit. The OOM killer should be invoked whenever
> appropriate from the allocation context. If we decide to fail the
> allocation in the PF path then we can safely roll back and retry the
> whole PF. This has an advantage that any locks held while doing the
> allocation will be released and that alone can help to make a further
> progress. Moreover we can relax retry-for-ever _inside_ the allocator
> semantic for the PF path and fail allocations when we cannot make
> further progress even after we hit the OOM condition or we do stall for
> too long. This would have a nice side effect that PF would be a killable
> context from the page allocator POV. From the user space POV there is no
> difference between retrying the PF and looping inside the allocator,
> right?
> 
> That being said, late just-in-case OOM killer invocation is not only
> suboptimal it also disallows us to make further changes in that area.
> 
> Or am I oversimplifying or missing something here?

I am sorry to keep reviving this. I simply do not understand why the
code actually make sense. If am missing something I would like to hear
what it is. Then I will shut up (I promiss) ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
