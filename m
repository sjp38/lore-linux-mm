Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 311A8C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB4A321874
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="abC7vf0m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB4A321874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCC496B026D; Tue,  6 Aug 2019 21:34:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A588B6B026E; Tue,  6 Aug 2019 21:34:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 858476B026F; Tue,  6 Aug 2019 21:34:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 435D66B026D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so57188745pfi.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=WVfiv/cbnb76HsdraV8mP++kB64dD71xcwK5EHAE8kcLx0iuDCNqs93UsRUa4FvLwZ
         B5gLXlDo3yzjl9Dwcs9h0pKek6KQnD4nvhZnIwWSfNW1GuhSeXDxOBdYclhNsN2dSEaA
         9RM2nRG3xePbKXfEwPIn6mOsEgYhr7xnGC7msGReumzwDytrZHhiiGfOAM7TbMYBYvqx
         gA1QQrsKZGxOmhsk+Th6vGW04eBNGvLibN3Nr6+QMXU4Tq93LzBsoRUL8doxGUINnaZc
         fj3mWzJa8faim14z8FM1VVSJxTvBKDx/U1+MhBrtPr2VbzVdF94EgllPS6RR3VgCHFy4
         1UiQ==
X-Gm-Message-State: APjAAAUokGI74OXI/jKC3onRS6k4bzKt+9XhsjzIz6s/fimgQyBMQeLK
	mlLFv4dcKKugjMJ5A7qFNUlXjMJEDjsbHfn7AtObAW5msg3HDXhei5SGeqrZywV5+IBeoDL86jh
	0gsyVxbDO5k89xSBnJMG9MfwvFZLjbxL8j/HEIvqBdiLUF/hQoIPmYaTCnEc5LZz6rg==
X-Received: by 2002:a65:56c1:: with SMTP id w1mr5420965pgs.395.1565141647864;
        Tue, 06 Aug 2019 18:34:07 -0700 (PDT)
X-Received: by 2002:a65:56c1:: with SMTP id w1mr5420937pgs.395.1565141647039;
        Tue, 06 Aug 2019 18:34:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141647; cv=none;
        d=google.com; s=arc-20160816;
        b=DuBFR2jjeFI7eGffbloIcdB+V/7qaqiXY7EzuCfrlQoAoo+dlAwio1rf78CCKh74NR
         luYC/pjBvD6f2jl7Iq+wVfqJGrSHbOUvmWe8O3Yx9TS2cLADfGvvzbEtlW8yjPxvmNZ5
         e8zp1DPZ/lhra5tuKliHLjGgmBvK5w5SBT1I5eKWRKpBh9C9itMKtpczkDnDmUUli9Bo
         xejL+vTizSTRqlJVZO4awvN10SLu1IV12gNyHWZ0GknY1huudaHwRnfzcjdylJtJuLVv
         FC4KQTNdUHRP2cTecfIDXFnG/e96lETTLYAagOzAqClqO+b/IiKkg9Jn3umOg3l+P4Vk
         Mxbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=xrZ1Uyx8fMrWdxvDYBX5Rb7U2EQxDSvEakFRIdYA3/UL9jcIRzgdhxLdXdhMRchuEs
         NMIRRzGUo8JlPr26tgQf/gQKQ4QhYGU/ksk1Hb6lYicGQOJrBuCtghQ2VjOWEMvxCcS9
         OZR/oLFWzFHZEFuTqjyuMGnmFML9uZs5QmSjCSr6KyNqPG0PbFYw4m8OE73zL/Tldsfi
         E5B3Xu78BVdQDWzbcatp5vTMyZlGsYPjGpUTdNeSVKdsPZ9PwJHPcVjd0XIAghUxWe+3
         fU6qwCRFbPRFiVtHuDNg5mUYwamY46fj2ojctbDf4ca7fNl6pdKMrj3Y5EYA+gyuBKGo
         YCtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=abC7vf0m;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o32sor106491473pld.12.2019.08.06.18.34.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=abC7vf0m;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=abC7vf0m4NHfC38BFCAMKWrCml8VHI8/tyJOz6tyKPGPsXxu0DOdz37V6xN3Thg1Zd
         UpeVYry5AG+h4scE5ih6O8+arLoECywsGCioTsrKWxm7sB389EG9oJuSV29/gE7h0LS0
         y5iguaVXKirIQlusYbxFmgE9r3+yptBAJLiq272v0Sl/QhyMLH3XCxKVguovo2yydY/e
         hPsoqdmsX1oREmKqBP2kENq5c26aaO0nlO2uQS585/gxX2DEptCDorR5OVzgCXwYNt2m
         opAr5jpbK/bXJNfg691sG72tAWDskEyT8B3AWzTTbwOCvmhfW6ETVYtk14IOwNSue0Fc
         R2QA==
X-Google-Smtp-Source: APXvYqw7+dnuyU0Y8q/AKeAaMraB2bbAgVOsWO8V26J8bDVfSW5vhARN1nLU2+DyCWOsFFzTtXKGNQ==
X-Received: by 2002:a17:902:e2:: with SMTP id a89mr5940458pla.210.1565141646808;
        Tue, 06 Aug 2019 18:34:06 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.05
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:06 -0700 (PDT)
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
	Arnd Bergmann <arnd@arndb.de>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Gustavo A . R . Silva" <gustavo@embeddedor.com>,
	Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 14/41] vmci: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:13 -0700
Message-Id: <20190807013340.9706-15-jhubbard@nvidia.com>
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

Note that this effectively changes the code's behavior in
qp_release_pages(): it now ultimately calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christoph Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Gustavo A. R. Silva <gustavo@embeddedor.com>
Cc: Kees Cook <keescook@chromium.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/vmw_vmci/vmci_context.c    |  2 +-
 drivers/misc/vmw_vmci/vmci_queue_pair.c | 11 ++---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/misc/vmw_vmci/vmci_context.c b/drivers/misc/vmw_vmci/vmci_context.c
index 16695366ec92..9daa52ee63b7 100644
--- a/drivers/misc/vmw_vmci/vmci_context.c
+++ b/drivers/misc/vmw_vmci/vmci_context.c
@@ -587,7 +587,7 @@ void vmci_ctx_unset_notify(struct vmci_ctx *context)
 
 	if (notify_page) {
 		kunmap(notify_page);
-		put_page(notify_page);
+		put_user_page(notify_page);
 	}
 }
 
diff --git a/drivers/misc/vmw_vmci/vmci_queue_pair.c b/drivers/misc/vmw_vmci/vmci_queue_pair.c
index 8531ae781195..e5434551d0ef 100644
--- a/drivers/misc/vmw_vmci/vmci_queue_pair.c
+++ b/drivers/misc/vmw_vmci/vmci_queue_pair.c
@@ -626,15 +626,8 @@ static void qp_release_queue_mutex(struct vmci_queue *queue)
 static void qp_release_pages(struct page **pages,
 			     u64 num_pages, bool dirty)
 {
-	int i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty(pages[i]);
-
-		put_page(pages[i]);
-		pages[i] = NULL;
-	}
+	put_user_pages_dirty_lock(pages, num_pages, dirty);
+	memset(pages, 0, num_pages * sizeof(struct page *));
 }
 
 /*
-- 
2.22.0

