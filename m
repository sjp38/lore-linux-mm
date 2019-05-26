Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DCDCC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:54:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27C1C2075E
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:54:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C1C2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8DF96B0003; Sun, 26 May 2019 09:54:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3DBF6B0005; Sun, 26 May 2019 09:54:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A079F6B0007; Sun, 26 May 2019 09:54:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 528806B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:54:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t58so23220231edb.22
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:54:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eym0BMHdbArtu9uPr+EyfIeUu2p0S0z5kNpGctDciqY=;
        b=p2mVaAbkCJdNDryRBGu2Smy/mmhvFRAgoMdWjGBPgehxNTF8hb8bHB+TE6LKrcoRAv
         lj1DU3fcY6ZH8pdXqUiJytmDQjILrmn4mcMnxsvCnJkC0DgDXezyNSUEtPFuAJAv3Yub
         kn1A5H/aU/uCbpBA+bRadVUL2tLz7wEezSKY0jpZpYRSdtwlWrmY7kQ5mWewYQEgmzWI
         DkebcggzVQ2YR+7MjQPdBYa8CST2JSZ1b+u97ejs4S/KUxsh9PZ1MCES9z6TLu+4xoGZ
         dCrBvA3/9phz69K3/d22XWcjsFqZzvaXeDSkU7quSuXQl8bQ3nevaHaE5ShRiMZbHs29
         E6ZA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWluRgiF3iFL+af8/RR0/4Psjx+bBPHoo4UJa2tzzoKw45njAGT
	p6XVjcOeL8hSYIySMzqhpznBAps6jY1JNODXP1E3rlAkGRWwJllkkh2TbjwyKS6Wi82PpF6bjYO
	RADxgiITWUhubqU9Z82DNNyIuRWxapU5l9OrY1PF8HmohBBiILR/G5V0V6JytzVk=
X-Received: by 2002:a17:906:5e16:: with SMTP id n22mr50139894eju.28.1558878896848;
        Sun, 26 May 2019 06:54:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmaVqmzSaPhWNn15CXD5hY6nomd8yTC+1Jz8sk6Fcnd5067eE2Nnjkej1/QvxoQiN/O81R
X-Received: by 2002:a17:906:5e16:: with SMTP id n22mr50139851eju.28.1558878895934;
        Sun, 26 May 2019 06:54:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878895; cv=none;
        d=google.com; s=arc-20160816;
        b=IiSgnse8hwPLIpXbD5PJSGjxztbDtUQOcOLm/J9EhDgN2zz68doyAklEGkBYDZQE0M
         44LAhmMJIA22xIztx6fYD1kD4n92vc21Ov431nNHFYS1tk9B/uKGbhuuz30mO3VJ8JWR
         Rdms4A38Bx8DyNx8/J0YfFC10VdCmtz90Km3u/jwZNUWCqyMMVlhKgTU/e50j5VyvfZ/
         9Eya8zL9eNwKPgtXTgdupUhrjHgEeqE8esHPWfVsz2CNWVhp0tCH1R1wjtUWHntrzR3N
         RcZwtzOshfcc9OvYDyzM0a6Aqs20clIvsoGcKcACvabvU9PXLCsObBF/BW+nmKXtoCS7
         bRxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eym0BMHdbArtu9uPr+EyfIeUu2p0S0z5kNpGctDciqY=;
        b=COjGHwaHNcTmGQBAFNeiqEpOfcpzh463DrR5FJB4ReeRDQLcZqWdwuVMFM58QkcwTg
         ZmiDNM7Hji7WEU2sVdMFgAFHMR+8frK9UgyliHRX4SsgBBq9evjY+xLAoDmxpO0cNmBt
         L/8DvX1g4YeFRwDJ6pYzdJ1a85D0lvSRfDeWICVS+eFNTrSsIo+kCyO0Qq3OxIS78XHr
         28D7ZVN1DrZ9mEp0VBz2+6zM+g3CFhaQgey1T4ZBsDKA6xTGivYbJ4uPPhgsD1lYYHi+
         1TSWIk5JL+yKK9fb0ywQXdZLlhhh4Jbcf6bJI9qgbQtcEr8477Np3FfkAyIfD3TE0qG+
         bdng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id k55si438782ede.289.2019.05.26.06.54.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:54:55 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 3D31BFF805;
	Sun, 26 May 2019 13:54:47 +0000 (UTC)
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
Subject: [PATCH v4 06/14] arm: Properly account for stack randomization and stack guard gap
Date: Sun, 26 May 2019 09:47:38 -0400
Message-Id: <20190526134746.9315-7-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
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

