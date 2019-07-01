Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71A27C46478
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:23:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D349205F4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:23:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EzSrG+EO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D349205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF50F6B0006; Mon,  1 Jul 2019 17:23:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA6578E0003; Mon,  1 Jul 2019 17:23:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 994D58E0002; Mon,  1 Jul 2019 17:23:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f206.google.com (mail-pl1-f206.google.com [209.85.214.206])
	by kanga.kvack.org (Postfix) with ESMTP id 665726B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:23:22 -0400 (EDT)
Received: by mail-pl1-f206.google.com with SMTP id p14so7882013plq.1
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:23:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=bNhCMdMsg7N+4Vj+pDsH8brC1Mtm6ra3Zd4KbsCvcEc=;
        b=KrR6o8YTPNl54YzT1Jb95tKBhpUUgAwuV6kqOgGGrO5ZC2M0Q/HFcBEuu6aCNRpoSV
         X9Jfc896GyQcQuh3r6VylzK1xYdKiZtWhy7WKEg4LKRJopl/xifmY3tI8lnqDxClprgL
         36RrTlHcXO86pJ1flb8iKO7mxyE9vxL8eSrGpU12qCTzYWkgtU9QzVjaxGcoUn5F79wP
         uVTkRPwtkmeJyo+toc6ebB9q6vHIh9o/+9tyKtOwyAwKFEWJnjh2WmAJgoZQtCtoiikr
         2XTWoiCliJVuwxr+WWqWZ+S2g/0GwUIojbRiPl0ZsfhTbnZNW+wDTbF0Qfu+4IkwxIOB
         lThw==
X-Gm-Message-State: APjAAAVhkPRjwGmDg/pJRy/zgV09BUfGWubGvykb9RnzppsMkZcV0HJ9
	4PDrR2ORTmX0qojk+iDlAm16XeaKdKaBf0MuRhVAu0g8sX4DWrzQQ61XbwSurJZ4+0Ts//6mq2y
	ToJiSFf2NxecZBu7ptkuWKZSPZKqzhZl4RvRh8ZI+QrY+TY3gCgPwkDYun0AoDFVQKg==
X-Received: by 2002:a63:4404:: with SMTP id r4mr26441350pga.245.1562016201983;
        Mon, 01 Jul 2019 14:23:21 -0700 (PDT)
X-Received: by 2002:a63:4404:: with SMTP id r4mr26441299pga.245.1562016201333;
        Mon, 01 Jul 2019 14:23:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562016201; cv=none;
        d=google.com; s=arc-20160816;
        b=GtkrQmmUuwTEG65zyO5oBS7RE1b3LK8QD4VtTPNpgiIcKR/mLrqxrsJCXA/s8l9N3D
         wi4C1Nq7FozKttf8/fB19xr4oQfqc1wsuAxmYkxVUHg0iTjohnTbATzABqX2MDnKqjtg
         iAYZa47MTOOKDdmdWhJY9YH6q94ZFF5idE/gEAya6SVjGixrGbsj9PMKvWhRwFjNo0Fg
         Z3mHSqJaByKGqOJC0dYRY9tgzPwGyOSPI/oJR9JeQOWohSFy/GOVxsvQOPSX7TxRD8bP
         Ws7AXitpdRalKvg2jEddpsVJg21rlii04qG7hXHpYUnI7FgSlzR1SMdZ2p2qec3X7ojT
         M+Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=bNhCMdMsg7N+4Vj+pDsH8brC1Mtm6ra3Zd4KbsCvcEc=;
        b=VHFSJ942q96gfZR1iJwrjhZ50gwx3pz16+OcrbnejGN5JniSbn8+ESZRn/qYV/G5fk
         IBxcxy1xdhPG7b4QaW96LYC2bbc7r7pd/zSJTgd2tIvrKwiMEARLRJYO8zHvXDPrJQUb
         VPCFLWmG4cIUy3li6yC1ufUa4TJ/NDKg6TkO0J0asUPl4elTxMDOw43SN44KBtaPx8vZ
         AFqNQk0guOfPzbEv6HkfcT6+Arawx2Yp59pUuv8TN/Oq8O1ILQ79On/r/yrTAhgLvyb5
         UBcmqZKdvmfRvIIKaY3JXTIeM2L8pmUJtaEt1W7zL+yvDM/S7v0jv2kzOk+hS2BE6iF6
         WH1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EzSrG+EO;
       spf=pass (google.com: domain of 3yhkaxqokcbu2z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yHkaXQoKCBU2z8CJwFC8D19916z.x97638FI-775Gvx5.9C1@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id s126sor5999501pfs.37.2019.07.01.14.23.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 14:23:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3yhkaxqokcbu2z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EzSrG+EO;
       spf=pass (google.com: domain of 3yhkaxqokcbu2z8cjwfc8d19916z.x97638fi-775gvx5.9c1@flex--henryburns.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3yHkaXQoKCBU2z8CJwFC8D19916z.x97638FI-775Gvx5.9C1@flex--henryburns.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=bNhCMdMsg7N+4Vj+pDsH8brC1Mtm6ra3Zd4KbsCvcEc=;
        b=EzSrG+EOzG9aDUs5P322SatgarBV953/Mej+gjGvdaBvEjLbtuHMj8Hm6kudG6uq4z
         rKFwo/55vjbeO6TT1CU7JtUYo2FdUYmUJCAVZk4qGns8YP1W9DpR7aqe64iIEV5RgaNW
         DEL5Dn/lRt17aKbzq8laUj86banrVjWj2Fszvod4Q7hIHFTD6py1tQAre/nV3PZZOM5w
         gvsj0dYoRS2NMjOMVkmdecdK9QnfU4M57w5HZj9qcx5ZLdVLXwwrBZhlIgB1JWPvm25l
         DYramdXDEMzqdCivSXP1B1NhOq90bJQGBKHZM1E0K/metPuJZ0z9/BWvpyLMmK2xQ0CG
         qN8w==
X-Google-Smtp-Source: APXvYqwRQQWef9NfDlZUOW6uA8Q/I1Yr4IGLq0eWpS5i+Pg2BY9Si+Xw2iiaG9Nne6b5FjY/XumkMia5bSRjv2Mp
X-Received: by 2002:a63:c20e:: with SMTP id b14mr2877738pgd.96.1562016200672;
 Mon, 01 Jul 2019 14:23:20 -0700 (PDT)
Date: Mon,  1 Jul 2019 14:23:03 -0700
Message-Id: <20190701212303.168581-1-henryburns@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH] mm/z3fold.c: Lock z3fold page before  __SetPageMovable()
From: Henry Burns <henryburns@google.com>
To: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, 
	Jonathan Adams <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Henry Burns <henryburns@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
lock the page. Following zsmalloc.c's example we call trylock_page() and
unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
passed in locked, as documentation.

Signed-off-by: Henry Burns <henryburns@google.com>
---
 mm/z3fold.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e174d1549734..5bc404dbbb4a 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -918,7 +918,9 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		set_bit(PAGE_HEADLESS, &page->private);
 		goto headless;
 	}
+	WARN_ON(!trylock_page(page));
 	__SetPageMovable(page, pool->inode->i_mapping);
+	unlock_page(page);
 	z3fold_page_lock(zhdr);
 
 found:
@@ -1325,6 +1327,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 
 	VM_BUG_ON_PAGE(!PageMovable(page), page);
 	VM_BUG_ON_PAGE(!PageIsolated(page), page);
+	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
 
 	zhdr = page_address(page);
 	pool = zhdr_to_pool(zhdr);
-- 
2.22.0.410.gd8fdbe21b5-goog

