Date: Fri, 10 Dec 2004 14:12:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: page fault scalability patch V12 [0/7]: Overview and
 performance tests
Message-Id: <20041210141258.491f3d48.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0412102125210.32422-100000@localhost.localdomain>
References: <Pine.LNX.4.58.0412101006200.8714@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0412102125210.32422-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, torvalds@osdl.org, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> > > (I do wonder why do_anonymous_page calls mark_page_accessed as well as
> > > lru_cache_add_active.  The other instances of lru_cache_add_active for
> > > an anonymous page don't mark_page_accessed i.e. SetPageReferenced too,
> > > why here?  But that's nothing new with your patch, and although you've
> > > reordered the calls, the final page state is the same as before.)
> > 
> > The mark_page_accessed is likely there avoid a future fault just to set
> > the accessed bit.
> 
> No, mark_page_accessed is an operation on the struct page
> (and the accessed bit of the pte is preset too anyway).

The point is a good one - I guess that code is a holdover from earlier
implementations.

This is equivalent, no?

--- 25/mm/memory.c~do_anonymous_page-use-setpagereferenced	Fri Dec 10 14:11:32 2004
+++ 25-akpm/mm/memory.c	Fri Dec 10 14:11:42 2004
@@ -1464,7 +1464,7 @@ do_anonymous_page(struct mm_struct *mm, 
 							 vma->vm_page_prot)),
 				      vma);
 		lru_cache_add_active(page);
-		mark_page_accessed(page);
+		SetPageReferenced(page);
 		page_add_anon_rmap(page, vma, addr);
 	}
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
