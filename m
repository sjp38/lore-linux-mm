Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71C8E6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 00:57:38 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so420301015pgd.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:57:38 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id d23si17946620plj.286.2016.12.05.21.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 21:57:37 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id f188so144946743pgc.3
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:57:37 -0800 (PST)
Date: Mon, 5 Dec 2016 21:57:34 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: add three more cond_resched() in swapoff
Message-ID: <alpine.LSU.2.11.1612052155140.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

Add a cond_resched() in the unuse_pmd_range() loop (so as to call
it even when pmd none or trans_huge, like zap_pmd_range() does);
and in the unuse_mm() loop (since that might skip over many vmas).
shmem_unuse() and radix_tree_locate_item() look good enough already.

Those were the obvious places, but in fact the stalls came from
find_next_to_unuse(), which sometimes scans through many unused
entries.  Apply scan_swap_map()'s LATENCY_LIMIT of 256 there too;
and only go off to test frontswap_map when a used entry is found.

Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/swapfile.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

--- 4.9-rc8/mm/swapfile.c	2016-11-13 11:44:43.056622549 -0800
+++ linux/mm/swapfile.c	2016-12-05 20:03:04.937152051 -0800
@@ -1234,6 +1234,7 @@ static inline int unuse_pmd_range(struct
 
 	pmd = pmd_offset(pud, addr);
 	do {
+		cond_resched();
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
 			continue;
@@ -1313,6 +1314,7 @@ static int unuse_mm(struct mm_struct *mm
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->anon_vma && (ret = unuse_vma(vma, entry, page)))
 			break;
+		cond_resched();
 	}
 	up_read(&mm->mmap_sem);
 	return (ret < 0)? ret: 0;
@@ -1350,15 +1352,12 @@ static unsigned int find_next_to_unuse(s
 			prev = 0;
 			i = 1;
 		}
-		if (frontswap) {
-			if (frontswap_test(si, i))
-				break;
-			else
-				continue;
-		}
 		count = READ_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
-			break;
+			if (!frontswap || frontswap_test(si, i))
+				break;
+		if ((i % LATENCY_LIMIT) == 0)
+			cond_resched();
 	}
 	return i;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
