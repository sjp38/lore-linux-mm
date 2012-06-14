Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0E52D6B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:42:42 -0400 (EDT)
Date: Thu, 14 Jun 2012 17:42:20 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: bugs in page colouring code
Message-ID: <20120614084219.GD22007@linux-sh.org>
References: <20120613152936.363396d5@cuia.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120613152936.363396d5@cuia.bos.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sjhill@mips.com, ralf@linux-mips.org, Borislav Petkov <borislav.petkov@amd.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Rob Herring <rob.herring@calxeda.com>, Russell King <rmk+kernel@arm.linux.org.uk>, Nicolas Pitre <nico@linaro.org>

On Wed, Jun 13, 2012 at 03:29:36PM -0400, Rik van Riel wrote:
> ARM & MIPS seem to share essentially the same page colouring code, with
> these two bugs:
> 
> COLOUR_ALIGN_DOWN can use the pgoff % shm_align_mask either positively
>    or negatively, depending on the address initially found by 
>    get_unmapped_area
> 
> static inline unsigned long COLOUR_ALIGN_DOWN(unsigned long addr,
>                                               unsigned long pgoff)
> {
>         unsigned long base = addr & ~shm_align_mask;
>         unsigned long off = (pgoff << PAGE_SHIFT) & shm_align_mask;
>
>         if (base + off <= addr)
>                 return base + off;
>
>         return base - off;
> }
>
> The fix would be to return an address that is a whole shm_align_mask
> lower: (((base - shm_align_mask) & ~shm_align_mask) + off

'addr' in this case is already adjusted by callers of COLOUR_ALIGN_DOWN(), so
this shouldn't be an issue, unless I'm missing something?

> The second bug relates to MAP_FIXED mappings of files.  In the
> MAP_FIXED conditional, arch_get_unmapped_area(_topdown) checks
> whether the mapping is colour aligned, but only for MAP_SHARED
> mappings.
> 
>                 /*
>                  * We do not accept a shared mapping if it would violate
>                  * cache aliasing constraints.
>                  */
>                 if ((flags & MAP_SHARED) &&
>                     ((addr - (pgoff << PAGE_SHIFT)) & shm_align_mask))
>                         return -EINVAL;
> 
These observations hold true for other architectures, too. I modelled the
SH implementation off of both MIPS and sparc, where these same patterns
exist. I would be surprised if there are any architectures that do
colouring in a different way.

The logic is such that in the MAP_FIXED case we can't align addr on to some
other boundary, and so anything that violates the aliasing constraints fails.
This is a departure from POSIX, and does occasionally lead to people sending in
patches to "correct" the behaviour for the LTP mmap01 testcase which does
iterative MAP_FIXED|MAP_SHARED PAGE_SIZE apart.

> This fails to take into account that the same file might be mapped
> MAP_SHARED from some programs, and MAP_PRIVATE from another.  The
> fix could be a simple as always enforcing colour alignment when we
> are mmapping a file (filp is non-zero).
> 
If that combination is possible then defaulting to colour alignment seems
reasonable. Whether that combination is reasonable or not is another matter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
