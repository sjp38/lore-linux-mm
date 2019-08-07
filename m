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
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1BF0C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 993F1217D7
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o1iMd41+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993F1217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E1AA6B026C; Tue,  6 Aug 2019 21:34:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F37A96B026D; Tue,  6 Aug 2019 21:34:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8BD36B026E; Tue,  6 Aug 2019 21:34:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97AE36B026C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id y7so6923222pgq.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=slc90TdA3P0zoiWcyh2qXNdMNWhwYTE23L5ZDANpAGfJGeS7Fkjl1gZY182rWOOz1u
         P0ywhWilxovjLO0p4JuCxZmz1EigG4DMhi0wxwcrO6eaGADUaFOaAKctSKRBo6VQbx13
         XxtKCBqt3hMl6lSb5l0sxPsB+lFHiYKqD1Qc5s+zd9h8jOEyElDJmNLqjZ8LxuGuCaHw
         7HYWGCJQ8O4jmux0AEbdziQU26zfTCgbTUFjkotSL/KyhBW3S8z1VC8Xl/N25OfayW7V
         XxhSUXifX8UnNlSJ1L0Z+tnWVJ3c2sQQWG1ijIfJ831gtUiZghXt/U6XVcZl+Jh0XW/8
         n0JA==
X-Gm-Message-State: APjAAAXK5dpRkFhHM1PpqW3KTEuj82l4XSBuxJC3apMA6UejWAmy0e+w
	Obo4nZQyzZZ6h5f2yEUt+jOOEIGKBiR2sRdNdPiirINU8H3DP8Q5q0/f2LKLcxOCeOOnyNUp/rZ
	U/yMOra6ucDGhUhCyvlLtZwMIsgY+lX65ZXNgP0NpDEWJeDybkgDbUn9nGvP7rfhjeQ==
X-Received: by 2002:a17:902:20e5:: with SMTP id v34mr2979188plg.136.1565141646301;
        Tue, 06 Aug 2019 18:34:06 -0700 (PDT)
X-Received: by 2002:a17:902:20e5:: with SMTP id v34mr2979155plg.136.1565141645529;
        Tue, 06 Aug 2019 18:34:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141645; cv=none;
        d=google.com; s=arc-20160816;
        b=MWzbhklr0ZVyOat2adfPSoLEo9vTrrlO3YhzsUqDVBqXxotD0n6BPXHKrHI1RMeQhB
         O6YGNnUPtfCL58c9QvkU7qyzz5NQlbCHVrNBg13UTtiBOb2VDd8aLNFo3/myOA0q5Urj
         Och6cMTW3nh+3GW00yg8IgPSBAaplICWrwjtOQt9dV5z8qppyDW6MRHc+S+zICcOFP/b
         qzFKqFe9YXInb28iiwwdAD0TQI87ghtz6mOSd0sBsrSz5jQo8yqgUFDVy/16aTMxqv8F
         mXw9jU3hCKBoF3PTJOGVFolJYyl4pQv4EzZMNecSPtaDp9SEEnHHL7DwoqyShUCMCLMO
         +6Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=ZmIXoP55jXxOzIj4hH/rrFvA3fW2VPEXbU4oW5YpDiNB8y8OBWTq4sJGfEZ9mt5rcj
         czn/n0yXGBzalmSRN7TlKR4bAMNFY46tVLTK4Q/YUOvflX8Q4BBjFAIM7suqS5Rqc+Ou
         XihDNomKxLFZcr78qx2iu4VLGS08b9kuXZqJhgqqeFCOM96PHykg7lPUr9eSGiYvw+0P
         T9NaXSrqF0Ig7XJlxEMY5ZTPqLFaVLmKytdHXQm5jnKt1r1BS4XCcM+TsRiKiHBUm606
         LoIQZ9phW3ot5qcWg3/k0ux3cDatzkS5KV12LYUJtbtzbDlzJQHWc/DxtUgIYMIx3xDz
         x6VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o1iMd41+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor42533438plb.65.2019.08.06.18.34.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=o1iMd41+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=o1iMd41+ccZkK09IMPd2AYRK2nxxj4luxr/oXYf1r5zvl1rB+5Njvw5+yOF9jzdNKW
         0sOvnAPF3Qav8GrCrICbMqDOV9qASg1Kx51KsLT3kM/WuvVdMW7XrY8CvDI8Q5dEWx12
         oQbwqpjSWiFbIsNFbcpYcVrmKluAqCipM9FxALoNB6s3X2SZRLlz53JQRsVYPh0pH9nV
         Kc9qcjAV7p7rTzqe2/MHBF1cE8sJ8msPeJl3VFMqaq2A+nfaaBpGi8bFHG/baDlwWEny
         MHNVdhC+ELal559VaRapllf9o6PzvZgYyIKj0wGmpTTu6N66MHuYIC1lBVMp4ydMH/rt
         +u0Q==
X-Google-Smtp-Source: APXvYqwDlo4CFJorDrBurduwUa2oSyS2Jx2b29d9K5TbsKnQqNAY6ckzALOmtrds4Hd5oSsH/O3vaA==
X-Received: by 2002:a17:90a:1b0c:: with SMTP id q12mr6044962pjq.76.1565141645264;
        Tue, 06 Aug 2019 18:34:05 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:04 -0700 (PDT)
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
	Sudeep Dutt <sudeep.dutt@intel.com>,
	Ashutosh Dixit <ashutosh.dixit@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Joerg Roedel <jroedel@suse.de>,
	Robin Murphy <robin.murphy@arm.com>,
	Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v3 13/41] scif: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:12 -0700
Message-Id: <20190807013340.9706-14-jhubbard@nvidia.com>
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

Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Zhen Lei <thunder.leizhen@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/mic/scif/scif_rma.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 01e27682ea30..d84ed9466920 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -113,13 +113,14 @@ static int scif_destroy_pinned_pages(struct scif_pinned_pages *pin)
 	int writeable = pin->prot & SCIF_PROT_WRITE;
 	int kernel = SCIF_MAP_KERNEL & pin->map_flags;
 
-	for (j = 0; j < pin->nr_pages; j++) {
-		if (pin->pages[j] && !kernel) {
+	if (kernel) {
+		for (j = 0; j < pin->nr_pages; j++) {
 			if (writeable)
-				SetPageDirty(pin->pages[j]);
+				set_page_dirty_lock(pin->pages[j]);
 			put_page(pin->pages[j]);
 		}
-	}
+	} else
+		put_user_pages_dirty_lock(pin->pages, pin->nr_pages, writeable);
 
 	scif_free(pin->pages,
 		  pin->nr_pages * sizeof(*pin->pages));
@@ -1385,11 +1386,9 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				if (ulimit)
 					__scif_dec_pinned_vm_lock(mm, nr_pages);
 				/* Roll back any pinned pages */
-				for (i = 0; i < pinned_pages->nr_pages; i++) {
-					if (pinned_pages->pages[i])
-						put_page(
-						pinned_pages->pages[i]);
-				}
+				put_user_pages(pinned_pages->pages,
+					       pinned_pages->nr_pages);
+
 				prot &= ~SCIF_PROT_WRITE;
 				try_upgrade = false;
 				goto retry;
-- 
2.22.0

