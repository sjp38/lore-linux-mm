Date: Thu, 30 Mar 2000 17:16:47 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: shrink_mmap SMP race fix
Message-ID: <Pine.LNX.4.21.0003301639540.368-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, MOLNAR Ingo <mingo@chiara.csoma.elte.hu>
List-ID: <linux-mm.kvack.org>

This patch fixes a race in shrink_mmap. In shrink_mmap between the
UnlockPage and the spin_lock(&pagemap_lru_lock) we wasn't holding any lock
and truncate_inode_pages or invalidate_inode_pages would been able to race
with us before we would had the time to reinsert the page in the local
temporary lru list.

The fix is to acquire the pagemap_lru_lock while the page is still locked.
We don't have priority inversion troubles there since we acquired the
per-page lock in the reverse order in first place using the trylock
method. Once we have the pagemap-lock acquired we can immediatly release
the per-page lock because the only thing we have to do then is to reinsert
the page in a lru and we don't need the per-page lock anymore for that. So
somebody can lockdown the page and start using it while we are inserting
it in the lru from shrink_mmap without races (fun :).

I'll keep thinking about it, right now it looks ok and it runs stable
here under swap SMP.

--- 2.3.99-pre3aa1-alpha/mm/filemap.c.~1~	Mon Mar 27 22:44:50 2000
+++ 2.3.99-pre3aa1-alpha/mm/filemap.c	Thu Mar 30 16:07:20 2000
@@ -329,20 +329,17 @@
 cache_unlock_continue:
 		spin_unlock(&pagecache_lock);
 unlock_continue:
+		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
 		put_page(page);
-dispose_relock_continue:
-		/* even if the dispose list is local, a truncate_inode_page()
-		   may remove a page from its queue so always
-		   synchronize with the lru lock while accesing the
-		   page->lru field */
-		spin_lock(&pagemap_lru_lock);
 		list_add(page_lru, dispose);
 		continue;
 
 unlock_noput_continue:
+		spin_lock(&pagemap_lru_lock);
 		UnlockPage(page);
-		goto dispose_relock_continue;
+		list_add(page_lru, dispose);
+		continue;
 
 dispose_continue:
 		list_add(page_lru, dispose);



This additional debugging patch make sure we don't do errors like we had
in invalidate_inode_pages (lru_cache_del() must be _always_ run with the
per-page lock acquired to avoid us to remove from the lru list a page that
is in the middle of the shrink_mmap processing).

--- 2.3.99-pre3aa1-alpha/include/linux/swap.h.~1~	Wed Mar 29 18:16:18 2000
+++ 2.3.99-pre3aa1-alpha/include/linux/swap.h	Thu Mar 30 16:41:45 2000
@@ -173,6 +173,8 @@
 
 #define	lru_cache_del(page)			\
 do {						\
+	if (!PageLocked(page))			\
+		BUG();				\
 	spin_lock(&pagemap_lru_lock);		\
 	list_del(&(page)->lru);			\
 	nr_lru_pages--;				\


This third patch removes a path that makes no sense to me. If you have an
explanation for it it's very welcome. The page aging happens very earlier
not before such place. I don't see the connection between the priority and
a fixed level of lru-cache. If something the higher is the priority the
harder we should shrink the cache (that's the opposite that the patch
achieves). Usually priority is always zero and the below check has no
effect. Also if something since it's relative to the LRU cache it should
be done _before_ start looking into the page and before clearing reference
bits all over the place (before the aging!) and also it should break the
loop instead of wasting CPU since there's going to be no way nr_lru_pages
will increase within shrink_mmap and so the check once start failng it
will keep failing wasting CPU for no good reason.

I also dislike the pgcache_under_min() thing but at least that happens to
make sense and tunable via sysctl and there's a good reason for not
breaking the loop there.

--- 2.3.99-pre3aa1-alpha/mm/filemap.c.~1~	Thu Mar 30 16:07:20 2000
+++ 2.3.99-pre3aa1-alpha/mm/filemap.c	Thu Mar 30 16:10:38 2000
@@ -294,12 +294,6 @@
 			goto cache_unlock_continue;
 
 		/*
-		 * We did the page aging part.
-		 */
-		if (nr_lru_pages < freepages.min * priority)
-			goto cache_unlock_continue;
-
-		/*
 		 * Is it a page swap page? If so, we want to
 		 * drop it if it is no longer used, even if it
 		 * were to be marked referenced..


I have algorithms completly autotuning (they happened to be in the
2.2.x-andrea patches somewhere in ftp.suse.com, there were many benchmarks
also posted on l-k at that time), they don't add anything fixed like the
above and I strongly believe the responsiveness under swap will be amazing
as soon as I'll port them to the new kernels. The only problem is that
with such algorithms there will be new flavours of SMP races in all the
map-unmap and depending on the implementation the struct page can waste a
further long word (there were no SMP issues in 2.2.x instead of obvious
reasons...) so probably it's more 2.5.x stuff now. Comments are welcome of
course.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
