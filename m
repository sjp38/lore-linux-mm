Date: Wed, 4 Mar 1998 23:21:53 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <Pine.LNX.3.91.980305001855.1439B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.980304194816.27764B-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Mar 1998, Rik van Riel wrote:

> On Wed, 4 Mar 1998, Stephen C. Tweedie wrote:
> 
> > > +#define PgQ_Locked	0	/* page is unswappable - mlock()'d */
> > > +#define PgQ_Active	1	/* page is mapped and active -> young */
> > > +#define PgQ_Inactive	2	/* page is mapped, but hasn't been referenced recently -> old */
> > > +#define PgQ_Swappable	3	/* page has no mappings, is dirty */
> > > +#define PgQ_Swapping	4	/* page is being swapped */
> > > +#define PgQ_Dumpable	5	/* page has no mappings, is not dirty, but is still in the page cache */
> > 
> > don't seem to give us all that much extra, since we probably never want
> > to go out and explicitly search for all pages on such lists.  (That's
> > assuming that the page aging and swapping scanner is working by walking
> > pages in physical address order, not by traversing any other lists.)
> 
> We just might want to do that. If we can _guarantee_
> a certain number of free+(inactive&clean) pages, we
> can keep the number of free pages lower, and we can
> keep more pages longer in memory, giving more speed
> to the overall system.

That's 'xactly what I had in mind (there's an extern atomic_t
page_queues_cnt[]; in my proposed mm.h ;-) .  The other aspect of the
queues is to replace the page->age scheme

Not only that, but I've just realized how we can get the queue's for free 
with some hackery...

In another message, Stephen C. Tweedie wrote:

> Given this, can we not over load the two new fields and reduce the
> expansion of the struct page?  The answer is yes, if and only if we
> restrict the new page queues to unmapped pages.  For my own code, the
> only queue which is really necessary is the list of pages ready to be
> reclaimed at interrupt time, and those pages will never be mapped.

You're absolutely right.  And by going all the way, we can even get the
queues in place, and still have a struct page that's the same size as 2.0.

struct page {
	union {
		struct {
			struct page *next;
			struct page *prev;
		} normal;
		struct {
			struct vm_area_struct *vma;
			unsigned long vm_offset;
		} private;
	} u;
	struct inode *inode;
	unsigned long offset;

	struct page *next_hash;
	atomic_t count;
	unsigned long flags;
	struct wait_queue *wait;

	struct page **prev_hash;
	struct buffer_head * buffers;
	struct page *pgq_next;
	struct page *pgq_prev;
}

What happened?  Well, both age and map_nr are gone.  With struct page
being 48 bytes on 32 bit machines, defining map_nr as: 

	((unsigned long)page - (unsigned long)mem_map) / sizeof(struct page) 

is sufficiently cheap.  I checked with egcs 1.0 and it generates awful
code for map_nr = page - mem_map (why?), whereas the above is fine (so
defining a map_nr(page) macro/inline should be okay).  Even if we keep
map_nr, it's still about the same size as in 2.0 (52 bytes).

Anyhoo, overlapping vma/vm_offset with next/prev works nicely as next/prev
are only used for the per-inode page list to discard pages in
invalidate_inode_pages if the page is shared, or for the page's position
in the free list.  If the page belongs to the swapper inode,
invalidate_inode_pages makes no sense, and it certainly isn't free.  This
looks to be cleaner than the suggestion of overlapping 

Another issue that Stephen brought to my attention, RSS limits, seems to
have a reasonable approach: when the RSS limit is lowered/exceeded, walk
the inactive/active lists looking for pages that are used by the process.
For the normal case (a private page used only by the mm in question), the
test is a simple check if page->u.private.vma->mm == mm.  If the page is
shared, we have to do the expensive walk-lots check, until we've dropped
the RSS of the process sufficiently.  However, we should be able to avoid
that most of the time by having an amount of 'slack' for the RSS, which
will allow the normal movement of pages from active->inactive->swappable
to reduce the process' RSS.  If it really is an issue, we can always walk
the page tables looking for inactive pages to toss..

Oh, it's almost working... =)

		-ben
