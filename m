Subject: [RFC][PATCH 1/2] Swap token re-tuned
From: Ashwin Chaugule <ashwin.chaugule@celunite.com>
Reply-To: ashwin.chaugule@celunite.com
Content-Type: multipart/mixed; boundary="=-G47GVx16zztwTWrr7rvK"
Date: Thu, 28 Sep 2006 22:28:03 +0530
Message-Id: <1159462684.11855.8.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-G47GVx16zztwTWrr7rvK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Sorry about that, I was'nt aware of the Thunderbird issue.
Sending the patches again. 
Thanks Peter !

-Ashwin

Try to grab swap token before the VM selects pages for eviction. 


Signed-off-by: Ashwin Chaugule <ashwin.chaugule@celunite.com>


--=-G47GVx16zztwTWrr7rvK
Content-Disposition: attachment; filename=swap-token-patch1
Content-Type: text/x-patch; name=swap-token-patch1; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/mm/filemap.c b/mm/filemap.c
index afcdc72..190d2c1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1478,8 +1478,8 @@ no_cached_page:
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
+	grab_swap_token(); /* Contend for token _before_ we read-in */
 	error = page_cache_read(file, pgoff);
-	grab_swap_token();
 
 	/*
 	 * The page we want has now been added to the page cache.
diff --git a/mm/memory.c b/mm/memory.c
index 92a3ebd..52eb9b8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1974,6 +1974,7 @@ static int do_swap_page(struct mm_struct
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
+		grab_swap_token(); /* Contend for token _before_ we read-in */
  		swapin_readahead(entry, address, vma);
  		page = read_swap_cache_async(entry, vma, address);
 		if (!page) {
@@ -1991,7 +1992,6 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
-		grab_swap_token();
 	}
 
 	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
diff --git a/mm/thrash.c b/mm/thrash.c

--=-G47GVx16zztwTWrr7rvK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
