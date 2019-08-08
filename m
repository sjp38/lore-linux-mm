Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF452C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:24:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B839720B7C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:24:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B839720B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 653D76B0003; Thu,  8 Aug 2019 02:24:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6034C6B0006; Thu,  8 Aug 2019 02:24:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CCBB6B000A; Thu,  8 Aug 2019 02:24:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F22736B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:24:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a15so912434edv.2
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:24:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wVOEOj3ZQH/LmpW3WBqdwFnDIfuDrBVXLtErTwdcowY=;
        b=plHpIg2f1vQMBgq0RhiT80zO7X5xLjZxA4DTvL8G351lEs89ISs4/6PrD19gQyAy7h
         M4Cq0WnOa9fgv1oRzlKJiCHcvPDLv7lhywluuIT6Trjz5+3xTojHm074lufRNQ/5mBoU
         +tj6W8zYOkQzO15lgWS1/WbGnwZDxrAXW/P3Zjxt4B5u9HJIOtaShDo9qihVaj3z0uPE
         pvj/14JWIao7MawCZKtGSjfu3kVzCNmlUNHNGC+iFSrK0P+8VrYGImES5GYrsOCWB6Sz
         Yf1QAp4/b94JLBXMOq3VAOTO1qBRuHK5BJASuawmc3vR8lxEozl9AufYt6lkNC5IJ/3e
         6HeA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUT3SWSt7/1vZjAe73toa3yMevzAJVMCemekPufDVlDR9qMsL9V
	Qk2b8juxdtrK9egNns7KX0RYLKY/kNtchlFI0Jjuo4c8xIHR/1ZKW4z7nA+5Af1RBiJc/4tqQGK
	mp8szdEIE8PZa/vlmnzTqXLXvshB76UFcRHE7iMXvLytJ3PaIGZqC/wmwwgts0E4=
X-Received: by 2002:a50:9177:: with SMTP id f52mr14128767eda.294.1565245481568;
        Wed, 07 Aug 2019 23:24:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTlQRD15ioRPIBc2difhmhlSWiy4bcgLndUk2DZVaZ19qgLOMhEDvEwX40A/Mc+huXHjbW
X-Received: by 2002:a50:9177:: with SMTP id f52mr14128692eda.294.1565245480143;
        Wed, 07 Aug 2019 23:24:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245480; cv=none;
        d=google.com; s=arc-20160816;
        b=K0kdHbHMcDZeajGwuh5CwUpIo6AGVNFvQKEPcnVjfEXvbIstcEkGBJ3NMJkAg4SsEu
         llHcvS9/dR636QozKL0tSq58CXvt5ufzrFx12AqqXGQBa11sYJcgi4I/G7wZ19iNsklm
         auIlWFRZgNTfHkwAPWYfnrbrWEfyXVHTDqJLGUAhL5lwSmYj2AYFmviz9A9Xjd1uH2NP
         KB2M6pVp0l4C1a1mG2RYln5okyW+HuJHWIAEq3PgzmXq8LwFssuc8ziTOWo/nYQ5G90m
         8Xotnz0lpRHtkAok15gw2bhkmWsBAvgPm7gpKXZLqYojkDD2Lzw/TDIhZnfRzPyY8HHi
         96Sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wVOEOj3ZQH/LmpW3WBqdwFnDIfuDrBVXLtErTwdcowY=;
        b=pmNXPR2qjN3aWe+gglbEVrbzMWY8LMXxoFCJM9DkISLPfIjWP4otKVG7LmIu+EEmc4
         f2dxdzyTqbZkXXEyjDcCk8xCpT/l1rQD6xYfxt9mTSFkMS7h5P99mS6ZXPILL9fsJAnQ
         NVtMgPTzRnUzJ5UIKWyGbGMly4YRsWwf25A5BCp0Nfm7dXfxGkzJR5Ytgy4h1i1h7dxq
         cklGEfQLLtD8dWpqoaPAovFcHGfM/DbRN6ogol/AyNGIHmwq1AeUNosdy8L+F9fcewKx
         ZYEkCd6LwFlrR5Q217t+70nXE1d3C9KCy1G1XSLUeC049J3SNCMoSlgvv3jEly/paTh4
         Pr6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id d23si30292430ejb.149.2019.08.07.23.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:24:40 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 94D2C6000B;
	Thu,  8 Aug 2019 06:24:35 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 06/14] arm: Properly account for stack randomization and stack guard gap
Date: Thu,  8 Aug 2019 02:17:48 -0400
Message-Id: <20190808061756.19712-7-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit takes care of stack randomization and stack guard gap when
computing mmap base address and checks if the task asked for randomization.

This fixes the problem uncovered and not fixed for arm here:
https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/arm/mm/mmap.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index f866870db749..bff3d00bda5b 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -18,8 +18,9 @@
 	 (((pgoff)<<PAGE_SHIFT) & (SHMLBA-1)))
 
 /* gap between mmap and stack */
-#define MIN_GAP (128*1024*1024UL)
-#define MAX_GAP ((TASK_SIZE)/6*5)
+#define MIN_GAP		(128*1024*1024UL)
+#define MAX_GAP		((TASK_SIZE)/6*5)
+#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
@@ -35,6 +36,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
+
+	/* Values close to RLIM_INFINITY can overflow. */
+	if (gap + pad > gap)
+		gap += pad;
 
 	if (gap < MIN_GAP)
 		gap = MIN_GAP;
-- 
2.20.1

