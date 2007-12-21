Date: Fri, 21 Dec 2007 01:56:33 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] xip: support non-struct page memory
Message-ID: <20071221005633.GD31040@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <476A8133.5050809@de.ibm.com> <6934efce0712200924o4e676484j95188a01b605bfdc@mail.gmail.com> <6934efce0712201612x57f77ab0le1d4d08d39e92c93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6934efce0712201612x57f77ab0le1d4d08d39e92c93@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 20, 2007 at 04:12:52PM -0800, Jared Hulbert wrote:
> On Dec 20, 2007 9:24 AM, Jared Hulbert <jaredeh@gmail.com> wrote:
> > > A poor man's solution could be, to store a pfn range of the flash chip
> > > and/or shared memory segment inside vm_area_struct, and in case of
> > > VM_MIXEDMAP we check if the pfn matches that range. If so: no
> > > refcounting. If not: regular refcounting. Is that an option?
> >
> > I'm not picturing what is responsible for configuring this stored pfn
> > range.  Does the fs do it on mount?  Does the MTD or your funky
> > direct_access block driver do it?
> >
> > What if you use VM_PFNMAP instead of VM_MIXEDMAP?
> 
> Though that might _work_ for ext2 it doesn't fix VM_MIXEDMAP.

Yeah, I guess they have the same problem as you: they want to be able
to support COW of non contiguous physical memory mappings as well (which
PFNMAP can't do).

 
> vm_normal_page() needs to know if a VM_MIXEDMAP pfn has a struct page
> or not.  Somebody had suggested we'd need a pfn_normal() or something.
>  Maybe it should be called pfn_has_page() instead.  For ARM
> pfn_has_page() == pfn_valid() near as I can tell.  What about on s390?
>  If pfn_valid() doesn't work, then can you check if the pfn is
> hotplugged in?  What would pfn_to_page() return if the associated
> struct page entry was not initialized?  Can we use what is returned to
> check if the pfn has no page?

As fas as I know, that's what pfn_valid() should tell you (ie. that you
have a struct page allocated). So I think this is kind of a quirk of the
s390 memory model and I'd rather not "legitimize" it by calling it pfn_normal
(because then what's pfn_valid for?).

But definitely I think we could support a hack for them one way or the other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
