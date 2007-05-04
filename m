Message-ID: <463AFB8C.2000909@yahoo.com.au>
Date: Fri, 04 May 2007 19:23:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans -- vm bugfixes
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <4636FDD7.9080401@yahoo.com.au> <Pine.LNX.4.64.0705011931520.16502@blonde.wat.veritas.com> <4638009E.3070408@yahoo.com.au> <Pine.LNX.4.64.0705021418030.16517@blonde.wat.veritas.com> <46393BA7.6030106@yahoo.com.au> <20070503103756.GA19958@infradead.org> <4639DBEC.2020401@yahoo.com.au>
In-Reply-To: <4639DBEC.2020401@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------060209070102080107050803"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060209070102080107050803
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:
> Christoph Hellwig wrote:

>> Is that every fork/exec or just under certain cicumstances?
>> A 5% regression on every fork/exec is not acceptable.
> 
> 
> Well after patch2, G5 fork is 3% and exec is 1%, I'd say the P4
> numbers will be improved as well with that patch. Then if we have
> specific lock/unlock bitops, I hope it should reduce that further.

OK, with the races and missing barriers fixed from the previous patch,
plus the attached one added (+patch3), numbers are better again (I'm not
sure if I have the ppc barriers correct though).

These ops could also be put to use in bit spinlocks, buffer lock, and
probably a few other places too.

2.6.21   1.49-1.51   164.6-170.8   741.8-760.3
+patch   1.71-1.73   175.2-180.8   780.5-794.2
+patch2  1.61-1.63   169.8-175.0   748.6-757.0
+patch3  1.54-1.57   165.6-170.9   748.5-757.5

So fault performance goes to under 5%, fork is in the noise, exec is
still up 1%, but maybe that's noise or cache effects again.

-- 
SUSE Labs, Novell Inc.

--------------060209070102080107050803
Content-Type: text/plain;
 name="lock-bitops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lock-bitops.patch"

Index: linux-2.6/include/asm-powerpc/bitops.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/bitops.h	2007-05-04 16:08:20.000000000 +1000
+++ linux-2.6/include/asm-powerpc/bitops.h	2007-05-04 16:14:39.000000000 +1000
@@ -87,6 +87,24 @@
 	: "cc" );
 }
 
+static __inline__ void clear_bit_unlock(int nr, volatile unsigned long *addr)
+{
+	unsigned long old;
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	__asm__ __volatile__(
+	LWSYNC_ON_SMP
+"1:"	PPC_LLARX "%0,0,%3	# clear_bit_unlock\n"
+	"andc	%0,%0,%2\n"
+	PPC405_ERR77(0,%3)
+	PPC_STLCX "%0,0,%3\n"
+	"bne-	1b"
+	: "=&r" (old), "+m" (*p)
+	: "r" (mask), "r" (p)
+	: "cc" );
+}
+
 static __inline__ void change_bit(int nr, volatile unsigned long *addr)
 {
 	unsigned long old;
@@ -126,6 +144,27 @@
 	return (old & mask) != 0;
 }
 
+static __inline__ int test_and_set_bit_lock(unsigned long nr,
+				       volatile unsigned long *addr)
+{
+	unsigned long old, t;
+	unsigned long mask = BITOP_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BITOP_WORD(nr);
+
+	__asm__ __volatile__(
+"1:"	PPC_LLARX "%0,0,%3		# test_and_set_bit_lock\n"
+	"or	%1,%0,%2 \n"
+	PPC405_ERR77(0,%3)
+	PPC_STLCX "%1,0,%3 \n"
+	"bne-	1b"
+	ISYNC_ON_SMP
+	: "=&r" (old), "=&r" (t)
+	: "r" (mask), "r" (p)
+	: "cc", "memory");
+
+	return (old & mask) != 0;
+}
+
 static __inline__ int test_and_clear_bit(unsigned long nr,
 					 volatile unsigned long *addr)
 {
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-05-04 16:14:36.000000000 +1000
+++ linux-2.6/include/linux/pagemap.h	2007-05-04 16:17:34.000000000 +1000
@@ -136,13 +136,18 @@
 extern void FASTCALL(__wait_on_page_locked(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
 
+static inline int trylock_page(struct page *page)
+{
+	return (likely(!TestSetPageLocked_Lock(page)));
+}
+
 /*
  * lock_page may only be called if we have the page's inode pinned.
  */
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
-	if (unlikely(TestSetPageLocked(page)))
+	if (!trylock_page(page))
 		__lock_page(page);
 }
 
@@ -153,7 +158,7 @@
 static inline void lock_page_nosync(struct page *page)
 {
 	might_sleep();
-	if (unlikely(TestSetPageLocked(page)))
+	if (!trylock_page(page))
 		__lock_page_nosync(page);
 }
 	
Index: linux-2.6/drivers/scsi/sg.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sg.c	2007-04-12 14:35:08.000000000 +1000
+++ linux-2.6/drivers/scsi/sg.c	2007-05-04 16:23:27.000000000 +1000
@@ -1734,7 +1734,7 @@
                  */
 		flush_dcache_page(pages[i]);
 		/* ?? Is locking needed? I don't think so */
-		/* if (TestSetPageLocked(pages[i]))
+		/* if (!trylock_page(pages[i]))
 		   goto out_unlock; */
         }
 
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c	2007-04-12 14:35:09.000000000 +1000
+++ linux-2.6/fs/cifs/file.c	2007-05-04 16:23:36.000000000 +1000
@@ -1229,7 +1229,7 @@
 
 			if (first < 0)
 				lock_page(page);
-			else if (TestSetPageLocked(page))
+			else if (!trylock_page(page))
 				break;
 
 			if (unlikely(page->mapping != mapping)) {
Index: linux-2.6/fs/jbd/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd/commit.c	2007-04-12 14:35:09.000000000 +1000
+++ linux-2.6/fs/jbd/commit.c	2007-05-04 16:23:30.000000000 +1000
@@ -64,7 +64,7 @@
 		goto nope;
 
 	/* OK, it's a truncated page */
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto nope;
 
 	page_cache_get(page);
Index: linux-2.6/fs/jbd2/commit.c
===================================================================
--- linux-2.6.orig/fs/jbd2/commit.c	2007-04-12 14:35:09.000000000 +1000
+++ linux-2.6/fs/jbd2/commit.c	2007-05-04 16:23:40.000000000 +1000
@@ -64,7 +64,7 @@
 		goto nope;
 
 	/* OK, it's a truncated page */
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto nope;
 
 	page_cache_get(page);
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c	2007-03-05 15:17:25.000000000 +1100
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c	2007-05-04 16:23:33.000000000 +1000
@@ -601,7 +601,7 @@
 			} else
 				pg_offset = PAGE_CACHE_SIZE;
 
-			if (page->index == tindex && !TestSetPageLocked(page)) {
+			if (page->index == tindex && trylock_page(page)) {
 				len = xfs_probe_page(page, pg_offset, mapped);
 				unlock_page(page);
 			}
@@ -685,7 +685,7 @@
 
 	if (page->index != tindex)
 		goto fail;
-	if (TestSetPageLocked(page))
+	if (!trylock_page(page))
 		goto fail;
 	if (PageWriteback(page))
 		goto fail_unlock_page;
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-05-03 08:38:53.000000000 +1000
+++ linux-2.6/include/linux/page-flags.h	2007-05-04 16:18:23.000000000 +1000
@@ -116,8 +116,12 @@
 		set_bit(PG_locked, &(page)->flags)
 #define TestSetPageLocked(page)		\
 		test_and_set_bit(PG_locked, &(page)->flags)
+#define TestSetPageLocked_Lock(page)		\
+		test_and_set_bit_lock(PG_locked, &(page)->flags)
 #define ClearPageLocked(page)		\
 		clear_bit(PG_locked, &(page)->flags)
+#define ClearPageLocked_Unlock(page)		\
+		clear_bit_unlock(PG_locked, &(page)->flags)
 #define TestClearPageLocked(page)	\
 		test_and_clear_bit(PG_locked, &(page)->flags)
 
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2007-05-02 15:00:28.000000000 +1000
+++ linux-2.6/mm/memory.c	2007-05-04 16:19:12.000000000 +1000
@@ -1550,7 +1550,7 @@
 	 * not dirty accountable.
 	 */
 	if (PageAnon(old_page)) {
-		if (!TestSetPageLocked(old_page)) {
+		if (trylock_page(old_page)) {
 			reuse = can_share_swap_page(old_page);
 			unlock_page(old_page);
 		}
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2007-05-02 14:48:36.000000000 +1000
+++ linux-2.6/mm/migrate.c	2007-05-04 16:19:15.000000000 +1000
@@ -569,7 +569,7 @@
 	 * establishing additional references. We are the only one
 	 * holding a reference to the new page at this point.
 	 */
-	if (TestSetPageLocked(newpage))
+	if (!trylock_page(newpage))
 		BUG();
 
 	/* Prepare mapping for the new page.*/
@@ -621,7 +621,7 @@
 		goto move_newpage;
 
 	rc = -EAGAIN;
-	if (TestSetPageLocked(page)) {
+	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
 		lock_page(page);
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2007-04-13 20:48:04.000000000 +1000
+++ linux-2.6/mm/rmap.c	2007-05-04 16:19:18.000000000 +1000
@@ -426,7 +426,7 @@
 			referenced += page_referenced_anon(page);
 		else if (is_locked)
 			referenced += page_referenced_file(page);
-		else if (TestSetPageLocked(page))
+		else if (!trylock_page(page))
 			referenced++;
 		else {
 			if (page->mapping)
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2007-05-02 15:00:26.000000000 +1000
+++ linux-2.6/mm/shmem.c	2007-05-04 16:19:22.000000000 +1000
@@ -1155,7 +1155,7 @@
 		}
 
 		/* We have to do this with page locked to prevent races */
-		if (TestSetPageLocked(swappage)) {
+		if (!trylock_page(swappage)) {
 			shmem_swp_unmap(entry);
 			spin_unlock(&info->lock);
 			wait_on_page_locked(swappage);
@@ -1214,7 +1214,7 @@
 		shmem_swp_unmap(entry);
 		filepage = find_get_page(mapping, idx);
 		if (filepage &&
-		    (!PageUptodate(filepage) || TestSetPageLocked(filepage))) {
+		    (!PageUptodate(filepage) || !trylock_page(filepage))) {
 			spin_unlock(&info->lock);
 			wait_on_page_locked(filepage);
 			page_cache_release(filepage);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2007-04-12 14:35:11.000000000 +1000
+++ linux-2.6/mm/swap.c	2007-05-04 16:19:28.000000000 +1000
@@ -412,7 +412,7 @@
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 
-		if (PagePrivate(page) && !TestSetPageLocked(page)) {
+		if (PagePrivate(page) && trylock_page(page)) {
 			if (PagePrivate(page))
 				try_to_release_page(page, 0);
 			unlock_page(page);
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2007-04-24 10:39:57.000000000 +1000
+++ linux-2.6/mm/swap_state.c	2007-05-04 16:19:32.000000000 +1000
@@ -252,7 +252,7 @@
  */
 static inline void free_swap_cache(struct page *page)
 {
-	if (PageSwapCache(page) && !TestSetPageLocked(page)) {
+	if (PageSwapCache(page) && trylock_page(page)) {
 		remove_exclusive_swap_page(page);
 		unlock_page(page);
 	}
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2007-04-24 10:39:55.000000000 +1000
+++ linux-2.6/mm/swapfile.c	2007-05-04 16:19:25.000000000 +1000
@@ -401,7 +401,7 @@
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
 			page = find_get_page(&swapper_space, entry.val);
-			if (page && unlikely(TestSetPageLocked(page))) {
+			if (page && unlikely(!trylock_page(page))) {
 				page_cache_release(page);
 				page = NULL;
 			}
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-05-02 15:00:27.000000000 +1000
+++ linux-2.6/mm/truncate.c	2007-05-04 16:19:35.000000000 +1000
@@ -185,7 +185,7 @@
 			if (page_index > next)
 				next = page_index;
 			next++;
-			if (TestSetPageLocked(page))
+			if (!trylock_page(page))
 				continue;
 			if (PageWriteback(page)) {
 				unlock_page(page);
@@ -291,7 +291,7 @@
 			pgoff_t index;
 			int lock_failed;
 
-			lock_failed = TestSetPageLocked(page);
+			lock_failed = !trylock_page(page);
 
 			/*
 			 * We really shouldn't be looking at the ->index of an
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-04-24 10:39:56.000000000 +1000
+++ linux-2.6/mm/vmscan.c	2007-05-04 16:19:38.000000000 +1000
@@ -466,7 +466,7 @@
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (TestSetPageLocked(page))
+		if (!trylock_page(page))
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
@@ -538,7 +538,7 @@
 				 * A synchronous write - probably a ramdisk.  Go
 				 * ahead and try to reclaim the page.
 				 */
-				if (TestSetPageLocked(page))
+				if (!trylock_page(page))
 					goto keep;
 				if (PageDirty(page) || PageWriteback(page))
 					goto keep_locked;

--------------060209070102080107050803--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
