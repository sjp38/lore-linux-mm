Date: Sat, 9 Nov 2002 18:52:42 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: [RFC PATCH] Re: get_user_pages rewrite (completed, updated for 2.4.46)
Message-ID: <20021109185242.T659@nightmaster.csn.tu-chemnitz.de>
References: <20021107110840.P659@nightmaster.csn.tu-chemnitz.de> <3DCC3E38.29B0ABEF@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DCC3E38.29B0ABEF@digeo.com>; from akpm@digeo.com on Fri, Nov 08, 2002 at 02:44:08PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

thanks for your review.

On Fri, Nov 08, 2002 at 02:44:08PM -0800, Andrew Morton wrote:

[custom_page_walker_t locking rules for vma->mm->page_table_lock]

> This locking is rather awkward.  Why is it necessary, and can it
> be simplified??
 
No unlocking is needed in the fast and common cases. That shall
reduce bus traffic.

That locking is also needed for follow_page and will not be
dropped, if the page is already faulted into the process space
(should be the common case for get_user_pages).

Under normal operation walk_user_pages is a loop of
follow_page(), which need needs that lock. e.g the while
statement in single_page_walk() will not go to the loop.

The original implementation did NO proper cleanup, if the call
spanned multiple VMAs. 

That's why I introduced the case IS_ERR(vma), where the
vma->mm->page_table_lock cannot be unlocked, but cleanup can
happen in case of wrong VMA and the walker having collected some
pages already.

We have two possibilities to simplify locking:

1) Explicit argument, whether the page_table_lock is taken.
   - Would simplify usage, but I know that this kind of functions
     where eliminated during the past, because Linus and some
     other people don't like that kind of magic.

   - Would remove the need to do that for huge tlb pages.

   - We must check for that flag and restore state at exit and
     the error path. Handling the error path is already
     complicated, but very visible (the IS_ERR is a good
     indicator even to the inexperienced reader).

2) Always be unlock before we enter the custom page walker.
   - Would cause lock/follow_page/unlock/lock/page_cache_get/unlock
     for EVERY page in the normal get_user_pages() case.

3) Always unlock if IS_ERR(page) would trigger.
   (Actually the IS_ERR(page) is triggered also, if IS_ERR(vma) is true).
   - Removes the unlocking completely from the custom page walker, 
     if it doesn't need to do that anyway.

   - Is no real simplification, since the walker can be entered
     with locking or without, as it is now.

   - We still require locking for huge tlb pages, but Mr. Irwin
     already acked the changes for that.
   
4) Introduce an explicit "cleaning" function passed additionally
   to the walk_user_pages() function.

   - This would seperate the error handling completly from the
     normal case.
   
   - It would be possible to omit the error handling, if not
     needed. (Or to forget it, if needed later ;-/ )
   
   - The page walker will ALWAYS be entered with the page_table_lock
     taken.

   - The cleanup handler will ALWAYS be entered without it and
     only the custom_data passed along.

   - Function enter/exit overhead is compiled twice, because we
     have two functions.

   - And we still require locking for huge tlb pages.
   
Which one do you like most? I would favor 3. I've appended 
a patch for that against page-walk-api-2.5.46-mm1-all.patch.bz2 
for you to test it.

I agree that the locking rules are awkward, but they are the best
solution I could come up with while preserving speed and
functionality. Any better rules will be implemented at your request.

> wrt the removal of the vmas arg to get_user_pages(): I assume this
> was because none of the multipage callers were using it?
 
Yes, thats true. If some caller needs this, it can use a custom
walker.

Single patch against 2.5.46-mm1 is at 

http://www.tu-chemnitz.de/~ioe/patches-page_walk/page-walk-api-2.5.46-mm1-all.patch.bz2

All patches with description and diffstat of the whole thing at:

   http://www.tu-chemnitz.de/~ioe/patches-page_walk/index.html

Thanks again for your review, I really appriciate your input here.

Regards

Ingo Oeser


diff -u linux-2.5.46-mm1-ioe/include/linux/mm.h linux-2.5.46-mm1-ioe/include/linux/mm.h
--- linux-2.5.46-mm1-ioe/include/linux/mm.h	Fri Nov  8 12:55:49 2002
+++ linux-2.5.46-mm1-ioe/include/linux/mm.h	Sat Nov  9 18:02:56 2002
@@ -396,14 +396,15 @@
  * If this functions gets a page, for which %IS_ERR(@page) is true, than it
  * should do it's cleanup of customdata and return -PTR_ERR(@page).
  *
- * This function is called with @vma->vm_mm->page_table_lock held,
- * if IS_ERR(@vma) is not true.
+ * If IS_ERR(@page) is NOT TRUE, this function is called with
+ * @vma->vm_mm->page_table_lock held. 
  *
- * But if IS_ERR(@vma) is true, IS_ERR(@page) is also true, since if we have no
- * vma, then we also have no user space page.
+ * The value of @vma is undefined if IS_ERR(@page) is TRUE.
+ * (So never use or check it if IS_ERR(@page) is TRUE)
  *
- * If it returns a negative value, then the page_table_lock must be dropped
- * by this function, if it is held.
+ * If it returns a negative value but got a valid page, then the
+ * page_table_lock must be dropped by this function. (This condition should be
+ * rather rare.)
  */
 typedef int (*custom_page_walker_t)(struct vm_area_struct *vma, 
 		struct page *page, unsigned long virt_addr, void *customdata);
diff -u linux-2.5.46-mm1-ioe/mm/memory.c linux-2.5.46-mm1-ioe/mm/memory.c
--- linux-2.5.46-mm1-ioe/mm/memory.c	Fri Nov  8 12:55:49 2002
+++ linux-2.5.46-mm1-ioe/mm/memory.c	Sat Nov  9 18:15:06 2002
@@ -1158,8 +1158,6 @@
 
 	struct gup_add_pages *gup = customdata;
 
-	BUG_ON(!customdata);
-
 	if (!IS_ERR(page)) {
 		gup->pages[gup->count++] = page;
 		flush_dcache_page(page);
@@ -1170,8 +1168,6 @@
 		return (gup->count == gup->max_pages) ? 1 : 0;
 	}
 
-	if (!IS_ERR(vma))
-		spin_unlock(&vma->vm_mm->page_table_lock);
 	gup_pages_cleanup(gup);
 	return -PTR_ERR(page);
 }
@@ -1192,7 +1188,6 @@
 
 		spin_unlock(&mm->page_table_lock);
 		fault = handle_mm_fault(mm, vma, start, write);
-		spin_lock(&mm->page_table_lock);
 
 		switch (fault) {
 		case VM_FAULT_MINOR:
@@ -1210,8 +1205,13 @@
 			spin_unlock(&mm->page_table_lock);
 			BUG();
 		}
+		spin_lock(&mm->page_table_lock);
 	}
-	return get_page_map(map);
+	map=get_page_map(map);
+	if (IS_ERR(map))
+		spin_unlock(&mm->page_table_lock);
+
+	return map;
 }
 
 /* VMA contains already "start".
@@ -1248,10 +1248,14 @@
 	spin_lock(&mm->page_table_lock);
 	page = single_page_walk(tsk, mm, vma, start, write);
 
-	if (!(IS_ERR(page) || PageReserved(page)))
+	if (IS_ERR(page)) 
+		goto out;
+
+	if (!PageReserved(page))
 		page_cache_get(page);
 
 	spin_unlock(&mm->page_table_lock);
+out:
 	return page;
 }
 
@@ -2101,8 +2105,6 @@
 		return (*todo) ? 0 : 1;
 	}
 
-	if (!IS_ERR(vma))
-		spin_unlock(&vma->vm_mm->page_table_lock);
 	return -PTR_ERR(page);
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
