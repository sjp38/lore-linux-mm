Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D543DC76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E14122CC3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 13:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OjjpPW7v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E14122CC3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDFE26B000A; Fri, 26 Jul 2019 09:41:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6ADC8E0003; Fri, 26 Jul 2019 09:41:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBD6C8E0002; Fri, 26 Jul 2019 09:41:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 897D06B000A
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 09:41:03 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r142so33182682pfc.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:41:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JA5tYA6xzXZ3AVCMyv2jH3qpBbdyS70wQgXDaqQEbDs=;
        b=FGOPKKSempIVPgjcSoE+7Mpz1byXknmnsEk53cQfGJ27HEEvApE0qN/r3kHyKDiPH2
         iUcMd5wMqD7nRjSoB4acdZ37YFjb2Y5a6/BijmitFSjuL5fKv6niVHA4NituXs72a/XX
         QJBEl7p7qkOLp5EvX/M4IYPHm/t3dzVAQognTkilPW50ZLDN9T4CAmrg/2h16hhXnTiq
         aKlr1m8p6alVlnUpWircFFVs3k5BXfsL0SuJI5KZXJV83SG72hGiQKEyJVe7oBoyRyM4
         tpUCUGbj3vPFFECJQysVtxn/MePMIDKToh0riS10scAPfvLlshXmTUAMjP9WDxd0BhzJ
         NNdA==
X-Gm-Message-State: APjAAAXU7NXI7Yu3lSptKQG9LdSIGDGXFQjTQpgfSmK6EGpmIODf3A5j
	TgTbp8XrUZg7mgwUc8FpcLpxO//0ZbIszZt5jDJNBrRYLGDpZAei0UoyDHnXPgCHWNkuyIxs6vO
	2LDX3CyAOj2BRQfKx0bAOv0ZwE+leGvsub+H00DljNA5p76zrTnh1SpN4BBH/4WWuuQ==
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr99772618pjb.42.1564148463244;
        Fri, 26 Jul 2019 06:41:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTRId5f6ARnN/sVcAahn9AdNZZNQbXRubl26vMk5Ptc6bjDFkdEXLEholsv0c5dYjluKoc
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr99772576pjb.42.1564148462617;
        Fri, 26 Jul 2019 06:41:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564148462; cv=none;
        d=google.com; s=arc-20160816;
        b=YqiyVfE28SBFYJ68BwQmoOr0W33nkYb7P/nYXg61PFhwyEM+Yob4A/owmyndE+laGg
         U2h9GK2dpHxbY6MiGEUiJd2NGBMd9vYeqktpC8iwdWcGKZMC9SmFfEGFV7XT7Jy03wDW
         pbX0rG3ynYUi0IfOy2fC24Zmjx9jSKHKTYaQLREW6RA1Wos9pU04KUtFIH6l4M1nS0Xf
         89sfKDCqz/XQN3HKldtWBIYk3ClffhyT6JUFKsKZVtIJjgQR1wKTyatKT+p48M5irr6o
         /L6imvhZJoLpK+2LqxV9Zt64A/PkD4F2fY7VuSQeUadEV7Jl7tsBQvYTJ0Gufg+5LBf6
         CnhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JA5tYA6xzXZ3AVCMyv2jH3qpBbdyS70wQgXDaqQEbDs=;
        b=EGuFHPA5KRuFBQcXj2r9MEkjkxdo2bEat1pua1XPOIev2O56G0b4SEPOEr96gPm85i
         Y7IJhp8aQd6BWrVlSB410FSVOBLXOnElxdA8/2vw7b3e0dcv3aX8TiDmxYCc6Szy/1NC
         aM2bo/VBRU3XFyorJtiHUh3HkR1LdRQ4c1vqkSwiVLFjPbes8AaoaOCoF8u1Uy0EH449
         1y4RVQXAw8rwuwYGTMRdRNu2xSe4ip8GOGpQsvg2aA61q3LAF3dmhhL7TodAN+IgfvVE
         BuS3cFGkSmMqKuvt5CVVHPaUukFOHnBsSdXeRfK1hlZJkgYqy/+iGOW4qb8wlmCjxJzG
         FzgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OjjpPW7v;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v10si20064395pgq.17.2019.07.26.06.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 06:41:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OjjpPW7v;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3C63222CB9;
	Fri, 26 Jul 2019 13:41:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564148462;
	bh=Qt2/1Z3/byDB4IlQk0hOeMb7GKWf8oM+Z2eeZc24UfU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=OjjpPW7v1GN99vV9Ddsmo5b1CPZ2sil7k8KzGs2GZNcuzZBAlUvo90lUqvgiHWdug
	 9frEFwg7ZguJGpVByRf6CNC5xSp70ex1NqD7AfNzTy/abdPwaJ1Wo2uJ4R/4S48orj
	 o0D5y6ephx5b73+ihstS3t5CBeGDYaa876ddYqMA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Henry Burns <henryburns@google.com>,
	Shakeel Butt <shakeelb@google.com>,
	Vitaly Vul <vitaly.vul@sony.com>,
	Vitaly Wool <vitalywool@gmail.com>,
	Jonathan Adams <jwadams@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 53/85] mm/z3fold.c: reinitialize zhdr structs after migration
Date: Fri, 26 Jul 2019 09:39:03 -0400
Message-Id: <20190726133936.11177-53-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190726133936.11177-1-sashal@kernel.org>
References: <20190726133936.11177-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Henry Burns <henryburns@google.com>

[ Upstream commit c92d2f38563db20c20c8db2f98fa1349290477d5 ]

z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
However, zhdr contains fields that can't be directly coppied over (ex:
list_head, a circular linked list).  We only need to initialize the
linked lists in new_zhdr, as z3fold_isolate_page() already ensures that
these lists are empty

Additionally it is possible that zhdr->work has been placed in a
workqueue.  In this case we shouldn't migrate the page, as zhdr->work
references zhdr as opposed to new_zhdr.

Link: http://lkml.kernel.org/r/20190716000520.230595-1-henryburns@google.com
Fixes: 1f862989b04ade61d3 ("mm/z3fold.c: support page migration")
Signed-off-by: Henry Burns <henryburns@google.com>
Reviewed-by: Shakeel Butt <shakeelb@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>
Cc: Vitaly Wool <vitalywool@gmail.com>
Cc: Jonathan Adams <jwadams@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/z3fold.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index e1686bf6d689..7e764b0d8c8a 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -1350,12 +1350,22 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
 		unlock_page(page);
 		return -EBUSY;
 	}
+	if (work_pending(&zhdr->work)) {
+		z3fold_page_unlock(zhdr);
+		return -EAGAIN;
+	}
 	new_zhdr = page_address(newpage);
 	memcpy(new_zhdr, zhdr, PAGE_SIZE);
 	newpage->private = page->private;
 	page->private = 0;
 	z3fold_page_unlock(zhdr);
 	spin_lock_init(&new_zhdr->page_lock);
+	INIT_WORK(&new_zhdr->work, compact_page_work);
+	/*
+	 * z3fold_page_isolate() ensures that new_zhdr->buddy is empty,
+	 * so we only have to reinitialize it.
+	 */
+	INIT_LIST_HEAD(&new_zhdr->buddy);
 	new_mapping = page_mapping(page);
 	__ClearPageMovable(page);
 	ClearPagePrivate(page);
-- 
2.20.1

