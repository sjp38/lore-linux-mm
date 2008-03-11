Date: Tue, 11 Mar 2008 11:58:53 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
Message-ID: <20080311105853.GA31429@wotan.suse.de>
References: <6934efce0803072033m5efd4d1o1ca8526f94649bb5@mail.gmail.com> <alpine.LFD.1.00.0803072331090.2911@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0803072331090.2911@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jared Hulbert <jaredeh@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Maxim Shchetynin <maxim@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 11:37:32PM -0800, Linus Torvalds wrote:
> 
> 
> On Fri, 7 Mar 2008, Jared Hulbert wrote:
> >
> > [RFC][PATCH 1/3] xip: no struct pages -- get_xip_mem
> > 
> > Convert XIP to support non-struct page backed memory.
> > The get_xip_page API is changed from a page based to an address/pfn based one.
> 
> Is there any way we could just re-use the same calling conventions as we 
> already use for "vma->fault()"?
> 
> > +	int (*get_xip_mem)(struct address_space *, pgoff_t, int, void **,
> > +			unsigned long *);
> 
> This really looks very close to 
> 
> 	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
> 
> and "struct vm_fault" returns either a kernel virtual address or a "struct 
> page *" 
> 
> So would it be possible to just use the same calling convention, except 
> passing a "struct address_space" instead of a "struct vm_area_struct"?
> 
> I realize that "struct vm_fault" doesn't have a pfn in it (if they don't 
> do a "struct page", they are expected to fill in the PTE directly instead 
> and return VM_FAULT_NOPAGE), but I wonder if it should.
> 
> The whole git_xip_page() issue really looks very similar to "fault in a 
> page from an address space". It feels kind of wrong to have filesystems 
> implement two functions for what seems to be the exact same issue.

It's not quite the same. get_xip_mem is used not just for page faults,
but also for read(2) and write(2) -- this really is the whole reason
why it wants a pfn and a kaddr: for the fault path, you need to install
the pfn, for read or write, the kernel wants a handle on the memory.

I think I'd rather not use vm_fault at the moment, and definitely not
unify it with fault (I'm still trying to unify nopage, nopfn, and
page_mkwrite with fault; and all of those really are special cases of
a fault).

Anyway, I'm just reposting the patchset, I'd love to get the ball rolling
again...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
