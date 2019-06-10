Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1E61C4321D
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 982A72082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oiEyUrF9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 982A72082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F6B86B026E; Mon, 10 Jun 2019 18:16:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280E76B026F; Mon, 10 Jun 2019 18:16:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0894B6B0270; Mon, 10 Jun 2019 18:16:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2E6F6B026E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:34 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d19so6523415pls.1
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C4SI1FY60nHM9WI3SinoYDutxba0iN08JIEwzLdROHQ=;
        b=Bmp8n5TIgw2W5ibdtJEBQlXwsSkmNzClD5PlIFzeSQ0R/Nfiv52f65zCrMGMtdEo17
         QhE5UbfQ498umYenADQURe4PaL9mJx5eE69uUv+2efjbnumMQZ1rKZwLjx3ROU8qSCWa
         rIz5t44vN6s53PhF2W7t1DxvSo5/JatsQJhuXu6901WP0gqSzDbcQA/t5kH1Fc5F2eNW
         RQm0L34wGYuYSfX4FyGaddyCUiQN/78Bl/CytqPoL9mb4D5bHbq8Cew+Mgz912N8bkzM
         GQc64VE5eUmHXeLoUMTlfycriMcU2YqrW0t8Xx1QGxeSlrUWoMNEgCaB0248LdbWZVvr
         kU4Q==
X-Gm-Message-State: APjAAAX3D+h0Ynmuv/ElAuK7H4rZY69GgcL+IIbJi1DvEtPV5zfwYY93
	/8arQHVVbJ9FHFGLbnL1pxo0nNXD4b+vSnNIoEefg+HftAj60oCagrzvQT1G0CQBuobj8uDTuic
	afCeNtqeJXYCkFHHcP46eoe0aB61GgwQf+Rs3Qag5UVFSeMy1yO+leJS/ipC16lg=
X-Received: by 2002:a65:638a:: with SMTP id h10mr17982448pgv.64.1560204994268;
        Mon, 10 Jun 2019 15:16:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyowL0/oco9JQB1afA6buVM9JXVinJanQPEHXwnVV6A878KIsDdLkwudm5vGUM6Bh3boy8Q
X-Received: by 2002:a65:638a:: with SMTP id h10mr17982390pgv.64.1560204993439;
        Mon, 10 Jun 2019 15:16:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560204993; cv=none;
        d=google.com; s=arc-20160816;
        b=WV98FK5LuVQo3JvydzyryF5QVK6hIi8LHEi7rtOKiauDn3FubrA1ulLHamRsK/5Cmb
         EXZ6a5GIWIkIAg0Dzc40wnNr22kAhzq2GonOUR5LBjBOsBFVPgq/KL44mqluVO+wzpU/
         xZH8uWmEUFGkNUTgZ9G87u0NUIGN35VKTGzrZfBOGofM06vZkkoRd1Wqw44KbqEn9DdX
         Z4gSAQifHBm3VuE1zb6IApyjkA/Xht+hLGh1PCGimy1el5q95X37jYlpwZq+WOplHave
         wWthym4ZRmZNyjoxLD93gTtGfC3AZlXD45XE1P9Jyr8yejp82AuwBxL/c7lybCKDzT6p
         z8Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=C4SI1FY60nHM9WI3SinoYDutxba0iN08JIEwzLdROHQ=;
        b=YsJtP/4Lj0ap3s/Am1TCKpygN/MGQ3Mq/Ukg9/4RvbHnw/Ovsp655hic38PwKB7OA0
         m9CFsyD+zg5rOUCB+/J2RmzAa03MifcVBlYCfGsJGSv5s5vbRMAkQ/V0V2P25KjpuOY8
         ocrDnWf7XPRFpWpgCNRYv3wjTwr3KX+LgF7474CHREDbnNL3jLin6EsOdecf/laRLyD9
         vPyUZTduUTwXMEI0XDztbdw9CWPnQ5ZvOzTUG9KG8MH6fLvo9xkFsKfuTc6Hrj1v1Tp7
         CpTzDzFOnn0MEjfe5AgFfdQxauBAXQWOTz503yZFL2rVFUiOFF+MxCf4FsdkxmqfZ+ID
         qmZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oiEyUrF9;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i18si10381703pfd.64.2019.06.10.15.16.33
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oiEyUrF9;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=C4SI1FY60nHM9WI3SinoYDutxba0iN08JIEwzLdROHQ=; b=oiEyUrF9IL6rgPxNWJeKLxV3Vy
	A8cdnaU0V5jZiFy3sqNuhMbp91le0IAXzEcVclX9d5PaW1wff2o6pTA2bVm2UN/onTrJQeQHryhSB
	nnUPnH7xpOvpXmaxOwDz5rOGqBMRMR9NOBhqyJ7XBHdXPfiNQ7Mrhp+9f29lQk9Y2BTdGyyJaPI6q
	TVeAWffkUc/loManhERDhHXfQFG0B8mzkFQcnNPbAmCYplm8rVef85/v60iq+c5KwdSp2mrl3onW7
	9J84YrKSW1WBeNpq/YL/fl/gqcugODpbtY3JYypgfqN8/G4+0fyb15o3i+3K2HQTTcFQgDpiCsyvL
	jnUhjrDQ==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSad-0002pA-7n; Mon, 10 Jun 2019 22:16:31 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 03/17] mm/nommu: fix the MAP_UNINITIALIZED flag
Date: Tue, 11 Jun 2019 00:16:07 +0200
Message-Id: <20190610221621.10938-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can't expose UAPI symbols differently based on CONFIG_ symbols, as
userspace won't have them available.  Instead always define the flag,
but only repsect it based on the config option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/xtensa/include/uapi/asm/mman.h    | 6 +-----
 include/uapi/asm-generic/mman-common.h | 8 +++-----
 mm/nommu.c                             | 4 +++-
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/uapi/asm/mman.h
index be726062412b..ebbb48842190 100644
--- a/arch/xtensa/include/uapi/asm/mman.h
+++ b/arch/xtensa/include/uapi/asm/mman.h
@@ -56,12 +56,8 @@
 #define MAP_STACK	0x40000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
 #define MAP_FIXED_NOREPLACE 0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
-#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
-# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
+#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
 					 * uninitialized */
-#else
-# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
-#endif
 
 /*
  * Flags for msync
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..cb556b430e71 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -19,15 +19,13 @@
 #define MAP_TYPE	0x0f		/* Mask for type of mapping */
 #define MAP_FIXED	0x10		/* Interpret addr exactly */
 #define MAP_ANONYMOUS	0x20		/* don't use a file */
-#ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
-# define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be uninitialized */
-#else
-# define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
-#endif
 
 /* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
 #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
+#define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory could be
+					 * uninitialized */
+
 /*
  * Flags for mlock
  */
diff --git a/mm/nommu.c b/mm/nommu.c
index d8c02fbe03b5..ec75a0dffd4f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1349,7 +1349,9 @@ unsigned long do_mmap(struct file *file,
 	add_nommu_region(region);
 
 	/* clear anonymous mappings that don't ask for uninitialized data */
-	if (!vma->vm_file && !(flags & MAP_UNINITIALIZED))
+	if (!vma->vm_file &&
+	    (!IS_ENABLED(CONFIG_MMAP_ALLOW_UNINITIALIZED) ||
+	     !(flags & MAP_UNINITIALIZED)))
 		memset((void *)region->vm_start, 0,
 		       region->vm_end - region->vm_start);
 
-- 
2.20.1

