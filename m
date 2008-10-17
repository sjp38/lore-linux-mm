Date: Fri, 17 Oct 2008 13:29:04 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc] SLOB memory ordering issue
In-Reply-To: <200810160506.14261.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.2.00.0810171235310.3438@nehalem.linux-foundation.org>
References: <200810160334.13082.nickpiggin@yahoo.com.au> <1224089658.3316.218.camel@calx> <200810160410.49894.nickpiggin@yahoo.com.au> <200810160506.14261.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Matt Mackall <mpm@selenic.com>, Hugh Dickins <hugh@veritas.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ok, finally looked at this.

There is indeed a locking bug there. "anon_vma_prepare()" optimistically 
looks at vma->anon_vma without taking the &mm->page_table_lock. That's not 
right.

Of course, we could just take the lock, but in this case it's probably ok 
to just admit that we have a lockless algorithm. But that implies that we 
need to do the right memory ordering.

And that, in turn, doesn't just imply a "smp_wmb()" - if you do memory 
ordering, you need to do it on *both* sides, so now the other side needs 
to also do a matching smp_rmb(). Or, in this case, smp_rmb_depends(), I 
guess.

That, btw, is an important part of memory ordering. You can never do 
ordering on just one side. A "smp_wmb()" on its own is always nonsensical. 
It always needs to be paired with a "smp_rmb()" variant.

Something like the appended may fix it.

But I do think we have a potential independent issue with the new page 
table lookup code now that it's lock-free. We have the smp_rmb() calls in 
gup_get_pte() (at least on x86), when we look things up, but we don't 
actually have a lot of smp_wmb()'s there when we insert the page.

For the anonymous page case, we end up doing a

	page_add_new_anon_rmap();

before we do the set_pte_at() that actually exposes it, and that does the 
whole

	page->mapping = (struct address_space *) anon_vma;
	page->index = linear_page_index(vma, address);

thing, but there is no write barrier between those and the actual write to 
the page tables, so when GUP looks up the page, it can't actually depend 
on page->mappign or anything else!

Now, this really isn't an issue on x86, since smp_wmb() is a no-op, and 
the compiler won't be re-ordering the writes, but in general I do think 
that now that we do lockless lookup of pages from the page tables, we 
probably do need smp_wmb()'s there just in front of the "set_pte_at()" 
calls.

NOTE NOTE! The patch below is only about "page->anon_vma", not about the 
GUP lookup and page->mapping/index fields. That's an independent issue.

And notice? This has _nothing_ to do with constructors or allocators.

And of course - this patch is totally untested, and may well need some 
thinking about.

			Linus

---
 mm/rmap.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 0383acf..21d09bb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -81,6 +81,13 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
+			/*
+			 * We hold the mm->page_table_lock, but another
+			 * CPU may be doing an optimistic load (the one
+			 * at the top), and we want to make sure that
+			 * the anon_vma changes are visible.
+			 */
+			smp_wmb();
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 			allocated = NULL;
@@ -92,6 +99,17 @@ int anon_vma_prepare(struct vm_area_struct *vma)
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
+	/*
+	 * Subtle: we looked up anon_vma without any locking
+	 * (in the comon case), and are going to look at the
+	 * spinlock etc behind it. In order to know that it's
+	 * initialized, we need to do a read barrier here.
+	 *
+	 * We can use the cheaper "depends" version, since we
+	 * are following a pointer, and only on alpha may that
+	 * give a stale value.
+	 */
+	smp_read_barrier_depends();
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
