Date: Mon, 2 Mar 1998 23:03:05 GMT
Message-Id: <199803022303.XAA03640@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <Pine.LNX.3.95.980302131917.32327E-100000@as200.spellcast.com>
References: <Pine.LNX.3.95.980302131917.32327E-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi Ben,

On Mon, 2 Mar 1998 14:04:01 -0500 (U), "Benjamin C.R. LaHaise"
<blah@kvack.org> said:

> Okay, I've been ripping my hair out this weekend trying to get my
> reverse pte lookups working using the inode/vma walking scheme, and
> I'm about to go mad because of it.

I'm not in the slightest bit surprised.  I've been giving it a lot of
thought, and it just gets uglier and uglier. :)

The problem --- of course --- is that the inheritance relationship of
private pages is a tree.  If we have a process which forks off several
children then in any given privately mapped vma, some pages can be
shared between all children.  Other children may have their own
private copies of other pages.  If _those_ children fork, we get a
subtree amongst which certain pages are shared only amongst that
subtree; other pages in the leaf processes are not shared anywhere at
all; and still other pages are shared by the whole tree.

Ouch.  Basically, what it comes down to is that after forking, the vma
is not really a good unit by which to account for individual pages.  

> Here are the alternatives I've come up with.  Please give me some
> comments as to which one people think is the best from a design
> standpoint (hence the cc to Linus) and performance wise, too.  Note
> that I'm ignoring the problem of overlapping inode/offset pairs
> given the new swap cache code.  (this is probably riddled with
> typos/thinkos)

> 	a)  add a struct vm_area_struct pointer and vm_offset to struct
> page.  To each vm_area_struct, add a pair of pointers so that there's a
> list of vm_area_structs which are private, but can be sharing pages.

What about privately mapped images, such as shared libraries?  Will
those vmas will end up with one inode for the backing file and a
separate inode for the private pages?  Such private vmas still have
anonymous pages in them.

> Hence we end up with something like:

page--> vma -> vm_next_private -> ... (cicular list)
> 	         |          |
> 	       vm_mm      vm_mm
> 	         |         ...
> 	        ... (use page->vm_offset - vma->vm_offset + vma->vm_start)
> 	         |
> 	        pte

> This, I think, is the cleanest approach.  

What happens to these vmas and inodes on fork()?  On mremap()?  

> It makes life easy for finding a shared anonymous pages, 

Shared anonymous pages are a very special case, and they are much much
much easier than the general case.  With shared anonymous vmas, _all_
pages in the entire vma are guaranteed to be shared; where is no
mixing of shared and private pages as there is with a private map
(anonymous or not).  My original plan with the swap cache was to
introduce a basis inode for vmas only for this special case; all other
cases are dealt with adequately by the swap cache scheme (not counting
the performance issues of being able to swap out arbitrary pages).

> 	b) per-vma inodes.  This scheme is a headache.  It would involve
> linking the inodes in order to maintain a chain of the anonymous
> pages.

> At fork() time, each private anonymous vma would need to have two new
> inodes allocated (one for each task), which would point to the old inode.
> Ptes are found using the inode, offset pair already in struct page, plus
> walking the inode tree.  Has the advantage that we can use the inode,
> offset pair already in struct page, no need to grow struct vm_area_struct;
> disadvantage: hairy, conflicts with the new swap cache code - requires
> the old swap_entry to return to struct page.

This is getting much closer to the FreeBSD scheme, which has similar
stacks of inodes for each anonymous vma.  It is a bit cumbersome, but
ought to work pretty well.

> 	c) per-mm inodes, shared on fork.  Again, this one is a bit
> painful, although less so than b.  This one requires that we allow
> multiple pages in the page cache exist with the same offset (ugly).

Very.  :) 

> Each anonymous page gets the mm_struct's inode attached to it, with
> the virtual address within the process' memory space being the
> offset.  The ptes are found in the same manner as for normal shared
> pages (inode->i_mmap->vmas).  Aliased page-cache entries are created
> on COW and mremap().

> My thoughts are that the only real options are (a) and (c).  (a) seems to
> be the cleanest conceptually, while (c) has very little overhead, but,
> again, conflicts with the new swap cache...

Yes.  The conclusion I came to a while ago is that (c) is the only way
to go if we do this.

This leaves us with one main question --- how do we select pages for
swapout?  We either do it via a scan of the page tables, as currently
happens in vmscan, or with a scan of physical pages as shrink_mmap()
does.  The changes described here are only useful if we take the
second choice.

My personal feeling at the moment is that the second option is going
to give us lower overhead swapping and a much fairer balance between
private data and the page cache.  However, there are are other
arguments; in particular, it is much easier to do RSS quotas and
guarantees if we are swapping on a per page-table basis.

If we do make this change, then some of the new swap cache code
becomes redundant.  The next question is, how do we cache swap pages
in this new scenario?  We still need a swap cache mechanism, both to
support proper readahead for swap and to allow us to defer the freeing
of swapped out pages until the last possible moment.  Now, if we know
we can atomically remove a page from all ptes at once, then it is
probably sufficient to unhook the struct page from the (inode-vma,
offset) hash and rehash it as (swapper-inode, entry).  It gets harder
if we want per-process control of RSS, since in that case we want to
use the same physical page for both vma and swap, and we will really
need a quick lookup from both indexes.

I'm not at all averse to growing the struct page if we absolutely have
to, however.  If we can effectively keep several hundred more pages in
memory as a result of not having to throw data away just to cope with
the worst-case interrupt memory requirements, then we will still see a
great overall performance improvement.

Cheers,
 Stephen.
