Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68A07C28CC1
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23E7D26529
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:22:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="k++TxmTq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23E7D26529
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAB076B0298; Sat,  1 Jun 2019 09:22:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5CB56B029A; Sat,  1 Jun 2019 09:22:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72696B029B; Sat,  1 Jun 2019 09:22:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 700426B0298
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:22:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i33so8234063pld.15
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:22:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sRgs2ljSsTtmaQQ5TK/ttAqLLvUR4E4RyPcBlDdK7Zw=;
        b=S96KIkCc8VrP4ohKyJ0AZgUZnQtPn5stFPygBKuhzszDF55+2T+Qr9w+zNAhstq+B0
         hQ1eOsm2pK2Hi6xYgoHsTplx/dzJKpvXsMbM+KxtWRMH3R6HUX60NTp67e3pYA3fKojO
         M/CK41ktWDuRbxoA2sOwMceXM7ijltz1XfOSJnI3zO4fiU8eyKy8EBxJ3srXlXiRVtqX
         w7usCLqiXc8ijRmXdRj3iaE20Zz1KEFgsvZGsXpQfvkTVN/YKMKToBcfWnQYKTk6hEH9
         n6av8Q/bbd4axi1tNUzXuGLN2i5R/Dn9Bnw/9byiMe/sS2MNNQK1G4FkpYdLu3iYveBt
         pQsA==
X-Gm-Message-State: APjAAAW8msRqjC4EaLKWX2krEms58o6AmID8POolInfdrVNw+37Q7Tdp
	gisP83x5mXRu6YmtK/JcRIxKHR4esFolpmaPddhUkFkuVARhmNc3/Oog3PxSPFrzP/6CdIqO4B/
	8DUr8xxzCxxIxgdZhmhDiifhBruPyssXwedEHWe3lnqSHjsq/9n1zksWFyNXJ0vD09w==
X-Received: by 2002:a63:2315:: with SMTP id j21mr15477300pgj.414.1559395353063;
        Sat, 01 Jun 2019 06:22:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiezTqF6YO0B0u6u/L3k6TVnTgvzl7usRyyCWoAZRhwuS1a3E6w6C1U8JVkK+VT31Ff0Xc
X-Received: by 2002:a63:2315:: with SMTP id j21mr15477221pgj.414.1559395352340;
        Sat, 01 Jun 2019 06:22:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395352; cv=none;
        d=google.com; s=arc-20160816;
        b=PAQJf20ACiZxJYWCQHtZ9AyK0dI2DI1bZwnAkXcjuRxK60mGPg9A/3iJxzrg+iapz6
         WJHSRzG+jmV+WnsPCBGU/YFNZNXjO7sfcDISwJMOvQ6nL1sQYKEamKuk903rpeRADOOR
         Z1yILF8uUotbpdeZtMBWnvhFkGykqDJNKw/MEEWUDvM5O4f28CZbdvPyZCNu99n7ZAZq
         63njvMpn9KZ0SxTA9yPDra+EBOu+xWmKxkgXg4EdC7yq+c6kafbK1uLfpm2po2CxGaiC
         ucclB61/sk0HB2i6L+Jv21PlCSwoKXADBP3ttdN6FXZbev8lCDW1bpRnKRHBoW73jTkp
         BD2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sRgs2ljSsTtmaQQ5TK/ttAqLLvUR4E4RyPcBlDdK7Zw=;
        b=w+CArJwMowMyv3QIbKQWJ5GD55MzdSnFDaNelW5EDUHzPu9E4b+DHpKjVeUa+m4UbP
         jCwmySBOLtAJ8SQW3rUG+FZX9uBwv6JdO2iNdGexdSyWswmyxAiyK/R+04noSYhO2sgy
         4U63beK0xLJfEI33IiySdRoUnpDns4kVWWYOgaEIYKBAwg/PAWwBPIDvb6YBBb9PmCWk
         TZt1polCPUJYgWJk14paeYL7sj20nFF/CXAGMWgZmqNQ+8xIdfotYMwS6ZVcuA3gcGwd
         gKbqQz32Lhi31/RvK9Jo9Np9mE7hF8RlNOYOFgMNmDshact3zWSQlFLBHNkfrXYXTxbl
         2bUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=k++TxmTq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c184si7984007pga.99.2019.06.01.06.22.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:22:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=k++TxmTq;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B4F26257AC;
	Sat,  1 Jun 2019 13:22:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395352;
	bh=l+1FgXVCwDDd/nfWypgYu8LPMfYlwzGqVMs7FqCUcss=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=k++TxmTqOfgRoPMC4rNUT3qizTnVE9/Voh+Nz8pplWOIiH1hZvi2fjEKcuutfFQzO
	 d4UlP1bIqtR3hOov13zjXBUtYpmvSLXH5Giil0XcYIcT8EsLHRLVC63YZA+v6paPSM
	 1SqVX4i9pOGO5iq5dVKdS/9s48T8TuJcFhrh/7NE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Yue Hu <huyue2@yulong.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ingo Molnar <mingo@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Laura Abbott <labbott@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 012/141] mm/cma.c: fix the bitmap status to show failed allocation reason
Date: Sat,  1 Jun 2019 09:19:48 -0400
Message-Id: <20190601132158.25821-12-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132158.25821-1-sashal@kernel.org>
References: <20190601132158.25821-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yue Hu <huyue2@yulong.com>

[ Upstream commit 2b59e01a3aa665f751d1410b99fae9336bd424e1 ]

Currently one bit in cma bitmap represents number of pages rather than
one page, cma->count means cma size in pages. So to find available pages
via find_next_zero_bit()/find_next_bit() we should use cma size not in
pages but in bits although current free pages number is correct due to
zero value of order_per_bit. Once order_per_bit is changed the bitmap
status will be incorrect.

The size input in cma_debug_show_areas() is not correct.  It will
affect the available pages at some position to debug the failure issue.

This is an example with order_per_bit = 1

Before this change:
[    4.120060] cma: number of available pages: 1@93+4@108+7@121+7@137+7@153+7@169+7@185+7@201+3@213+3@221+3@229+3@237+3@245+3@253+3@261+3@269+3@277+3@285+3@293+3@301+3@309+3@317+3@325+19@333+15@369+512@512=> 638 free of 1024 total pages

After this change:
[    4.143234] cma: number of available pages: 2@93+8@108+14@121+14@137+14@153+14@169+14@185+14@201+6@213+6@221+6@229+6@237+6@245+6@253+6@261+6@269+6@277+6@285+6@293+6@301+6@309+6@317+6@325+38@333+30@369=> 252 free of 1024 total pages

Obviously the bitmap status before is incorrect.

Link: http://lkml.kernel.org/r/20190320060829.9144-1-zbestahu@gmail.com
Signed-off-by: Yue Hu <huyue2@yulong.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/cma.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 6ce6e22f82d9c..476dfe13a701f 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -371,23 +371,26 @@ int __init cma_declare_contiguous(phys_addr_t base,
 #ifdef CONFIG_CMA_DEBUG
 static void cma_debug_show_areas(struct cma *cma)
 {
-	unsigned long next_zero_bit, next_set_bit;
+	unsigned long next_zero_bit, next_set_bit, nr_zero;
 	unsigned long start = 0;
-	unsigned int nr_zero, nr_total = 0;
+	unsigned long nr_part, nr_total = 0;
+	unsigned long nbits = cma_bitmap_maxno(cma);
 
 	mutex_lock(&cma->lock);
 	pr_info("number of available pages: ");
 	for (;;) {
-		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
-		if (next_zero_bit >= cma->count)
+		next_zero_bit = find_next_zero_bit(cma->bitmap, nbits, start);
+		if (next_zero_bit >= nbits)
 			break;
-		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		next_set_bit = find_next_bit(cma->bitmap, nbits, next_zero_bit);
 		nr_zero = next_set_bit - next_zero_bit;
-		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
-		nr_total += nr_zero;
+		nr_part = nr_zero << cma->order_per_bit;
+		pr_cont("%s%lu@%lu", nr_total ? "+" : "", nr_part,
+			next_zero_bit);
+		nr_total += nr_part;
 		start = next_zero_bit + nr_zero;
 	}
-	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	pr_cont("=> %lu free of %lu total pages\n", nr_total, cma->count);
 	mutex_unlock(&cma->lock);
 }
 #else
-- 
2.20.1

