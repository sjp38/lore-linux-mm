Return-Path: <SRS0=zwjV=WV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62A32C3A5A3
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24A5522CE9
	for <linux-mm@archiver.kernel.org>; Sun, 25 Aug 2019 00:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aLhNaLvV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24A5522CE9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C52DE6B0503; Sat, 24 Aug 2019 20:55:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB45F6B0505; Sat, 24 Aug 2019 20:55:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACB076B0506; Sat, 24 Aug 2019 20:55:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0063.hostedemail.com [216.40.44.63])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8196B0503
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 20:55:02 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 27724824CA26
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:02 +0000 (UTC)
X-FDA: 75859130844.29.war53_49021fcfe6006
X-HE-Tag: war53_49021fcfe6006
X-Filterd-Recvd-Size: 2917
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 25 Aug 2019 00:55:01 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 628DA22CF7;
	Sun, 25 Aug 2019 00:55:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566694500;
	bh=5HYpnWuJ3nYcHULbN9ZEAdHlX5aKAAA5am09MKUmBjA=;
	h=Date:From:To:Subject:From;
	b=aLhNaLvVpRCMyKWPS+iYJ4gyE6kwGv3jDwTeIz1IrsW1/fP0VN9CV49gFl3CmXlzY
	 j5/s+PCUithPry/y3C3Db1zr3Q5e7MVIC7L+J8dQb+bPuJnTpofO5KmeVYujBmYO1g
	 Ic3xuUsTnOQYyvi5KyV4HbMubgwDXDCZnriKnWaQ=
Date: Sat, 24 Aug 2019 17:54:59 -0700
From: akpm@linux-foundation.org
To: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org,
 mgorman@techsingularity.net, mhocko@kernel.org,
 mm-commits@vger.kernel.org, stable@vger.kernel.org,
 torvalds@linux-foundation.org, vbabka@suse.cz, willy@infradead.org
Subject:  [patch 08/11] mm, page_owner: handle THP splits correctly
Message-ID: <20190825005459.Ik4Bi2G1I%akpm@linux-foundation.org>
User-Agent: s-nail v14.8.16
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vlastimil Babka <vbabka@suse.cz>
Subject: mm, page_owner: handle THP splits correctly

THP splitting path is missing the split_page_owner() call that
split_page() has.  As a result, split THP pages are wrongly reported in
the page_owner file as order-9 pages.  Furthermore when the former head
page is freed, the remaining former tail pages are not listed in the
page_owner file at all.  This patch fixes that by adding the
split_page_owner() call into __split_huge_page().

Link: http://lkml.kernel.org/r/20190820131828.22684-2-vbabka@suse.cz
Fixes: a9627bc5e34e ("mm/page_owner: introduce split_page_owner and replace manual handling")
Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/huge_memory.c |    4 ++++
 1 file changed, 4 insertions(+)

--- a/mm/huge_memory.c~mm-page_owner-handle-thp-splits-correctly
+++ a/mm/huge_memory.c
@@ -32,6 +32,7 @@
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/page_owner.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2516,6 +2517,9 @@ static void __split_huge_page(struct pag
 	}
 
 	ClearPageCompound(head);
+
+	split_page_owner(head, HPAGE_PMD_ORDER);
+
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
 		/* Additional pin to swap cache */
_

