Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA1CC282CA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2ABE222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PC0tXF87"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2ABE222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19CFD8E0006; Wed, 13 Feb 2019 12:46:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1512A8E0002; Wed, 13 Feb 2019 12:46:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 017CD8E0006; Wed, 13 Feb 2019 12:46:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A95EF8E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:43 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x14so2216638pln.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BQw99tH11D4Psdp+C10nNaKh7Npv1/BdP3rwuJ1L/lY=;
        b=KLOx9f+b8yP0yDhquf5qyiRHFUHHOqCqAU9HnxiABT1qvNbb3HdcG7kRe5T86FF4a+
         sxItu/nEOsz1MuRLkgEDndFhER0GVWM16gar2MX/1QuGV4UcBUWBO+BQptwEvNE7wt52
         XJ1lfaFVSZ6QWFCtU9WaMHoPPGUHs1jPdglBtlJ9vnr3f0eQeM8+168hS9jrlV9doNuf
         5vlLC9fyG249WHDJtDCDXlUIaGZA/QKtyBwP+1BimDSqr3w6UKUNJ0NSdIUgUaUlkNEi
         pyn4tFAa7XEeyG1QJ0J47DaIJQf7amghrtKm3idlu1diAs+s4bw6WQeQ6Xcd/vBTocFi
         85pA==
X-Gm-Message-State: AHQUAuZn7jI6jgo9jk5GDC38BAm/y0zF9Mc9zRw7xeEMzAVdv/K/6VDL
	llIuHh4w5br7vXx5oJI5pQQsMoPyvTSPfme4N3l/PnqRON71IuM6TicGRd3cv+KGjuocjpC4uDV
	A+EYGTEN4kNuAEcB+4EvOpg4kU4Q0MrrjON2nTpnzaVoVJmQhE8RxWndDO0JoRB0=
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr1691267plt.188.1550080003336;
        Wed, 13 Feb 2019 09:46:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbsQTiKSmWd4qbGDY6Sd9jFZfTGlidqIn0Bdx2Tmn4FI0mdSd1TQTepfImTqnQFti378Q0E
X-Received: by 2002:a17:902:6949:: with SMTP id k9mr1691227plt.188.1550080002670;
        Wed, 13 Feb 2019 09:46:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550080002; cv=none;
        d=google.com; s=arc-20160816;
        b=tIhd68XSs8+jBcmOmiuOPBswVlQBBGXvSNaf4RNRxkB+poPWR6CdLaBAM1PYiRTPi7
         w/CVCMYjJ6bHltKmWcuzFrzoPjAWDNpAXdS4Ir6iWGFfxl2+X4F0MXMD7ODjQs2SpFuF
         EwSzvxPW3lF3gUXnSLhXayJGx1CS/Q8vqMgIVc3hZoCKWC0lIpjMJl0h5D3nMBJsUsNw
         X/SJPM9fODn0/6a11g8YP5UyTrxvSpNaSeJUpM9vphTpnStKmudWaLmMmlt/Jw2vBMvg
         bgRX0CMPT9UGZ7A84qx0dgYgxqOcpiSwL4ZZGryTICw1Ac0MA083elnd0vaR2jQOwAbW
         mQ5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=BQw99tH11D4Psdp+C10nNaKh7Npv1/BdP3rwuJ1L/lY=;
        b=YDuSlnrZwKfqRuhf1aNLIGcL53Zy5kBRFAkBKHVJYpnvLmv3Fge+qFjVmMtsIAfWER
         pSGlixYX5OQRJoL2yujV/Ab4Z+kdkyBw31RRXK86GLos7LlXe7lg3ofV8b3YflbnVJ2C
         D/0bR6cJvF30F1JKwkxCiEX2vl501P6V96Iwv0SnEqJlXBUdhJyW9sKax22wonYh6G1h
         A+8Yf/4vtlGaILzJnHLQOloMd42XHyzO4k5y16OfgfSiB8SPu3+JdmhbgyYvGxXJXIDh
         o+DUvgOlM36rzkxLj7pMdZQp7APIxsMJY1F5ArY7C2gvRpvpzdxadRdnKKAUhkQOOXnp
         I02Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PC0tXF87;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 79si16132773pgb.351.2019.02.13.09.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PC0tXF87;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=BQw99tH11D4Psdp+C10nNaKh7Npv1/BdP3rwuJ1L/lY=; b=PC0tXF87R/V9iw6qGhuVO3esea
	CcjsC7X+SdSz7Bxxf/NyWSDtWTft0xTNQGkdfjtppDQgBofPdXPTYOap+FMX9vsjU/cbU217D7ady
	ZOz0q/nGrV8SFf4ZuOPklMxRIoIj18hbZi7KJk3d4rWFyqeqVWylAERdx7BI40awG35quaiQPEVjt
	H9REOlJWN7zBsyL4mgWwaBhQJnYMD6wizSf1fSQkyEpVe8u4IXhXPlgdq6pC5kQttpVdpz1GZsabE
	t4gSQ6rY2vtmg+eWQVgsuEkw+BsJsjfT7rtTflqYb+sPzJa4EifzT+A3eKVxJBQfrxVLSJg3v6FBO
	GCd2vPhA==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtycB-0006gW-B2; Wed, 13 Feb 2019 17:46:31 +0000
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
Subject: [PATCH 4/8] initramfs: factor out a helper to populate the initrd image
Date: Wed, 13 Feb 2019 18:46:17 +0100
Message-Id: <20190213174621.29297-5-hch@lst.de>
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

This will allow for cleaner code sharing in the caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 init/initramfs.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/init/initramfs.c b/init/initramfs.c
index 6c2ed1d7276e..c2e9a8845e98 100644
--- a/init/initramfs.c
+++ b/init/initramfs.c
@@ -595,6 +595,28 @@ static void __init clean_rootfs(void)
 	kfree(buf);
 }
 
+#ifdef CONFIG_BLK_DEV_RAM
+static void populate_initrd_image(char *err)
+{
+	ssize_t written;
+	int fd;
+
+	unpack_to_rootfs(__initramfs_start, __initramfs_size);
+
+	printk(KERN_INFO "rootfs image is not initramfs (%s); looks like an initrd\n",
+			err);
+	fd = ksys_open("/initrd.image", O_WRONLY | O_CREAT, 0700);
+	if (fd < 0)
+		return;
+
+	written = xwrite(fd, (char *)initrd_start, initrd_end - initrd_start);
+	if (written != initrd_end - initrd_start)
+		pr_err("/initrd.image: incomplete write (%zd != %ld)\n",
+		       written, initrd_end - initrd_start);
+	ksys_close(fd);
+}
+#endif /* CONFIG_BLK_DEV_RAM */
+
 static int __init populate_rootfs(void)
 {
 	/* Load the built in initramfs */
@@ -604,7 +626,6 @@ static int __init populate_rootfs(void)
 	/* If available load the bootloader supplied initrd */
 	if (initrd_start && !IS_ENABLED(CONFIG_INITRAMFS_FORCE)) {
 #ifdef CONFIG_BLK_DEV_RAM
-		int fd;
 		printk(KERN_INFO "Trying to unpack rootfs image as initramfs...\n");
 		err = unpack_to_rootfs((char *)initrd_start,
 			initrd_end - initrd_start);
@@ -612,22 +633,7 @@ static int __init populate_rootfs(void)
 			goto done;
 
 		clean_rootfs();
-		unpack_to_rootfs(__initramfs_start, __initramfs_size);
-
-		printk(KERN_INFO "rootfs image is not initramfs (%s)"
-				"; looks like an initrd\n", err);
-		fd = ksys_open("/initrd.image",
-			      O_WRONLY|O_CREAT, 0700);
-		if (fd >= 0) {
-			ssize_t written = xwrite(fd, (char *)initrd_start,
-						initrd_end - initrd_start);
-
-			if (written != initrd_end - initrd_start)
-				pr_err("/initrd.image: incomplete write (%zd != %ld)\n",
-				       written, initrd_end - initrd_start);
-
-			ksys_close(fd);
-		}
+		populate_initrd_image(err);
 	done:
 		/* empty statement */;
 #else
-- 
2.20.1

