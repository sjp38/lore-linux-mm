Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6FC6B0254
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 09:22:18 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so207374002wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:22:17 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id m1si6022618wif.83.2015.09.23.06.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 06:22:16 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so238116017wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:22:16 -0700 (PDT)
Date: Wed, 23 Sep 2015 16:22:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [linux-next] khugepaged inconsistent lock state
Message-ID: <20150923132214.GC25020@node.dhcp.inet.fi>
References: <20150921044600.GA863@swordfish>
 <20150921150135.GB30755@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1509211611190.8889@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509211611190.8889@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon, Sep 21, 2015 at 04:57:05PM -0700, Hugh Dickins wrote:
> On Mon, 21 Sep 2015, Kirill A. Shutemov wrote:
> > On Mon, Sep 21, 2015 at 01:46:00PM +0900, Sergey Senozhatsky wrote:
> > > Hi,
> > > 
> > > 4.3.0-rc1-next-20150918
> > > 
> > > [18344.236625] =================================
> > > [18344.236628] [ INFO: inconsistent lock state ]
> > > [18344.236633] 4.3.0-rc1-next-20150918-dbg-00014-ge5128d0-dirty #361 Not tainted
> > > [18344.236636] ---------------------------------
> > > [18344.236640] inconsistent {IN-RECLAIM_FS-W} -> {RECLAIM_FS-ON-W} usage.
> > > [18344.236645] khugepaged/32 [HC0[0]:SC0[0]:HE1:SE1] takes:
> > > [18344.236648]  (&anon_vma->rwsem){++++?.}, at: [<ffffffff81134403>] khugepaged+0x8b0/0x1987
> > > [18344.236662] {IN-RECLAIM_FS-W} state was registered at:
> > > [18344.236666]   [<ffffffff8107d747>] __lock_acquire+0x8e2/0x1183
> > > [18344.236673]   [<ffffffff8107e7ac>] lock_acquire+0x10b/0x1a6
> > > [18344.236678]   [<ffffffff8150a367>] down_write+0x3b/0x6a
> > > [18344.236686]   [<ffffffff811360d8>] split_huge_page_to_list+0x5b/0x61f
> > > [18344.236689]   [<ffffffff811224b3>] add_to_swap+0x37/0x78
> > > [18344.236691]   [<ffffffff810fd650>] shrink_page_list+0x4c2/0xb9a
> > > [18344.236694]   [<ffffffff810fe47c>] shrink_inactive_list+0x371/0x5d9
> > > [18344.236696]   [<ffffffff810fee2f>] shrink_lruvec+0x410/0x5ae
> > > [18344.236698]   [<ffffffff810ff024>] shrink_zone+0x57/0x140
> > > [18344.236700]   [<ffffffff810ffc79>] kswapd+0x6a5/0x91b
> > > [18344.236702]   [<ffffffff81059588>] kthread+0x107/0x10f
> > > [18344.236706]   [<ffffffff8150c7bf>] ret_from_fork+0x3f/0x70
> > > [18344.236708] irq event stamp: 6517947
> > > [18344.236709] hardirqs last  enabled at (6517947): [<ffffffff810f2d0c>] get_page_from_freelist+0x362/0x59e
> > > [18344.236713] hardirqs last disabled at (6517946): [<ffffffff8150ba41>] _raw_spin_lock_irqsave+0x18/0x51
> > > [18344.236715] softirqs last  enabled at (6507072): [<ffffffff81041cb0>] __do_softirq+0x2df/0x3f5
> > > [18344.236719] softirqs last disabled at (6507055): [<ffffffff81041fb5>] irq_exit+0x40/0x94
> > > [18344.236722] 
> > >                other info that might help us debug this:
> > > [18344.236723]  Possible unsafe locking scenario:
> > > 
> > > [18344.236724]        CPU0
> > > [18344.236725]        ----
> > > [18344.236726]   lock(&anon_vma->rwsem);
> > > [18344.236728]   <Interrupt>
> > > [18344.236729]     lock(&anon_vma->rwsem);
> > > [18344.236731] 
> > >                 *** DEADLOCK ***
> > > 
> > > [18344.236733] 2 locks held by khugepaged/32:
> > > [18344.236733]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff81134122>] khugepaged+0x5cf/0x1987
> > > [18344.236738]  #1:  (&anon_vma->rwsem){++++?.}, at: [<ffffffff81134403>] khugepaged+0x8b0/0x1987
> > > [18344.236741] 
> > >                stack backtrace:
> > > [18344.236744] CPU: 3 PID: 32 Comm: khugepaged Not tainted 4.3.0-rc1-next-20150918-dbg-00014-ge5128d0-dirty #361
> > > [18344.236747]  0000000000000000 ffff880132827a00 ffffffff81230867 ffffffff8237ba90
> > > [18344.236750]  ffff880132827a38 ffffffff810ea9b9 000000000000000a ffff8801333b52e0
> > > [18344.236753]  ffff8801333b4c00 ffffffff8107b3ce 000000000000000a ffff880132827a78
> > > [18344.236755] Call Trace:
> > > [18344.236758]  [<ffffffff81230867>] dump_stack+0x4e/0x79
> > > [18344.236761]  [<ffffffff810ea9b9>] print_usage_bug.part.24+0x259/0x268
> > > [18344.236763]  [<ffffffff8107b3ce>] ? print_shortest_lock_dependencies+0x180/0x180
> > > [18344.236765]  [<ffffffff8107c7fc>] mark_lock+0x381/0x567
> > > [18344.236766]  [<ffffffff8107ca40>] mark_held_locks+0x5e/0x74
> > > [18344.236768]  [<ffffffff8107ee9f>] lockdep_trace_alloc+0xb0/0xb3
> > > [18344.236771]  [<ffffffff810f30cc>] __alloc_pages_nodemask+0x99/0x856
> > > [18344.236772]  [<ffffffff810ebaf9>] ? find_get_entry+0x14b/0x17a
> > > [18344.236774]  [<ffffffff810ebb16>] ? find_get_entry+0x168/0x17a
> > > [18344.236777]  [<ffffffff811226d9>] __read_swap_cache_async+0x7b/0x1aa
> > > [18344.236778]  [<ffffffff8112281d>] read_swap_cache_async+0x15/0x2d
> > > [18344.236780]  [<ffffffff8112294f>] swapin_readahead+0x11a/0x16a
> > > [18344.236783]  [<ffffffff81112791>] do_swap_page+0xa7/0x36b
> > > [18344.236784]  [<ffffffff81112791>] ? do_swap_page+0xa7/0x36b
> > > [18344.236787]  [<ffffffff8113444c>] khugepaged+0x8f9/0x1987
> > > [18344.236790]  [<ffffffff810772f3>] ? wait_woken+0x88/0x88
> > > [18344.236792]  [<ffffffff81133b53>] ? maybe_pmd_mkwrite+0x1a/0x1a
> > > [18344.236794]  [<ffffffff81059588>] kthread+0x107/0x10f
> > > [18344.236797]  [<ffffffff81059481>] ? kthread_create_on_node+0x1ea/0x1ea
> > > [18344.236799]  [<ffffffff8150c7bf>] ret_from_fork+0x3f/0x70
> > > [18344.236801]  [<ffffffff81059481>] ? kthread_create_on_node+0x1ea/0x1ea
> > 
> > Hm. If I read this correctly, we see following scenario:
> > 
> >  - khugepaged tries to swap in a page under mmap_sem and anon_vma lock;
> >  - do_swap_page() calls swapin_readahead() with GFP_HIGHUSER_MOVABLE;
> >  - __read_swap_cache_async() tries to allocate the page for swap in;
> >  - lockdep_trace_alloc() in __alloc_pages_nodemask() notices that with
> >    given gfp_mask we could end up in direct relaim.
> >  - Lockdep already knows that reclaim sometimes (e.g. in case of
> >    split_huge_page()) wants to take anon_vma lock on its own.
> > 
> > Therefore deadlock is possible.
> 
> Oh, thank you for working that out.  As usual with a lockdep trace,
> I knew it was telling me something important, but in a language I
> just couldn't understand without spending much longer to decode it.
> Yes, wrong to call do_swap_page() while holding anon_vma lock.
> 
> > 
> > I see two ways to fix this:
> > 
> >  - take anon_vma lock *after* __collapse_huge_page_swapin() in
> >    collapse_huge_page(): I don't really see why we need the lock
> >    during swapin;
> 
> Agreed.

Okay. Patch for this is below.

Ebru, could you test it?

> >  - respect FAULT_FLAG_RETRY_NOWAIT in do_swap_page(): add GFP_NOWAIT to
> >    gfp_mask for swapin_readahead() in this case.
> 
> Sounds like a good idea; though I have some reservations you're welcome
> to ignore.  Partly because it goes beyond what's actually needed here,
> partly because there's going to be plenty of waiting while the swapin
> is done, partly because I think such a change may better belong to a
> larger effort, extending FAULT_FLAG_RETRY somehow to cover the memory
> allocation as well as the I/O phase (but we might be hoping instead for
> a deeper attack on mmap_sem which would make FAULT_FLAG_RETRY redundant).

I agree, we need something more coherent here, than what I wanted to do at
first. I don't have time for this :-/

Anyone?

> And the down_write of mmap_sem here, across all of those (63? 511?)
> swapins, worries me.  Should the swapins be done higher up, under
> just a down_read of mmap_sem (required to guard vma)?  Or should
> mmap_sem be dropped and retaken repeatedly, and the various things
> (including vma itself) be checked repeatedly?  I don't know.

Ebru, would you willing to rework collapse_huge_page() to call
__collapse_huge_page_swapin() under down_read(mmap_sem)?
