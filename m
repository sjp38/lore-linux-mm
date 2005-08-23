Date: Tue, 23 Aug 2005 08:22:15 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
In-Reply-To: <430A6D08.1080707@yahoo.com.au>
Message-ID: <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
 <430A6D08.1080707@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Nick Piggin wrote:
> 
> I like this.

Thanks, and thanks for taking a look.

> It is very like what I did, and having the 'fallback'
> case still take the "narrowed" lock eliminates some of the complexity
> I had. So it should be fairly easy to add the per-pte locks on top
> of this.

Glad if you can find it useful as a step on the way forward.

> I had preempt_disable() in tlb_gather_mmu which I thought was nice,
> but maybe you don't?

I most definitely agree.  tlb_gather_mmu uses smp_processor_id when it
should be using get_cpu, we don't usually open code the preempt_disable.

But there's a number of things peculiar about tlb_gather_mmu and friends
(e.g. the rss but not anon_rss asymmetry; and what have those got to do
with "tlb" anyway?), spread over several arches, I decided to stay away
for now, go into all that at a later date.  What it should be doing
about rss depends rather on what Christoph ends up with there.

> > +#ifdef CONFIG_SPLIT_PTLOCK
> > +#define __pte_lockptr(page)	((spinlock_t *)&((page)->private))
> > +#define pte_lock_init(page)	spin_lock_init(__pte_lockptr(page))
> > +#define pte_lock_deinit(page)	((page)->mapping = NULL)
> 
> Do you mean page->private?

No, it does mean page->mapping: depending on DEBUG options and whatnot,
the spinlock_t might (currently, I think) be as many as 5 unsigned longs,
hich happily just happen to fit into the unmodified 32-bit struct page,
and the only "corruption" which actually matters is that freeing a page
protests if page->mapping is found set.

At the least I should add a build time check that spinlock_t doesn't
overflow beyond the end of the struct page, if we continue this way.
I'm hoping that (with sparsemem?) on the many node machines, your
struct page will be on the same node your page is on?  But others may
hate embedding in the struct page like this, and prefer to kmalloc
separately: shouldn't be hard to tweak the implementation.  For now
it's numbers we want, to see if it's worth going this way at all.

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
