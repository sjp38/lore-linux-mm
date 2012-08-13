Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 7A8186B0083
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 07:17:19 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 13 Aug 2012 21:16:33 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7DBHE3c2162866
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:17:14 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7DBHDXL004094
	for <linux-mm@kvack.org>; Mon, 13 Aug 2012 21:17:13 +1000
Message-ID: <5028E237.8020504@linux.vnet.ibm.com>
Date: Mon, 13 Aug 2012 19:17:11 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 11/12] thp: use khugepaged_enabled to remove duplicate code
References: <5028E12C.70101@linux.vnet.ibm.com>
In-Reply-To: <5028E12C.70101@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Use khugepaged_enabled to see whether thp is enabled

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6ddf671..6becf6c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -102,10 +102,7 @@ static int set_recommended_min_free_kbytes(void)
 	unsigned long recommended_min;
 	extern int min_free_kbytes;

-	if (!test_bit(TRANSPARENT_HUGEPAGE_FLAG,
-		      &transparent_hugepage_flags) &&
-	    !test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
-		      &transparent_hugepage_flags))
+	if (!khugepaged_enabled())
 		return 0;

 	for_each_populated_zone(zone)
@@ -228,11 +225,7 @@ static ssize_t enabled_store(struct kobject *kobj,
 			ret = err;
 	}

-	if (ret > 0 &&
-	    (test_bit(TRANSPARENT_HUGEPAGE_FLAG,
-		      &transparent_hugepage_flags) ||
-	     test_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
-		      &transparent_hugepage_flags)))
+	if (ret > 0 && khugepaged_enabled())
 		set_recommended_min_free_kbytes();

 	return ret;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
