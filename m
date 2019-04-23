Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2988C282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EF96217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MP9XJpD/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EF96217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 251FE6B0010; Tue, 23 Apr 2019 12:31:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 201DB6B0266; Tue, 23 Apr 2019 12:31:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A3576B0269; Tue, 23 Apr 2019 12:31:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5BF16B0010
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:31:32 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r5so3940999pgb.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:31:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=F4ovugSZ4k518reRfqbXv2B9nKVl0sUZlFoyZr4rX/Ud/YTuQdMdnqx3N0ZAJOluFF
         AaPhE51/xFxrEDRKK8oquEBX7ro9wPZbpP0kZyvEqN6ahue6JNZalQwGlNPpkajUypqo
         i+mIeb5sEricYPa1uMHORP9W/ob8NAuqaEjyIbwzan50PdWia/MewKU07skdP1FT/UzS
         5EKs6NsL+SeDkTaQwABLhJWSga3RPoFRtO4Rr2zpS2VM+fSKZ1ha+569VoGFhwEdJK7s
         zpkY4v6uMcUQX2Tv/KK9gL5UqZzZ8Te0gDBg8jmx6V7419GkYmwoQ+jFTZqBDnim0k8I
         +X/w==
X-Gm-Message-State: APjAAAVkMyp/nbZ/Xh1Lt5uO7Z7xxG1LBzzJOpEHsz6Trjck20kALNHE
	DnWzK4kPeXfT/YXWT8NpvirOgQO1CL52goM6XThaKfMwF6hgf3LosC5UfcMrykcxPV6m5RoNraU
	NtLFRngFoTv6HeoEunAjb53al/Y/HpYGJ4sxZW0KX1S4yEPARMtaDu76FE0QLC28=
X-Received: by 2002:a62:480d:: with SMTP id v13mr28329721pfa.125.1556037092480;
        Tue, 23 Apr 2019 09:31:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm0GIdFNcQVvELJTt4+5KtQB0STXay+rxC7oGsV92Bna3w+cKSJT9WIPSaxWdGv6C/T6Zd
X-Received: by 2002:a62:480d:: with SMTP id v13mr28329614pfa.125.1556037091514;
        Tue, 23 Apr 2019 09:31:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037091; cv=none;
        d=google.com; s=arc-20160816;
        b=HdDMwMWqbErCJVWSCikIqnSR48LUUMdx+j/MMQF/Oqb3naNR/G0eohx/udPQ670MNQ
         ubLHvL+3qmbkLKTWkhRpi/QniprLK38mxqVNnYV3vvXjpvi6eAo2q0fYE5qczjR/iThu
         6Vy8EuDIm51FIG5OoClWmFiM4w2/2HHMf+yTqCPB7kPVCMkFgjZgXPRDAWEiOX5LLN9i
         uCfowTgY0BqRZ/IzjS4HGCEZuDxjDmG9klZoYPCHu414eu9jfbS+rrIoE23Z+lPZIRjC
         tznjglnfrYxbYrwdloT/RbSrdb2CGIJP2jJwmE8Fh7tkBBsBiX5nu1I6tGioe5w3NuzA
         Ti5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=;
        b=bl7l2X0U4ipF4QE0HFKmRzMrjm+pwTqDzcWNVzLdUUZWLn6BD0bnQUsboJAhhHYbMi
         imv1jdq04S88nHg01597giPsOAjaOGf9tYFPUbQVMq83ui+5DZ/lB9sIGRRNJ60YAnxV
         432T9OmB1xati3JnqsARgTforPzRBazPKcg3d4nSBitNsME/cgtxT9FJfDYPCZ1EV9+I
         /ElDdDl8x76xRkaaEuPsnFPdY/Wr/GjnOwEWIGHDccvmhnaGu+ZZ60IyRjaUyFsmhqUJ
         +1YBdxtc8ZvqJFjBGONz+alQaW76jcwEpbj4y7btHFTw7fFyTH6EvNpoxAjNvXxki9/7
         lTAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="MP9XJpD/";
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 34si6533296pgt.306.2019.04.23.09.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 09:31:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="MP9XJpD/";
       spf=pass (google.com: best guess record for domain of batv+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+307e856acde472aa9de6+5721+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=uHFTnl4vUjrNVYTFv2dDUy+7np+VKavI9He7Ga2MW2s=; b=MP9XJpD/YDBzhAaWL4T3dWWcc1
	TPxn0IQP5ZtDi7WPcFcZFv5WwFUYahtTpxT7289UxxSBI6l9Iyl42Rm/9e0rs+uU1YymrfyH7z8Yv
	NsLEbkTbBin707y0toERTo5+I8BXuxN5I1F3MngkS/0XGC5v7INfjyC123nBirBr9tWBioJxo62Kx
	I5J4brPLZcirfF5tz/mK1mZ2tLW9W3zahmqrPCcW/NwijeAlhd35+cDe/EZYDBbjj3x74hnwcO6rn
	b23U81AyYKrUKyH4iCm73SUQP3/R2dtNDUQ0NepM7wB5qeXZvMzA32LMBhPpbh32ZKA/7aihMAnhQ
	tHbZ915g==;
Received: from 213-225-37-80.nat.highway.a1.net ([213.225.37.80] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIyKQ-00042x-E8; Tue, 23 Apr 2019 16:31:30 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH 2/2] mm: stub out all of swapops.h for !CONFIG_MMU
Date: Tue, 23 Apr 2019 18:30:59 +0200
Message-Id: <20190423163059.8820-3-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190423163059.8820-1-hch@lst.de>
References: <20190423163059.8820-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The whole header file deals with swap entries and PTEs, none of which
can exist for nommu builds.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/swapops.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..b02922556846 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -6,6 +6,8 @@
 #include <linux/bug.h>
 #include <linux/mm_types.h>
 
+#ifdef CONFIG_MMU
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -50,13 +52,11 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 	return entry.val & SWP_OFFSET_MASK;
 }
 
-#ifdef CONFIG_MMU
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
 	return !pte_none(pte) && !pte_present(pte);
 }
-#endif
 
 /*
  * Convert the arch-dependent pte representation of a swp_entry_t into an
@@ -375,4 +375,5 @@ static inline int non_swap_entry(swp_entry_t entry)
 }
 #endif
 
+#endif /* CONFIG_MMU */
 #endif /* _LINUX_SWAPOPS_H */
-- 
2.20.1

