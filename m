Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E0A0C6B005D
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 15:30:35 -0400 (EDT)
Date: Wed, 13 Jun 2012 15:29:36 -0400
From: Rik van Riel <riel@redhat.com>
Subject: bugs in page colouring code
Message-ID: <20120613152936.363396d5@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Borislav Petkov <borislav.petkov@amd.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

I am working on a project to make arch_get_unmapped_area(_topdown) scale
for processes with large numbers of VMAs, as well as unify the various
architecture specific variations into one common set of code that does
it all.

While trying to unify the page colouring code, I have run into a number
of bugs in both the ARM/MIPS implementation, and the x86-64 implementation.

Since one of the objects of my project is to get rid of the architecture
specific copies of code, it seems more practical to document the bugs in
the current code, rather than fix them first and then replace the code
later...

What I am asking for is a quick review of my analysis below, pointing
out my mistakes and getting a general feeling whether my proposed merger
of the various page colouring functions into one function that does it
all is something you would be ok with.


ARM & MIPS seem to share essentially the same page colouring code, with
these two bugs:

COLOUR_ALIGN_DOWN can use the pgoff % shm_align_mask either positively
   or negatively, depending on the address initially found by 
   get_unmapped_area

static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
                                              unsigned long pgoff)
{
        unsigned long base = addr & ~shm_align_mask;
        unsigned long off = (pgoff << PAGE_SHIFT) & shm_align_mask;

        if (base + off <= addr)
                return base + off;

        return base - off;
}

The fix would be to return an address that is a whole shm_align_mask
lower: (((base - shm_align_mask) & ~shm_align_mask) + off 


The second bug relates to MAP_FIXED mappings of files.  In the
MAP_FIXED conditional, arch_get_unmapped_area(_topdown) checks
whether the mapping is colour aligned, but only for MAP_SHARED
mappings.

                /*
                 * We do not accept a shared mapping if it would violate
                 * cache aliasing constraints.
                 */
                if ((flags & MAP_SHARED) &&
                    ((addr - (pgoff << PAGE_SHIFT)) & shm_align_mask))
                        return -EINVAL;

This fails to take into account that the same file might be mapped
MAP_SHARED from some programs, and MAP_PRIVATE from another.  The
fix could be a simple as always enforcing colour alignment when we
are mmapping a file (filp is non-zero).



The page colouring code on x86-64, align_addr in sys_x86_64.c is
slightly more amusing.

For one, there are separate kernel boot arguments to control whether
32 and 64 bit processes need to have their addresses aligned for
page colouring.

Do we really need that?
Would it be a problem if I discarded that code, in order to get
to one common cache colouring implementation?


Secondly, MAP_FIXED never checks for page colouring alignment.
I assume the cache aliasing on AMD Bulldozer is merely a performance
issue, and we can simply ignore page colouring for MAP_FIXED?
That will be easy to get right in an architecture-independent
implementation.


A third issue is this:

        if (!(current->flags & PF_RANDOMIZE))
                return addr;

Do we really want to skip page colouring merely because the 
application does not have PF_RANDOMIZE set?  What is this
conditional supposed to do?

When an app calls mmap with address 0, what breaks by giving
it a properly page coloured address, instead of the first
suitable address we find?


The last issue with the page colouring for x86-64 is that it
does not take pgoff into account.  In other words, if one
process maps a file starting at offset 0, and another one maps
the file starting at offset 1, both mappings start at the same
page colour and the mappings do not align right. This is easy
to fix, by making that aspect of the code similar to the ARM
and MIPS code.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
