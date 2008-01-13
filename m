Date: Sun, 13 Jan 2008 03:44:10 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
Message-ID: <20080113024410.GA22285@wotan.suse.de>
References: <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com> <47872CA7.40802@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47872CA7.40802@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 11, 2008 at 09:45:27AM +0100, Carsten Otte wrote:
> Jared Hulbert wrote:
> >>I think you're looking for
> >>pfn_has_struct_page_entry_for_it(), and that's different from the
> >>original meaning described above.
> >
> >Yes.  That's what I'm looking for.
> >
> >Carsten,
> >
> >I think I get the problem now.  You've been saying over and over, I
> >just didn't hear it.  We are not using the same assumptions for what
> >VM_MIXEDMAP means.
> >
> >Look's like today most architectures just use pfn_valid() to see if a
> >pfn is in a valid RAM segment.  The assumption used in
> >vm_normal_page() is that valid_RAM == has_page_struct.  That's fine by
> >me for VM_MIXEDMAP because I'm only assuming 2 states a page can be
> >in: (1) page struct RAM (2) pfn only Flash memory ioremap()'ed in.
> >You are wanting to add a third: (3) valid RAM, pfn only mapping with
> >the ability to add a page struct when needed.
> >
> >Is this right?
> About right. There are a few differences between "valid ram" and our 
> DCSS segments, but yes. Our segments are not present at system 
> startup, and can be "loaded" afterwards by hypercall. Thus, they're 
> not detected and initialized as regular memory.
> We have the option to add struct page entries for them. In case of 
> using the segment for xip, we don't want struct page entries and 
> rather prefer VM_MIXEDMAP, but with regular memory (with struct page) 
> being used after cow.

You know that pfn_valid() can be changed at runtime depending on what
your intentions are for that page. It can remain false if you don't
want struct pages for it, then you can switch a flag...


> >>Jared, did you try this on arm?
> >
> >No.  I'm not sure where we stand.  Shall I bother or do I wait for the
> >next patch?
> I guess we should wait for Nick's patch. He has already decided not to 
> go down this path.

I've just been looking at putting everything together (including the
pte_special patch). I still hit one problem with your required modification
to the filemap_xip patch.

You need to unconditionally do a vm_insert_pfn in xip_file_fault, and rely
on the pte bit to tell the rest of the VM that the page has not been
refcounted. For architectures without such a bit, this breaks VM_MIXEDMAP,
because it relies on testing pfn_valid() rather than a pte bit here.
We can go 2 ways here: either s390 can make pfn_valid() work like we'd
like; or we can have a vm_insert_mixedmap_pfn(), which has
#ifdef __HAVE_ARCH_PTE_SPECIAL
in order to do the right thing (ie. those architectures which do have pte
special can just do vm_insert_pfn, and those that don't will either do a
vm_insert_pfn or vm_insert_page depending on the result of pfn_valid).

The latter I guess is more efficient for those that do implement pte_special,
however if anything I would rather investigate that as an incremental patch
after the basics are working. It would also break the dependency of the
xip stuff on the pte_special patch, and basically make everything much
more likely to get merged IMO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
