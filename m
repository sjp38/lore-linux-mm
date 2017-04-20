Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 21EA62806D2
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:16 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id a103so53472879ioj.8
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:26:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x9si5798756pgo.51.2017.04.20.02.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 02:26:15 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3K9O37Z073765
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:14 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29xmw4w81d-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 05:26:14 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 20 Apr 2017 10:26:08 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [RFC 1/2] mm: Uncharge poisoned pages
Date: Thu, 20 Apr 2017 11:26:01 +0200
In-Reply-To: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1492680362-24941-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1492680362-24941-2-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

When page are poisoned, they should be uncharged from the root memory
cgroup.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 mm/memory-failure.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 27f7210e7fab..00bd39d3d4cb 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -530,6 +530,7 @@ static const char * const action_page_types[] = {
 static int delete_from_lru_cache(struct page *p)
 {
 	if (!isolate_lru_page(p)) {
+		memcg_kmem_uncharge(p, 0);
 		/*
 		 * Clear sensible page flags, so that the buddy system won't
 		 * complain when the page is unpoison-and-freed.
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
