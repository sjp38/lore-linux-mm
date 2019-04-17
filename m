Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED1C8C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B526120872
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 05:28:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B526120872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 529D76B0008; Wed, 17 Apr 2019 01:28:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FF7F6B0266; Wed, 17 Apr 2019 01:28:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 417876B0269; Wed, 17 Apr 2019 01:28:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1BF96B0008
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:28:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id q17so996679eda.13
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 22:28:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=akQS/yG8sPhImfKfbdP4IgmJO6rV8gx2SpQpdbx2UzQ=;
        b=KxOYJet5btkbe2bYNd/1RKbQkwq+kG5hR0DI7UC27umpOwAyES7Vay9LDdbH4hMUNH
         C8fACSZ+XXmRmy3ZXEyouAWfVsXCraM55MRBSDTMA9hVs5D+4xTTD6YsBO88gXr2MgtX
         w3QvpPkEQwmjLjMkimylXez4ykVw1Ca+/rxPvYFosyNf+TaOG9dUV6mlplnxa/k/qIVY
         sCGpNjuph72h1WvaEqOj0a4iLWxM9m+opfOy4ESsdl03cKmovJ24glJvnxXSFWo+fnbZ
         2ejYq3P3Hm0/VI7zLsN1xWt2u90L49xJK80SbaLZY7/c7+wqwRyOXdNy8K1OpkEtK7c5
         aNiw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV3qRKhNXVWdgwMYawkCQOGTGZaU/T3WEt6FWtS8kq0KqhsWjtD
	p4sV0na5jkmDlAxL2YaSvPAJe5KkGnC+lSOxBpofabpHCJC8dAj4ZvPZsByVXTU2ie+8mJ9lz/I
	LLVjSUf55QZoxAhe6xjrl8D5vrRmvdh+L30OnfIJz6+PaUA1yCQWnBLnk+mvPOZA=
X-Received: by 2002:a17:906:ddb:: with SMTP id p27mr47118845eji.183.1555478905421;
        Tue, 16 Apr 2019 22:28:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/Ife5bTAxn65rlNwJ8nJyX5c86fbRqxflgicdf/EJ8ehr2As5odRuqLEw8D3HcouRPIJk
X-Received: by 2002:a17:906:ddb:: with SMTP id p27mr47118812eji.183.1555478904559;
        Tue, 16 Apr 2019 22:28:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555478904; cv=none;
        d=google.com; s=arc-20160816;
        b=M9bKwEeVsD765kULstuvkuGCxDufWJYnV+wm32/xwIybZOzQoFCyWRChhTr2VzUZXW
         zck/hLc2ym8nwDRyOWfXrzhgls3AqUTccEL1UFS0XNqfsLohKOJs1k3gi3Vdbk3/IucP
         Pe0Ea/h2Ky427pwBut5i/P//43Qbb9CnU5NoHDLOHMWpSQtGlGOfBHqDDUzXI/elRfAY
         d+OOFSC5f2BGGxfxduz6QZqx+JWYAQ9dVeSCLY5PC6UsZGOeh5uQpG8hNVa/QcqsbiYJ
         CG/N1RZA0bTviPANJkKYu6rh46bGGpNMBUKOx+OrV/teuGtsSjF7KRYifWne2WRHPHTw
         +KgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=akQS/yG8sPhImfKfbdP4IgmJO6rV8gx2SpQpdbx2UzQ=;
        b=tm9xValkBLlnVFLgUBSKltoBIVPhdl1ClLpCwSMFmW2u4kuu4FbMv+hAYnRfFRYtf8
         HFcvZk+fHMr0mYHyhvU0Zx3YXDlkQk10LYaVO4Q01TOSHLFGwp1PERZ4UtYztGXqrrYp
         Ny1t0NAvvCpe7brbsPoAa+XM0htFt90xGI5Mx22GsnImBeT3ZQfc0/Pq6CU2bWEVyaDF
         p+u7aYWGri+mjz0nehgeDXzhJRFytkkPRX/5nH5TkXKC1pJ0fVa/2tcImxhSvmUAhLAo
         4ZR51AzX2wdiH0etyNK2HmX6EwldTP+F1YjGK6dOLgdlKeosleBoDy41mUwB3mMJVOmt
         vEFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id m2si6630031ejr.38.2019.04.16.22.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Apr 2019 22:28:24 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 3A2E6200008;
	Wed, 17 Apr 2019 05:28:18 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v3 05/11] arm: Properly account for stack randomization and stack guard gap
Date: Wed, 17 Apr 2019 01:22:41 -0400
Message-Id: <20190417052247.17809-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417052247.17809-1-alex@ghiti.fr>
References: <20190417052247.17809-1-alex@ghiti.fr>
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
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
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

