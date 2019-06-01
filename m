Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0069CC28CC4
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEC1027149
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hyjPcmLt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEC1027149
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76D206B0269; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B0CE6B000D; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5042E6B000E; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 039496B0266
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:52 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z2so9158768pfb.12
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PtF6JlZd/BfV9Typ91IQ/A0fJXKPUUPSZdBpZtuTT7o=;
        b=FX6bQzIhM7LJysTOqYfULk9RaLq4hePY1ZWwzfOaYsE4UUb0tdT4w42A4dPR9loBu2
         C3UWxpZdGo5yl1Pkko0rfVGxNCRDp448lzA67yw4v5vLFudVNZ9b8HcJdGix1ohvhu/F
         CvzHOql/QRA8aunZ05laiRBDw+Vf/1pVKUS0EW70g/Q6du93wU0UUC1A5oxwZnlLw3wz
         q3++e1Jmy/DxSEduQkH/ewJsdApxdMPHc1apLak6KSXKbrPHyz2bUEuIhpW8NoIS4cZZ
         rHRd/tqIK8HPzTKDqL5XWN7R519WUqL881xWx3PwcEsslKeaBj/qoc5cjsF/NnYacBLL
         2+Hg==
X-Gm-Message-State: APjAAAWJF3q3DMGQEikfphXspADLa5XhAaVTUBANS5AvDPfr1xBXi+p1
	2IJQoc7vzT9XXZCp+EyKkB9BjVRgCQn8Ymjgsmh0PWRv02arZIkDFT2eaB3gX6KCBDMPV58XBVi
	wKJvqDEtuvQum2yqmHWhEK39NUx7bzuEsn6MAaovTiuzyrintiWfpPobRJUmE1JI=
X-Received: by 2002:a63:5351:: with SMTP id t17mr13804805pgl.152.1559375451595;
        Sat, 01 Jun 2019 00:50:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJpsOYGCjb7fGpQeKszlTBINJTpCcfQvo0AcAHEDO1Yg+TmKXWlZiwjsn/ANUWdhWqOKRg
X-Received: by 2002:a63:5351:: with SMTP id t17mr13804717pgl.152.1559375449540;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=Pe/ymI/749VQqI7CvTcjFFp+8qnCTtg3vqp9ab+zkyh2ASqASA7vqRBswXb7XnaZgt
         Sqm+Ze/mFSDyV/JvX+nWh9Ri3q62tV9Wt/s1glK6scbQtNFHxg27z5Tqc44aIwPqDwv+
         OPdc+dOyliiezCqIx+FnvWF5C73YHI2FghwmhLHIRHIwZA6l68VjplQRla//u1oI0wYI
         BlZe+bJDCH6yNoCadFGe+1sGzwVAy2LArTrLPNDf6hI/0wS2KlC53pGc76zqIzhS3Xq8
         SC/MGb4E8YElhOQsUSfpou58aT9SWRD+7sjt70cuoIxssEFK1u2Q4LjbUmLTTX/sVSxC
         SCPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PtF6JlZd/BfV9Typ91IQ/A0fJXKPUUPSZdBpZtuTT7o=;
        b=MjmltGMdF06jmoGOgecwV3JA/uQULOQCsuGS5LczUaMTdD6Y0fUHFN6p+jW9s54ZHs
         RQUTWF6iUHxDgw0kyHiOvZMokTnOj6WWBFHdxotYJMlr/GwZ7jB6whASfHXSOUA1QgQz
         d8G+CWDUQwAmrm7PYcc8/3AkX9NveIneICPry0D/uQ6RfveBykUXBr6eElIbXw7yzNmL
         +WxarjHzbEcHLR/j8x583+i90ytMCikaylMsZOVUIda7D1F9gTdn1LIc8DzjTLy/YcKi
         VuQ4ywRBbRGaDy/3yeBXsvWxnIDJAeDABieRFdBdWWqICWLfJ98vpPXKc3KJeaLc4PpQ
         Wokg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hyjPcmLt;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m2si8670769pjk.63.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hyjPcmLt;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=PtF6JlZd/BfV9Typ91IQ/A0fJXKPUUPSZdBpZtuTT7o=; b=hyjPcmLtpzsxZZqlvh75qKW2VE
	RoZyn2HMekrjZEzE40C041i52hpzuDfJwM9cPRPWwQv94nzemt2EtQDVo8FnM2sTEjfWULCnI4RpF
	2erohWRZG7mJT0wIIuj+5YXhdN5c+UEHTV8RpEaE5ee+1/XHYJQkGPkDx5itNmZ8DNZ/IX0VCNnrG
	f6yXEMbuiDDcfLxwKhbCjeKq2CErUUmhFfeNIhe+YM71UCFFu7fh88Ofk8jVC9pra9GPmUb6HnPDY
	DL8V2wZ7t0fs4R8RcM+V7Fp1M0082VCLwHugE0FJCxBWvZ1WH4OKbhzAp8L5/ZAIw4saZVbzvvJv+
	ti/0ydPg==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymE-00077u-Jv; Sat, 01 Jun 2019 07:50:07 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH 01/16] uaccess: add untagged_addr definition for other arches
Date: Sat,  1 Jun 2019 09:49:44 +0200
Message-Id: <20190601074959.14036-2-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrey Konovalov <andreyknvl@google.com>

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..949d43e9c0b6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.20.1

