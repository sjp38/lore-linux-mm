Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 608C9C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:02:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F28421738
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:02:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F28421738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70E26B0003; Wed, 24 Jul 2019 02:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C21B96B0008; Wed, 24 Jul 2019 02:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9B16B000A; Wed, 24 Jul 2019 02:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 601CF6B0003
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:02:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so29572712edr.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:02:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KhEHOzJH1XekHaEjlNvFqkjJE/BSWfvZ32hlPcMINEc=;
        b=bU+Xml5K6lM7zX6advWyD5kAENmnWGKcnq+BOMMy7v3Kwp31aYszXIVqMxoh/JeaBF
         dkGsmOxxBAUcIzq3V0pGzDtGhxdVD+gA/Nq+KWKUQgsqJMK0cGFv/4F4eCeIh0lVv6R9
         h8lMuPc6+T6ujJDs1ZGJY8j68bCBpTk1/egIn4mdWTr5aDf5fPxNnC2GjsIpwxKa6z8h
         Ogr/lUc1qA6sbGuA0kfD/zO7ebV1Nhvacni/aBxuvH01yKK6uU8z8xqKSK3Lc7OwTc/c
         /U87RRleFkCel76dMnO93UtUt3/15iU1nLXfagpGW8wRtaqCUZOdf9jA1b0t1Mp7GVfV
         yJUQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW1sg530/AdIapPKQmLux/S2B1Jcq0bnkd0Gi6og0yxB3LY+wMO
	SJJFpKdL4qK3/zl6vYL2bLgatvfNrmgHf2wrv69Rl6A1CL9sDG5iCBPZ3ibQRE1n3IAJyOWkci8
	L13vxzwvR5pY5mHb8/hbmwvoSHb0IBvEvJEmji90Iqf/d8zmHwe7AawJ/NOu5c0w=
X-Received: by 2002:aa7:c509:: with SMTP id o9mr32810121edq.164.1563948140981;
        Tue, 23 Jul 2019 23:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5FxIBKpfGvG4d/UHLCSgRYxNgtZPUP8N0+wby71AqshY79OtFUUaHstBgsuj3hkxAvNpo
X-Received: by 2002:aa7:c509:: with SMTP id o9mr32810068edq.164.1563948140121;
        Tue, 23 Jul 2019 23:02:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948140; cv=none;
        d=google.com; s=arc-20160816;
        b=tOmX2zeYOYh1DjGot/NrgSJnLU0Pgvdk8p+pwlUpPVggMo5q+Z6ag0MECJHMfGdARk
         EQqTLXhUk2jrMD3KB61RA/U+Er17tzDjWCc3W2fVVDKk7N8ke0yuWoma0/BZLTEdcfWr
         pJFCDvcDgwRj9aNLcJJRHQPKBHcmNyGeyrv2jFs1NWJpaH9w5yP0Pq99pPrtjlCkdYuA
         rVFqFaRqdOtCuIOkPnRjvoh4wXGBOk8XWYSKkSrInSrpkvF3YPECpe0/ostEBcmKRfxz
         wrrQC+iG+aOWtzAVW6DzCMfrZtB/mSjppkjTihhNK/MoDvM5ytambnHk4K/2IRFI2rny
         MXxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=KhEHOzJH1XekHaEjlNvFqkjJE/BSWfvZ32hlPcMINEc=;
        b=fB/2Kb/oBjpIhJEM+NiUQ7g0iRhHOEorZVIG/qGmIzXkg+oMfNl0FPB3xJ4rkJU6d2
         0uS9DPFL5XiGYYzIlWb9Yh00ykC232CsDv706UXFQuu9hKayH0mmnvyGolMwphAwd4RE
         SV9xCmI+NtqBP99OdTYBkdMdZvSEFQANeSyNlD3XS0099YxCEGjyRCtMbHHFbVHyEh3V
         8zf7UkuPp4cRuDoZjnP0bkdZXCEQoIA8XGCHW/mffxtmVCthlXp85CbdQ6haWZiyOnPI
         isi7WFh2jWiH5YfZ8rn2Y6YREgewpcZi2F1x7D6nCxbkcl73HDzWIhqzdUx+8tXVn8bz
         BfZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id b2si7713510ede.451.2019.07.23.23.02.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:02:20 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id AF3E124000A;
	Wed, 24 Jul 2019 06:02:15 +0000 (UTC)
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
Subject: [PATCH REBASE v4 03/14] arm64: Consider stack randomization for mmap base only when necessary
Date: Wed, 24 Jul 2019 01:58:39 -0400
Message-Id: <20190724055850.6232-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not offset mmap base address because of stack randomization if
current task does not want randomization.
Note that x86 already implements this behaviour.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm64/mm/mmap.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
index bb0140afed66..e4acaead67de 100644
--- a/arch/arm64/mm/mmap.c
+++ b/arch/arm64/mm/mmap.c
@@ -54,7 +54,11 @@ unsigned long arch_mmap_rnd(void)
 static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 {
 	unsigned long gap = rlim_stack->rlim_cur;
-	unsigned long pad = (STACK_RND_MASK << PAGE_SHIFT) + stack_guard_gap;
+	unsigned long pad = stack_guard_gap;
+
+	/* Account for stack randomization if necessary */
+	if (current->flags & PF_RANDOMIZE)
+		pad += (STACK_RND_MASK << PAGE_SHIFT);
 
 	/* Values close to RLIM_INFINITY can overflow. */
 	if (gap + pad > gap)
-- 
2.20.1

