Date: Fri, 28 Apr 2000 00:32:37 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
Message-ID: <20000428003237.B3983@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net> <20000426140031.L3792@redhat.com> <200004261311.GAA13838@pizda.ninka.net> <20000426162353.O3792@redhat.com> <200004261525.IAA13973@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200004261525.IAA13973@pizda.ninka.net>; from David S. Miller on Wed, Apr 26, 2000 at 08:25:59AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: sct@redhat.com, sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
>    On fork(), I assume you just leave multiple vmas attached to the
>    same address space?  With things like mprotect, you'll still have a
>    list of vmas to search for in this design, I'd think.
> 
> At fork, the code which copies the address space just calls
> "anon_dup()" for non-NULL vma->vm_anon, to clone the anon_area in the
> child's VMA.  anon_dup adds a new VMA to the mapping->i_mmap list and
> bumps the anon_area reference count.

Fwiw, I don't think you need separate anon-layer structures at all.
struct address_space is enough.  However, you do need a (small) tree of
those.

Here's a conceptual design I came up with today.  It uses only
address_space and vmas:

  - Each vma points to an address_space, as does each page.

  - There's an address_space for each file/shm and each new anon mapping.

  - Each address_space may have a *parent* address_space.

  - Each address_space has a list of all it's child spaces and all the
    vmas which use it directly.

  - For private mappings only, the first copy-on-write for a given vma
    creates a *new* address_space.  All privately modified pages go in
    the new address space, and of course these spaces are swappable.
    The new space's parent is the old space.

  - When vmas are duplicated for fork(), the new vma points to the same
    address_space as the old one.  If it's a private mapping, both vmas
    are flagged so that the first c-o-w will generate new address_spaces.

  - To get from vma to a page (e.g. to map the page), look up the page
    in the vma's address_space, then in its parent if necessary etc. up
    to the root of that tree.

At first this looks like it might slow down page lookup at fault time,
but it's not that bad.  Now that you can get from struct page to all its
ptes, you don't in general have to unmap ptes for swapping to work.

This means you often know which address_space must contain the page,
or at least which one to check first.

A few optimisations keep the tree in shape, but they're not necessary:

  - When you've modified all the pages in a private mapping, the parent
    address_space is no longer required by this mapping.  So cut the
    tree there.  That will release the parent if nobody else refers to
    it.

  - If a child is the only reference to its parent, they can be merged.

As with David's code, the big advantage is you can now easily find all
the page table entries for a given page.  So swapping gets simpler.
Especially, the dynamics of swapping get simpler and so have fewer
instabilities.

Although it's possible to have large address_space trees, this is
unlikely.  I would expect trees only 2 or 3 deep for normal cases.

There's no problem with working out the offset for anonymous mappings.
It's simply vm_pgoff == index, however the mapping was mremapped etc.

In some sense, I think this tree structure is actually the minimum you
need to traverse to find all the vmas that may currently map the page,
if you do not wish to maintain structures describing smaller regions.

The advantage over David's anon layer is that there isn't one :-)
It's also pretty close to what we have already.

Would this scheme work?  Comments, please.

thanks,
-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
