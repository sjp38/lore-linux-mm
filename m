Date: Tue, 13 May 2008 10:48:12 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 2/2] mm: remove nopfn
Message-ID: <20080513154812.GA23256@sgi.com>
References: <20080513074723.GB12869@wotan.suse.de> <20080513074829.GC12869@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080513074829.GC12869@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 09:48:29AM +0200, Nick Piggin wrote:
> There are no users of nopfn in the tree. Remove it.
> 

The SGI mspec driver use to use the nopfn callout. I see that this
was recently changed but the new code fails with:


	kernel BUG at mm/memory.c:2278!
	fop1[5887]: bugcheck! 0 [1]
	Modules linked in:
	Call Trace:
	 [<a000000100012740>] show_stack+0x40/0xa0
	 [<a000000100013050>] show_regs+0x850/0x8a0
	 [<a000000100036210>] die+0x1b0/0x2c0
	 [<a000000100036370>] die_if_kernel+0x50/0x80
	 [<a000000100037a50>] ia64_bad_break+0x230/0x460
	 [<a00000010000a2a0>] ia64_leave_kernel+0x0/0x270
	 [<a000000100141650>] __do_fault+0xb0/0xa20
	 [<a000000100145a50>] handle_mm_fault+0x2f0/0xf40
	 [<a000000100059160>] ia64_do_page_fault+0x220/0xa40
	 [<a00000010000a2a0>] ia64_leave_kernel+0x0/0x270


The mspec driver is tripping the bugcheck in __do_fault()
	BUG_ON(vma->vm_flags & VM_PFNMAP);

The driver does not create pte entries at map time. Instead, it
relies on the nopfn (now fault) callout to assign resources
and create the ptes. It is intentionally done this way in order to
ensure that node-local resources are assigned.

What should the driver be doing to avoid this problem??


Also, the new GRU driver will have a similar problem. It currently
uses the nopfn callout since it needs to be able to assign resources
at fault, not mmap. The driver is not currently in-tree but will be
posted as soon as mmu_notifiers are available. I can post the current
version if it is helpful.....


--- jack


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
