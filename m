Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88CDFC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4650D218A5
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MUd+Y8oY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4650D218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C3526B0006; Wed,  3 Jul 2019 08:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FC206B0007; Wed,  3 Jul 2019 08:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2009F8E0003; Wed,  3 Jul 2019 08:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBD9A6B0006
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:24:06 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x13so1508668pgk.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 05:24:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=;
        b=Bi0P/aj5SI6IgfwSMswzjq0r2+VjI1mHpK+Th44EJ1D/Ob3yE9hJx3WKPfjVnfd1Gj
         58okxiJ0koodu3v8Cv4ZBlE9Qn/99sr4E8lbf9Z99I9Mh+EHPaLC0hbQon5s85zALt9g
         vMiWYIpcKXuWq6zYkvm4eA4B/TlfeHMuRzlrmrrXJm2m2DkgqryN15EBxiWbf4XU2Mlq
         lBk97uIQbl+JDKpfsMLm3voJclGKic/1aev6jkLRD2OHJPJ5sZCFBEQA/MiL3RoNozo5
         z2IVuWor73bZ/rIXmN6Yqr/pKC7pyOgzqSiG9joBLyVfDeaiYvAZt82Tc0oUvHW5d0zu
         lmHg==
X-Gm-Message-State: APjAAAU3ulz1xH5AWI469/hHwnUXoCt39QZ716whCp/+yEU3b/zOqe+Q
	980ga7i9yVHll01WJFwShOZ7NiF0QAQYLTotZTxrlx2bAywtGQ7RCOE78JLWdG89hAaQpmLtXK3
	p5Jif6hLtAEvhvj6YB3oVpG4b52HiwGJIEfthirw5OU2tB4GNIvonSny9bliIbpU=
X-Received: by 2002:a17:902:e011:: with SMTP id ca17mr42879526plb.328.1562156646554;
        Wed, 03 Jul 2019 05:24:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwXmSNLc+g9pdn7+KfjYljvPAaB2kMTeGtmFQUMof9KacJ91md91M9LR+kqKr2vYQEGlOw
X-Received: by 2002:a17:902:e011:: with SMTP id ca17mr42879452plb.328.1562156645850;
        Wed, 03 Jul 2019 05:24:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562156645; cv=none;
        d=google.com; s=arc-20160816;
        b=Eoee8Nxa3D3PfHV4behrNtDZXKyYoV8jvR2roEDO7dWxIBW0e1XdhZmlW5RS3GH4jf
         85E27gz2c8qdO4/0L+Pve3sImaWAB8glU96XTxnSNwAaVOGBCBcLSl2+NjrxWXo5pjJj
         oPWNudyKD+MjSr4AjpCG1kdEHJXpildcYh4n+sxjwV8mJEala+jstSJTv/DLmrFaOv5r
         h6EQO6hq1OR0f4LrDbOq8y7LCFacuy1wtomqHj/1+/HVT3v5NghwmIEGpXXX3MZUfDxo
         EgCQufPWLBWEE1mO7Cw5RgXaBFjSqE9YpaGynxFEOtOqh65NbSM7Us3Q05AKK/erWZLf
         1xyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=;
        b=0u1sClvRgg/O9ua4BVJTSN+5HmUzrfGoXakDsu+B5x5MycZSnQdeiY3EEI9dnGCqq2
         +bd9ek4R9iEfdjSns9IUFw8A9RpEOK+4fyrneZnm34O3ulVpjwLRz7YDcfe8VpRCZrO2
         yFXfXq2nmihf/JKa3bskA0t5xOBOoOgfwhdSt6GEFfvo6AxA8vyqh2NkuUZZ5ucxhhVr
         L/Ekj93prOcaziYPewJrEDDP5Rmq+d5P3pcaW7jHqQkAUFsG7J7Vsz6faI5oZYLPx9An
         I3LFmBSGZT+hZtao+lhOI56Ym8M/Hmpi+/4n/ZInuOVFKNdvFHvL4WxprX+nbRPISmSZ
         oBMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MUd+Y8oY;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d6si1869808pjs.47.2019.07.03.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MUd+Y8oY;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=; b=MUd+Y8oY0cjPM7Ngrrh+1QbvVl
	Iw7GC+wh6WoOk+ROg6w0IVi1yeZnewXKsyHD94h3+H+Ffm6j4+AZ3ZfmDOClO0oeEPCDaGD34se6z
	GV0q3TmKG1k6TxqbQk0XfKokArCLw7Wk/4mphZyt39WFQrIU4fMPt6lt3xkPfPcPB5PbPuBi10Zkh
	1/4+r8JCURCHFpcv7VSmaEv/gFbUZTXz7BqcMFPC35ZpJCyrFhqDsnGTzm+KsVRosQ7jfMNCYvpMR
	VfCCGCghP2oSG5KB90hF+LtbuxRmLjlEj9S/xC+lP1nRbuj0puic+0MpzE6pZa7KX41QhSdkIg52N
	GBd14KhA==;
Received: from [12.46.110.2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hieIp-0002Fp-Lr; Wed, 03 Jul 2019 12:23:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-riscv@lists.infradead.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 1/3] mm: fix the MAP_UNINITIALIZED flag
Date: Wed,  3 Jul 2019 05:23:57 -0700
Message-Id: <20190703122359.18200-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703122359.18200-1-hch@lst.de>
References: <20190703122359.18200-1-hch@lst.de>
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
but only respect it based on the config option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Vladimir Murzin <vladimir.murzin@arm.com>
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

