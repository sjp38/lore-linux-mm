Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A6EC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:11:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72ACF22387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:11:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72ACF22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1215D6B000C; Wed, 24 Jul 2019 02:11:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D1CB8E0003; Wed, 24 Jul 2019 02:11:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDD178E0002; Wed, 24 Jul 2019 02:11:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF066B000C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:11:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r21so29572222edc.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:11:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0C35ePTka3aILniTSobALrcos9kafZPeyeIsA3FK51o=;
        b=FDhvtyTLzuyUXdv9GdUxyembbHcZpNKdHcUm/JseES78XTw/IRYSG18XlfdntrswdU
         73wIU7kvk/SoX3fQKbDN8r+HpeXTdGixsYsmru67dg2TqW8WX3/ZcFCCgB6DvDQvtXG2
         5FozXlg1HiO+Wg6VOUkdRMcvJahxOVbb5ITHPEB0hQvYKbrgT3hS5sthjN+LlEI2XqcY
         XdKpVa/O2fCLcZgsUBJX/Vdavso6qozustMTuBIUtv0F7KvMJMmVokKtGtcWlfUimvtc
         w9tCYjX80JYZK5Z8GTVPkYR275urI7PhSs29B1OcL2fF6cmlcTgkIa8w9IqCrqIFNNkV
         8tfw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVfu8HiVdfYmRuq7JIF2ia570MlGTdRbldxNWx2VFeq+3JzfcbW
	Dq6pGamedLo1Rd0iTVEcls/AAbSW6lDzHF9Kj+Q0w3Ibt5bG8bG5Keir6fytgbQH8GzyhZLhDSD
	lJwnT1sS+nPMzrdM2NhrssL80Awodv1lyXSxCxMFkFcZK/w1SuWJsu0BQMqs2zyQ=
X-Received: by 2002:a50:f4dd:: with SMTP id v29mr69298808edm.246.1563948662230;
        Tue, 23 Jul 2019 23:11:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy53MlVzhpHa8vhDGKto69ACey0n0D6t3TE774N3v7mzhlgt9MkYHUoYrSNy0lEqRjA9UNe
X-Received: by 2002:a50:f4dd:: with SMTP id v29mr69298754edm.246.1563948661380;
        Tue, 23 Jul 2019 23:11:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948661; cv=none;
        d=google.com; s=arc-20160816;
        b=WkzPuVJvFWcHyOy7hlM3Y3nCJqGngbI//8rh2h7XIUVh79idZ4CkQq/wCMl7P1uP7g
         opRzhloxjeA9+5GF7f5FSnQSobFHaYFP34Nkolv6PMc/QPlq525JkcqcIxiRN5YA5tYu
         g2HXvZ0QxPWrZcdYDVYkhMUXvgPlRJmtJJYxXrK58j19RzuiMMjo8K7ZGcRCZmA0nyX1
         MlbmFIpLM5uRjZgw6B1H0cLRb6q2DtsfpI+o5jMEs0zUHXWEyB8AySbQh258WJ3pFQd+
         jNSLUOucOp9nnqcTSsaE5QX8bPhUgoWTALEtvzeI93DH7BgGiTtVSrzjsc38/ICCdZYF
         1z3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0C35ePTka3aILniTSobALrcos9kafZPeyeIsA3FK51o=;
        b=VLS6CNuIeGplbPDE8WpveYoPPZthrFD3qqoaRKWUd1MhOh3BdP9xvzhyS0nm3gdsfJ
         FYBCTgE8Ur+U+mr59CYoF9g9sR4eRKAMn3L/ZmX+NlaDqPlHSMyfsunBQsRA2CbggmHa
         wXg3yAjqh1Sz3ycw12HhwWCV0RcdOaDyv92pdQ3fR7dvu528hsBpQRMpX+W62ZO3ViPr
         SqGB4TCjaySVRKtgM2Rga0jlHa5W1IM4i5BkFtesNrq9GTwlyUJ98wTRCNPJmc2UvhQ7
         JDuwnbWJq+lgLVJ2WHtbdoWUDI2b4Af3JwmnoDvS0qaX9Xna+SsWOCUD3SdwNgNLWvlv
         0kvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id j42si8419051ede.285.2019.07.23.23.11.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:11:01 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 1BAEE60002;
	Wed, 24 Jul 2019 06:10:56 +0000 (UTC)
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
Subject: [PATCH REBASE v4 11/14] mips: Adjust brk randomization offset to fit generic version
Date: Wed, 24 Jul 2019 01:58:47 -0400
Message-Id: <20190724055850.6232-12-alex@ghiti.fr>
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

This commit simply bumps up to 32MB and 1GB the random offset
of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.

Suggested-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 arch/mips/mm/mmap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index a7e84b2e71d7..faa5aa615389 100644
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
+		rnd = rnd & SZ_32M;
 	else
-		rnd = rnd & 0xffffffful;
+		rnd = rnd & SZ_1G;
 
 	return rnd;
 }
-- 
2.20.1

