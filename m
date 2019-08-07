Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC4EAC48BD6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9342321743
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BG5A7Xtq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9342321743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D88C6B0275; Tue,  6 Aug 2019 21:34:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 264376B0276; Tue,  6 Aug 2019 21:34:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F33AE6B0277; Tue,  6 Aug 2019 21:34:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BCE856B0275
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b18so56032405pgg.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PTeNIVNtmjQFCjQxL5R5M/OrbQjiP2mk2OJMaygoDr4=;
        b=alJY7r1cRu3JRo4XLCJYxQ+/81dazyt1HvVyZqqAjz+kIfHBCU8gMky+4IlhnzhPqe
         ywJLxD8X+WK36kNfXwNtqGeUadUZHOFWzNsRw03ZHJOaFfv65vpYZvawT44hPyyPIZW9
         1uXWYrOnSApk0EPWLhCVtHBGddqfM1KCvOcNsSCaFTqV5kIhndI+bCKmjC0GWi64l5sV
         O0VoBt8qZD0vJymVsRqGLiSlFCSobxeRBBVQynf10U4cxLD6ClzRTaU6QXlLZRCdp58W
         KmJscEpU1ayNcDb8jl6oELveC9tuHYZC1FBliL8XqJZNRdIlh/9NUUH/afgJNNwuuv8b
         m/Aw==
X-Gm-Message-State: APjAAAXT3gTdpczKH5Jlcsgy2RJGK3CsNmZxxOY8aQCshDDV151VWHs6
	355wyTPiA27T365S2m1JhQCmvrUHrNXtzRnjo2bjQDTvheLNUMs4fh4SE+ji42aEOKDRsOwz8gY
	oqg2IgbfpWLHpG7YvIET6eJsvv2vCmBKAWYjVCaCiQSX1W825GhkD2vh4Sh1oWOb0fg==
X-Received: by 2002:a63:550e:: with SMTP id j14mr4980861pgb.302.1565141661345;
        Tue, 06 Aug 2019 18:34:21 -0700 (PDT)
X-Received: by 2002:a63:550e:: with SMTP id j14mr4980819pgb.302.1565141660495;
        Tue, 06 Aug 2019 18:34:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141660; cv=none;
        d=google.com; s=arc-20160816;
        b=BNUIzYonwA6tVJOS3yLLQfjUHLkkeMsYRn2MrvxjxOews5wdBqX0RrhjSIQWOvKrDF
         Jz1WlfNr//DsWKYzX/tlZ+SzSkpF+dt9TCjog61R6ILhkkDBGKp78KfS59zo8r26p+7v
         WSfPOwUHoxHkcVECeZUXGe99bnD0LwY/z5q2TEMdZ389Q6FYoe/U6WctUXL0j2Dl8GIG
         TwsP6cNXKDvmt7qcz9z9PP5gd4lXuykNQGZEFl9Xr9wveDsjosKJ3u3PBJ04UYg7Wodh
         AKqbLAbHDlsYgdIujrQDG2nLB331dTqf8YOy7ol08YtGpKTkVVCsbAWCb6wtZBlqAx/V
         zNjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=PTeNIVNtmjQFCjQxL5R5M/OrbQjiP2mk2OJMaygoDr4=;
        b=Kq+cNrGzAcsn7jZaf8WwdA4xgPHHgvVCo1jY9t6hgYkgjL1LMqPYj3I6jh4dO4AdPX
         3hpubvQllul4pIXc2S/uDvsx6fwMZK1uvS5yz8cHGBSBVX4rKP7bcUAQ4FDBO1d7NwWv
         pdPpXSdbCovAx79qCtyJ8tWly8OaHww/YAlCBjMtEzxhuqFmCp7ynIilNsWAKKjP94iA
         HUYDSPEpOWBO3za+LU7RwfJqBcwYW/ReziDq6iHllNFcZx4JNGPrgtt5eYQ5f7YiOWgX
         B+dIa1oq1PHor33DjaoajCl28il6zdJYwyfjjQfFhjAffzc7JL3IeV44Oa/WrVA4GfO4
         HUqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BG5A7Xtq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z68sor63760362pgz.39.2019.08.06.18.34.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=BG5A7Xtq;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PTeNIVNtmjQFCjQxL5R5M/OrbQjiP2mk2OJMaygoDr4=;
        b=BG5A7XtqqH4f15Klc4uU0q4X0R2Yv3wfhImw8oiXt1v6JO5KY1LfJ/FOOlCOXGnxrU
         VariQ4IygIhND6FU5kQCuk9//LCB/lYGlYLJ8TWLMj0IGcKtGZaK7cHMiGMOL9oUoiZc
         YswM2ntpv1sQkIcN3tEUtcv2aNlSoNXxcBOnTcDMk5HYtBIeSLrq5eWXN9nroLrC19Z/
         C0ZG1Pu1hecBjOrW3c3xob4Zs7H7sVar9fXDnKdmBW1H5ACiR9/XADMiFFYI0P1SdPij
         tJqcrXGje17KBWR1RldTVMzhM/TqzNCkMDLzOIHQRTxPFXZrOO5rIe3URKbbtNFMFJkR
         bC8w==
X-Google-Smtp-Source: APXvYqwNS1xrXhm+UjCuzC7PKxoGrXRgWDwKbPmsbF2Yg7VGgKZOnBNXO8oPa1127+JgtcA8HVibPw==
X-Received: by 2002:a63:c055:: with SMTP id z21mr5455551pgi.380.1565141660136;
        Tue, 06 Aug 2019 18:34:20 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:19 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Juergen Gross <jgross@suse.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: [PATCH v3 22/41] xen: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:21 -0700
Message-Id: <20190807013340.9706-23-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

This also handles pages[i] == NULL cases, thanks to an approach
that is actually written by Juergen Gross.

Signed-off-by: Juergen Gross <jgross@suse.com>

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: xen-devel@lists.xenproject.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/xen/privcmd.c | 32 +++++++++++---------------------
 1 file changed, 11 insertions(+), 21 deletions(-)

diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index c6070e70dd73..c7d0763ca8c2 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -582,10 +582,11 @@ static long privcmd_ioctl_mmap_batch(
 
 static int lock_pages(
 	struct privcmd_dm_op_buf kbufs[], unsigned int num,
-	struct page *pages[], unsigned int nr_pages)
+	struct page *pages[], unsigned int *nr_pages)
 {
-	unsigned int i;
+	unsigned int i, free = *nr_pages;
 
+	*nr_pages = 0;
 	for (i = 0; i < num; i++) {
 		unsigned int requested;
 		int pinned;
@@ -593,35 +594,22 @@ static int lock_pages(
 		requested = DIV_ROUND_UP(
 			offset_in_page(kbufs[i].uptr) + kbufs[i].size,
 			PAGE_SIZE);
-		if (requested > nr_pages)
+		if (requested > free)
 			return -ENOSPC;
 
 		pinned = get_user_pages_fast(
 			(unsigned long) kbufs[i].uptr,
-			requested, FOLL_WRITE, pages);
+			requested, FOLL_WRITE, pages + *nr_pages);
 		if (pinned < 0)
 			return pinned;
 
-		nr_pages -= pinned;
-		pages += pinned;
+		free -= pinned;
+		*nr_pages += pinned;
 	}
 
 	return 0;
 }
 
-static void unlock_pages(struct page *pages[], unsigned int nr_pages)
-{
-	unsigned int i;
-
-	if (!pages)
-		return;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (pages[i])
-			put_page(pages[i]);
-	}
-}
-
 static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 {
 	struct privcmd_data *data = file->private_data;
@@ -681,11 +669,12 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 
 	xbufs = kcalloc(kdata.num, sizeof(*xbufs), GFP_KERNEL);
 	if (!xbufs) {
+		nr_pages = 0;
 		rc = -ENOMEM;
 		goto out;
 	}
 
-	rc = lock_pages(kbufs, kdata.num, pages, nr_pages);
+	rc = lock_pages(kbufs, kdata.num, pages, &nr_pages);
 	if (rc)
 		goto out;
 
@@ -699,7 +688,8 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 	xen_preemptible_hcall_end();
 
 out:
-	unlock_pages(pages, nr_pages);
+	if (pages)
+		put_user_pages(pages, nr_pages);
 	kfree(xbufs);
 	kfree(pages);
 	kfree(kbufs);
-- 
2.22.0

