Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E84056B0047
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 12:40:51 -0500 (EST)
Date: Sat, 23 Jan 2010 18:39:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 03 of 30] alter compound get_page/put_page
Message-ID: <20100123173958.GA6494@random.random>
References: <patchbomb.1264054824@v2.random>
 <2c68e94d31d8c675a5e2.1264054827@v2.random>
 <1264095346.32717.34452.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1264095346.32717.34452.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 09:35:46AM -0800, Dave Hansen wrote:
> Christoph kinda has a point here.  The gup code is going to be a pretty
> hot path for some people, and this does add a bunch of atomics that some
> people will have no need for.
> 
> It's also a decent place to put a helper function anyway.
> 
> void pin_huge_page_tail(struct page *page)
> {
> 	/*
> 	 * This ensures that a __split_huge_page_refcount()
> 	 * running underneath us cannot 
> 	 */
> 	VM_BUG_ON(atomic_read(&page->_count) < 0);
> 	atomic_inc(&page->_count);
> }
> 
> It'll keep us from putting the same comment in too many arches, I guess

We can replace the compound_lock with a branch, by setting a
PG_trans_huge on all compound pages allocated by huge_memory.c, that
would only benefit gup on hugetlbfs (and it'll add the cost of one
branch to gup on transparent hugepages, that's why I didn't do
that). But I can add it. Note the compound_lock is granular on a
cacheline already hot and exclusive read-write on the l1 cache, not
like the mmap_sem (that gup_fast avoids), but surely an atomic op is
more costly than just a branch...

> >  static inline void get_page(struct page *page)
> >  {
> > -	page = compound_head(page);
> > -	VM_BUG_ON(atomic_read(&page->_count) == 0);
> > +	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
> 
> Hmm.

This means, if the page is not a tail page, count must be >= 1 (,
which is more strict and more correct than the already existing check
== 0 that should really be <= 0). If a page is a tail page, then the
bugcheck is only for < 0, because tail pages are only pinned by gup
and if there is no gup going on, there is no pin either on tail pages.

> 
> 	if 
> 
> >  	atomic_inc(&page->_count);
> > +	if (unlikely(PageTail(page))) {
> > +		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
> > +		atomic_inc(&page->first_page->_count);
> > +		/* __split_huge_page_refcount can't run under get_page */
> > +		VM_BUG_ON(!PageTail(page));
> > +	}
> >  }
> 
> Are you hoping to catch a race in progress with the second VM_BUG_ON()
> here?  Maybe the comment should say, "detect race with
> __split_huge_page_refcount".

Exactly. I think the current comment was explicit enough. But frankly
this is pure paranoid and I'm thinking that gcc can eliminate the
bugcheck entirely because atomic_inc doesn't clobber "memory" so I'll
remove the bugcheck instead, but leaving the current comment.

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -322,10 +322,13 @@ static inline void get_page(struct page 
 	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
 	atomic_inc(&page->_count);
 	if (unlikely(PageTail(page))) {
+		/*
+		 * This is safe only because
+		 * __split_huge_page_refcount can't run under
+		 * get_page().
+		 */
 		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
 		atomic_inc(&page->first_page->_count);
-		/* __split_huge_page_refcount can't run under get_page */
-		VM_BUG_ON(!PageTail(page));
 	}
 }
 


> >  static inline struct page *virt_to_head_page(const void *x)
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -409,7 +409,8 @@ static inline void __ClearPageTail(struc
> >  	 1 << PG_private | 1 << PG_private_2 | \
> >  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
> >  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> > -	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON)
> > +	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
> > +	 1 << PG_compound_lock)
> 
> Nit: should probably go in the last patch.

Why? If you apply this single patch we already want to immediately
detect if somebody is running compund_lock but forgetting to
compound_unlock before freeing the page. Just like with PG_lock. There
may be other nits on how I tried to splited the original monolith
without having to rewrite lots of intermediate code, but this looks
ok or at least I don't get why to move it elsewhere ;).

> That looks functional to me, although the code is pretty darn dense. :)
> But, I'm not sure there's a better way to do it.

I'm not sure either.

If you or Christoph or anybody else asks me to add a PG_trans_huge set
by huge_memory.c immediately after allocating the hugepage, and to
make the above put_page/get_page tail pinning and compound_lock
entirely conditional to PG_trans_huge being set I'll do it
immediately. As said it will replace around 2 atomic ops on each
gup/put_page run on a tail page allocated in hugetlbfs (not through
the transparent hugepage framework) with a branch, so it will
practically eliminate the overhead caused to O_DIRECT over
hugetlbfs. I'm not doing it unless explicitly asked because:

1) it will make code even a little more dense

2) it will microslowdown transparent hugepage gup (which means
O_DIRECT over transparent hugepage and the kvm minor fault will have
to pay one more branch than necessary)

It might be a worthwhile tradeoff but I'm not big believer in
hugetlbfs optimization (unless they're entirely self contained) so
that's why I'm not inclined to do it unless explicitly asked. I think
we should rather think on how to speedup gup on transparent hugepage,
and secondly we should add transparent hugepage support starting with
tmpfs probably.

As you guessed, I also couldn't think of a more efficient way than to
use this compound_lock on tail pages to allow the proper atomic adjust
of the tail page refcounts in __split_huge_page_refcount.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
