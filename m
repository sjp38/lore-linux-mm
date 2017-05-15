Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 14B2E6B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:51:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t126so5459417pgc.9
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:51:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c19si5438919pfe.59.2017.05.15.05.51.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 05:51:27 -0700 (PDT)
Date: Mon, 15 May 2017 14:51:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: page allocation failures in swap_duplicate ->
 add_swap_count_continuation
Message-ID: <20170515125123.GG6056@dhcp22.suse.cz>
References: <772d81b0-df36-8644-41ca-dc13d0c0f2b5@de.ibm.com>
 <20170515080323.GD6056@dhcp22.suse.cz>
 <1c778ef8-b8ac-a62b-f5cf-35752582db6d@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1c778ef8-b8ac-a62b-f5cf-35752582db6d@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon 15-05-17 10:10:17, Christian Borntraeger wrote:
> On 05/15/2017 10:03 AM, Michal Hocko wrote:
> > On Fri 12-05-17 11:18:42, Christian Borntraeger wrote:
> >> Folks,
> >>
> >> recently I have seen page allocation failures during
> >> paging in the paging code:
> >> e.g. 
> >>
> >> May 05 21:36:53  kernel: Call Trace:
> >> May 05 21:36:53  kernel: ([<0000000000112f62>] show_trace+0x62/0x78)
> >> May 05 21:36:53  kernel:  [<0000000000113050>] show_stack+0x68/0xe0 
> >> May 05 21:36:53  kernel:  [<00000000004fb97e>] dump_stack+0x7e/0xb0 
> >> May 05 21:36:53  kernel:  [<0000000000299262>] warn_alloc+0xf2/0x190 
> >> May 05 21:36:53  kernel:  [<000000000029a25a>] __alloc_pages_nodemask+0xeda/0xfe0 
> >> May 05 21:36:53  kernel:  [<00000000002fa570>] alloc_pages_current+0xb8/0x170 
> >> May 05 21:36:53  kernel:  [<00000000002f03fc>] add_swap_count_continuation+0x3c/0x280 
> >> May 05 21:36:53  kernel:  [<00000000002f068c>] swap_duplicate+0x4c/0x80 
> >> May 05 21:36:53  kernel:  [<00000000002dfbfa>] try_to_unmap_one+0x372/0x578 
> >> May 05 21:36:53  kernel:  [<000000000030131a>] rmap_walk_ksm+0x14a/0x1d8 
> >> May 05 21:36:53  kernel:  [<00000000002e0d60>] try_to_unmap+0x140/0x170 
> >> May 05 21:36:53  kernel:  [<00000000002abc9c>] shrink_page_list+0x944/0xad8 
> >> May 05 21:36:53  kernel:  [<00000000002ac720>] shrink_inactive_list+0x1e0/0x5b8 
> >> May 05 21:36:53  kernel:  [<00000000002ad642>] shrink_node_memcg+0x5e2/0x800 
> >> May 05 21:36:53  kernel:  [<00000000002ad954>] shrink_node+0xf4/0x360 
> >> May 05 21:36:53  kernel:  [<00000000002aeb00>] kswapd+0x330/0x810 
> >> May 05 21:36:53  kernel:  [<0000000000189f14>] kthread+0x144/0x168 
> >> May 05 21:36:53  kernel:  [<00000000008011ea>] kernel_thread_starter+0x6/0xc 
> >> May 05 21:36:53  kernel:  [<00000000008011e4>] kernel_thread_starter+0x0/0xc 
> >>
> >> This seems to be new in 4.11 but the relevant code did not seem to have
> >> changed.
> >>
> >> Something like this 
> >>
> >> diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> index 1781308..b2dd53e 100644
> >> --- a/mm/swapfile.c
> >> +++ b/mm/swapfile.c
> >> @@ -3039,7 +3039,7 @@ int swap_duplicate(swp_entry_t entry)
> >>         int err = 0;
> >>  
> >>         while (!err && __swap_duplicate(entry, 1) == -ENOMEM)
> >> -               err = add_swap_count_continuation(entry, GFP_ATOMIC);
> >> +               err = add_swap_count_continuation(entry, GFP_ATOMIC | __GFP_NOWARN);
> >>         return err;
> >>  }
> >>  
> >>
> >> seems not appropriate, because this code does not know if the caller can
> >> handle returned errors.
> >>
> >> Would something like the following (white space damaged cut'n'paste be ok?
> >> (the try_to_unmap_one change looks fine, not sure if copy_one_pte does the
> >> right thing)
> > 
> > No, it won't. If you want to silent the warning then explain _why_ it is
> > a good approach. It is not immediatelly clear to me.
> 
> Consider my mail a bug report, not a proper fix. As far as I can tell, try_to_unmap_one
> can handle allocation failure gracefully, so not warn here _looks_ fine to me.

Could you be more specific about the issue then? I haven't checked very
closely but AFAIR we just keep pages on the LRU if try_to_unmap fails
and keep reclaiming. So we can handle the failure but it would be good
to know that something like that happened because if this is not a
one-off issue then it will help us to see why we see a seemingly
spurious OOM.

> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index 235ba51..3ae6f33 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -898,7 +898,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> >>                 swp_entry_t entry = pte_to_swp_entry(pte);
> >>  
> >>                 if (likely(!non_swap_entry(entry))) {
> >> -                       if (swap_duplicate(entry) < 0)
> >> +                       if (swap_duplicate(entry, __GFP_NOWARN) < 0)
> >>                                 return entry.val;
> 
> This code has special casing for the allocation failure path, but I cannot
> decide if it does the right thing here.

My point was that you should _always_ use the full gfp mask when taken
as a parameter so the above should be GFP_ATOMIC | __GFP_NOWARN...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
