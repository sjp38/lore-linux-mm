Date: Mon, 2 Mar 1998 14:04:01 -0500 (U)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: reverse pte lookups and anonymous private mappings; avl trees?
Message-ID: <Pine.LNX.3.95.980302131917.32327E-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hello,

Okay, I've been ripping my hair out this weekend trying to get my reverse
pte lookups working using the inode/vma walking scheme, and I'm about to
go mad because of it.  Here are the alternatives I've come up with. 
Please give me some comments as to which one people think is the best from
a design standpoint (hence the cc to Linus) and performance wise, too. 
Note that I'm ignoring the problem of overlapping inode/offset pairs given
the new swap cache code.  (this is probably riddled with typos/thinkos)

	a)  add a struct vm_area_struct pointer and vm_offset to struct
page.  To each vm_area_struct, add a pair of pointers so that there's a
list of vm_area_structs which are private, but can be sharing pages.
Hence we end up with something like:

	page--> vma -> vm_next_private -> ... (cicular list)
	         |          |
	       vm_mm      vm_mm
	         |         ...
	        ... (use page->vm_offset - vma->vm_offset + vma->vm_start)
	         |
	        pte

This, I think, is the cleanest approach.  It makes life easy for finding a
shared anonymous pages, but has the downside of adding 8 bytes onto the
page map (16 on the 64 bit machines), same to the vm_area_struct.  Perhaps
the vma's vm_next_share/vm_pprev_share pointers could be reused (although
the seperate private mapping share list would make searching for
non-anonymous, but private mappings faster).

	b) per-vma inodes.  This scheme is a headache.  It would involve
linking the inodes in order to maintain a chain of the anonymous pages.
At fork() time, each private anonymous vma would need to have two new
inodes allocated (one for each task), which would point to the old inode.
Ptes are found using the inode, offset pair already in struct page, plus
walking the inode tree.  Has the advantage that we can use the inode,
offset pair already in struct page, no need to grow struct vm_area_struct;
disadvantage: hairy, conflicts with the new swap cache code - requires
the old swap_entry to return to struct page.

	c) per-mm inodes, shared on fork.  Again, this one is a bit
painful, although less so than b.  This one requires that we allow
multiple pages in the page cache exist with the same offset (ugly).  Each
anonymous page gets the mm_struct's inode attached to it, with the virtual
address within the process' memory space being the offset.  The ptes are
found in the same manner as for normal shared pages (inode->i_mmap->vmas).
Aliased page-cache entries are created on COW and mremap().

My thoughts are that the only real options are (a) and (c).  (a) seems to
be the cleanest conceptually, while (c) has very little overhead, but,
again, conflicts with the new swap cache...

On another note, is there any particular reason why the AVL tree for vma's
was removed in 2.1?  Because of recent changes to use the struct file * in
the vma, vma's aren't going to be coalesced as much, and some of the
private/anon changes I'm suggesting could contribute to that even further. 
I seem to remember someone suggesting the use of red-black trees as an
alternative, and methinks a friend has some code we can borrow. Just as a
note, with the introduction of PAM, quite a few daemons have ~30 vma's. 
If each time we want to steal a page we have to do a 30 element list walk,
the complexity of the swapper remains a bit high in my opinion (as kswapd
is now).

		-ben
