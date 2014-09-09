Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 403BD6B0096
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 14:23:24 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kx10so5930507pab.10
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 11:23:23 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id t5si24542612pdd.122.2014.09.09.11.23.17
        for <linux-mm@kvack.org>;
        Tue, 09 Sep 2014 11:23:17 -0700 (PDT)
Message-ID: <540F4592.9030408@sr71.net>
Date: Tue, 09 Sep 2014 11:23:14 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
References: <54061505.8020500@sr71.net> <5406262F.4050705@intel.com> <54062F32.5070504@sr71.net> <20140904142721.GB14548@dhcp22.suse.cz> <5408CB2E.3080101@sr71.net> <20140905123517.GA21208@cmpxchg.org> <540DCF99.2070900@intel.com> <20140909145044.GA16027@cmpxchg.org>
In-Reply-To: <20140909145044.GA16027@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On 09/09/2014 07:50 AM, Johannes Weiner wrote:
> The mctz->lock is only taken when there is, or has been, soft limit
> excess.  However, the soft limit defaults to infinity, so unless you
> set it explicitly on the root level, I can't see how this could be
> mctz->lock contention.
> 
> It's more plausible that this is the res_counter lock for testing soft
> limit excess - for me, both these locks get inlined into check_events,
> could you please double check you got the right lock?

I got the wrong lock.  Here's how it looks after mainline, plus your free_pages_and_swap_cache() patch:

Samples: 2M of event 'cycles', Event count (approx.): 51647128377                            
+   60.60%     1.33%  page_fault2_processes              [.] testcase                       a??
+   59.14%     0.41%  [kernel]                           [k] page_fault                     a??
+   58.72%     0.01%  [kernel]                           [k] do_page_fault                  a??
+   58.70%     0.08%  [kernel]                           [k] __do_page_fault                a??
+   58.50%     0.29%  [kernel]                           [k] handle_mm_fault                a??
+   40.14%     0.28%  [kernel]                           [k] do_cow_fault                   a??
-   34.56%    34.56%  [kernel]                           [k] _raw_spin_lock                 a??
   - _raw_spin_lock                                                                         a??
      - 78.11% __res_counter_charge                                                         a??
           res_counter_charge                                                               a??
           try_charge                                                                       a??
         - mem_cgroup_try_charge                                                            a??
            + 99.99% do_cow_fault                                                           a??
      - 10.30% res_counter_uncharge_until                                                   a??
           res_counter_uncharge                                                             a??
           uncharge_batch                                                                   a??
           uncharge_list                                                                    a??
           mem_cgroup_uncharge_list                                                         a??
           release_pages                                                                    a??
      + 4.75% free_pcppages_bulk                                                            a??
      + 3.65% do_cow_fault                                                                  a??
      + 2.24% get_page_from_freelist                                                        a??

> You also said that this cost hasn't been there before, but I do see
> that trace in both v3.16 and v3.17-rc3 with roughly the same impact
> (although my machines show less contention than yours).  Could you
> please double check that this is in fact a regression independent of
> 05b843012335 ("mm: memcontrol: use root_mem_cgroup res_counter")?

Here's the same workload on the same machine with only Johannes' revert applied:

-   35.92%    35.92%  [kernel]                           [k] _raw_spin_lock                 a??
   - _raw_spin_lock                                                                         a??
      - 49.09% get_page_from_freelist                                                       a??
         - __alloc_pages_nodemask                                                           a??
            + 99.90% alloc_pages_vma                                                        a??
      - 43.67% free_pcppages_bulk                                                           a??
         - 100.00% free_hot_cold_page                                                       a??
            + 99.93% free_hot_cold_page_list                                                a??
      - 7.08% do_cow_fault                                                                  a??
           handle_mm_fault                                                                  a??
           __do_page_fault                                                                  a??
           do_page_fault                                                                    a??
           page_fault                                                                       a??
           testcase                                                                         a??

So I think it's probably part of the same regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
