Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9249CC28CBF
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64AB22085A
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:59:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64AB22085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E725E6B0005; Sun, 26 May 2019 09:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E22366B0007; Sun, 26 May 2019 09:59:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D38EF6B0008; Sun, 26 May 2019 09:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83DA76B0005
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:59:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so23234135edb.22
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q87r3fNmNCP3Biyq3RF0DkHapd6qlpuqLXAsIpA43rw=;
        b=JM8B2Z5sCt6uktATMgtysjY7kfjtQ2M9k+PmfYFZeXOYkPwciWZbeGh3Cfr4mUQzuG
         YyubRFvG722LjPgD6MVvPcuNnPrRd/D3phhOOW4gTWUk6fkrPigYc9MMgN69cvm2DROO
         JtpDEphVTcwiEJS+MIWs1X71i6cgy6NsosK9zcshqhM5ylEEO6UX6YmHtt7FvPESQWrN
         OfWpGtFIuTlBHnx2/WZOYQseUirrUhno3xMiKBy/7x2l84sg0Ou8Q1jZDzKIOsg71CwW
         kBvb2SM8k02WWIQT4r/bdf2GQ2DxKrJjnrkOmrxJvgws6kEQHaZWZkxfaxkpG89B0m6C
         H6aw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXHqat63brWPJ1aXFvRSqOSDKx1FwJyeifi9QwXBqhZKLmcgKHk
	EEo6ZgPh52Lf8v1qUL7Wl2zHPRgTDNSvsAwF3VR/TT1lLdAKKIb2djquniQTsKuqPI06SD5e2YX
	Sl82JTML89plI0GbmH69+7J/aDBDFWKZyCEF/k3N1VvN7qzAI7QThP56AMTpjp2w=
X-Received: by 2002:a50:9435:: with SMTP id p50mr117824098eda.40.1558879157058;
        Sun, 26 May 2019 06:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzuvguqB86LazKYwuKUUnSc7CMFbsHKFMrijGXATMNu514Ez3IVBBCS4VneYPmE4TOxlVgm
X-Received: by 2002:a50:9435:: with SMTP id p50mr117824028eda.40.1558879156008;
        Sun, 26 May 2019 06:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558879156; cv=none;
        d=google.com; s=arc-20160816;
        b=eojFf3BOpQUKfb5eyNAF7f2jGSwhjBzPlBGftOEl7F+aSpazrucCgI2jvwBaVAI5jk
         iu24y8tpcq+QcAuTigXNCoG4COZEKWTmANBwFschCGItexsqqhThBs07xsNuw/zJ4e7C
         210uK9tYEiLTN4dKTCNsVn4aVPohfJzR9yOjid/R4bWJHZIs2oEdbm8btGp6joYErq+v
         0wVNbteMISPrwr3ejkQ2R/xva/TcnexitqEUZwaMwq+C/qmpumua+tkv3JOjURzdjSvF
         ZmfVTeKCcz8Al+JoGO853sGiEZtSEjnkRIgt1vMFJ/c5reI24iwDLAI1xiO1ToVIwPLQ
         C+GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Q87r3fNmNCP3Biyq3RF0DkHapd6qlpuqLXAsIpA43rw=;
        b=ZOvzo+U09q8aF/C/xYucIA2290JUR+VY2kksz3lawWarXT5+5mocwU4jZ+Hcq4umXH
         4LFXzeuD9z0ZNCknChp0aTStokrNafG2CvMAUmcoqKi1dnhPmjoHBoLMMdUjVKxM5rfu
         f1ZG7okMD7Bn6ETjja2nTFUZ3L03KfPY7k+8avxM+NBYTLDGTtz8/5xUmj4t3UwNHd3Q
         myEksZ7rdibJIyCCy+jU+K6EzjI5Kp2fO4nUWrNba3cRqK9skcZPe7wxnv/RQI8YP2p+
         JUXngr3HJIBNADfCunfnHJCpKZAngnEk5DM7VXov0EksdbS0FuXFWOsNgmhXZJiR3M+e
         /eyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id t57si1466371eda.339.2019.05.26.06.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:59:15 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 974FB60003;
	Sun, 26 May 2019 13:59:11 +0000 (UTC)
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
Subject: [PATCH v4 10/14] mips: Use STACK_TOP when computing mmap base address
Date: Sun, 26 May 2019 09:47:42 -0400
Message-Id: <20190526134746.9315-11-alex@ghiti.fr>
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
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index 3ff82c6f7e24..ffbe69f3a7d9 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 #define COLOUR_ALIGN(addr, pgoff)				\
-- 
2.20.1

