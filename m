Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lATLoFPd032198
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 16:50:15 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lATLmT5i124022
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 16:48:34 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lATLmTMC025299
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 16:48:29 -0500
Date: Thu, 29 Nov 2007 13:48:28 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] mm: fix confusing __GFP_REPEAT related comments
Message-ID: <20071129214828.GD20882@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The definition and use of __GFP_REPEAT, __GFP_NOFAIL and __GFP_NORETRY
in the core VM have somewhat differing comments as to their actual
semantics. Annoyingly, the flags definition has inline and header
comments, which might be interpreted as not being equivalent. Just add
references to the header comments in the inline ones so they don't go
out of sync in the future. In their use in __alloc_pages() clarify that
the current implementation treats low-order allocations and __GFP_REPEAT
allocations as distinct cases, albeit currently with the same result.

To clarify, the flags' semantics are:

__GFP_NORETRY means try no harder than one run through __alloc_pages

__GFP_REPEAT means __GFP_NOFAIL

__GFP_NOFAIL means repeat forever

order <= PAGE_ALLOC_COSTLY_ORDER means __GFP_NOFAIL

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

---

Andrew, I sent this patch in about a week ago, hoping for some responses
to the following questions, but didn't get any :/ Do you think you can
pull this into the next -mm? I am ok with waiting and reposting after
2.6.24, so that you can focus on stabilization, if you'd prefer.

>From the original e-mail:

I'm not sure if the clarified semantics are really desired, and am
hoping this patch clarifies that for me:

In looking at the callers using __GFP_REPEAT, not all handle failure --
should they be using __NOFAIL?

Should __GFP_REPEAT eventually be able to fail? That is, maybe it makes
sense to somehow monitor the success of reclaim? If we are able to free
an equivalent order of pages as requested but still can't allocate the
pages requested, then fail? This would at least allow *some* behavior
between NORETRY and NOFAIL... This would get closer to what I was trying
to achieve in my hugetlb-specific patch
(http://marc.info/?l=linux-mm&m=119515798913982&w=2) without such
specific changes.

Should __GFP_NORETRY mean no retrying anywhere? The default path through
the allocator, before we even check if we should or should not retry
appears to retry in some sense of the word. This is of less concern to
me than the other two, though.

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 7e93a9a..e4ed545 100644
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
index 4ffed1c..93c7a9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1599,8 +1599,9 @@ nofail_alloc:
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
