Received: by wa-out-1112.google.com with SMTP id m33so22897wag
        for <linux-mm@kvack.org>; Tue, 13 Nov 2007 17:29:46 -0800 (PST)
Message-ID: <6934efce0711131729i4539d1cewf84974ea459f8e0f@mail.gmail.com>
Date: Tue, 13 Nov 2007 17:29:46 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
In-Reply-To: <200711132308.08739.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
	 <200711111109.34562.nickpiggin@yahoo.com.au>
	 <6934efce0711121403h2623958cq49490077c586924f@mail.gmail.com>
	 <200711132308.08739.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Well you aren't allowed to put a pfn into an is_cow_mapping() with
> vm_insert_pfn().  That's my whole point.

Why not?  Maybe I don't understand what this really is.  I want to be
able to COW from pfn only pages.  Wouldn't this restriction cramp my
style?  Or is it that you can't tolerate pfn's in a VM_PFNMAP vma?

> Oh sure, which is why I say you could do exactly that, but with
> *another* VM_flag. Because you'll break subtle things if you change
> VM_PFNMAP.

Okay so I'll code that up and see if I get what you are saying here.

> /dev/mem gives a window into all memory, and you don't actually want
> to take a reference or elevate the mapcount on the actual underlying
> pages.
>
> There are also other cases that we may want to use VM_PFNMAP for,
> which aren't technically going to break if you refcount them, but it
> is suboptimal. Eg. vdso pages -- it might be useful to avoid the
> cacheline bouncing of refcounting these.

Okay I see.

> Yeah sure OK. The only thing that really matters is pfn_valid() ==
> page with a valid struct page, which should be refcounted.

That seems clear to me.

> > > BUG_ON((vma->vm_flags & VM_JAREDMAP) && pfn_valid(pfn));
> >
> > Okay, maybe.  I got to look at this more carefully.
>
> OK, well this would prevent you putting improperly refcounted
> pfn_valid() pages into the pagetables with vm_insert_pfn().

Of course now I get it.

> Insert the pfn_valid() pages with vm_insert_page(), which I think
> should take care of all those issues for you.

Right.  So that's probably what I've been doing indirectly, with .nopage/.fault?

> No sorry, I didn't word that very well: so long as the pages you
> have which _are_ pfn_valid() do have valid and properly refcounted
> struct pages, then inserting them as normal pages into the VM should
> be fine.
>
> By properly refcounted, I mean that page->_count isn't 0, and that
> you are prepared for the page to be freed when the user mappings go
> away *if* you have dropped your own reference. Just common sense
> stuff really.
>
> When I waffled on about doing a bit of setup work, I'd forgotten
> about vm_insert_page(), which should already do just about everything
> you need.

So long as I just us vm_insert_page() and don't screw around with
anything else, I'm good right?

> These pages could live under the !pfn_valid() rules, which, in your
> new VM_flag scheme, should not require underlying struct pages. So
> hopefully don't need messing with sparsemem?

But say I want to do more, like migrate them and such, won't I want to
have some kind of page struct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
