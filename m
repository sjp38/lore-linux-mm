Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89CAFC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:24:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44453217F4
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:24:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eAyFUgUu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44453217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 421436B0003; Tue, 16 Jul 2019 17:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ABDC8E0003; Tue, 16 Jul 2019 17:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 224218E0001; Tue, 16 Jul 2019 17:24:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id EEE706B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:24:47 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d11so18157329qkb.20
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 14:24:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=2wgQ6fTRz8YVKlsgVYdX5VKS/93WfCC6IDxOgquvAIU=;
        b=tsevpAjUYJ0w2pDOB+FVS/xyR0uOjBzRC32c0lCDv7Gl7z3uhCL0UH/UM+RiDSw/7B
         OGkncPH4sc6oHkrC02Wz92ZFyeaFBlqB2d/j8/RuMJeRErsnqRxiQ9a6FLxQYqI7vaXg
         fDvtuodawyFyl9q2xx31yh5r9KtgEqrnxdpUtIRN2SuV7I3QJ/vqIt28M8vSoAcP3Ql7
         5rckqR6fTn/6S1k0cD+4u9yAJISd8/Q43gsTUfDzkYTpY9lL6SVFGTd3QlaPnUzCz3vK
         +VTdDSaIma2a1DwTiUIrgaTTOMGKDAiwuMTmraANYqx1Rw40qSMOvq3j0CWq+P0quzhj
         nqow==
X-Gm-Message-State: APjAAAXGYair+X/SW/LQyHoMCshBUWlM8eE2t7OOWvzcLLoZzq8nyUPS
	ngvCgAWM0Qa4FyBi9DxtSOI9aDfg7Qo+vOOZQhctF4/bPpg9HKEBN7fYYsXqnF+VmtF5k3f9XSR
	PdgRmCilgM3b3gCvWvrrgJo9Wu+2j2ovMKqkiC6iGYXmdThxs4GGKR+PAXbsWfnrBAQ==
X-Received: by 2002:ac8:26d5:: with SMTP id 21mr24508070qtp.266.1563312287721;
        Tue, 16 Jul 2019 14:24:47 -0700 (PDT)
X-Received: by 2002:ac8:26d5:: with SMTP id 21mr24508040qtp.266.1563312287214;
        Tue, 16 Jul 2019 14:24:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563312287; cv=none;
        d=google.com; s=arc-20160816;
        b=whXi6U2QNLn/SC4GDM324cWQbnMaSdgfuL09DRkZwpEzmBN5urXiPkkcecvlThi5sC
         zDepdi8/ToKMGY9V4Sf5yFXQvDNvPw4yFdVVEvFL9LrkNpgvBRzZkMXf6MhjkcPwLq7I
         u1HD7kOASO+VJ9yw1tUENQa1StKQEicOHlLv97v2VwxsXMXc/y2eh8L/VhfHBhFv/eX5
         yDLo7pkpDfP24+L6iH5QazSEo5NuMYqyO80Nxl/XV0RiZ5UN59viRORgwI/Fl51hbVua
         4SUz4tqKxmvxaqx3RnInTmlpXDaiSFzkhqMRBEvd8h5dg9RY/SxE7LM6rptg55PLfW6v
         5qsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=2wgQ6fTRz8YVKlsgVYdX5VKS/93WfCC6IDxOgquvAIU=;
        b=YYlTqCbtzdb0Pq2tSNGcQ4YBf2rEmTwYHHVE5E0VexhLkFqth0zor37kKYLm7RurC9
         qK90+m7HFfALqcpT73zWpGUuG7qJi1XPMdi94OG9mTNUbUJygLd59MQnjGpP5nvexgj3
         L7U++UXPojmJe1oF9mi/DLBwuh+Qce4nQmyPIrJyOrKBGdC3Glg8Ex2J1vqowxrwCGvu
         Wb/EBA3LBafG6pmKMMxbEpXlZItoNIMiE01pf1h1DZIwQsX+Zs9ycmnhL+s/rYlBgYQV
         +Dkfub+cLyNFHQZstQSS3+VVJkMoxOhYE1v0QWxjw/n++19ThBBPmU8zLgPOlFKpADax
         ry0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eAyFUgUu;
       spf=pass (google.com: domain of 3nkauxqykcmcb7cun1t11tyr.p1zyv07a-zzx8npx.14t@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nkAuXQYKCMcB7Cun1t11tyr.p1zyv07A-zzx8npx.14t@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d15sor13114246qkk.175.2019.07.16.14.24.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 14:24:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3nkauxqykcmcb7cun1t11tyr.p1zyv07a-zzx8npx.14t@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eAyFUgUu;
       spf=pass (google.com: domain of 3nkauxqykcmcb7cun1t11tyr.p1zyv07a-zzx8npx.14t@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3nkAuXQYKCMcB7Cun1t11tyr.p1zyv07A-zzx8npx.14t@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=2wgQ6fTRz8YVKlsgVYdX5VKS/93WfCC6IDxOgquvAIU=;
        b=eAyFUgUuhZtkGf735osAhmhEOFvr3JINPaEutas0ADwVueaiB44EIy1B1MwHy11cK9
         AI1n6V9SXRhvQnDpsUlL+hC884VzfZ+3tyiWjrW7YnBgWlWVHtyyBE4TxoZjXWDYZYjm
         p78rN0UOy/ft76DhLFL+oaCZTdrlcW41XPaNdpNhi5Cira/vfd0jfbVk+80oVrbqgT28
         makPjbEDLZNg0s0AF4Dej0l4JiX9eMkEc07DNLilO3Uw26CoMEHSt+CIKzrojmW1TBYd
         0eGcJ4qok9OAk2AkcENuCT95km6BwOGiMrb2zhQIq7RIj+CbptOxahEyZcUPn2ykINAR
         QepQ==
X-Google-Smtp-Source: APXvYqxWSZMAIjSYZTED5PDBoHzrS/JaWeubuVN7NgOTm8ki1Xt/BMtbMdWV8FD3ncWZnn00SKBIe2ebHiI=
X-Received: by 2002:a37:b741:: with SMTP id h62mr23551088qkf.490.1563312286773;
 Tue, 16 Jul 2019 14:24:46 -0700 (PDT)
Date: Tue, 16 Jul 2019 15:24:36 -0600
Message-Id: <20190716212436.7137-1-yuzhao@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
Subject: [PATCH] mm: replace list_move_tail() with add_page_to_lru_list_tail()
From: Yu Zhao <yuzhao@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@suse.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, 
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>, Matthew Wilcox <willy@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Peng Fan <peng.fan@nxp.com>, Ira Weiny <ira.weiny@intel.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Yu Zhao <yuzhao@google.com>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a cleanup patch that replaces two historical uses of
list_move_tail() with relatively recent add_page_to_lru_list_tail().

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 mm/swap.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index ae300397dfda..0226c5346560 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -515,7 +515,6 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 	del_page_from_lru_list(page, lruvec, lru + active);
 	ClearPageActive(page);
 	ClearPageReferenced(page);
-	add_page_to_lru_list(page, lruvec, lru);
 
 	if (PageWriteback(page) || PageDirty(page)) {
 		/*
@@ -523,13 +522,14 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 		 * It can make readahead confusing.  But race window
 		 * is _really_ small and  it's non-critical problem.
 		 */
+		add_page_to_lru_list(page, lruvec, lru);
 		SetPageReclaim(page);
 	} else {
 		/*
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		add_page_to_lru_list_tail(page, lruvec, lru);
 		__count_vm_event(PGROTATED);
 	}
 
@@ -844,17 +844,15 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 		get_page(page_tail);
 		list_add_tail(&page_tail->lru, list);
 	} else {
-		struct list_head *list_head;
 		/*
 		 * Head page has not yet been counted, as an hpage,
 		 * so we must account for each subpage individually.
 		 *
-		 * Use the standard add function to put page_tail on the list,
-		 * but then correct its position so they all end up in order.
+		 * Put page_tail on the list at the correct position
+		 * so they all end up in order.
 		 */
-		add_page_to_lru_list(page_tail, lruvec, page_lru(page_tail));
-		list_head = page_tail->lru.prev;
-		list_move_tail(&page_tail->lru, list_head);
+		add_page_to_lru_list_tail(page_tail, lruvec,
+					  page_lru(page_tail));
 	}
 
 	if (!PageUnevictable(page))
-- 
2.22.0.510.g264f2c817a-goog

