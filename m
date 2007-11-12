Received: by nz-out-0506.google.com with SMTP id s1so1739273nze
        for <linux-mm@kvack.org>; Mon, 12 Nov 2007 15:53:24 -0800 (PST)
Message-ID: <6934efce0711121553s6b88d1qe48b19adee1b7a85@mail.gmail.com>
Date: Mon, 12 Nov 2007 15:53:22 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
In-Reply-To: <1194906542.18185.73.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
	 <200711111109.34562.nickpiggin@yahoo.com.au>
	 <6934efce0711121403h2623958cq49490077c586924f@mail.gmail.com>
	 <1194906542.18185.73.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 11/12/07, Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> On Mon, 2007-11-12 at 14:03 -0800, Jared Hulbert wrote:
> > They will, because it isn't allowed to be a COW mapping, and hence it
> > > fails the vm_normal_page() test.
> >
> > No.  It doesn't work.  If I have a mapping that doesn't abide by the
> > pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
> > rule, which is easy to do with vm_insert_pfn(), it won't get to NULL
> > at
> > if (pfn == vma->vm_pgoff + off)
> > and because we don't expect to get this far with a PFN sometimes I do
> > have a is_cow_mapping() that is just a PFN.  Which means I fail the
> > second test and get to the print_bad_pte().  At least that's what I
> > have captured in the past.  Is that bad?
>
> .../...
>
> I've hit that sort of thing in the past. I find vm_normal_page() very
> fragile in addition to hard to understand.

Despite the fact that is only ~50 line and 2/3 comments, I agree.

> Why can't we just have a VM flags that say "no normal pages here, move
> along, nothing to see" ? :-)

That won't work for me.

> That reminds me of a related problem: Such VMAs can't have
> access_process_vm() neither, which means you can't access them with gdb.
> That means for example that on Cell, an SPU local store cannot be
> inspected with gdb. I suspect the DRM with the new TTM has the same
> issue.
>
> I was thinking about adding an access() hook to the VM ops for such
> special VMAs to be able to provide ptrace with appropriate locking.

I don't know if I've tried that....

> > I'm still not sure you quite grasp what I am doing.  You assume the
> > map only contains PFN and COW'ed in core pages.  I'm mixing it all up.
> >  A given page in a file for AXFS is either backed by a uncompressed
> > XIP'able page or a compressed page that needs to be uncompressed to
> > RAM to be used (think SquashFS, CramFS, etc.)  So I would have raw
> > PFN's that are !pfn_valid() by nature, COW'ed pages that are from the
> > raw PFN, and in RAM pages that are backed by a compressed chunk on
> > Flash.  What more the raw PFN's are definately not in
> > remap_pfn_range() order.
>
> Your problem is harder than mine as it seems to me that a given VMA can
> have both normal and non-normal pages... I'm afraid there is no other
> way to deal with that than introducing a PTE flag for those, which means
> whacking something in all archs... unless you do provide something in
> the like of pfn_normal() to use here.

I still don't see why pfn_valid() won't work for me here.  These PFN's
from the MTD drivers are by defination !pfn_valid().  The PTE flag
route sounds nasty.

> > Okay.... I don't understand how to do that.  These PFN's are from an
> > MTD partition.  They don't have a page structs.  So I don't mind
> > having real page structs backing the Flash pages being used here.  It
> > would make it unnecessary to tweak the filemap_xip.c stuff, eventually
> > it will be useful for doing read/write XIP stuff.  However, I just
> > really don't get how to even start that.
>
> Having page structs introduces different kind of problems, I would
> recommend not going there unless you really can't do otherwise. It's
> been a terrible pain in the neck on Cell with SPEs until I introduced
> vm_insert_pfn() to get rid of them.

That was you?  Thanks.  It makes AXFS possible too.  Long term I may
want to do this anyway.

> > I have a page that is at a hardware level read-only.  What kind of
> > rules can that page live under?  More importantly these PFN's get
> > mapped in with a call to ioremap() in the mtd drivers.  So once I
> > figure out how to SPARSE_MEM, hotplug these pages in I've got to hack
> > the MTD to work with real pages.  Or something like that.  I'm not
> > ready to take that on yet, I just don't understand it all enough yet.
>
> I think vm_normal_page() could use something like pfn_normal() which
> isn't quite the same as pfn_valid()... or just use pfn_valid() but in
> that case, that would mean removing a bunch of the BUG_ON's indeed.

That's exactly what my original patch does.  Would my patch break
spufs?  Nick said my patch would break /dev/mem I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
