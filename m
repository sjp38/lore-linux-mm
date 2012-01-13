Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 001726B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 10:36:16 -0500 (EST)
Date: Fri, 13 Jan 2012 15:35:56 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC PATCH] proc: clear_refs: do not clear reserved pages
Message-ID: <20120113153556.GY1068@n2100.arm.linux.org.uk>
References: <1326467587-22218-1-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326467587-22218-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Nicolas Pitre <nico@fluxnic.net>, moussaba@micron.com, David Rientjes <rientjes@google.com>

On Fri, Jan 13, 2012 at 03:13:07PM +0000, Will Deacon wrote:
> /proc/pid/clear_refs is used to clear the Referenced and YOUNG bits for
> pages and corresponding page table entries of the task with PID pid,
> which includes any special mappings inserted into the page tables in
> order to provide things like vDSOs and user helper functions.
> 
> On ARM this causes a problem because the vectors page is mapped as a
> global mapping and since ec706dab ("ARM: add a vma entry for the user
> accessible vector page"), a VMA is also inserted into each task for this
> page to aid unwinding through signals and syscall restarts. Since the
> vectors page is required for handling faults, clearing the YOUNG bit
> (and subsequently writing a faulting pte) means that we lose the vectors
> page *globally* and cannot fault it back in. This results in a system
> deadlock on the next exception.
> 
> This patch avoids clearing the aforementioned bits for reserved pages,
> therefore leaving the vectors page intact on ARM. Since reserved pages
> are not candidates for swap, this change should not have any impact on
> the usefulness of clear_refs.

Having just looked at mm/swapfile.c, what ensures that we don't try to swap
the vectors page out?

I thought that VM_IO or VM_RESERVED once guaranteed that the vma wouldn't
be scanned, but I don't see anything in there which tests these flags.
As a result, it seems to me that the original patch is wrong, and we need
to keep the vectors page completely out of the vma list to prevent it
ever being made old.

Maybe the MM gurus can comment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
