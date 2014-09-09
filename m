Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 495C36B0044
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 10:50:58 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id m15so3154874wgh.7
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 07:50:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s6si18328100wiy.42.2014.09.09.07.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Sep 2014 07:50:56 -0700 (PDT)
Date: Tue, 9 Sep 2014 10:50:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140909145044.GA16027@cmpxchg.org>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <20140905123517.GA21208@cmpxchg.org>
 <540DCF99.2070900@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <540DCF99.2070900@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Sep 08, 2014 at 08:47:37AM -0700, Dave Hansen wrote:
> On 09/05/2014 05:35 AM, Johannes Weiner wrote:
> > On Thu, Sep 04, 2014 at 01:27:26PM -0700, Dave Hansen wrote:
> >> On 09/04/2014 07:27 AM, Michal Hocko wrote:
> >>> Ouch. free_pages_and_swap_cache completely kills the uncharge batching
> >>> because it reduces it to PAGEVEC_SIZE batches.
> >>>
> >>> I think we really do not need PAGEVEC_SIZE batching anymore. We are
> >>> already batching on tlb_gather layer. That one is limited so I think
> >>> the below should be safe but I have to think about this some more. There
> >>> is a risk of prolonged lru_lock wait times but the number of pages is
> >>> limited to 10k and the heavy work is done outside of the lock. If this
> >>> is really a problem then we can tear LRU part and the actual
> >>> freeing/uncharging into a separate functions in this path.
> >>>
> >>> Could you test with this half baked patch, please? I didn't get to test
> >>> it myself unfortunately.
> >>
> >> 3.16 settled out at about 11.5M faults/sec before the regression.  This
> >> patch gets it back up to about 10.5M, which is good.  The top spinlock
> >> contention in the kernel is still from the resource counter code via
> >> mem_cgroup_commit_charge(), though.
> > 
> > Thanks for testing, that looks a lot better.
> > 
> > But commit doesn't touch resource counters - did you mean try_charge()
> > or uncharge() by any chance?
> 
> I don't have the perf output that I was looking at when I said this, but
> here's the path that I think I was referring to.  The inlining makes
> this non-obvious, but this memcg_check_events() calls
> mem_cgroup_update_tree() which is contending on mctz->lock.
> 
> So, you were right, it's not the resource counters code, it's a lock in
> 'struct mem_cgroup_tree_per_zone'.  But, the contention isn't _that_
> high (2% of CPU) in this case.  But, that is 2% that we didn't see before.
> 
> >      1.87%     1.87%  [kernel]               [k] _raw_spin_lock_irqsave       
> >                                |
> >                                --- _raw_spin_lock_irqsave
> >                                   |          
> >                                   |--107.09%-- memcg_check_events
> >                                   |          |          
> >                                   |          |--79.98%-- mem_cgroup_commit_charge
> >                                   |          |          |          
> >                                   |          |          |--99.81%-- do_cow_fault
> >                                   |          |          |          handle_mm_fault
> >                                   |          |          |          __do_page_fault
> >                                   |          |          |          do_page_fault
> >                                   |          |          |          page_fault
> >                                   |          |          |          testcase
> >                                   |          |           --0.19%-- [...]

The mctz->lock is only taken when there is, or has been, soft limit
excess.  However, the soft limit defaults to infinity, so unless you
set it explicitly on the root level, I can't see how this could be
mctz->lock contention.

It's more plausible that this is the res_counter lock for testing soft
limit excess - for me, both these locks get inlined into check_events,
could you please double check you got the right lock?

As the limit defaults to infinity, and really doesn't mean anything on
the root level it's idiotic to test it, we can easily eliminate that.
With the patch below, I don't have that trace show up in the profile
anymore.  Could you please give it a try?

You also said that this cost hasn't been there before, but I do see
that trace in both v3.16 and v3.17-rc3 with roughly the same impact
(although my machines show less contention than yours).  Could you
please double check that this is in fact a regression independent of
05b843012335 ("mm: memcontrol: use root_mem_cgroup res_counter")?

Thanks!

---
