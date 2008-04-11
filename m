Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3BNZQag014078
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 19:35:26 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BNZKJU190134
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:35:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BNZKtA007327
	for <linux-mm@kvack.org>; Fri, 11 Apr 2008 17:35:20 -0600
Date: Fri, 11 Apr 2008 16:35:00 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH 1/3] mm: fix misleading __GFP_REPEAT related comments
Message-ID: <20080411233500.GA19078@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The definition and use of __GFP_REPEAT, __GFP_NOFAIL and __GFP_NORETRY
in the core VM have somewhat differing comments as to their actual
semantics. Annoyingly, the flags definition has inline and header
comments, which might be interpreted as not being equivalent. Just add
references to the header comments in the inline ones so they don't go
out of sync in the future. In their use in __alloc_pages() clarify that
the current implementation treats low-order allocations and __GFP_REPEAT
allocations as distinct cases.

To clarify, the flags' semantics are:

__GFP_NORETRY means try no harder than one run through __alloc_pages

__GFP_REPEAT means __GFP_NOFAIL

__GFP_NOFAIL means repeat forever

order <= PAGE_ALLOC_COSTLY_ORDER means __GFP_NOFAIL

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>

---
Andrew, would it be possible to give this patch and the following two a
spin in the next -mm?

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 898aa9d..b46b861 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -40,9 +40,9 @@ struct vm_area_struct;
 #define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
 #define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
-#define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
-#define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
-#define __GFP_NORETRY	((__force gfp_t)0x1000u)/* Do not retry.  Might fail */
+#define __GFP_REPEAT	((__force gfp_t)0x400u)	/* See above */
+#define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* See above */
+#define __GFP_NORETRY	((__force gfp_t)0x1000u)/* See above */
 #define __GFP_COMP	((__force gfp_t)0x4000u)/* Add compound page metadata */
 #define __GFP_ZERO	((__force gfp_t)0x8000u)/* Return zeroed page on success */
 #define __GFP_NOMEMALLOC ((__force gfp_t)0x10000u) /* Don't use emergency reserves */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 935ae16..1db36da 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1691,8 +1691,9 @@ nofail_alloc:
 	 * Don't let big-order allocations loop unless the caller explicitly
 	 * requests that.  Wait for some write requests to complete then retry.
 	 *
-	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL for order
-	 * <= 3, but that may not be true in other implementations.
+	 * In this implementation, either order <= PAGE_ALLOC_COSTLY_ORDER or
+	 * __GFP_REPEAT mean __GFP_NOFAIL, but that may not be true in other
+	 * implementations.
 	 */
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
