Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 387D76B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 13:27:09 -0500 (EST)
Received: by wiwl15 with SMTP id l15so2180429wiw.5
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:27:08 -0800 (PST)
Received: from mail-we0-x22c.google.com (mail-we0-x22c.google.com. [2a00:1450:400c:c03::22c])
        by mx.google.com with ESMTPS id cq1si4967298wib.21.2015.02.27.10.27.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Feb 2015 10:27:07 -0800 (PST)
Received: by wesq59 with SMTP id q59so22052818wes.1
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:27:07 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH] mm: set khugepaged_max_ptes_none by 1/8 of HPAGE_PMD_NR
Date: Fri, 27 Feb 2015 20:26:48 +0200
Message-Id: <1425061608-15811-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

Using THP, programs can access memory faster, by having the
kernel collapse small pages into large pages. The parameter
max_ptes_none specifies how many extra small pages (that are
not already mapped) can be allocated when collapsing a group
of small pages into one large page.

A larger value of max_ptes_none can cause the kernel
to collapse more incomplete areas into THPs, speeding
up memory access at the cost of increased memory use.
A smaller value of max_ptes_none will reduce memory
waste, at the expense of collapsing fewer areas into
THPs.

The problem was reported here:
https://bugzilla.kernel.org/show_bug.cgi?id=93111

Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/huge_memory.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e08e37a..497fb5a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -59,11 +59,10 @@ static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
 static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
 /*
- * default collapse hugepages if there is at least one pte mapped like
- * it would have happened if the vma was large enough during page
- * fault.
+ * The default value should be a compromise between memory use and THP speedup.
+ * To collapse hugepages, unmapped ptes should not exceed 1/8 of HPAGE_PMD_NR.
  */
-static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR-1;
+static unsigned int khugepaged_max_ptes_none __read_mostly = HPAGE_PMD_NR/8;
 
 static int khugepaged(void *none);
 static int khugepaged_slab_init(void);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
