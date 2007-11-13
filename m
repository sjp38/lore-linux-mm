From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
Date: Wed, 14 Nov 2007 04:26:51 +1100
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com> <200711132308.08739.nickpiggin@yahoo.com.au> <6934efce0711131729i4539d1cewf84974ea459f8e0f@mail.gmail.com>
In-Reply-To: <6934efce0711131729i4539d1cewf84974ea459f8e0f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711140426.51614.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 14 November 2007 12:29, Jared Hulbert wrote:
> > Well you aren't allowed to put a pfn into an is_cow_mapping() with
> > vm_insert_pfn().  That's my whole point.
>
> Why not?

Because it breaks VM_PFNMAP as you saw. *This* is why vm_normal_page()
does actually work correctly with vm_insert_pfn() and VM_PFNMAP today :)
Because they all work together to ensure that vm_insert_pfn's "breakage"
of the vm_pgoff you say isn't actually broken.


> Maybe I don't understand what this really is.  I want to be 
> able to COW from pfn only pages.  Wouldn't this restriction cramp my
> style?  Or is it that you can't tolerate pfn's in a VM_PFNMAP vma?

Yes, it's simply a question of implementation (and one which is required
for /dev/mem). So all we have to do really is to create a new type of
mapping for you.

And because /dev/mem is out of the picture, so is the requirement of
mapping pfn_valid() pages without refcounting them. The sketch I gave
in the first post *should* be on the right way

I can write the patch for you if you like, but if you'd like a shot at
it, that would be great!


> > Insert the pfn_valid() pages with vm_insert_page(), which I think
> > should take care of all those issues for you.
>
> Right.  So that's probably what I've been doing indirectly, with
> .nopage/.fault?

If it hasn't been going oops, yes it's probably what's happening.
And that would be a valid thing for you to do -- if you return the
page via fault(), it will get refcounted for you, no need for
vm_insert_page().


> > When I waffled on about doing a bit of setup work, I'd forgotten
> > about vm_insert_page(), which should already do just about everything
> > you need.
>
> So long as I just us vm_insert_page() and don't screw around with
> anything else, I'm good right?

Actually, I have a patch to unify ->fault and ->nopfn which might
make it quite neat for you. From your fault handler, you could
decide either to do the vm_insert_pfn(), or return the the struct
page to the generic code, and not worry about vm_insert_page at all.


> > These pages could live under the !pfn_valid() rules, which, in your
> > new VM_flag scheme, should not require underlying struct pages. So
> > hopefully don't need messing with sparsemem?
>
> But say I want to do more, like migrate them and such, won't I want to
> have some kind of page struct?

But most of the complexity of migrating pages goes away if you are
only dealing with pfns that you control, I suspect. Ie. you can
just unmap all pagetables mapping them, and prevent your fault handler
from giving out new references to the pfn until everything is switched
over (or, if that would be too slow, have the fault handler flip a
switch causing the migration to fail/retry).

For your struct page backed pages, if those guys ever are allowed onto
the LRU or into pagecache, or via get_user_pages(), then yes they should
go through the full migration path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
