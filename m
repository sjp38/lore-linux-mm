Received: by py-out-1112.google.com with SMTP id d32so5266430pye
        for <linux-mm@kvack.org>; Wed, 14 Nov 2007 10:52:19 -0800 (PST)
Message-ID: <6934efce0711141052y4df1f0e8h47e7f1decd7b4ee0@mail.gmail.com>
Date: Wed, 14 Nov 2007 10:52:18 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
In-Reply-To: <200711140426.51614.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
	 <200711132308.08739.nickpiggin@yahoo.com.au>
	 <6934efce0711131729i4539d1cewf84974ea459f8e0f@mail.gmail.com>
	 <200711140426.51614.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wednesday 14 November 2007 12:29, Jared Hulbert wrote:
> > > Well you aren't allowed to put a pfn into an is_cow_mapping() with
> > > vm_insert_pfn().  That's my whole point.
> >
> > Why not?
>
> Because it breaks VM_PFNMAP as you saw. *This* is why vm_normal_page()
> does actually work correctly with vm_insert_pfn() and VM_PFNMAP today :)
> Because they all work together to ensure that vm_insert_pfn's "breakage"
> of the vm_pgoff you say isn't actually broken.

oh okay I get it.

> Actually, I have a patch to unify ->fault and ->nopfn which might
> make it quite neat for you. From your fault handler, you could
> decide either to do the vm_insert_pfn(), or return the the struct
> page to the generic code, and not worry about vm_insert_page at all.

Where? mm tree?  I saw that in mm tree a while ago, of course I'm
pretty sure the pfn path was very broken.  Assuming it was fixed since
then should I go ahead and develop off that?

> But most of the complexity of migrating pages goes away if you are
> only dealing with pfns that you control, I suspect. Ie. you can
> just unmap all pagetables mapping them, and prevent your fault handler
> from giving out new references to the pfn until everything is switched
> over (or, if that would be too slow, have the fault handler flip a
> switch causing the migration to fail/retry).
>
> For your struct page backed pages, if those guys ever are allowed onto
> the LRU or into pagecache, or via get_user_pages(), then yes they should
> go through the full migration path.

Okay yeah, I suppose if I control the memory, there isn't too much to
be concerned about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
