From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
Date: Tue, 13 Nov 2007 23:08:08 +1100
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com> <200711111109.34562.nickpiggin@yahoo.com.au> <6934efce0711121403h2623958cq49490077c586924f@mail.gmail.com>
In-Reply-To: <6934efce0711121403h2623958cq49490077c586924f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711132308.08739.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 13 November 2007 09:03, Jared Hulbert wrote:
> On 11/10/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > On Saturday 10 November 2007 06:15, Jared Hulbert wrote:
> > > Per conversations regarding XIP from the vm/fs mini-summit a couple
> > > months back I've got a patch to air out.
> > >
> > > The basic problem is that the assumptions about PFN mappings stemming
> > > from the rules of remap_pfn_range() aren't always valid.  For example:
> > > what stops one from using vm_insert_pfn() to map PFN's into a vma in
> > > an arbitrary order?  Nothing.  Yet those PFN's cause problems in two
> > > ways.
> > >
> > > First, vm_normal_page() won't return NULL.
> >
> > They will, because it isn't allowed to be a COW mapping, and hence it
> > fails the vm_normal_page() test.
>
> No.  It doesn't work.  If I have a mapping that doesn't abide by the
> pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
> rule, which is easy to do with vm_insert_pfn(), it won't get to NULL at
> if (pfn == vma->vm_pgoff + off)
> and because we don't expect to get this far with a PFN sometimes I do
> have a is_cow_mapping() that is just a PFN.  Which means I fail the
> second test and get to the print_bad_pte().  At least that's what I
> have captured in the past.  Is that bad?

Well you aren't allowed to put a pfn into an is_cow_mapping() with
vm_insert_pfn(). That's my whole point. Everything should work and
be consistent today. (The real issue is that "work" doesn't work for
you).


> I'm still not sure you quite grasp what I am doing.  You assume the
> map only contains PFN and COW'ed in core pages.  I'm mixing it all up.
>  A given page in a file for AXFS is either backed by a uncompressed
> XIP'able page or a compressed page that needs to be uncompressed to
> RAM to be used (think SquashFS, CramFS, etc.)  So I would have raw
> PFN's that are !pfn_valid() by nature, COW'ed pages that are from the
> raw PFN, and in RAM pages that are backed by a compressed chunk on
> Flash.  What more the raw PFN's are definately not in
> remap_pfn_range() order.

OK, that's fine. So long as your underlying pages (that are pfn_valid())
are able to cope with the refcounting, nothing changes.


> > > My answer to this is to
> > > simply check if pfn_valid()  if it isn't then we've got a proper PFN
> > > that can only be a PFN.  If you do have a valid PFN then you are (A) a
> > > 'cow'ed' PFN that is now a real page or (B) you are a real page
> > > pretending to be a PFN only.  The thing that makes me nervous is that
> > > my hack doesn't let that page pretend to be a PFN.  I can't figure out
> > > why a page would need/want to pretend to be a PFN so I don't see
> > > anything wrong with this, but maybe somebody does.
> > >
> > > Second, there are a few random BUG_ON() that don't seem to serve any
> > > purpose other than to punish the PFN's that don't abide by
> > > remap_pfn_range() rules.  I just get rid of them.  The problem is I
> > > don't really understand why they are there in the first place so for
> > > all I know I'm horribly breaking spufs or something.
> >
> > They are perhaps slightly undercommented, but they are definitely
> > required. And it is to ensure that everything works correctly.
>
> Help me understand this.  It seems to work fine if we remove these.

Oh sure, which is why I say you could do exactly that, but with
*another* VM_flag. Because you'll break subtle things if you change
VM_PFNMAP.


> > > Okay so I haven't tried this out on 2.6.24-rc1 yet, but the same basic
> > > idea worked on 2.6.23 and older.  I just wanted to get feedback on
> > > this approach.  I don't know the vm all that well so I want to make
> > > sure I'm not doing something really stupid that breaks a bunch of code
> > > paths I don't use.
> >
> > You actually can't just use pfn_valid, because there are cases where
> > you actually *cannot* touch the underlying struct page's mapcount,
> > flags, etc. I think the only real user is /dev/mem.
>
> Okay, I don't get why, but that's okay.

/dev/mem gives a window into all memory, and you don't actually want
to take a reference or elevate the mapcount on the actual underlying
pages.

There are also other cases that we may want to use VM_PFNMAP for,
which aren't technically going to break if you refcount them, but it
is suboptimal. Eg. vdso pages -- it might be useful to avoid the
cacheline bouncing of refcounting these.


> > So my suggestion to you, if you want to support COW pfnmaps, is to
> > create a new VM_FLAG type (VM_INVALIDPFNMAP? ;)), which has the
> > pfn_valid() == COW semantics that you want.
>
> I __don't__ want pfn_valid() == COW.  I want pfn_valid() ==
> is_real_RAM_page().  That real RAM page is not necessarily COW'ed yet.
>   Remember I want a mapping that contains some Flash back pages and
> some RAM backed pages.

Yeah sure OK. The only thing that really matters is pfn_valid() ==
page with a valid struct page, which should be refcounted.


> > BUG_ON((vma->vm_flags & VM_JAREDMAP) && pfn_valid(pfn));
>
> Okay, maybe.  I got to look at this more carefully.

OK, well this would prevent you putting improperly refcounted
pfn_valid() pages into the pagetables with vm_insert_pfn().

Insert the pfn_valid() pages with vm_insert_page(), which I think
should take care of all those issues for you.


> > May not work out so easy, but AFAIKS it will work. See how much milage
> > that gets you.
> >
> > The other thing you might like is to allow pfn_valid(pfn) pfns to go
> > into these mappings, and you know it is fine to twiddle with the
> > struct page (eg. if you want to switch between different pfns, which
> > I know the spufs guys want to). That's not too hard: just take out some
> > of the assertions. You might have to do a little bit of setup work too,
> > like increment the page count and mapcount etc. but just so long as you
> > put that in a mm/memory.c helper rather than your own code, it should
> > be clean enough.
>
> Okay.... I don't understand how to do that.  These PFN's are from an
> MTD partition.  They don't have a page structs.  So I don't mind
> having real page structs backing the Flash pages being used here.  It
> would make it unnecessary to tweak the filemap_xip.c stuff, eventually
> it will be useful for doing read/write XIP stuff.  However, I just
> really don't get how to even start that.

No sorry, I didn't word that very well: so long as the pages you
have which _are_ pfn_valid() do have valid and properly refcounted
struct pages, then inserting them as normal pages into the VM should
be fine.

By properly refcounted, I mean that page->_count isn't 0, and that
you are prepared for the page to be freed when the user mappings go
away *if* you have dropped your own reference. Just common sense
stuff really.

When I waffled on about doing a bit of setup work, I'd forgotten
about vm_insert_page(), which should already do just about everything
you need.


> I have a page that is at a hardware level read-only.  What kind of
> rules can that page live under?  More importantly these PFN's get
> mapped in with a call to ioremap() in the mtd drivers.  So once I
> figure out how to SPARSE_MEM, hotplug these pages in I've got to hack
> the MTD to work with real pages.  Or something like that.  I'm not
> ready to take that on yet, I just don't understand it all enough yet.

These pages could live under the !pfn_valid() rules, which, in your
new VM_flag scheme, should not require underlying struct pages. So
hopefully don't need messing with sparsemem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
