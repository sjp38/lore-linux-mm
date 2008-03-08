Date: Fri, 7 Mar 2008 23:37:32 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
In-Reply-To: <6934efce0803072033m5efd4d1o1ca8526f94649bb5@mail.gmail.com>
Message-ID: <alpine.LFD.1.00.0803072331090.2911@woody.linux-foundation.org>
References: <6934efce0803072033m5efd4d1o1ca8526f94649bb5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>


On Fri, 7 Mar 2008, Jared Hulbert wrote:
>
> [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
> 
> Convert XIP to support non-struct page backed memory.
> The get_xip_page API is changed from a page based to an address/pfn based one.

Is there any way we could just re-use the same calling conventions as we 
already use for "vma->fault()"?

> +	int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
> +			unsigned long *);

This really looks very close to 

	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);

and "struct vm_fault" returns either a kernel virtual address or a "struct 
page *" 

So would it be possible to just use the same calling convention, except 
passing a "struct address_space" instead of a "struct vm_area_struct"?

I realize that "struct vm_fault" doesn't have a pfn in it (if they don't 
do a "struct page", they are expected to fill in the PTE directly instead 
and return VM_FAULT_NOPAGE), but I wonder if it should.

The whole git_xip_page() issue really looks very similar to "fault in a 
page from an address space". It feels kind of wrong to have filesystems 
implement two functions for what seems to be the exact same issue.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
