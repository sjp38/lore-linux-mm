Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.codito.com (Postfix) with ESMTP id 7CE883EC65
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 19:33:10 +0530 (IST)
Received: from mail.codito.com ([127.0.0.1])
	by localhost (vera.celunite.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7TOvLvl4DrAM for <linux-mm@kvack.org>;
	Thu, 28 Sep 2006 19:33:10 +0530 (IST)
Received: from [192.168.100.251] (unknown [220.225.33.101])
	by mail.codito.com (Postfix) with ESMTP id 4CA993EC62
	for <linux-mm@kvack.org>; Thu, 28 Sep 2006 19:33:10 +0530 (IST)
Message-ID: <451BD700.4010106@codito.com>
Date: Thu, 28 Sep 2006 19:36:56 +0530
From: Ashwin Chaugule <ashwin.chaugule@codito.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 1/2] Swap token re-tuned
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Try to grab swap token before the VM selects pages for eviction.


Signed-off-by: Ashwin Chaugule <ashwin.chaugule@celunite.com>

-- 

diff --git a/mm/filemap.c b/mm/filemap.c
index afcdc72..190d2c1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1478,8 +1478,8 @@ no_cached_page:
     * We're only likely to ever get here if MADV_RANDOM is in
     * effect.
     */
+    grab_swap_token(); /* Contend for token _before_ we read-in */
    error = page_cache_read(file, pgoff);
-    grab_swap_token();

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
+        grab_swap_token(); /* Contend for token _before_ we read-in */
         swapin_readahead(entry, address, vma);
         page = read_swap_cache_async(entry, vma, address);
        if (!page) {
@@ -1991,7 +1992,6 @@ static int do_swap_page(struct mm_struct
        /* Had to read the page from swap area: Major fault */
        ret = VM_FAULT_MAJOR;
        count_vm_event(PGMAJFAULT);
-        grab_swap_token();
    }

    delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
-- 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
