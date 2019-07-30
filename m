Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9702DC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 612932087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:03:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 612932087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0DE8E0016; Tue, 30 Jul 2019 02:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71568E0003; Tue, 30 Jul 2019 02:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D399D8E0016; Tue, 30 Jul 2019 02:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 888778E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:03:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so39619004edc.17
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PQ9i7jzea9mGKNH8KcMLWsVLtL6mR1QxNOrNNbBorkI=;
        b=GB5R0+cByM4MXNC5N3Ckpf/2RgnCyVTWkynUbX0yYJWUQmU/OsUtAiquNUTheSOFFy
         6eKMx5+93Ar5JUb3/9gA0QSso9o7DTMtSlhCdM8GmO5a01Fz1sgzX36N0T9ASR37VqwW
         6VLQFsOZY3Mck2iaEHyYm3dQNhaDDbO5THcAFos4gghsNowNpd/KASvQ/lGIMn7SxTA8
         5HnGh17rUFoRLXo/0yVb8gPw5KtOtza5CTsuth2bZEZmrXI1NUX5fewYoMPk6xhs6G2Y
         dS6amMyo583Cb3HS+V++K9U50g0wp96vSqyUNPko0MI8EBeQ6V4a8bngD3oFGysmPPhE
         1E3Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVK2Y8uxEYwkknE1bgCopAoeW5CZfSNndSzhYb2HABmj2AcGtc3
	T19AhC1E9D8MIAe2FwIuuTS0J0aXbEKGGXoaA5XUci+senEeU1lhZFFx0xvMjK7vqz8iWl7iSlJ
	M+8U2cm5Um1dniRukgGnjwK/r1HL+fNWP1k/npJvQ7Bj3zl1Vu7p5rNG7cUkHb5g=
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr24695845eju.308.1564466607149;
        Mon, 29 Jul 2019 23:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpF/32RijyaRi0dIwnYXE9qLtNwG8dJbZ6vbEuu0UbbKPIFsndmLRB08pS5huoFr14qQeE
X-Received: by 2002:a17:906:499a:: with SMTP id p26mr24695806eju.308.1564466606416;
        Mon, 29 Jul 2019 23:03:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466606; cv=none;
        d=google.com; s=arc-20160816;
        b=iADCxsc5vstvf2uwvuVU+2Gzxb7/zt77WXITEQDQ80fLuvSbr5mCFRhlDrAv+iBezL
         XziBQqnoX9ItqKkhA2e/C5J9c/RhCkmdkEyiLdsbGwvXrHQb37jFjF0mluWnEmFXVpm4
         JQpMuwmk3R9vaApvfpfZAk4qtr7S7r1ZmWFP1cyShQOl9iLLpquvcdeFei24FmDDrQP1
         U6RVHtbKQk4WUXm4qU3UgHAr6CZucdbnsRLlaFw0TbMa8guX2wYod5SQm7819bY3ETxW
         bTUi6EGrOE5XSteSu1J8BgeffFluhM1u/MLUG/3PYIqGYez8IfsggXWtq5sNuQ8X0U7b
         fD1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PQ9i7jzea9mGKNH8KcMLWsVLtL6mR1QxNOrNNbBorkI=;
        b=eodWfswH6TOu5BXdDp5tRb7Ipv3NYvaq4KSCzwuF8hx6FgmBvdDVZ1mDcWx8nzaNce
         eE4T0RinU/Sek4NUeZs3VFEddWbiLMMLz0pVPp50slVK4SgvfYi24mkU9brcV7oIfx46
         CdzktzpCsbU0RkaADnk+Y50bUdXVOJTsTNOjZp+DPPbixBJTmYyDJ9NUcSBkaCJqX4G4
         T+OGaUAolUIDCyBykWhVOKIrirMSp2A9rhSlbHqTqQzTC3czMj6LFppZY8rPqkup8L2C
         NnJb2pUTz4/Wqj3DjF0V1VbywEAFiG/Tm+b2cyfqz66WHT6baZpt8hNNpVEoLCaIm2z7
         1KmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id q17si16760223eja.24.2019.07.29.23.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:03:26 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id 0BBC320006;
	Tue, 30 Jul 2019 06:03:21 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
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
Subject: [PATCH v5 11/14] mips: Adjust brk randomization offset to fit generic version
Date: Tue, 30 Jul 2019 01:51:10 -0400
Message-Id: <20190730055113.23635-12-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commit simply bumps up to 32MB and 1GB the random offset
of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.

Suggested-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/mm/mmap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index a7e84b2e71d7..ff6ab87e9c56 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -16,6 +16,7 @@
 #include <linux/random.h>
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
+#include <linux/sizes.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
@@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
 	unsigned long rnd = get_random_long();
 
 	rnd = rnd << PAGE_SHIFT;
-	/* 8MB for 32bit, 256MB for 64bit */
+	/* 32MB for 32bit, 1GB for 64bit */
 	if (TASK_IS_32BIT_ADDR)
-		rnd = rnd & 0x7ffffful;
+		rnd = rnd & (SZ_32M - 1);
 	else
-		rnd = rnd & 0xffffffful;
+		rnd = rnd & (SZ_1G - 1);
 
 	return rnd;
 }
-- 
2.20.1

