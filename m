Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6C89A6B0035
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 22:21:10 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id q58so6757189wes.4
        for <linux-mm@kvack.org>; Sun, 27 Jul 2014 19:21:09 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id bq1si10911641wib.82.2014.07.27.19.21.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 27 Jul 2014 19:21:08 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zhong@linux.vnet.ibm.com>;
	Mon, 28 Jul 2014 03:21:07 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id B282B17D8063
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 03:22:29 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6S2Kl7323265446
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 02:20:48 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6S2KlNf001077
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 20:20:47 -0600
Message-ID: <1406514043.2941.6.camel@TP-T420>
Subject: [PATCH v2]mm: fix potential infinite loop in
 dissolve_free_huge_pages()
From: Li Zhong <zhong@linux.vnet.ibm.com>
Date: Mon, 28 Jul 2014 10:20:43 +0800
In-Reply-To: <20140724124511.GA14379@nhori>
References: <1406194585.2586.15.camel@TP-T420>
	 <20140724124511.GA14379@nhori>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nadia.yvette.chambers@gmail.com>

It is possible for some platforms, such as powerpc to set HPAGE_SHIFT to
0 to indicate huge pages not supported. 

When this is the case, hugetlbfs could be disabled during boot time:
hugetlbfs: disabling because there are no supported hugepage sizes

Then in dissolve_free_huge_pages(), order is kept maximum (64 for
64bits), and the for loop below won't end:
for (pfn = start_pfn; pfn < end_pfn; pfn += 1 << order)

As suggested by Naoya, below fix checks hugepages_supported() before
calling dissolve_free_huge_pages().

Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 469bbf5..f642701 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1695,7 +1695,8 @@ repeat:
 	 * dissolve free hugepages in the memory block before doing offlining
 	 * actually in order to make hugetlbfs's object counting consistent.
 	 */
-	dissolve_free_huge_pages(start_pfn, end_pfn);
+	if (hugepages_supported())
+		dissolve_free_huge_pages(start_pfn, end_pfn);
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
