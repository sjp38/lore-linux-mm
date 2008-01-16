Date: Wed, 16 Jan 2008 05:04:24 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/4] include: add callbacks to toggle reference counting for VM_MIXEDMAP pages
Message-ID: <20080116040424.GA29681@wotan.suse.de>
References: <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <1199891032.28689.9.camel@cotte.boeblingen.de.ibm.com> <1199891645.28689.22.camel@cotte.boeblingen.de.ibm.com> <6934efce0801091017t7f9041abs62904de3722cadc@mail.gmail.com> <4785D064.1040501@de.ibm.com> <6934efce0801101201t72e9b7c4ra88d6fda0f08b1b2@mail.gmail.com> <47872CA7.40802@de.ibm.com> <20080113024410.GA22285@wotan.suse.de> <478B4942.4030003@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <478B4942.4030003@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 14, 2008 at 12:36:34PM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >You know that pfn_valid() can be changed at runtime depending on what
> >your intentions are for that page. It can remain false if you don't
> >want struct pages for it, then you can switch a flag...
> We would'nt need to switch at runtime: it is sufficient to make that 
> decision when the segment gets attched.
> 
> >I've just been looking at putting everything together (including the
> >pte_special patch). 
> Yippieh. I am going to try it out next :-).

Just had a few things come up so I've been unable to finish this off
earlier, but I'll have a look again tonight if I manage to make some
progress on one more bug I'm working on.


> >I still hit one problem with your required modification
> >to the filemap_xip patch.
> >
> >You need to unconditionally do a vm_insert_pfn in xip_file_fault, and rely
> >on the pte bit to tell the rest of the VM that the page has not been
> >refcounted. For architectures without such a bit, this breaks VM_MIXEDMAP,
> >because it relies on testing pfn_valid() rather than a pte bit here.
> >We can go 2 ways here: either s390 can make pfn_valid() work like we'd
> >like; or we can have a vm_insert_mixedmap_pfn(), which has
> >#ifdef __HAVE_ARCH_PTE_SPECIAL
> >in order to do the right thing (ie. those architectures which do have pte
> >special can just do vm_insert_pfn, and those that don't will either do a
> >vm_insert_pfn or vm_insert_page depending on the result of pfn_valid).
> Of those two choices, I'd cleary favor vm_insert_mixedmap_pfn(). But 
> we can #ifdef __HAVE_ARCH_PTE_SPECIAL in vm_insert_pfn() too, can't 
> we? We can safely set the bit for both VM_MIXEDMAP and VM_PFNMAP. Did 
> I miss something?

I guess we could, but we have some good debug checking in vm_insert_pfn,
and I'd like to make it clear that using it will not result in the
struct page being touched.

vm_insert_mixedmap_pfn (maybe we could rename it to vm_insert_mixed)
would be quite a specialised thing which is easier to audit if it is
on its own IMO.

But you're right in that there is nothing technical preventing it.

Anyway, I'll post some patches soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
