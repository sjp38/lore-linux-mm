Date: Sun, 31 Jul 2005 06:30:59 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
Message-ID: <20050731113059.GC2254@lnx-holt.americas.sgi.com>
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au> <20050731105234.GA2254@lnx-holt.americas.sgi.com> <42ECB0EC.4000808@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42ECB0EC.4000808@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 31, 2005 at 09:07:24PM +1000, Nick Piggin wrote:
> Robin Holt wrote:
> >Should there be a check to ensure we don't return VM_FAULT_RACE when the
> >pte which was inserted is exactly the same one we would have inserted?
> 
> That would slow down the do_xxx_fault fastpaths, though.
> 
> Considering VM_FAULT_RACE will only make any difference to get_user_pages
> (ie. not the page fault fastpath), and only then in rare cases of a racing
> fault on the same pte, I don't think the extra test would be worthwhile.
> 
> >Could we generalize that more to the point of only returning VM_FAULT_RACE
> >when write access was requested but the racing pte was not writable?
> >
> 
> I guess get_user_pages could be changed to retry on VM_FAULT_RACE only if
> it is attempting write access... is that worthwhile? I guess so...
> 
> >Most of the test cases I have thrown at this have gotten the writer
> >faulting first which did not result in problems.  I would hate to slow
> >things down if not necessary.  I am unaware of more issues than the one
> >I have been tripping.
> >
> 
> I think the VM_FAULT_RACE patch as-is should be fairly unintrusive to the
> page fault fastpaths. I think weighing down get_user_pages is preferable to
> putting logic in the general fault path - though I don't think there should
> be too much overhead introduced even there...
> 
> Do you think the patch (or at least, the idea) looks like a likely solution
> to your problem? Obviously the !i386 architecture specific parts still need
> to be filled in...

The patch works for me.

What I was thinking didn't seem that much heavier than what is already being
done.  I guess a patch against your patch might be a better illustration:

This is on top of your patch:

Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2005-07-31 05:39:24.161826311 -0500
+++ linux/mm/memory.c	2005-07-31 06:26:33.687274327 -0500
@@ -1768,17 +1768,17 @@ do_anonymous_page(struct mm_struct *mm, 
 		spin_lock(&mm->page_table_lock);
 		page_table = pte_offset_map(pmd, addr);
 
+		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
+						vma->vm_page_prot)), vma);
 		if (!pte_none(*page_table)) {
+			if (!pte_same(*page_table, entry))
+				ret = VM_FAULT_RACE;
 			pte_unmap(page_table);
 			page_cache_release(page);
 			spin_unlock(&mm->page_table_lock);
-			ret = VM_FAULT_RACE;
 			goto out;
 		}
 		inc_mm_counter(mm, rss);
-		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
-							 vma->vm_page_prot)),
-				      vma);
 		lru_cache_add_active(page);
 		SetPageReferenced(page);
 		page_add_anon_rmap(page, vma, addr);
@@ -1879,6 +1879,10 @@ retry:
 	}
 	page_table = pte_offset_map(pmd, address);
 
+	entry = mk_pte(new_page, vma->vm_page_prot);
+	if (write_access)
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
 	 * due to the bad i386 page protection. But it's valid
@@ -1895,9 +1899,6 @@ retry:
 			inc_mm_counter(mm, rss);
 
 		flush_icache_page(vma, new_page);
-		entry = mk_pte(new_page, vma->vm_page_prot);
-		if (write_access)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			lru_cache_add_active(new_page);
@@ -1906,11 +1907,12 @@ retry:
 			page_add_file_rmap(new_page);
 		pte_unmap(page_table);
 	} else {
+		if (!pte_same(*page_table, entry))
+			ret=VM_FAULT_RACE;
 		/* One of our sibling threads was faster, back out. */
 		pte_unmap(page_table);
 		page_cache_release(new_page);
 		spin_unlock(&mm->page_table_lock);
-		ret = VM_FAULT_RACE;
 		goto out;
 	}



In both cases, we have immediately before this read the value from the
pte so all the processor infrastructure is already in place and the
read should be extremely quick.  In truth, the compiler should eliminate
the second load, but I can not guarantee that.

What do you think?

Robin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
