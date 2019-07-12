Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B02C6C742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 22:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50433217D4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 22:22:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qSqUpYgx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50433217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 608638E016A; Fri, 12 Jul 2019 18:22:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BA0C8E0003; Fri, 12 Jul 2019 18:22:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A7ED8E016A; Fri, 12 Jul 2019 18:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 296D48E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 18:22:27 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id p193so4566683vkd.7
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 15:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=kEx1JTVWGnPw7PBaID0vQzLE5AVxmop4HrGd6+u6kxc=;
        b=IresLuSWYAY6PDmnZYLOXPxc5Sj7nz8/q4nlcGuhrjMBszJCb9royeoc38CkktMtFE
         ODnTURKY8Q7sDloiq1ytux6CfH7pVnULgDrJtFZS//vfBmXuZ52riDJwyhoXKa3Q5Hw4
         RGt5aStZ/WZn2OYOTqfTcYu+15Cq+BPKYRdo/wlpNrndMui9oYxZ+dwfQIdalgP95tqK
         /CN3fEoAgZ1HTIrjPGl5CS1BBldIipbbaVBhAFAo1k7Pg42hSsV3tuh5A01i0dCsIPkM
         kluJK+Q3kth544ekoxpLu0YnQIaef6aO7wFtmAO0Dpk8qCZpF57m/BIn7Kx0FDiWgm2f
         uesw==
X-Gm-Message-State: APjAAAUSEq8J1jyCoGotHPQlDyhWelN8fzjABg4zpYn93YUawfYLr77x
	J1h21QcjegTc/LcG/vyqHyDOwLGpyMQ+F4Z5xphGAJE+yS9pfJm40QHRkTyS0RJXT6XfKDH2b4R
	CWlauFNoAkJbXUQdYpd9xv1T+9IkSuzvteyb1cwHD5OQ9VTingJ7ieM/xjmpTUszAQg==
X-Received: by 2002:ab0:7782:: with SMTP id x2mr8491098uar.140.1562970146752;
        Fri, 12 Jul 2019 15:22:26 -0700 (PDT)
X-Received: by 2002:ab0:7782:: with SMTP id x2mr8491073uar.140.1562970146012;
        Fri, 12 Jul 2019 15:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562970146; cv=none;
        d=google.com; s=arc-20160816;
        b=SX/PTQBWiIM21SgvtI1b/WdV9dAZiSTN++lWdvk1+l6PaLNcwqyt7Zl8H3seRFHIZ4
         03W2WhCL4cO+1U30N3BhEUttm0YVwhZTi9x6/82utg5ZpbSPr4XTCjvfvxskn4VtGMTD
         8qPvAnGErNHlsFx0xDcB1Q9DLu9xEvur4zvDyXK24R4zStuoTqNT9TsPSJhX8jS0ee5K
         MYrAb72DYHdCvnwVTui2cCEvo245HW9DuqeCQpNXHkWw0k6sQ+E2fPG3Jy6RsBXhUxQd
         sGV3jFG9wT2RcU2Q3dDmjJAaKy289pTt5miG6AZrPRTzpgsmIvrEYBD1hK0otpE3Efgl
         hpoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=kEx1JTVWGnPw7PBaID0vQzLE5AVxmop4HrGd6+u6kxc=;
        b=l90JeNFn3xLmCPBQZsTIZgJTPd3AZUEpxau+mbr4ZgRiLtOqPPnc8XxfxDkWsxPMbi
         3osX+gYVICrLlecLHNJMNp+/KCTu02wYaTMbJ8CPTQTlmYKqhnwLUA5DiaGqhwswgBGS
         sFvAYnTNckms1PoH+SFnoHBfKePnm/9t3ctsCnkr6gaiMG90cS5AJatr6I47C5vjbqxm
         uj/8CeEn9TnUTDoHhcKDb2TsEgTgj4v73oPbF7hsqGQMtJEplE4LCiXeXAc/i7hHpRFQ
         owBroNFHfjCMab1ma8R1VF6DVnKHqDavqD4fN6icY6cvYjEF1K20x+qPuiou7VgbxN7B
         sKmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qSqUpYgx;
       spf=pass (google.com: domain of 3iqgpxqokcmqrox18l41x2qyyqvo.mywvsx47-wwu5kmu.y1q@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3IQgpXQoKCMQrox18l41x2qyyqvo.mywvsx47-wwu5kmu.y1q@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d188sor3141628vkf.72.2019.07.12.15.22.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 15:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3iqgpxqokcmqrox18l41x2qyyqvo.mywvsx47-wwu5kmu.y1q@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qSqUpYgx;
       spf=pass (google.com: domain of 3iqgpxqokcmqrox18l41x2qyyqvo.mywvsx47-wwu5kmu.y1q@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3IQgpXQoKCMQrox18l41x2qyyqvo.mywvsx47-wwu5kmu.y1q@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=kEx1JTVWGnPw7PBaID0vQzLE5AVxmop4HrGd6+u6kxc=;
        b=qSqUpYgxDFOWLl7WX5ZMCvv2dnzMaJCqPuNXx+1t+LERJgI7++uG0ZO8RDFLJAvyCI
         6vtlGj/aPA2PgSjWEt8UtsZ2xZdxNwmtf+811n5cci63SBJXhTeNlao84VjBtwx3aiTl
         s38YNeMwPr3A3vty/petaHAj8L8Cp0/4FFpjrNOxoaoFY0wMbu+pYKT24o7mxuljGGk1
         3n0I9/ZcxrVJxkW7sWptnhLEWk3ERnQ1o+AXflBrA9HjWDQk8m55PwirzEGfHMLb1vh8
         q7+siU7xerds1v9PduFCN+C6GGgZPfPvY7YYRFUuFFfJmz0Rx+3B38Y4gM9Pr7Gm2W8t
         rdAA==
X-Google-Smtp-Source: APXvYqw6UZScP0QuYWM6ggxZU6RObcNzc+ZCIWguGEz2HJky3VLBkJe0y3M2lj9SX52WcJWNIbqPrvDmuPtF+BPV
X-Received: by 2002:a1f:1d58:: with SMTP id d85mr6949921vkd.13.1562970145444;
 Fri, 12 Jul 2019 15:22:25 -0700 (PDT)
Date: Fri, 12 Jul 2019 15:21:18 -0700
Message-Id: <20190712222118.108192-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.510.g264f2c817a-goog
Subject: [PATCH] mm/z3fold.c: Allow __GFP_HIGHMEM in z3fold_alloc
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Snild Dolkow <snild@sony.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One of the gfp flags used to show that a page is movable is
__GFP_HIGHMEM.  Currently z3fold_alloc() fails when __GFP_HIGHMEM is
passed.  Now that z3fold pages are movable, we allow __GFP_HIGHMEM. We
strip the movability related flags from the call to kmem_cache_alloc()
for our slots since it is a kernel allocation.

Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e78f95284d7c..cb567ddf051c 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -193,7 +193,8 @@ static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
 							gfp_t gfp)
 {
 	struct z3fold_buddy_slots *slots = kmem_cache_alloc(pool->c_handle,
-							    gfp);
+							    (gfp & ~(__GFP_HIGHMEM
+								   | __GFP_MOVABLE)));
 
 	if (slots) {
 		memset(slots->slot, 0, sizeof(slots->slot));
@@ -844,7 +845,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 	enum buddy bud;
 	bool can_sleep = gfpflags_allow_blocking(gfp);
 
-	if (!size || (gfp & __GFP_HIGHMEM))
+	if (!size)
 		return -EINVAL;
 
 	if (size > PAGE_SIZE)
-- 
2.22.0.510.g264f2c817a-goog

