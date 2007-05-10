Date: Thu, 10 May 2007 14:43:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 8464] New: autoreconf: page allocation failure. order:2,
 mode:0x84020
Message-Id: <20070510144319.48d2841a.akpm@linux-foundation.org>
In-Reply-To: <200705102128.l4ALSI2A017437@fire-2.osdl.org>
References: <200705102128.l4ALSI2A017437@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nicolas.Mailhot@LaPoste.net, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 May 2007 14:28:18 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8464
> 
>            Summary: autoreconf: page allocation failure. order:2,
>                     mode:0x84020
>     Kernel Version: 2.6.21-mm2 with SLUB
>             Status: NEW
>           Severity: normal
>              Owner: clameter@sgi.com
>          Submitter: Nicolas.Mailhot@LaPoste.net
>                 CC: akpm@osdl.org
> 
> 
> Most recent kernel where this bug did *NOT* occur: 2.6.21-rc6.mm1 with SLAB
> Distribution: Fedora Devel
> Hardware Environment: AMD X2 on CK804
> Software Environment: N/A
> Problem Description:
> 
> Just noticed this in kernel logs :
> 
>  autoreconf: page allocation failure. order:2, mode:0x84020
> May 10 20:13:13 rousalka kernel: 
> May 10 20:13:13 rousalka kernel: Call Trace:
> May 10 20:13:13 rousalka kernel: [<ffffffff8025b56a>] __alloc_pages+0x2aa/0x2c3
> May 10 20:13:13 rousalka kernel: [<ffffffff8029c05f>] bio_alloc+0x10/0x1f
> May 10 20:13:13 rousalka kernel: [<ffffffff8027519d>] __slab_alloc+0x196/0x586
> May 10 20:13:13 rousalka kernel: [<ffffffff80300d21>]
> radix_tree_node_alloc+0x36/0x7e
> May 10 20:13:13 rousalka kernel: [<ffffffff80275922>] kmem_cache_alloc+0x32/0x4e
> May 10 20:13:13 rousalka kernel: [<ffffffff80300d21>]
> radix_tree_node_alloc+0x36/0x7e
> May 10 20:13:13 rousalka kernel: [<ffffffff803011a4>] radix_tree_insert+0xcb/0x18c
> May 10 20:13:13 rousalka kernel: [<ffffffff88029bd0>] :ext3:ext3_get_block+0x0/0xe4
> May 10 20:13:13 rousalka kernel: [<ffffffff80256ac4>] add_to_page_cache+0x3d/0x95
> May 10 20:13:13 rousalka kernel: [<ffffffff8029fe29>] mpage_readpages+0x85/0x12c
> May 10 20:13:13 rousalka kernel: [<ffffffff88029bd0>] :ext3:ext3_get_block+0x0/0xe4
> May 10 20:13:13 rousalka kernel: [<ffffffff8025cde1>]
> __do_page_cache_readahead+0x158/0x22d
> May 10 20:13:13 rousalka kernel: [<ffffffff88084aa7>]
> :dm_mod:dm_table_any_congested+0x46/0x63
> May 10 20:13:13 rousalka kernel: [<ffffffff88082ce8>]
> :dm_mod:dm_any_congested+0x3b/0x42
> May 10 20:13:13 rousalka kernel: [<ffffffff80258802>] filemap_fault+0x162/0x347
> May 10 20:13:13 rousalka kernel: [<ffffffff80261c66>] __do_fault+0x66/0x446
> May 10 20:13:13 rousalka kernel: [<ffffffff80263ca9>] __handle_mm_fault+0x4b1/0x8f5
> May 10 20:13:13 rousalka kernel: [<ffffffff80419e84>] do_page_fault+0x39a/0x7b7
> May 10 20:13:13 rousalka kernel: [<ffffffff80419f31>] do_page_fault+0x447/0x7b7
> May 10 20:13:13 rousalka kernel: [<ffffffff8041847d>] error_exit+0x0/0x84
> 

This looks bad.

It's a bit hard to tell who failed - was it bio_alloc() or was it
radix-tree node allocation?  Give the allocation mode, I'd suspect
bio_alloc(), but I don't immediately see where we'd be doing an atomic
allocation for a bio.

Either way, it would worry me greatly if slub is fiddling with the mapping
of object-size-to-page-allocation-order.  A _lot_ of things which were
previously relaible and hugely tested would become less reliable, and less
tested.

Christoph, can we please take a look at /proc/slabinfo and its slub
equivalent (I forget what that is?) and review any and all changes to the
underlying allocation size for each cache?

Because this is *not* something we should change lightly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
