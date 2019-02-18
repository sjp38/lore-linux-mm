Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE7BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2343E217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2343E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF96E8E0007; Mon, 18 Feb 2019 16:07:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA8C08E0002; Mon, 18 Feb 2019 16:07:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABF198E0007; Mon, 18 Feb 2019 16:07:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59A468E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:38 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id f5so8342628wrt.13
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I00cjU5zXSQrlQOQ0zaNYv7UvzPZwT0wOJkS62bsHzU=;
        b=pqBYtW8v1ArUoGUZUoNqwaibZ3J6SWbdwdTamy5CLNBCcTlNTC5IbVcTV0Fcmrikc3
         L0ZEvV6V/IG0Eay3hdMOtl44u6wwUTsfnR/IcdDNNKyNgOih5WVlj40Te1KYgjhZUY53
         nGEzMfsR9bSdobojE4mN/r8TvJ8xYzHhYizXxL5COybOg6dbWMXcIuOgfbDAbk5X7/tQ
         ewqpGEdyhnAkbe9Bep0UMCwCSCNQmTVbzPnzrdzx/Hrs1cvTcP+BRE1a3SJl5ZSld5nU
         UPMzOgRgV6wWRZD2SroIUsqHEC4v8dind/aBCAglhjJd+1E/3697P/e/bfyr//FksSx7
         GCrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuaR4wJd6zB2+9wUx6zsanIQ/Y04mdsHni4qB/LIA9XWXRLd+I5f
	vGn5d+octjErGB3mJ+CnBac0XO7nTpY/JOpPwKXd8AcGCqPuE/Jzwo6cVhNih0KOaM3s/3mS76I
	9BGQ1Wk1+JJF+fnbn1ABQp23BOcp46xPncp5sb2ty9eLlo38FsP3yPAbKQv7b6G/jpg==
X-Received: by 2002:a05:600c:2:: with SMTP id g2mr443478wmc.109.1550524057890;
        Mon, 18 Feb 2019 13:07:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYA5h7fDWvn5KVmfqCjtEuhBYlX0NZFfQkC9g6ann8iAiHWXsCYa4mWKyBkC9dZ07ky34uI
X-Received: by 2002:a05:600c:2:: with SMTP id g2mr443442wmc.109.1550524056880;
        Mon, 18 Feb 2019 13:07:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524056; cv=none;
        d=google.com; s=arc-20160816;
        b=EAbIU76zq6UX+M5gmVUu1WaCFbDt2/3ropBJaczo901XPzogOrj2koIUR628Afao/2
         kGArYVSU/F5vP4iKh8msLyULJ/GoExYn2a14MxaEp9EzfLi+8gzyinfZcoNh6Ovf3O/m
         yQCWXZgX2zxoxSwiTa8qd0y4tQKyHXb1H48OrLbWZfeAUeWrieZ3uCTKxE4+Hsen3ffI
         5kfwh+QoYuZemP0dwmJSxDwW43AWRUFpQXAyW1+nHXa0khrrE1egy2Cj1D4LMHGivs6k
         o6uX+l1ID7aNtFU3CJGSELD/uh5vbX0RrbeUpimMPYzWSlC0htZaE4uvOjrXJ+FybeMf
         kUag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=I00cjU5zXSQrlQOQ0zaNYv7UvzPZwT0wOJkS62bsHzU=;
        b=p+GTpNrF0Lz+VpwlVYJ/5W47aCIaocjJiOQ8V3YRsCE6DWp5W4Gq9+UCjrAztj7YsF
         riyWPTB3e2Uttu86TEW4w9eXABYgmfp//KoY/G0yoK9UpaOkU9JPf9BkYffWZdk3HNFB
         o4i6Kg1GpoM74E7do0tdQG77Oa8drH1q4EqXzRNfQi08XpzxNKv2+TO7kDsLiF+U3RPk
         6KCk7y064CwMUlSUKL2OJf04M4ENlOpwtOvKTjf5Ui/V4iRZ9eYIhK1sja7Rcb9qZkG8
         R1t7xA/CP1rPOxngpfd41EDFMHqNHFOeD88GefezYACjq1Uug9AI2IC1fba3EIknJjwW
         2Rog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id y22si13866060wrd.342.2019.02.18.13.07.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:36 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id 64ABA27FD49
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 4/6] cma: Add support for GFP_ZERO
Date: Mon, 18 Feb 2019 16:07:13 -0500
Message-Id: <20190218210715.1066-5-krisman@collabora.com>
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

Since cma_alloc now has gfp_mask, make it honor GFP_ZERO, to not suprise
potential users.

Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
---
 mm/cma.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 5789e3545faf..1dff74b1a8c5 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -408,12 +408,13 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	unsigned long start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
 	size_t i;
+	void *kaddr;
 	struct page *page = NULL;
 	int ret = -ENOMEM;
 
 	/* Be noisy about caller asking for unsupported flags. */
 	WARN_ON(unlikely(!(gfp_mask & __GFP_DIRECT_RECLAIM) ||
-			 (gfp_mask & (__GFP_ZERO|__GFP_NOFAIL))));
+			 (gfp_mask & __GFP_NOFAIL)));
 
 	if (!cma || !cma->count)
 		return NULL;
@@ -477,8 +478,15 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	 * those page blocks.
 	 */
 	if (page) {
-		for (i = 0; i < count; i++)
+		for (i = 0; i < count; i++) {
 			page_kasan_tag_reset(page + i);
+
+			if (gfp_mask & __GFP_ZERO) {
+				kaddr = kmap_atomic(page + i);
+				clear_page(kaddr);
+				kunmap_atomic(kaddr);
+			}
+		}
 	}
 
 	if (ret && !(gfp_mask & __GFP_NOWARN)) {
-- 
2.20.1

