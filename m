Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08EBFC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B82D62089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="oQ+2sb4O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B82D62089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9146B0008; Mon, 24 Jun 2019 01:43:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42FEC8E0002; Mon, 24 Jun 2019 01:43:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31D678E0001; Mon, 24 Jun 2019 01:43:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F007B6B0008
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so6726825plb.2
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=;
        b=h6cU5z94bif5aS8SjblqrBF8S/0cqI5GtupIvSsr45UmGkUhfCzKLsP8Wk/z9Mdlyr
         Sw9hVDaZuC4ZNEu4jg0eWoTRiZf4Po838AFTZ7v6MyAQbIzHJJ+i5oNV7ivygeUVPqYF
         wajygIjsPzosVHajLVs2xWh/bG7yZn+JLK+yse+7aMOM26gV+MENKCigG/Z8Qx58sMZM
         1l97E+Bei874Bbk5kk00cKogZXlkqrA+j5pxoq/b9v5EE5d5hEqgiFkyZP+VC3Ihun+n
         v0u33Apm/DbiTYoOE4hZngkXBnFZ78kqxvUpRSbQFRwZaNwyBd0iF04yxMMJfQvMHIQh
         /B+A==
X-Gm-Message-State: APjAAAVPEETG0XSQCvAHfhom0sW88ucbmweRCb9y1Ri3KbCbNXPeCcjp
	VxOX/WgHIuCXlUlno5GE09fXzUfB4VMDQOdnWXhSSEg0K/u2Rhz8KIIkcJCbmoh+hmr1PVmHc2+
	yEBpSVz/jz7lrveeuqWYnAWYECf9dZF4oyg6SyiZGf7pdxrwH7PvlzEL82Hpr3Fs=
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr23597640pjr.116.1561355008655;
        Sun, 23 Jun 2019 22:43:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTl6hB2AVkfbG3v76yxi4IOhRmbQZB3Fgd7xDOSALWZ1rIIMLpuMUKf9s3i+i/muBlpMQB
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr23597579pjr.116.1561355007908;
        Sun, 23 Jun 2019 22:43:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355007; cv=none;
        d=google.com; s=arc-20160816;
        b=Qm+WokjI9/N6N9fEbecMdV/1IpJ0kXV8Y1tpzVa7a2TwSnsEgsB21OtRoBbhmS7+AB
         C9kqOW0ItztDER++Bg59BtwDMmqVs9tnftjC1RNck7z5z1Bi3wSc17T05T5QCB0HDFKX
         +xuctMGZEhopFKGL4jzzKcI0C0vR4A+8N33B7KhMeBQEvk4h8TkTR5jg5jELGYVKJsR0
         KEFsFzUYnRwcOLNTzeaLDx12KJD7DTvnhgZzXW9lRK8ZFt1SBydzAQHAzLyWRz38G9U3
         Y8f8Ps0ecc/ASBbSC0COmTRZmSjHOhE4mhjNyNmpDx0DJMxEF962qdc0mGYiBnvKRDOK
         kJlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=;
        b=SI0lT/uwdB1uADlesJYvSS2ivQCKCyIUZQ30TnSPMSh2+okNXXQuhKmmZLdenafg5l
         oYgXo3vdvZVq21dWQb8NBFnNw6Mf71TRtM4Bdf83nMFFj3sjjrueFswi5TK7uwStcClQ
         W+m9rgTJzSJTbFZPPfZcPe8f/fI/7GkiZj9lqU+8kmf0xaNTb9iqYeEuK7RgDKRoYny5
         Hw/BX5zOeWKCMe8UGjU1MAuvZFKySzWLeZFck50sq2enjQaLIsCeWmpuaTokity/mJwv
         ftjpwp4Rr4ZOJ4rv7A+/5Yt2exQL58wTevUG6oF/qSDa5h1MZGYXooVlm77cZCFu44Ws
         huzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oQ+2sb4O;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m19si26085pgb.523.2019.06.23.22.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=oQ+2sb4O;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=dGgF55hFtmmmZc+ieAzS4XO99ZIShl4dVYuogqe2WpY=; b=oQ+2sb4O0ME8d5ABjk4P58q0nw
	GIsnV3dmJ/XiMyp6DvmASmc4e5qGID3C66YIiTWRuy/o8Ws3yDWphOJBSiduNIzLdTKUaicf/eT5+
	+J8xkvIy0OgTS9FXTCwbHDLUDO2czpVwB8TGgdLKOE/Fc+tVqHBSOvSMYLGLtsPKFswRD0EGvJ0bp
	AFIsQdQU3ONiJIJ4edKqFETEQtDQuKbY9oUUthtrbn2nDZik41DPsPUguFaOzAHoYKZvQzRL+t5LX
	BJKN5z/viz/nDZY3Ue8edIuv8pyfQgby9aJmhKEnEVq4ZKaEnbDqV0pszHiwm9V55p3Pa861BFO6P
	BV4LEQ5Q==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlG-00068k-3f; Mon, 24 Jun 2019 05:43:26 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 03/17] mm/nommu: fix the MAP_UNINITIALIZED flag
Date: Mon, 24 Jun 2019 07:42:57 +0200
Message-Id: <20190624054311.30256-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
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

