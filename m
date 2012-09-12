Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 06C0D6B00CE
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 08:56:26 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 12 Sep 2012 22:55:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q8CCkqvU22216930
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:46:52 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q8CCu8BR017341
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 22:56:08 +1000
Message-ID: <50508666.90605@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2012 20:56:06 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] thp: fix forgetting to reset the page alloc indicator
References: <50508632.9090003@linux.vnet.ibm.com>
In-Reply-To: <50508632.9090003@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

If NUMA is enabled, the indicator is not reset if the previous page
request is failed, then it will trigger the VM_BUG_ON in khugepaged_alloc_page

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/huge_memory.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e366ca5..66d2bc6 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1825,6 +1825,7 @@ static bool khugepaged_prealloc_page(struct page **hpage, bool *wait)
 			return false;

 		*wait = false;
+		*hpage = NULL;
 		khugepaged_alloc_sleep();
 	} else if (*hpage) {
 		put_page(*hpage);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
