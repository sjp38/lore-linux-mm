Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0EFCC6B0126
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 13:52:07 -0400 (EDT)
Message-ID: <20101013175205.21187.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Wed, 13 Oct 2010 12:52:05 -0500 (GMT+5)
In-Reply-To: <20101013144044.GS30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

Mel Gorman writes:
> 
> On Mon, Oct 11, 2010 at 02:00:39PM -0700, Andrew Morton wrote:
> > 
> > It's corruption of user memory, which is unusual.  I'd be wondering if
> > there was a pre-existing bug which 6dda9d55bf545013597 has exposed -
> > previously the corruption was hitting something harmless.  Something
> > like a missed CPU cache writeback or invalidate operation.
> > 
> 
> This seems somewhat plausible although it's hard to tell for sure. But
> lets say we had the following situation in memory
> 
> [<----MAX_ORDER_NR_PAGES---->][<----MAX_ORDER_NR_PAGES---->]
> INITRD                        memmap array

I don't use initrd, so this isn't exactly what happened here. But it could be
close. Let me throw out some more information and see if it triggers any
ideas.

First, I tried a new test after seeing the corruption happen:
# md5sum /sbin/e2fsck ; echo 1 > /proc/sys/vm/drop_caches ; md5sum /sbin/e2fsck
And got 2 different answers. The second answer was the correct one.

Since applying the suggested patch which changed MAX_ORDER-1 to MAX_ORDER-2,
I've been trying to isolate exactly when the corruption happens. Since I
don't know much about kernel code, my main method is stuffing the area full
of printk's.

First I duplicated the affected function __free_one_page, since it's inlined
at 2 different places, so I could apply the patch to just one of them. This
proved that the problem is happening when called from free_one_page.

The patch which fixes (or at least covers up) the bug will only matter when
order==MAX_ORDER-2, otherwise everything is the same. So I added a lot of
printk's to show what's happening when order==MAX_ORDER-2. I found that, very
repeatably, 126 such instances occur during boot, and 61 of them pass the
page_is_buddy(higher_page, higher_buddy, order + 1) test, causing them to
call list_add_tail.

Next, since the bug appears when this code decides to call list_add_tail,
I made my own wrapper for list_add_tail, which allowed me to force some of
the calls to do list_add instead. Eventually I found that of the 61 calls,
the last one makes the difference. Allowing the first 60 calls to go through
to list_add_tail, and switching the last one to list_add, the symptom goes
away.

dump_stack() for that last call gave me a backtrace like this:
[c0303e80] [c0008124] show_stack+0x4c/0x144 (unreliable)
[c0303ec0] [c0068a84] free_one_page+0x28c/0x5b0
[c0303f20] [c0069588] __free_pages_ok+0xf8/0x120
[c0303f40] [c02d28c8] free_all_bootmem_core+0xf0/0x1f8
[c0303f70] [c02d29fc] free_all_bootmem+0x2c/0x6c
[c0303f90] [c02cc7dc] mem_init+0x70/0x2ac
[c0303fc0] [c02c66a4] start_kernel+0x150/0x27c
[c0303ff0] [00003438] 0x3438

And this might be interesting: the PFN of the page being added in that
critical 61st call is 130048, which exactly matches the number of available
pages:

  free_area_init_node: node 0, pgdat c02fee6c, node_mem_map c0330000
    DMA zone: 1024 pages used for memmap
    DMA zone: 0 pages reserved
    DMA zone: 130048 pages, LIFO batch:31
  Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 130048

Suspicious?

If 130048 is added to the head of the order==MAX_ORDER-2 free list, there's
no symptom. Add it to the tail, and the corruption appears.

That's all I know so far.

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
