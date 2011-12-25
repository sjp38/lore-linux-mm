Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 439176B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 15:46:41 -0500 (EST)
Message-ID: <4EF78BAB.9030508@parallels.com>
Date: Mon, 26 Dec 2011 00:46:35 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mincore: Introduce the MINCORE_SWAP bit
References: <4EF78B6A.8020904@parallels.com>
In-Reply-To: <4EF78B6A.8020904@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

When a page is swapped out it should be included in the memory dump,
but the existing mincore() doesn't report the set bit for such pages.

Thus add a bit for swapped out pages.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/mman.h |    1 +
 mm/mincore.c         |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9d1de16..bfe4038 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -12,6 +12,7 @@
 
 #define MINCORE_RESIDENT	0x1
 #define MINCORE_ANON		0x2
+#define MINCORE_SWAP		0x4
 
 #ifdef __KERNEL__
 #include <linux/mm.h>
diff --git a/mm/mincore.c b/mm/mincore.c
index 3163dfb..82c5c3e 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -146,7 +146,7 @@ static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 			} else {
 #ifdef CONFIG_SWAP
 				pgoff = entry.val;
-				*vec = mincore_page(&swapper_space, pgoff);
+				*vec = mincore_page(&swapper_space, pgoff) | MINCORE_SWAP;
 #else
 				WARN_ON(1);
 				*vec = MINCORE_RESIDENT;
-- 
1.5.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
