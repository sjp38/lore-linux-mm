Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA586C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:12:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81595229ED
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:12:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81595229ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B766B000D; Wed, 24 Jul 2019 02:12:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31AD58E0003; Wed, 24 Jul 2019 02:12:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E3EC8E0002; Wed, 24 Jul 2019 02:12:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C313D6B000D
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:12:08 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y15so29570119edu.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:12:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=66FrIHCi/FwU5Qd+YH0GklxRIkE/On5h0rf1MXh1DUQ=;
        b=tBiSCOGmQAGEgxdB4jHKm35Wi5bD37D1GjQWJ1+Zr83RRSQzB6blClAxnCKI60RUG4
         wOyWhxzmQCbmLePbANxOfpWuF/pH077z+XyKv6jvOjm9BF09Hh9zJLzgv2pMyTzyAcIE
         SnRj2uSbak7p6xQs4eKevI8yW2cLm2yNIWtBGqhHW7aWb+kbtn0JpmnYVxLipetCfxhw
         6gFxe9XOl/WKVBNhdvgoCEn5wILEL6twgsVDBbuQHzPiQ9LacfcQYlQLhDxUdnX8V303
         UZzGGsBsCWHlpk4MclKCuKfpJgyBBIWzt8IPjqSFZJz1L6Gavntu7yC+bpRDuDJoZh5O
         l5pQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWEGpKuQ48zkQHAHt4TjvR3IWvCBCdBcIRkjbrrJuWH01LGdkgH
	cGPpJttaoV754++u8PsozrFZR9wNURWRT/L2Z/+ideINKAFmXSCqRaCG41KO9ABeN3iwmEfD31H
	Y5MxfkXRe2t2H8V/5Lh5gSSjqLpT53HFbPb+tlEWj1JmI7XgKqb7FiGP0HUT9li0=
X-Received: by 2002:aa7:c515:: with SMTP id o21mr69490087edq.2.1563948728389;
        Tue, 23 Jul 2019 23:12:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVJVSKnQw6VwOkna3RuskGMDrKwh3llukNMuJwxBHGS8wOPgf4wAiTXgzuI2xTl4rs9/iX
X-Received: by 2002:aa7:c515:: with SMTP id o21mr69490037edq.2.1563948727547;
        Tue, 23 Jul 2019 23:12:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948727; cv=none;
        d=google.com; s=arc-20160816;
        b=m2rg5F2nyfB6moGotAn2P0dfB6Z8gkDjUzrA3DugMfRn23D1MwL6ihzV8T/slVuOtD
         Afn/SXpK3r6Ru96zzmy+fO49IBvQ/AOVnlM0VKcqVKj229WnS+D8Tmrz6lklIs4P53jq
         XJ6Fm1jhB9LYQDoJmNTPpwcZdZ6Syq2OjUQaISvcBmRmwLxDg6EG1YOGEWIEBzD4s6dZ
         7ZlusfVLbIaoRwNwy171fcvzlalFqCRxK+PXar/U93S/wn6diO6dbq6NfZ2Be33/HRXa
         Oe5DWQzBeEj/3o0ufEVj8muHqt2nDZ2uiZQ6HwcDi4NxJBY3sP2qTeJLX+ZGmUaiRrLZ
         nqXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=66FrIHCi/FwU5Qd+YH0GklxRIkE/On5h0rf1MXh1DUQ=;
        b=hv3wbdKxpSm9ztL39auxMc6uqDqFLHynE0+ROwqUoolzpYW+vZ1+b7QUjM5O3sYPPV
         eTd0ZPG7HkyKnlliDZcOn/UUBS1zjgpNvNBAQH5wjms+1UZGVMshzee0xFFrwb9nBtFU
         5t4Z7iRvX9cjp4waMOUBT2N9bmwx3EGG88qnUmrZkjuRiMZBgr/dtSYb8+bf4uOSXlLl
         PxxnIMDIgp4AVb9PO0QZYRZZHcl4tdpA+pg5oPlNhbcpjUeQt9tqWl2KQKOPkzZsrNJU
         3w273nnZHIwheFLwKgMyEhbsSMvJIFM8L7CADNU8uLSA357qHqGVrYFa07p1NS7x4pb6
         YdeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id o47si7916841edc.347.2019.07.23.23.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:12:07 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 8BB91100006;
	Wed, 24 Jul 2019 06:12:01 +0000 (UTC)
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
Subject: [PATCH REBASE v4 12/14] mips: Replace arch specific way to determine 32bit task with generic version
Date: Wed, 24 Jul 2019 01:58:48 -0400
Message-Id: <20190724055850.6232-13-alex@ghiti.fr>
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

Mips uses TASK_IS_32BIT_ADDR to determine if a task is 32bit, but
this define is mips specific and other arches do not have it: instead,
use !IS_ENABLED(CONFIG_64BIT) || is_compat_task() condition.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 arch/mips/mm/mmap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index faa5aa615389..d4eafbb82789 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -17,6 +17,7 @@
 #include <linux/sched/signal.h>
 #include <linux/sched/mm.h>
 #include <linux/sizes.h>
+#include <linux/compat.h>
 
 unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
 EXPORT_SYMBOL(shm_align_mask);
@@ -191,7 +192,7 @@ static inline unsigned long brk_rnd(void)
 
 	rnd = rnd << PAGE_SHIFT;
 	/* 32MB for 32bit, 1GB for 64bit */
-	if (TASK_IS_32BIT_ADDR)
+	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
 		rnd = rnd & SZ_32M;
 	else
 		rnd = rnd & SZ_1G;
-- 
2.20.1

