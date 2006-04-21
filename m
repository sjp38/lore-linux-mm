Date: Fri, 21 Apr 2006 00:29:38 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-Id: <20060421002938.3878aec5.akpm@osdl.org>
In-Reply-To: <20060301045910.12434.4844.sendpatchset@linux.site>
References: <20060301045901.12434.54077.sendpatchset@linux.site>
	<20060301045910.12434.4844.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
>  +/**
>  + *	remap_vmalloc_range  -  map vmalloc pages to userspace
>  + *
>  + *	@vma:		vma to cover (map full range of vma)
>  + *	@addr:		vmalloc memory
>  + *	@pgoff:		number of pages into addr before first page to map
>  + *	@returns:	0 for success, -Exxx on failure
>  + *
>  + *	This function checks that addr is a valid vmalloc'ed area, and
>  + *	that it is big enough to cover the vma. Will return failure if
>  + *	that criteria isn't met.
>  + *
>  + *	Similar to remap_pfn_range (see mm/memory.c)
>  + */

When replacing calls to remap_pfn_rage() with calls to remap_valloc_range():

- remap_pfn_range() sets VM_IO|VM_RESERVED|VM_PFNMAP on the user's vma. 
  remap_valloc_range() sets only VM_RESERVED.

- remap_pfn_range() has special handling for COWable user vma's, but
  remap_valloc_range() does not.

- are vma->vm_start and vma->vm_end always a multiple of PAGE_SIZE?  (I
  always forget).  If not, remap_valloc_range() looks a tad buggy.


pls explain.


- remap_valloc_range() can use ~PAGE_MASK, not PAGE_SIZE-1

- remap_valloc_range() would lose a whole buncha typecasts if you use the
  gcc pointer-arith-with-void* extension.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
