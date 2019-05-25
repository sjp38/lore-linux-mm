Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7822C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F0672053B
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k8gst9Wu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F0672053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48DA06B000D; Sat, 25 May 2019 09:32:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43FAD6B000E; Sat, 25 May 2019 09:32:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FB636B0010; Sat, 25 May 2019 09:32:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E87316B000D
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c7so9204156pfp.14
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LECtn05W6P2NimP0OllUf9vpm+KEHNIpicbdgrA2kyI=;
        b=EjMiwu2tN1HSHUkOTuDLiadHDCgRwhuYYBUtf/mpXGpmDhhvhnoUcK/oKl0lVJN6QB
         Wy6/XPUG2mgVfdENCvKe2v55Xix6d9kEtbIjoa6j/mNeIunYzv/9H5OHiDJ8Gt0JXguD
         q1iwxWIc98RVbkGos6aKEcdVRQmcyKaYqKE+VvJvhsjg1GQ4w3Mpxw+R91DcXTBaejiJ
         OLZ4dfI4hKnaWBF7RjvoIl4nZLeTJSm32ioMnvPAqbluBhn87P1btbdtmXn62J3Ad/2D
         26kbxFB3WNUAPe5lsnf2Tg3dQ9Tn/YIBQzX6yDlT83pKWtJbxC1l5i+pb48iVJYcun9D
         FXTQ==
X-Gm-Message-State: APjAAAVRSgOAygL+Iw7thg9CCo6bEehprZq/Z8DeFzkdZC1k0cumURPP
	sinfCdm6UA03qACqDkipXAiOotE5xMV6uAJh1/nwumfI5Dx2NctxJuPXdmZlcj4za0lDj5+L04I
	S6tcHe2V/vmKXebHOGYVW7k7v5qQnATTgFJ7j1cv7Uph7t+X8CfDe0Lm3Rxl3M80=
X-Received: by 2002:a65:41c6:: with SMTP id b6mr46691296pgq.399.1558791149586;
        Sat, 25 May 2019 06:32:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+7+G2QYfQJ9QEoBwi9HdGg5QdNC7SfZS89KmagGhQ84IBSJ2oEYYD+AdZz22DZXz5eWob
X-Received: by 2002:a65:41c6:: with SMTP id b6mr46691221pgq.399.1558791148858;
        Sat, 25 May 2019 06:32:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791148; cv=none;
        d=google.com; s=arc-20160816;
        b=c63Mq96OBnMs3ecxxlFt/JYpB1p73aoRy1hhtz8Z86fCAWZmOzw+oK7X/Iqd1hmP86
         6qN0QMIZGfYU8Y0s6RoCXZ3zjB/uCYI2+eGjAn3RG8ky5vCMZC/XzlqbZwWZ9A0DuiBp
         aALpAreCHolZHdZvExv7rrIF135NQibezHTDdTz0kzeWFSWC9yjL4kY7GmJE/+YGwafd
         c8drM2f2CzEu+UUHWH8njnKgY8l+RNU/wlX5pnyXiuZXxy6OJ/G9JXqn+BjITbDHfONz
         cTiARbAGuRqpEGAxMQaSnSzRRiVcMDWZPNCYCDMvtcwpB5/wu0Te/+DuNymQu4Dhgy5p
         ywrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LECtn05W6P2NimP0OllUf9vpm+KEHNIpicbdgrA2kyI=;
        b=EpnBbb/VacNSzAExJE/LzEVldgoLp1ltcz7UtKAEchutySNhm74Gx64N0N1hXIuP7z
         Vulm6gQ2H5ovB2TJfPfYPJjGX5X0Xie3s9RbwKASTbNJupSp+H1rkbutmlD9jEyYChwa
         qCVnGivQ8xTwe7VfPvqPXbSBncgYPSc2zGUgS+DZq/2AW7z6lK2PPtvRLMKxpZSGBQWg
         PwyAWYHjxC5eMPwCFIQlcfjbo68KNaUgi7rnjVz/1GUQCalQ93SjN/XGiiJlYcMD5hbD
         sPwHkEe69vCQC70Pe3IuWgpzelyK2PHVGXBT/s1EQ2Kzg+23yyZjnjX/G5mZlC/OTnQv
         j87Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k8gst9Wu;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f33si9064288plf.166.2019.05.25.06.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k8gst9Wu;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=LECtn05W6P2NimP0OllUf9vpm+KEHNIpicbdgrA2kyI=; b=k8gst9WuPquL97md/tHmXZQkBD
	hn0QTx8oa20csZMaFnMKCBgUoSKd6TRGT8nMw+l2blX+vM5IsiYEr+trtkLraBToZuKn3VDbG5xuA
	cxls9b6CRrfMWHlXo3zhCi+l/ucpwTyxtSx2ySEtK0P679gUtIOAEUfXBigaj2lDLiWSZ/Ena4l+d
	/Sw9q/76Y2EoiKyUoqSvVwaidlPXWIMpo2+ZZ4jIQRzvZcEl3DUguMES55HjopjazGs11iTCGD0J/
	VFnyOS8e+p+fdrnb/SNdr/4wUWdWzJjdRagRamO42+zKlAZdPmIuNkVdJ+W3eXNbGqrnfUEXh5m5A
	FjpChbeg==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmf-0006Zp-3t; Sat, 25 May 2019 13:32:25 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 6/6] mm: don't allow non-generic get_user_pages_fast implementations
Date: Sat, 25 May 2019 15:32:03 +0200
Message-Id: <20190525133203.25853-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190525133203.25853-1-hch@lst.de>
References: <20190525133203.25853-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add an explicit ifdef instead of the weak functions for the stubs
so that we can't let new get_user_pages_fast implementation slip in.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/util.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/mm/util.c b/mm/util.c
index 91682a2090ee..74ae737ffd95 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -300,6 +300,7 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
 }
 #endif
 
+#ifndef CONFIG_HAVE_GENERIC_GUP
 /*
  * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
  * back to the regular GUP.
@@ -308,8 +309,8 @@ void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
  * If the architecture does not support this function, simply return with no
  * pages pinned.
  */
-int __weak __get_user_pages_fast(unsigned long start,
-				 int nr_pages, int write, struct page **pages)
+int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
+		struct page **pages)
 {
 	return 0;
 }
@@ -339,13 +340,13 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast);
  * requested. If nr_pages is 0 or negative, returns 0. If no pages
  * were pinned, returns -errno.
  */
-int __weak get_user_pages_fast(unsigned long start,
-				int nr_pages, unsigned int gup_flags,
-				struct page **pages)
+int get_user_pages_fast(unsigned long start, int nr_pages,
+		unsigned int gup_flags, struct page **pages)
 {
 	return get_user_pages_unlocked(start, nr_pages, pages, gup_flags);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
+#endif /* !CONFIG_HAVE_GENERIC_GUP */
 
 unsigned long vm_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
-- 
2.20.1

