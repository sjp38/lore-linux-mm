Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 716256B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 05:03:02 -0400 (EDT)
Date: Mon, 22 Jun 2009 17:02:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 11/15] HWPOISON: The high level memory error handler in
	the VM v8
Message-ID: <20090622090233.GB8110@localhost>
References: <20090620031608.624240019@intel.com> <20090620031626.106150781@intel.com> <20090621085721.GD8218@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090621085721.GD8218@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "npiggin@suse.de" <npiggin@suse.de>, "chris.mason@oracle.com" <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jun 21, 2009 at 04:57:21PM +0800, Andi Kleen wrote:
> > v8:
> > check for page_mapped_in_vma() on anon pages (Hugh, Fengguang)
> 
> This change was no good as discussed earlier.
> 
> > test and use page->mapping instead of page_mapping() (Fengguang)
> > cleanup some early kill comments (Fengguang)
> 
> This stuff belongs into the manpage. I haven't written it yet,
> but will. I don't think kernel source comments is the right place.

OK. You may take this block

        + * When the corrupted page data is not recoverable, the tasks mapped the page
        + * have to be killed. We offer two kill options:
        + * - early kill with SIGBUS.BUS_MCEERR_AO (optional)
        + * - late  kill with SIGBUS.BUS_MCEERR_AR (mandatory)
        + * A task will be early killed as soon as corruption is found in its virtual
        + * address space, if it has called prctl(PR_MEMORY_FAILURE_EARLY_KILL, 1, ...);
        + * Any task will be late killed when it tries to access its corrupted virtual
        + * address. The early kill option offers KVM or other apps with large caches an
        + * opportunity to isolate the corrupted page from its internal cache, so as to
        + * avoid being late killed.

and/or this one into the man page :)

        +=============================================================
        +
        +memory_failure_early_kill:
        +
        +Control how to kill processes when uncorrected memory error (typically
        +a 2bit error in a memory module) is detected in the background by hardware
        +that cannot be handled by the kernel. In some cases (like the page
        +still having a valid copy on disk) the kernel will handle the failure
        +transparently without affecting any applications. But if there is
        +no other uptodate copy of the data it will kill to prevent any data
        +corruptions from propagating.
        +
        +1: Kill all processes that have the corrupted and not reloadable page mapped
        +as soon as the corruption is detected.  Note this is not supported
        +for a few types of pages, like kernel internally allocated data or
        +the swap cache, but works for the majority of user pages.
        +
        +0: Only unmap the corrupted page from all processes and only kill a process
        +who tries to access it.
        +
        +The kill is done using a catchable SIGBUS with BUS_MCEERR_AO, so processes can
        +handle this if they want to.
        +
        +This is only active on architectures/platforms with advanced machine
        +check handling and depends on the hardware capabilities.
        +
         ==============================================================


But I think these new comments are OK?

        + * We don't aim to rescue 100% corruptions. That's unreasonable goal - the
        + * kernel text and slab pages (including the big dcache/icache) are almost
        + * impossible to isolate. We also try to keep the code clean by ignoring the
        + * other thousands of small corruption windows.
        + *

And this:

        @@ -275,6 +286,12 @@ static void collect_procs_file(struct pa

                        vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff,
                                              pgoff)
        +                       /*
        +                        * Send early kill signal to tasks whose vma covers
        +                        * the page but not necessarily mapped it in its pte.
        +                        * Applications who requested early kill normally want
        +                        * to be informed of such data corruptions.
        +                        */
                                if (vma->vm_mm == tsk->mm)
                                        add_to_kill(tsk, page, vma, to_kill, tkc);
                }

> > introduce invalidate_inode_page() and don't remove dirty/writeback pages
> > from page cache (Nick, Fengguang)
> 
> I'm still dubious this is a good idea, it means potentially a lot 
> of pages not covered.

This is good for .31 I think. But for .32 we can sure cover more pages :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
