Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9745CC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:30:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D475217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:30:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D475217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 081E26B0006; Thu,  8 Aug 2019 02:30:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00BB36B000C; Thu,  8 Aug 2019 02:30:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEEC06B000D; Thu,  8 Aug 2019 02:30:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1BD6B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:30:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so57583005edx.12
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:30:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PQ9i7jzea9mGKNH8KcMLWsVLtL6mR1QxNOrNNbBorkI=;
        b=lX8xtqnZ0BEfCxaUd8VsgWxroci3XIfoHLpqNmk8w+CPOz2DPw/YPiacIc8uWJdV7Y
         qDJr2hxZzJpRLRCtZ+mNajJFea4ybm0vgwVjN5Y7SqfE2cVlHEq9KKXdsU/TiYEOIw3l
         5se6ELCLMdvNTMe3adw7ZbuUZZxfD9l+cl46l1BWjsjg2sAG1kIfG29xkqS1q7NgSQsB
         cbVf1CR6nXS0xd1FpBpussHa4+cx4ubkLIZu2nCkHQU8yPdadT7fnE1/YfkNhng7gIZe
         qZTqYu87aKG5wVoSy/NHNJ+Vv6TvTBTSQHzQR1Z4iwB5uVgSqK5PO13esBINSVJLK1E9
         wtYA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXKdacajXtjJsPU55doNSpaBGP+dYIy56+VEZb88NHmdFFytVRm
	5L49zvJLzOzVwrqymMj4vn9QUhdvMsLZS1ZPBaL9qE1M+/BKC85CEuSBmQhDPJpAVdjlD2GTwtd
	r7IlemukFB6hRCKzHAmp+/3kpBqZt9qoHpPwtvV7gvxwZUv6I4dVBDC3aTThKBJk=
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr11964011ejb.155.1565245808157;
        Wed, 07 Aug 2019 23:30:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4E3+hx4b2smncYlYyHNi5cp1g2KEtF4a/T4hTBXKzs6zRdXDpL5YQGQ1ouYWpYj3vLJpU
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr11963944ejb.155.1565245807210;
        Wed, 07 Aug 2019 23:30:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245807; cv=none;
        d=google.com; s=arc-20160816;
        b=VHleg7JBJGVF1UlrD3tu/QDOuWr/qGSycqzzCM+AqUnjBJcXn/afRUA7ViIWPfxF7C
         zMgUC2fUgp5ByKvb9JyA2cnVRnqfIlpXGuXFOr5HAMnbkgGxr45DPYIZIMkb1U8uDbCK
         oA5XdKAwEAejlbGfDnx6L7c4uEoN4lo8H0cT29249Uo3B148LxEyZlrHF5ATgoX+kvbO
         qsg6/d3ZcF7hhH6wJogqGSS6wmi4rPxsQkV3vYRNeTx0u27eFPqiHmKIyzsGyqfv65L9
         NuVuAK0kzG1GBBYGntZKLK6WWNTZ2mN8yAgYBOOs/7QKwnrfff1HlFQFAioLuXCBwVn1
         0q0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PQ9i7jzea9mGKNH8KcMLWsVLtL6mR1QxNOrNNbBorkI=;
        b=EHhnXmaNSkJU3uRKN/NH53Umnvjqt0SGvzHBchxsu6T6LN0QOiE1uiezCeVeuOhxT3
         vs9xrRfOsHkmlucYUOZTwZbG8K6XIoY3C4GHlIItEYNl5k5aV8o4KfUuyJLF+P0pYfOK
         GgkFlxC17duiX16LEcth888gO7ocwkJpEp/L9IcHdEBqb3PYQz/iqLo2xiTWF2qaA8lj
         +Qb9ZPhzJuaIi+2Xb5Y8sNQmAWnONTLg33arUDJ1qZMVDkWjWuFxPWfw5POYCg4hMkIq
         PEb8fr5zvW7GAVeOHgIErPfGwsuGsqJtEN7aPi2fvk2zJTe0pfjcmg8WUpcVucKNXW7n
         vB1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id y50si32961129edc.274.2019.08.07.23.30.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:30:07 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 42BAFE000B;
	Thu,  8 Aug 2019 06:30:01 +0000 (UTC)
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
Subject: [PATCH v6 11/14] mips: Adjust brk randomization offset to fit generic version
Date: Thu,  8 Aug 2019 02:17:53 -0400
Message-Id: <20190808061756.19712-12-alex@ghiti.fr>
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

