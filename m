Date: Tue, 3 Mar 1998 01:29:41 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <199803022303.XAA03640@dax.dcs.ed.ac.uk>
Message-ID: <Pine.LNX.3.95.980302235716.8007A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hello Stephen!

On Mon, 2 Mar 1998, Stephen C. Tweedie wrote:

> Hi Ben,
> 
> On Mon, 2 Mar 1998 14:04:01 -0500 (U), "Benjamin C.R. LaHaise"
> <blah@kvack.org> said:
> 
> > Okay, I've been ripping my hair out this weekend trying to get my
> > reverse pte lookups working using the inode/vma walking scheme, and
> > I'm about to go mad because of it.

Monday's brought some enlightenment now.

> I'm not in the slightest bit surprised.  I've been giving it a lot of
> thought, and it just gets uglier and uglier. :)

The more I've thought about it this evening, the more I'm liking the type
(a) approach (aka the vma->vm_private list)...  It was only as I wrote the
original message that I came up with the idea (as inodes we all that came
to mind over the weekend), so it was a bit fuzzy at the time of writing. 

> The problem --- of course --- is that the inheritance relationship of
> private pages is a tree.  If we have a process which forks off several
> children then in any given privately mapped vma, some pages can be
> shared between all children.  Other children may have their own
> private copies of other pages.  If _those_ children fork, we get a
> subtree amongst which certain pages are shared only amongst that
> subtree; other pages in the leaf processes are not shared anywhere at
> all; and still other pages are shared by the whole tree.

	     vm_next/prev_private (aka vm_private list)
	vma -> vma -> vma -> vma
	 |      |      |      |
	...    ...    ...    ...
	 |      |      |      |
	pte    pte    pte    pte
	 |   /          \    /
	page             page
	 |->vma == vma1   |->vma == vma3

(number the vma's from 1->4, left to right)  the values for page->vma are
arbitrary, and really only need to be one of the vmas on the (doubly link)
vm_private list.  Somewhere below in this message is the code for finding
a single pte, trivially extended for all cases as the early January
patch/idea suggested.  It basically creates the same thing that exists for
inode backed pages - a list to traverse that contains all *possible*
mappings to the page.  As with the i_mmap list, not all mappings point to
the same page, but they can be found.  One thing this would allow us to do
is to pre-fill all pointers on swapin.  Not nescessarily a good idea, but
possible. - swap_map could be replaced by a bitmap if we pre-filled
(makes sense as the sharing of swapped pages is rare).

> Ouch.  Basically, what it comes down to is that after forking, the vma
> is not really a good unit by which to account for individual pages.  

This is where the type (a) approach really shines.  At fork time, each
non-shared vma created gets inserted into the vm_next_private list.  The
more its swirled around my mind, the nastier doing a get_empty_inode for
each vma on fork() makes me kringe -- we can't slow down fork! ;-) 

...snip...
> What about privately mapped images, such as shared libraries?  Will
> those vmas will end up with one inode for the backing file and a
> separate inode for the private pages?  Such private vmas still have
> anonymous pages in them.

The type 'a' approach can basically be considered to be exactly the same
as what is done now: if the page is still being shared, it's in the page
cache for the inode, hence we can find the pte by means of the i_mmap
list.  If it's anonymous, then we can find each and every pte via the
vm_private list (the vma of the page will get set upon its creation - COW 
or swapin) by walking vm_(prev|next)_private in either direction, skipping
over the ptes which do *not* point to the page -- exactly the same as we'd 
do for shared mappings.

> > Hence we end up with something like:
> 
> page--> vma -> vm_next_private -> ... (cicular list)
> > 	         |          |
> > 	       vm_mm      vm_mm
> > 	         |         ...
> > 	        ... (use page->vm_offset - vma->vm_offset + vma->vm_start)
> > 	         |
> > 	        pte
> 
> > This, I think, is the cleanest approach.  
> 
> What happens to these vmas and inodes on fork()?  On mremap()?  

On mremap(), nothing really happens -- unless the area is shrunk, in which
case any vma that disappears is removed from it's vma_private list. Note
that it will need to pass the vma being zapped down to zap_page_range, as
if that is the vma to which the page belongs, the page->vma pointer will
need to be set to one of the other members of the private list (unless the
page isn't used by anyone else, in which case the page can be thrown onto
the discard list if it's page cached and still used someone else, or free
list if its not used by anyone).  This applies to unmapping as well.

This all translates into making the merging of vm_area_structs much rarer.
If we want to keep being able to merge vm_area_structs during the
single-mapping (normal) case, then life would get hairy (basically it
could only work when the vma is the sole member of its vm_private list,
and any pages present would require their vma->vm_offset be adjusted).

One of the things that I didn't describe earlier is that page->vm_offset
is relative to vma->vm_offset (same as page->offset, that is pte vaddr =
page->vm_offset - vma->vm_offset + vma->vm_start).  If the vma is shrunk,
vma->vm_offset is increased as it would be for shared pages.

In order to maintain the mergability (wonderful word ;) of the 'usual
case' (eg sbrk, or extending the size of a mapping), the vma->vm_offset
value will need to be set to the virtual address of the mapping.  That way
everything lines up nicely.

> > It makes life easy for finding a shared anonymous pages, 
> 
> Shared anonymous pages are a very special case, and they are much much
> much easier than the general case.  With shared anonymous vmas, _all_
> pages in the entire vma are guaranteed to be shared; where is no
> mixing of shared and private pages as there is with a private map
> (anonymous or not).  My original plan with the swap cache was to
> introduce a basis inode for vmas only for this special case; all other
> cases are dealt with adequately by the swap cache scheme (not counting
> the performance issues of being able to swap out arbitrary pages).

Thankfully this scheme coexists with the new swap cache.  More important
that shared anonymous pages, is the case of a single not shared anonymous
page:
	unsigned long addr = page->vm_offset - page->vma->vm_offset + page->vma->vm_start;
	pte_t *pte_p = pte_offset(pmd_offset(pgd_offset(page->vma->vm_mm), addr), addr);


> > 	b) per-vma inodes.  This scheme is a headache.  It would involve
> > linking the inodes in order to maintain a chain of the anonymous
> > pages.
...
> This is getting much closer to the FreeBSD scheme, which has similar
> stacks of inodes for each anonymous vma.  It is a bit cumbersome, but
> ought to work pretty well.

Cumbersome indeed - I don't want to have to throw out your new swap cache
for this one, which looks like a *huge* looser on fork(); typical
processes on my machine have 10-12 (normal) or 30-32 (using the PAM
libraries, or X) vmas apiece.  Almost all of them are private writable
mappings, and get_empty_inode is not the fastest code in the kernel.  Add
to that the fact that people running 512+ processes now need an additional
5000->15000 inodes and things begin to look pretty bad.

> > 	c) per-mm inodes, shared on fork.  Again, this one is a bit
> > painful, although less so than b.  This one requires that we allow
> > multiple pages in the page cache exist with the same offset (ugly).
> 
> Very.  :) 
> 
> > Each anonymous page gets the mm_struct's inode attached to it, with
> > the virtual address within the process' memory space being the
> > offset.  The ptes are found in the same manner as for normal shared
> > pages (inode->i_mmap->vmas).  Aliased page-cache entries are created
> > on COW and mremap().
> 
> > My thoughts are that the only real options are (a) and (c).  (a) seems to
> > be the cleanest conceptually, while (c) has very little overhead, but,
> > again, conflicts with the new swap cache...
> 
> Yes.  The conclusion I came to a while ago is that (c) is the only way
> to go if we do this.

I hope I've cleared up my explanation of (a) enough that it is beginning
to look viable.  It seems to be what Linus had in mind when the
discussions came up a while ago (he suggested adding a pointer to the
vma in struct page - the offset and vm_private list follow naturally).

> This leaves us with one main question --- how do we select pages for
> swapout?  We either do it via a scan of the page tables, as currently
> happens in vmscan, or with a scan of physical pages as shrink_mmap()
> does.  The changes described here are only useful if we take the
> second choice.

> My personal feeling at the moment is that the second option is going
> to give us lower overhead swapping and a much fairer balance between
> private data and the page cache.  However, there are are other
> arguments; in particular, it is much easier to do RSS quotas and
> guarantees if we are swapping on a per page-table basis.

Ummm, not really.  I think that because of the mm scheme chosen to support
clone, these quotas are really only applicable on a per-mm basis.
Sticking a quota on a process, only to have it exceeded by it's clone()
twin doesn't make terribly much sense to me.  In the pte_list patch,
rather than kill a single task when a fault occurred during swapin/out, I
walked the task table and killed all which shared the mm.

...snipped concerns over (c) - methinks to avoid (c) until (a) is
undoable...
> I'm not at all averse to growing the struct page if we absolutely have
> to, however.  If we can effectively keep several hundred more pages in
> memory as a result of not having to throw data away just to cope with
> the worst-case interrupt memory requirements, then we will still see a
> great overall performance improvement.

That's what I thought.  Also, the people who are starting to run machines
with huge amounts of memory (512megs+) will benefit greatly.  What do you
think about having all the page stealing done through get_free_page?  I'd
like to see get_free_pages (non-atomic) block until enough pages have been
reclaimed to the dumpable list; that way we can avoid the system ever
deadlocking on swap.  But the network stack would need the patches Pavel
wrote to drop packets when low on memory -- don't drop packets destined
for the swapping socket, but all others are game.  Wow, that would make
Linux much more stable indeed!

Oh, below are my current changes to mm.h to give you a hint of where I'm
going.  Note that despite the cvs directory name, it is against 2.1.89-5.
I'm actually proposing the use of 6 possible queues for pages to be on,
mostly so that we can keep track of and grab what we want when we want it;
this could be pruned if it matters.

		-ben

Index: ../include/linux/mm.h
===================================================================
RCS file: /home/dot1/blah/cvs/linux-2.1.86-mm/include/linux/mm.h,v
retrieving revision 1.1.1.3
diff -u -u -r1.1.1.3 mm.h
--- mm.h	1998/03/03 03:23:20	1.1.1.3
+++ mm.h	1998/03/03 04:47:59
@@ -46,6 +46,11 @@
 	struct vm_area_struct *vm_next_share;
 	struct vm_area_struct **vm_pprev_share;
 
+	/* Mappings that are private, yet shared.  Derived from fork()ing.
+	 */
+	struct vm_area_struct *vm_next_private;
+	struct vm_area_struct *vm_prev_private;
+
 	struct vm_operations_struct * vm_ops;
 	unsigned long vm_offset;
 	struct file * vm_file;
@@ -100,6 +105,7 @@
 		unsigned long page);
 	int (*swapout)(struct vm_area_struct *,  unsigned long, pte_t *);
 	pte_t (*swapin)(struct vm_area_struct *, unsigned long, unsigned long);
+	int (*unuse)(struct vm_area_struct *, struct page *, pte_t *); /* not finalized */
 };
 
 /*
@@ -116,21 +122,48 @@
 	struct page *prev;
 	struct inode *inode;
 	unsigned long offset;
+
 	struct page *next_hash;
 	atomic_t count;
 	unsigned int age;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
+
 	struct wait_queue *wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
 	unsigned long map_nr;	/* page->map_nr == page - mem_map */
+
+	/* used for private mappings -> inode == NULL or &swapper_inode */
+	struct vm_area_struct *vma;
+	unsigned long vma_offset;
+
+	/* page on one of the circular page_queues */
+	struct page *pgq_next;
+	struct page *pgq_prev;
 } mem_map_t;
 
+/* uses a dummy struct page so we get next & prev for beginning/end of lists */
+extern struct page page_queues[];
+extern atomic_t page_queues_cnt[];
+
+#define PgQ_Locked	0	/* page is unswappable - mlock()'d */
+#define PgQ_Active	1	/* page is mapped and active -> young */
+#define PgQ_Inactive	2	/* page is mapped, but hasn't been referenced recently -> old */
+#define PgQ_Swappable	3	/* page has no mappings, is dirty */
+#define PgQ_Swapping	4	/* page is being swapped */
+#define PgQ_Dumpable	5	/* page has no mappings, is not dirty, but is still in the page cache */
+
+#define NR_PAGE_QUEUE		(PgQ_Dumpable+1)
+
+/* The low 3 bits of page->flag have been snarfed to index into page_queues */
+#define PGmask_pgq		0x7
+
 /* Page flag bit values */
-#define PG_locked		 0
-#define PG_error		 1
-#define PG_referenced		 2
-#define PG_uptodate		 3
+#define PG_on_queue		 3
+#define PG_locked		10
+#define PG_error		11
+#define PG_referenced		12
+#define PG_uptodate		13
 #define PG_free_after		 4
 #define PG_decr_after		 5
 /* Unused			 6 */
@@ -140,6 +173,7 @@
 #define PG_reserved		31
 
 /* Make it prettier to test the above... */
+#define PageOnQueue(page)	(test_bit(PG_on_queue, &(page)->flags))
 #define PageLocked(page)	(test_bit(PG_locked, &(page)->flags))
 #define PageError(page)		(test_bit(PG_error, &(page)->flags))
 #define PageReferenced(page)	(test_bit(PG_referenced, &(page)->flags))
