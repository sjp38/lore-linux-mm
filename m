Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C9E7C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D28322190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WNJwYLVh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D28322190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71F3E8E0007; Wed, 13 Feb 2019 12:46:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D3478E0002; Wed, 13 Feb 2019 12:46:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 482598E0007; Wed, 13 Feb 2019 12:46:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 034828E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:48 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a72so486360pfj.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fTdHUPsgYRu4VneoajaxB1/e1nadjQ3WHuZL105MHUY=;
        b=aydpIUYzi5oQllZMB/CG7tVZULp70lcHcsUetSiZCqXH0Px8kcGOQ6YppaV7fT5FCq
         oDmtB3vB/kO78nmIayZu11wCVGhyt7DCgdsQrMxCSBldcs91Wmn4VQK1HKdQs2x5ZPzU
         AlG0iiFXKlt12jWrtoLt46kzbXuCfKZA+uc1zw6JRtPquZ6bJeFsXFYpTyWsbQexCu/1
         GjR3rZjS29NSEo75ObFDkfYu6GFXI8AC/0HwM+FdFsh/MxJfS0I21EogpXH9RmEOa1MF
         ryOuAZXphjnDNQOJXarCfm0YcUDZ7shJf+aZV4z70PhMfQCC0Z+TojTN10sGt9Tpn4sD
         AdNg==
X-Gm-Message-State: AHQUAuYbtwHqJwDk5CgICzTJCDGiD8EoT8laTfYPKtvqisQ5gjJwwltT
	wYEERcQNaA+7VepeUO+AC4QZiRX/Y3jMX2eSTvjDpcmY1pRUUVEYp6vSVVVnKJOpMZi0etNsXA0
	REoMmhWqmXipl7hjePyVTQahz+dx8tVQR6tCDiG0Duf9fg8NxYAKSXFkYLgjnFJU=
X-Received: by 2002:a62:1c45:: with SMTP id c66mr1636467pfc.90.1550080007677;
        Wed, 13 Feb 2019 09:46:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZV5MU4wGOHIkUvZEyWXlwP5cbknvIB/ZHaqtR+on9PaX0DcUT2k63z+k03rTqNcq2Wp4mk
X-Received: by 2002:a62:1c45:: with SMTP id c66mr1636425pfc.90.1550080006993;
        Wed, 13 Feb 2019 09:46:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080006; cv=none;
        d=google.com; s=arc-20160816;
        b=VLbAnkMKFoh0hWKHN1jHZyuIFlZG54xeiPhucEmx1CnHMIEC1Wbp8NOmtlRy98sajk
         3vNQvawdvSAXyJBwC/DUstvwrpw4syp0Fdo0uit2U8o4OQq+WrggcR+sIxT/vsvLxHuU
         sOyB4h7B0Twz/6ysU5B5l2rlTt6Xp7oCIUX6O7bJDCHwmzrpTfais6EhqKSL6NVUztEL
         wl4drKEmCtn/d+nTwXY22HKYC8E50sLtd2rzf7+ReYWXjuc0vA+xDHQfKgYN6KYxw58p
         bDyJxYQUhycr0xYB0qg+EOj7wFg6vAFoVm/hEPLK28yH/MMxyGREBSZC9AF1FNTGTwsQ
         K0AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fTdHUPsgYRu4VneoajaxB1/e1nadjQ3WHuZL105MHUY=;
        b=0IQlb6oNCXoig0WXPxR6C0T4BQJ2Jc4Gb5fYOuNHhNCpYYpVdQqUjIDC0e1ifs+nII
         Kdf9ePy5v5EkdXKjY7BuF9cQruMtQeisXw4V05i1lSTWrOO71i6X5k4g8r9KtNtd+lYj
         zPyyyi9T9mxJrkAeaRCh4RsVSlqqQLhTY/NqpeNhaGQUnfadwaTgIo0mIox3u+YHFV0H
         /Fw+ym8dquQonts2XRib+0tzqmpSWNRx1E1mOiIGU3ILeiA0KmndgNG3LHkJCSntZMSr
         Skt1Eo+dyZIHvD4q+zXgDNMnZCQGWIQd3PeTCS54pVlvONAsomxn0IyD/dwSari8pnAH
         z8mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WNJwYLVh;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a1si14841144pgw.142.2019.02.13.09.46.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:46 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WNJwYLVh;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=fTdHUPsgYRu4VneoajaxB1/e1nadjQ3WHuZL105MHUY=; b=WNJwYLVhSQl1R0/3jqf/I4YZNY
	hOjgUb5Fd0oKnOtL6U2GbrsZrqM+RLTi+gkXwZTbHuD6rPN1DtGjkl0FxIamC0O++xHvh3FAqXTxn
	LkHfHYNxmpgwmRlok7rtvWs31VllCpAFPsVPCDOhiwmeYugfSXaGBNUM3mEeRysJag3eb58o7DXlN
	nxcWjHweOwduHENFmeadafi5Gjql10SaL2euZZsZ0SQbJvVZyR/NmXq4F86h2CVoSs6iNwkfhxJCv
	WAdGAiI4nraWBAF749N3f/+NHlnupVRcz5Z2G78dPjoYqHmphoc6xj0D4ixjunMox31yfbCIUH7ya
	WENCLhxw==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtycD-0006kA-Ph; Wed, 13 Feb 2019 17:46:34 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5/8] initramfs: cleanup populate_rootfs
Date: Wed, 13 Feb 2019 18:46:18 +0100
Message-Id: <20190213174621.29297-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213174621.29297-1-hch@lst.de>
References: <20190213174621.29297-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code for kernels that support ramdisks or not is mostly the
same.  Unify it by using an IS_ENABLED for the info message, and
moving the error message into a stub for populate_initrd_image.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 init/initramfs.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/init/initramfs.c b/init/initramfs.c
index c2e9a8845e98..c55e08f72fad 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -615,6 +615,11 @@ static void populate_initrd_image(char *err)
 		       written, initrd_end - initrd_start);
 	ksys_close(fd);
 }
+#else
+static void populate_initrd_image(char *err)
+{
+	printk(KERN_EMERG "Initramfs unpacking failed: %s\n", err);
+}
 #endif /* CONFIG_BLK_DEV_RAM */
 
 static int __init populate_rootfs(void)
@@ -623,30 +628,22 @@ static int __init populate_rootfs(void)
 	char *err = unpack_to_rootfs(__initramfs_start, __initramfs_size);
 	if (err)
 		panic("%s", err); /* Failed to decompress INTERNAL initramfs */
-	/* If available load the bootloader supplied initrd */
-	if (initrd_start && !IS_ENABLED(CONFIG_INITRAMFS_FORCE)) {
-#ifdef CONFIG_BLK_DEV_RAM
+
+	if (!initrd_start || IS_ENABLED(CONFIG_INITRAMFS_FORCE))
+		goto done;
+
+	if (IS_ENABLED(CONFIG_BLK_DEV_RAM))
 		printk(KERN_INFO "Trying to unpack rootfs image as initramfs...\n");
-		err = unpack_to_rootfs((char *)initrd_start,
-			initrd_end - initrd_start);
-		if (!err)
-			goto done;
+	else
+		printk(KERN_INFO "Unpacking initramfs...\n");
 
+	err = unpack_to_rootfs((char *)initrd_start, initrd_end - initrd_start);
+	if (err) {
 		clean_rootfs();
 		populate_initrd_image(err);
-	done:
-		/* empty statement */;
-#else
-		printk(KERN_INFO "Unpacking initramfs...\n");
-		err = unpack_to_rootfs((char *)initrd_start,
-			initrd_end - initrd_start);
-		if (err) {
-			printk(KERN_EMERG "Initramfs unpacking failed: %s\n", err);
-			clean_rootfs();
-		}
-#endif
 	}
 
+done:
 	/*
 	 * If the initrd region is overlapped with crashkernel reserved region,
 	 * free only memory that is not part of crashkernel region.
-- 
2.20.1

