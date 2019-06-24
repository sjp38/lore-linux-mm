Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0357DC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFAD72089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:44:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="r5n6pCeH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFAD72089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 288F96B026C; Mon, 24 Jun 2019 01:44:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D5158E0002; Mon, 24 Jun 2019 01:44:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F03AD8E0001; Mon, 24 Jun 2019 01:44:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C11376B026C
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:44:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i35so7471768pgi.18
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:44:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=;
        b=n7P3NfhtRJNWH8BwopS9QABrtImuImM+50L9aptjPu2VuA7UanscUPFTUGZ8H32VRJ
         4vhB3irjrv6n3jDpiEkLgVCRYZL//iQ5Qg1ROjBMdXdvGqh3G1qKu3eW3o+KpFKMhi9c
         cKJTE0xT0f7KJPdxIXFsUzOKtZe4sQ34oHjtbnE0WjUwCn8QP3ItEJQmySVXpIoBkEAB
         kQZJSM4NDbOivBYmT5mwbkhumwUfehp4dOGMnDZ7xxd8pWXapWk4l6LOS1tGIkZ66LqE
         ieM93FzW8fv3A1lRtJiO41Gno4iHnaumbJ6+oC0CaCM8MiXT+B9Yw5RYhxD65fiUXxeI
         Xgyg==
X-Gm-Message-State: APjAAAV+QLmXo1NDZ4Kx0Krpr475Sm86Ujhu9nM+8i5SbllE9avMiiC3
	6mkQ1Kt406rdPiovZ3U9yPPD10YBwvaeay5SjvK5yQXjUNPh7vUksHcSygfYiEdv0CtKvwcoPrz
	hMlFp1lds2hx/hGQH5nz9zT5SAy8blTjd7OT4hyz1lqPLzOmAqR9jwbtvTLl/ido=
X-Received: by 2002:a63:6c4a:: with SMTP id h71mr30711570pgc.331.1561355041369;
        Sun, 23 Jun 2019 22:44:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHiYDk8fiYfV2nWyKAFJH04lHSl7lLxD5VylnwhuZC5IoKeP/cF9ceO1WchHR54cXgUedT
X-Received: by 2002:a63:6c4a:: with SMTP id h71mr30711535pgc.331.1561355040692;
        Sun, 23 Jun 2019 22:44:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355040; cv=none;
        d=google.com; s=arc-20160816;
        b=jeIAz2iNyeXBpW+bCUsQ+pJKLvcD/+/V0lf9cOTUG8oWCynrKqRG6Y769IfOe4Ze27
         rV9z/lipliOQehJlwjJATKoxC1KVAJNwHyx463kK7Ln9AehcbmT+0mkXtha3KJQ7YqaO
         ARPwqzQ3Cw5HdLA6ZjlFNQUQTYNY5XVWPVSmYrf54+sUz4FdajGxLIJqwlgXzbsJKB8/
         tCgQ9w5y4lWD88kJoWFyY307ScIQIDnmrx8ZVYymvUZkaLcuAWcun2vJ40FzoQOeD/Oq
         Uu69IaT7tVu5GwRYKRMzLppXqK4hzjgMGl/Vo2dGBHHAVM1VIo3MQsM1s6argJ1xUwMh
         Jpxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=;
        b=A1KesBzb3QgO6vr8mtbtO16yDiPDcCIrq4iSObIoqFHuLYzy1bqPZZCTVv7pFw8su0
         RU/4+J1q9Vetap5pzAkEVfQS0WXuHZe2LD9tRziuilCa4oKuWMkSw7Njy3igwafIlPpt
         EGXWfoIuXkj7rD4kk1lvIn5Nhf7r8ydNZVZ0+ASTlDhgUTvV+5pjlXbKxFIDNmUmebHE
         ljMVqIqZKnoibUtsktZX7Jp8BDGxU82UCqTMqfspriJn1LWcYWYwBjIzWYY2PGLaLYN/
         /ou9JQNz5HWAAQbJUVBbaaJLJ9SfOt34vSYQCL4ynLiC/4PQGW/zvcWKUt6d2RJFpBsZ
         6/2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r5n6pCeH;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si8870615pgt.281.2019.06.23.22.44.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:44:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=r5n6pCeH;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=4ocWky3c08iK0yepv2gQs0SBg5KjT+xunPaTv4oC5uw=; b=r5n6pCeH/gadzSXK5KdI2Tqxv8
	YODK6eN48ucCegAYBApmU91XF9qDbVsH6tKFA77OewDRe6wqTI7SOkxxGuNy9Sqic+I0WUPShkgI5
	Q1lzoYmneNbpVbOUPj+V3mJQXEi+aDzQsaS8iujdNcz5g+2YOFVvO09khJr31WiotohZZLvZ1sZxX
	Au7/D6AWMmPm2BTMHXivfuRi7XYiZI3SmPmvmgQznl97DnHs/ShMX+Jt4xrDoWzclv6O8NDl/VF15
	MEZtZEouwgD3Ybb8UXfWgU8hWoGgN6ZUV08QMBzBJNpFVg/90QTwtKFUM9bKrgLFEMLNGW7/C5meg
	uw+VkyYQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHln-0006kL-1n; Mon, 24 Jun 2019 05:43:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 13/17] riscv: poison SBI calls for M-mode
Date: Mon, 24 Jun 2019 07:43:07 +0200
Message-Id: <20190624054311.30256-14-hch@lst.de>
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

There is no SBI when we run in M-mode, so fail the compile for any code
trying to use SBI calls.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/include/asm/sbi.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/riscv/include/asm/sbi.h b/arch/riscv/include/asm/sbi.h
index 21134b3ef404..1e17f07eadaf 100644
--- a/arch/riscv/include/asm/sbi.h
+++ b/arch/riscv/include/asm/sbi.h
@@ -8,6 +8,7 @@
 
 #include <linux/types.h>
 
+#ifndef CONFIG_M_MODE
 #define SBI_SET_TIMER 0
 #define SBI_CONSOLE_PUTCHAR 1
 #define SBI_CONSOLE_GETCHAR 2
@@ -94,4 +95,5 @@ static inline void sbi_remote_sfence_vma_asid(const unsigned long *hart_mask,
 	SBI_CALL_4(SBI_REMOTE_SFENCE_VMA_ASID, hart_mask, start, size, asid);
 }
 
-#endif
+#endif /* CONFIG_M_MODE */
+#endif /* _ASM_RISCV_SBI_H */
-- 
2.20.1

