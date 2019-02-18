Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F14D8C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B94ED217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B94ED217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0418E0008; Mon, 18 Feb 2019 16:07:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1F18E0002; Mon, 18 Feb 2019 16:07:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 569C88E0008; Mon, 18 Feb 2019 16:07:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 02E8F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:42 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id s5so8094933wrp.17
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WMV4Y+Xxwx0amh79b7ogT26X55X7KS8eKOuS0jAVMLw=;
        b=msLeedaXi6T3llmVK1F3Gt+CRXpBKGOTNY8XljBxnI52DP3LBgv+W+/JTvfxtLdryw
         EgjDeB9nq5wlk9+74Dc5nAxnC333s0uKh8gprscZGPVOMc6Iro5OK/oe6Vv+jafm8CzN
         FvVVgnME9qKYDGxryOXVVSZBQTvFHqAT2PJ4QoxTl+9n5LtyguxWD202by0b/MDHnPhk
         ZXkB/55GqMBRjshwz6uvigdymKpPNMGT/7QhYtsQ8Qy0kFBcuZos8rcJdAQlUkpiYCLJ
         c2oDtZuorUFDhN7XPnNnA5MthNCYkeRb5m+9jLvZskXpvgnE2WHEt4GiFmRzK1Z09ga6
         3hLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAubKxyB1AAxTMud7PeyFvTKPHLqnMSnbDUjlxnXqDOGEfUdsLCO6
	hlDDDEbT2ooIbgEp8YxuQG/hxRmppvShvGr35hU17cxPrKFo7++weR8yRgs10TDBLWxC9kCyxXi
	P6j+1Lc/O7paYdyEyN82/EtnX3TY2asBgB41WMChHiTovpW4TpIBu7kuySR3KvL7kqQ==
X-Received: by 2002:a1c:cf82:: with SMTP id f124mr458126wmg.95.1550524061526;
        Mon, 18 Feb 2019 13:07:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcJcCenvcMS+ro+i37t+yB4OCXSx7E57ie+fUKpkVgijfBBpMzEEaqp2aCFYBY/MMCFPRv
X-Received: by 2002:a1c:cf82:: with SMTP id f124mr458098wmg.95.1550524060639;
        Mon, 18 Feb 2019 13:07:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524060; cv=none;
        d=google.com; s=arc-20160816;
        b=yk6lq7ViewrbeqyxPD/Fg5aucxkjMY6VnjUQQZKgsNNuxbQ0iLBokw6VunyFifAu0d
         sLq2MOAs7sJMkch+lGlLFcrdOqTVDlQbHhlWrd6wgsJPEn2Bjp6qWVMCcsCJtb9Ewwtk
         nH9w0hSWh7NsCSuIyUTgOmgfo5tlcO9oVkLN+GfiGsWzLytMZTyLQXSf0681KYIH3DGX
         OgRSkdtcyIEfJnqYepzM6yzcVYn6WLqs3Oe4ICnlyZ1KMhQKDsU2k/a2NhxtawKSEcPN
         phNfSgEpUmBosh0lmxaF78XOOLznylAHIBrJNfjoMLGXPscabEmZmNJd7JhBRUcX0Sx1
         DqKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=WMV4Y+Xxwx0amh79b7ogT26X55X7KS8eKOuS0jAVMLw=;
        b=uPyO7omhmOxbkuVqy4Hgf7SnAbFy+cRzqtRZ4VSuwWpb39yXFphNh8B57ftUi6bkyD
         rNPxnWMOjnIAQ2YqwEvo+Q8a2iECWembLVm9L8oP5tUVTxs23cBfjc1SHoHUq5t5bReA
         E2Q3K+GmwD72UDcdIUONS7NPRStwZxxrMjjJwA4k/kWmmjtJJpuHCJnaG23plwwNVjN6
         Zya1vnXlkzaAAns7CfGV7nnwCMERfSNhcglZ4tTsD1UbSsjBzxJ0SQRa9eY31xpjYlXy
         dqmVJmuh3nfbrK5E1ts/HBnGQtaE6TDOPJIDCuqxsrBIauWaS/uj2fv7aMz+6mqhZ1ZG
         tIWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id s15si4528892wrt.209.2019.02.18.13.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:40 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id 2AB6027F9AB
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 5/6] page_isolation: Propagate temporary pageblock isolation error
Date: Mon, 18 Feb 2019 16:07:14 -0500
Message-Id: <20190218210715.1066-6-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If the page isolation failed because of racing the setup of the pages
migrate type, it is very likely that a further attempt will succeed. In
this case, instead of -EBUSY, return -EAGAIN, to let callers handle this
condition properly.

Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
---
 mm/page_isolation.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index ce323e56b34d..a8169d8ea02d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -30,10 +30,12 @@ static int set_migratetype_isolate(struct page *page, int migratetype, int isol_
 	/*
 	 * We assume the caller intended to SET migrate type to isolate.
 	 * If it is already set, then someone else must have raced and
-	 * set it before us.  Return -EBUSY
+	 * set it before us.  Return -EAGAIN
 	 */
-	if (is_migrate_isolate_page(page))
+	if (is_migrate_isolate_page(page)) {
+		ret = -EAGAIN;
 		goto out;
+	}
 
 	pfn = page_to_pfn(page);
 	arg.start_pfn = pfn;
@@ -188,6 +190,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	unsigned long pfn;
 	unsigned long undo_pfn;
 	struct page *page;
+	int ret = -EBUSY;
 
 	BUG_ON(!IS_ALIGNED(start_pfn, pageblock_nr_pages));
 	BUG_ON(!IS_ALIGNED(end_pfn, pageblock_nr_pages));
@@ -196,10 +199,13 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	     pfn < end_pfn;
 	     pfn += pageblock_nr_pages) {
 		page = __first_valid_page(pfn, pageblock_nr_pages);
-		if (page &&
-		    set_migratetype_isolate(page, migratetype, flags)) {
-			undo_pfn = pfn;
-			goto undo;
+		if (page) {
+			ret = set_migratetype_isolate(page, migratetype,
+						      flags);
+			if (ret) {
+				undo_pfn = pfn;
+				goto undo;
+			}
 		}
 	}
 	return 0;
@@ -213,7 +219,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		unset_migratetype_isolate(page, migratetype);
 	}
 
-	return -EBUSY;
+	return ret;
 }
 
 /*
-- 
2.20.1

