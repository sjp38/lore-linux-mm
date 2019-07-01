Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91A22C06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4087B206E0
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:57:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="KADS1dQg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4087B206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5DA18E0005; Mon,  1 Jul 2019 17:57:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0EF78E0002; Mon,  1 Jul 2019 17:57:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFE0B8E0005; Mon,  1 Jul 2019 17:57:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE6B8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:57:58 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id x19so8326198pgx.1
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:57:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:from:to
         :cc:subject:date:message-id:in-reply-to:references;
        bh=XgWwsa61aZBxJ2BDh3Q0RgZD8d2w9bfc/L2B41XFq4E=;
        b=pjjpav9qeoDzLj69y3pmjutbUQl99bs9FXBwQdWpb4no3TSycmSgf7f/wjPd3Ytf+S
         68hf0wApzmcNbMNMvUKVgJRCKyzGtfoyFhGnuPA8eIZKc7uu5DQh11usKk1it/JFJDdp
         5Aq6WlWwIZ2FU984R7aDSEEq2VVQqfJ1hxscBDdE/rypQRMiOeFtcNFv0hX/YkHpZJWk
         mB7CFMyklIMJolP2r78DrQR0YdmbJj/ga8o81ihZ2NYGLIwx7kz+N95Aap+NDH65SJao
         OAtPRdeCjGpgdlT/AOdKRgXl+jAKK+IN+UkjAJKhv8yHVjrysUuJrMz0AyJbV8Hq++iI
         b9mw==
X-Gm-Message-State: APjAAAVHfSiWesstqNn5sC6qUHcDSA251G2M4V4XnP9f1n0DaclC1agy
	yVnAxwE9AHrvM11MVRDk/j9HCp4USlX4OElU4GAzRfiyttAWTCJtgROqLJbDjRr8w/VpijIcNP4
	oBSHlHQYTeKzU/x/jjg1LJa/ZEkOZBmsp9jkoWTUc3i2B986qwFVSJfG0EDAU5wNqOg==
X-Received: by 2002:a63:4d4a:: with SMTP id n10mr26347356pgl.396.1562018278264;
        Mon, 01 Jul 2019 14:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy56B7Lyz+JN2zNjYPX6KwgkHeargLXL/VeijlTNQRi4sslNZItdnBz/z1GBSk3YHSd7Srn
X-Received: by 2002:a63:4d4a:: with SMTP id n10mr26347320pgl.396.1562018277415;
        Mon, 01 Jul 2019 14:57:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562018277; cv=none;
        d=google.com; s=arc-20160816;
        b=dxxczMoYYEpZVvFwtzastbv2sjqUzLnOX0S/9TzF4VwwYxFn+13I1foNpk21g86xgl
         yoUSwTFCj5RupkDV5pfpDy0Mea7cZDYW614Ti+xlLaKYvnOYdetH/Dph/5FAji8Q4Qkp
         Ff/EnhBFD0am6wWdeoJMusKaM7MJWCJadBiK+ED3rzVFL3KTgrhn8vNfGyoW8crEoFGc
         yk080xOQx9Z/97/lH+iF1WnH5cUitE+DQhJKkx4WrpQ4xwh6OSrh85X6zxQvX1Lt3usJ
         gg3wkTYMv7MFdtM/sVXNPd42Ph8FKSuaoNwDoNhJCAzheV76iZRdPjEK7j3ImbxcZAQI
         7NiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=XgWwsa61aZBxJ2BDh3Q0RgZD8d2w9bfc/L2B41XFq4E=;
        b=X7+MgA4H1rIv5WhdTaQmAtj7nQyD477E0V3aiV8sJHIAFf9ysa8l9O70HOheiNw1PO
         9tNbHwKUK/Is1nqH4GmmbUQsSdR5WKYULOLf0YKpnTAR9As9SS4g0HDQtluujTTts52K
         8mscIVvXtfHRJoQuksCHjCKcG3I831cNcxLk0Gi0Lq8+MQsSikwrUD4VTiy06s8C7QvQ
         CFEAR9ChebpfXD5sHf9mO/RnClEO8yPaz6jtouIdRaJSa5jzG6AyGVTfzqY7m65u4btq
         ucfqDlMmAoZ3/TKyLMTQmYs+LdafW0JTdqm+Gr+SwU6W6l4e9JUNiPf6WH5ZckN+dqXg
         lHqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=KADS1dQg;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa1.hgst.iphmx.com (esa1.hgst.iphmx.com. [68.232.141.245])
        by mx.google.com with ESMTPS id q75si11016093pgq.538.2019.07.01.14.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:57:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 68.232.141.245 as permitted sender) client-ip=68.232.141.245;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=KADS1dQg;
       spf=pass (google.com: domain of prvs=0789f8ff9=chaitanya.kulkarni@wdc.com designates 68.232.141.245 as permitted sender) smtp.mailfrom="prvs=0789f8ff9=chaitanya.kulkarni@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1562018277; x=1593554277;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references;
  bh=MbHOnCWpKU9OhNQ3wNRN8l4gA1/62SoaCYINRxhsjOE=;
  b=KADS1dQg4EU8mbhayi4lwtDMVqy1/AZq7XFlZ0iE2MZq93d3hNbrTWlL
   mLtH4gklBoX+iXQOE0f6PiuSdl5xN6sewsBYu5sJx180CvwQzCSC5WWIL
   vX66LVl8ju69JpJueAnZN5PjuH0yQ/4o1Y1OqfjPkIQ8a7YDTZSXmYNE+
   0K7aJeHvWizPSjGbAYz0ex3sgXj2BhUPLDPu5CDVEnpBbunPDOpJt3vGw
   VwOABnPAN3QHh/kBdVJUGyIEAMN1ji1crbYs4krByxz7GUPIfIcj2/JeS
   9MlVySUBYlhFni5o0CzChLLYuDsGoJKPPv0OdWJ0BjLVZyIDh8vv8MKqp
   g==;
X-IronPort-AV: E=Sophos;i="5.63,440,1557158400"; 
   d="scan'208";a="218377243"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 02 Jul 2019 05:57:56 +0800
IronPort-SDR: uOCNjcB0VeIAXzsYZ0vqGaLmBbdvmEYbsbhef4UJCj+xdD3inJpUD5T6JGiBRTlbB4G800KN8o
 /6jvcQPqtbmkJFRCci+WM65IXEl/oBa0TP797chQ0fPwqBeR8ZL+kHhLnqdPHd5HgRQZsgCCiO
 1r1dCCV2Ug6HHoUwbXKAdDgkZAC7h2flGLmfzDwSsm7YjFaQzOB5LEe6VXbHPEE6gdYTPCsBp8
 gxmdWH+KYQNMtNF4Mqv7w0pbGsSMR4eJ47r+5PxiW+jpL9rRGwwDOUHDjGR5Wu+p22+i/iqMXb
 mOBnoTz70NisaT8JOIqjxVsq
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 01 Jul 2019 14:56:57 -0700
IronPort-SDR: CL+xf59TlgjtZyTlFRdcDLuFt75xQy3gXKfSxFmbCWJT5LpCjDOhLvVhJA8iyfcFX8teiNIU61
 JS6nyhX2Ks1O0rTthsOcqUEA8YwUv0TSYQVGKXjnChLzxvglb4z6E2l2b22Mx69PqCKDUgabxq
 z+flC2nm/UzUtye/ZE8/A8OzzamaJyVuGujFyj+kM5z3Ul371Uu9BPqEO6baKu5HavSUMM/V2z
 T3UMAzRyJNRY+iQgrLC/LgbFgJNzaxW0R7TuHnASZhh7TGWl6LIKon4o4jEMddBsNPFxtsL3Cn
 T7w=
Received: from cvenusqemu.hgst.com ([10.202.66.73])
  by uls-op-cesaip02.wdc.com with ESMTP; 01 Jul 2019 14:57:57 -0700
From: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
To: linux-mm@kvack.org,
	linux-block@vger.kernel.org
Cc: bvanassche@acm.org,
	axboe@kernel.dk,
	Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
Subject: [PATCH 3/5] block: allow block_dump to print all REQ_OP_XXX
Date: Mon,  1 Jul 2019 14:57:24 -0700
Message-Id: <20190701215726.27601-4-chaitanya.kulkarni@wdc.com>
X-Mailer: git-send-email 2.17.0
In-Reply-To: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
References: <20190701215726.27601-1-chaitanya.kulkarni@wdc.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In the current implementation when block_dump is enabled we only report
bios with data. In this way we are not logging the REQ_OP_WRITE_ZEROES,
REQ_OP_DISCARD or any other operations without data etc.

This patch allows all bios with and without data to be reported when
block_dump is enabled and adjust the existing code.

Signed-off-by: Chaitanya Kulkarni <chaitanya.kulkarni@wdc.com>
---
---
 block/blk-core.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/block/blk-core.c b/block/blk-core.c
index 5143a8e19b63..9855c5d5027d 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1127,17 +1127,15 @@ EXPORT_SYMBOL_GPL(direct_make_request);
  */
 blk_qc_t submit_bio(struct bio *bio)
 {
+	unsigned int count = bio_sectors(bio);
 	/*
 	 * If it's a regular read/write or a barrier with data attached,
 	 * go through the normal accounting stuff before submission.
 	 */
 	if (bio_has_data(bio)) {
-		unsigned int count;
 
 		if (unlikely(bio_op(bio) == REQ_OP_WRITE_SAME))
 			count = queue_logical_block_size(bio->bi_disk->queue) >> 9;
-		else
-			count = bio_sectors(bio);
 
 		if (op_is_write(bio_op(bio))) {
 			count_vm_events(PGPGOUT, count);
@@ -1145,15 +1143,16 @@ blk_qc_t submit_bio(struct bio *bio)
 			task_io_account_read(bio->bi_iter.bi_size);
 			count_vm_events(PGPGIN, count);
 		}
+	}
 
-		if (unlikely(block_dump)) {
-			char b[BDEVNAME_SIZE];
-			printk(KERN_DEBUG "%s(%d): %s block %Lu on %s (%u sectors)\n",
-			current->comm, task_pid_nr(current),
-				blk_op_str(bio_op(bio)),
-				(unsigned long long)bio->bi_iter.bi_sector,
-				bio_devname(bio, b), count);
-		}
+	if (unlikely(block_dump)) {
+		char b[BDEVNAME_SIZE];
+
+		printk(KERN_DEBUG "%s(%d): %s block %Lu on %s (%u sectors)\n",
+		current->comm, task_pid_nr(current),
+			blk_op_str(bio_op(bio)),
+			(unsigned long long)bio->bi_iter.bi_sector,
+			bio_devname(bio, b), count);
 	}
 
 	return generic_make_request(bio);
-- 
2.21.0

