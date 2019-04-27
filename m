Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 787B6C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C6F821655
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1xkUzQmT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C6F821655
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D38366B0003; Fri, 26 Apr 2019 21:43:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE91E6B0008; Fri, 26 Apr 2019 21:43:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9506B000A; Fri, 26 Apr 2019 21:43:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 866696B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:43:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id r13so3174459pga.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=djnSDumNSUIy8rko1tpIVyLpLiY5pB2Y9XGdbsFKdCM=;
        b=dq5qt2DkQ8Qy27hYIrdJjVXAXAuetAVfVFtGjJ63MOWPJaNyRDJn6Ct4XtPASrkD7S
         GOQ0dSlt3R0Giv3Orlt0GqS7+pqb6oyyZKr7YTrf7xoYqPRANZLS2JO8ZQEzC9DwIkJX
         2vDr+50Oq6+7SYLj2CRY72S4N10Btx7OG3VxYXCcTeJ+9x2bglVFD/EzmpM9+WlK/4NW
         hZiqlzKoA2i+mUKaUvu+RbJrfwomAiHCGTeEutx3mIb2XOMBzk02knH2gTQmaxNXDQl8
         i6+ywgYPjCuKPit3zAGG0MQfjl80S+d//pMLOeBwCaYk4BbTGvsGk7JqaDeJmZY259T0
         gKrw==
X-Gm-Message-State: APjAAAUGbESjEiUaLenZ/yh93JB6kvSgej/HCSu75W+mYhua4lPzHvHB
	ul3nymIbkvdqjbK2Smt4A1dAnJ3xcCktkjIMFWc0NZMQCL0Oof0chC4yftRZdBEPpYRPeKGxEGm
	gQlxnfan8vY7ssHb0P86spGZmpJd2mgKD0LaimvzHK3JR2I4nBpKD6tWVpoIqw0IIvg==
X-Received: by 2002:aa7:87c5:: with SMTP id i5mr13918823pfo.20.1556329402197;
        Fri, 26 Apr 2019 18:43:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGzg4LNvcC+ZhYdWQYrcx/+n0NOn86BmNfJZyUe02OEZH/AuJ9sFIICnMxxAAU9EoHfayk
X-Received: by 2002:aa7:87c5:: with SMTP id i5mr13918784pfo.20.1556329401391;
        Fri, 26 Apr 2019 18:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329401; cv=none;
        d=google.com; s=arc-20160816;
        b=tMuwW2c21qaUqadWIMo5v0wNCbPV65MOkEal+2PO1Mf7ohdBSlibUgf+uJ1up/Rben
         FwwIrh5oCZ1QAyZde4GQH1UsiMZF5htki0vtEjqrgV1g45iwrr638EmHFqp9DVyZtx0R
         D4antLTJUKwM4W1vzKAHv/yMUE4kmS44iWX5h1M9ihfuSk2mQc6AXJGQ3X2wjs+1XqZN
         15gfPe8YofDCXpOuvRwwBgaW+TYCkPUxHQn+IRudNG7SkyvT+fjyrJwwqaux8ru8wEe4
         +sIsdLpNU2o51B+tF9ZhKxW7cUc1+rXv4pt1zssrOme9TxNaRxbyyItKwGfGut0QnUyq
         j2/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=djnSDumNSUIy8rko1tpIVyLpLiY5pB2Y9XGdbsFKdCM=;
        b=V79I+veXcr6HsD9NFd9nbeFGRXi8L5WGQ+kxCOYXBdaYv1N9iqdexVxJWQDkKJOVky
         LaIi6O3ns4Xq8hzh4tXueFDQjQbNSzPOuEwFMsnGHyolb4KuMeUqfB+BQQfn0SVXYzIm
         Y10A3+b70NxzjogW6CDMxNHSuG3z8He4cRW/diTfBvI9WnyNOvrP6hMgi4voX9PL//nc
         owvwKeAhYy2POollNBYBy3OrlPMZGwfbjLJMouZeEayXJEKIRNFsvn5PK9NufVslPO3K
         TxtUdKmgr8VtbpR6+XLtOa+K0CIHoA+EDvqoZaYpfZL9+0+Dlef2kxMW6hm6g3bNd6jA
         DDLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1xkUzQmT;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y66si25699996pgy.186.2019.04.26.18.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1xkUzQmT;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4AF2A208CB;
	Sat, 27 Apr 2019 01:43:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329401;
	bh=UbU0W5REMsR23LNOykfGmpOPpJJneDMOJFFazNyD0Dk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=1xkUzQmT6fzoHGuRrBln475FTqThW2TZGKz7PJ1lwHFmk5CJPQZh0ehrL2AmY+N2E
	 tD8NfW4S9kqSH05PuoQz0ND9BlmbSWkMnvEsLFlLYkIgtRzNxEbDC/sQ9ShVMWN7PR
	 +6IiZsJCXPZHw/oIgdS2hl3PJgucRBA2aT73/gLM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 31/32] mm: make page ref count overflow check tighter and more explicit
Date: Fri, 26 Apr 2019 21:42:22 -0400
Message-Id: <20190427014224.8274-31-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014224.8274-1-sashal@kernel.org>
References: <20190427014224.8274-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

[ Upstream commit f958d7b528b1b40c44cfda5eabe2d82760d868c3 ]

We have a VM_BUG_ON() to check that the page reference count doesn't
underflow (or get close to overflow) by checking the sign of the count.

That's all fine, but we actually want to allow people to use a "get page
ref unless it's already very high" helper function, and we want that one
to use the sign of the page ref (without triggering this VM_BUG_ON).

Change the VM_BUG_ON to only check for small underflows (or _very_ close
to overflowing), and ignore overflows which have strayed into negative
territory.

Acked-by: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: stable@kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/mm.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 58f2263de4de..4023819837a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -824,6 +824,10 @@ static inline bool is_device_public_page(const struct page *page)
 #endif /* CONFIG_DEVICE_PRIVATE || CONFIG_DEVICE_PUBLIC */
 
 
+/* 127: arbitrary random number, small enough to assemble well */
+#define page_ref_zero_or_close_to_overflow(page) \
+	((unsigned int) page_ref_count(page) + 127u <= 127u)
+
 static inline void get_page(struct page *page)
 {
 	page = compound_head(page);
@@ -831,7 +835,7 @@ static inline void get_page(struct page *page)
 	 * Getting a normal page or the head of a compound page
 	 * requires to already have an elevated page->_refcount.
 	 */
-	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
+	VM_BUG_ON_PAGE(page_ref_zero_or_close_to_overflow(page), page);
 	page_ref_inc(page);
 }
 
-- 
2.19.1

