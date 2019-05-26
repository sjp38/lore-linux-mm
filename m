Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 595BCC282E5
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2ACC82085A
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:56:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2ACC82085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8FE66B0003; Sun, 26 May 2019 09:56:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B19606B0005; Sun, 26 May 2019 09:56:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2ED16B0007; Sun, 26 May 2019 09:56:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 527F56B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:56:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p14so23365631edc.4
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:56:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iEUnru/pgX+pWRywt03LhpHMFzmbntBrlVCKRjubFbE=;
        b=IjfeJMwQYEp3RWrvYAnZT370xyX6ppoKGbshnWMFPFYLWZuP+dARXxmq09ZNd9ypro
         rNrHHYMb7EnV6kiqZ3OY9P5GPVkjGQkuD8vdyY+yjy/KtCSw2jOF8wvhxWZYIop3Zsiq
         z7iCnzWYLIqyb2iIuHhmWCXhLbJKR5jzk38BHDjvcXWdtar7pE/E/Tmu/UVAtfeV4F6x
         VZbeAiZ8Iohs6n4UxhnrbaqObFBIqDXx99nev8ylXk/Qz11VINvFypcnDF12ryLBiSp1
         WusnvF6TMrVocjp6OE6o0qcnyf5X6X2EI765AgSxIsl4cJNp/gRpPmr00nM0O6IP2hPx
         4+Og==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVkk8U5lUBBFlOWo0hRxPOsi5g6nxhTno4IZ/32RbQfmmss7s/O
	Ga4uTYW+WyG9/kkrROeY1iO6FwVOC5jfYe6oiN8pV8C6HRzVojKGl+PoUHYRAW+zidxM2Muc9wn
	pbgBttK3p8cN4TyatYkFuPRfSG7YznO6V6ikiEC4uuM7DqoZvNljJMuPr4T/4dxU=
X-Received: by 2002:a50:8903:: with SMTP id e3mr115062577ede.11.1558878961847;
        Sun, 26 May 2019 06:56:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxonfJgA+N31R8QJBXKZByObpVWMBNYdRNy7doZXrl/H5A+oyXNGa3/A8ZUT2fDKlCPdQ+2
X-Received: by 2002:a50:8903:: with SMTP id e3mr115062507ede.11.1558878960700;
        Sun, 26 May 2019 06:56:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878960; cv=none;
        d=google.com; s=arc-20160816;
        b=lRdPCrG3Gh67b3DcAbetSfhXzt8tYuKDV6cro54Qs1I57Fpejz5sLXWtjd+Y+83LeO
         OMKuSEMzI43tCVPUyLznOd6tt8XbNX0oQVKie7MbD5NgRwesZqrmOpsNtlMspii7DS2Q
         j7fzI5C3xWGO5cTfIlBDSOTd8d7bwGlPgoWSQAhg3JghJq4UlmHqgJSZkIifkn9Nh9a8
         8DA7nqXgT/0aVpzVrtZRT2V8sCc3ofBh5K9TUXK5dw3jw/sHuSF5lXFlXsqNgkChExKY
         KtP5WFlj4L2Lft9etHGFyg209BWDH3nnFkRhuxLDfx6YdoxSdyszY/Am9cRRg3zgcvEF
         CU8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iEUnru/pgX+pWRywt03LhpHMFzmbntBrlVCKRjubFbE=;
        b=J5fxwq1FPdXZX2vAwrrCoYk5i92qpqZIz0t3L5YTbFckFNat7SJuBJsM3PMjK1TD4k
         vWeuKCoLHzC/gVQ6KVX5beUPcmwPmIAsm0kwzJfaF6aQ238Htrh5si97piIJE+gWFTdq
         zxp4iYWqPg4h6MppL3VLFabQh0n1CnFX+936OX13EJ5+cwYg8u80hzAPA9nQTYBe4boI
         BGNCRnUwS4id1XbUuMfrO2dyl4hU9izds9qnGKM2rtpyeJ1H5ojIJVsYNu9MIs6sRbFZ
         y3uUANO34KoS7oBNNnhBvRQI8kUEWJJhAFWvNePbijume1hMjgLqINwRKA4yJdBs/4NB
         kPbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id j49si3377361ede.377.2019.05.26.06.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:56:00 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 0B511FF804;
	Sun, 26 May 2019 13:55:55 +0000 (UTC)
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
Subject: [PATCH v4 07/14] arm: Use STACK_TOP when computing mmap base address
Date: Sun, 26 May 2019 09:47:39 -0400
Message-Id: <20190526134746.9315-8-alex@ghiti.fr>
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

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
---
 arch/arm/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
index bff3d00bda5b..0b94b674aa91 100644
--- a/arch/arm/mm/mmap.c
+++ b/arch/arm/mm/mmap.c
@@ -19,7 +19,7 @@
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 /*
-- 
2.20.1

