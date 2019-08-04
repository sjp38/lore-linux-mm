Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08254C41517
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3710217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MqpI7yn2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3710217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9C146B026A; Sun,  4 Aug 2019 18:49:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D24836B026B; Sun,  4 Aug 2019 18:49:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADD4C6B026C; Sun,  4 Aug 2019 18:49:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7361B6B026A
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m17so42450579pgh.21
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=NqAWhTQJX+S/oLTXfwN1MAzdfRaYThEPrVAqHh58RLbTGqvbuVdAgSozNyKrx2q79a
         4RKd0l9vwOkXQrLv8ZONUUJ4+D1Sh3jss2/QZ3dXr+mtw3aPbvWCezyui9ycTYj4z1Uc
         g6cq4rphvnCl6ifVV92CDKO2jZ2jrMNM0IAAMZD9RKRrPyLDnOYdy0Y5Nhtnu6qKR9S0
         e8tyyHFXGyvD+JbZUjVSA7MnlZdzF9OLnyKZ0wb7VRpa4WkNsZMh+LCDPRehLsCBy6AX
         pNo/Dr30U54gcYb/h4fX2yVrjkHI/plOxwz6si9PnQDNmQ4KK48xEMER9FNvtkeEZhLJ
         xe1g==
X-Gm-Message-State: APjAAAWk9be7yrv49RgzuEJR3C3Jy+OQKE+9dKgm/c1aViXaX3ry7qUO
	yA3IYibCxlwtHETn6+m8Mv1AigVP6zPh2rElUfZH+AAdntbng5O7TffFTSomxXTRL73QNgUWbrU
	qjmNLUUdNica2g2OHbtj//RELiup7dcjEzApZQ83eHSR8Q8OaUlGg8ax+lVqo5q48qg==
X-Received: by 2002:a62:2582:: with SMTP id l124mr69696149pfl.43.1564958979160;
        Sun, 04 Aug 2019 15:49:39 -0700 (PDT)
X-Received: by 2002:a62:2582:: with SMTP id l124mr69696136pfl.43.1564958978552;
        Sun, 04 Aug 2019 15:49:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958978; cv=none;
        d=google.com; s=arc-20160816;
        b=L2iiparZqVBLKNOlf/ah5FMMAXHIuGDHLd6n6GmiBJHli4HbC5tJFGOfbaLBdLWgq2
         MSHvKhxaXefrXLupCdVSEYP5n4PUBb76ud3NyYn2Ded1808yMS18dx3sFZMBisSCi4/h
         dTFTj/oHnh4NDRZZjd+H8IltKGNldIV8GF67ENagTviH2QbEP9Kd95caq1j6Z2xjFDQC
         kT2L9bNlconvVSm1UBnkOarq3HPpceyHJMx3f6xzH8Qm8EOYqXZdcWTFkT0pUJxK72/7
         15B271+fTY0g6frsLmZGsvg5Fz7pZixQZwJNBLQDt0CXhmy+uZUyUvmx3fQmlN/A6HPT
         AKYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=RIe6EaQvWF/oQq6HDon7ngLvN5KocEYphbzXO8fD3IavNXIj96I2089hwkbt9MbJaK
         Z8YNkex5x3xJfu1c37prDrmPhdxGrmubl6OtthtR2xxxvDUsbKlatPy7WgVxvR/GpCCX
         xlaYueGfBHIXvvVCCx7O0ew0dDYPOvdSn1zHVjsFJEnNDxFW1xgYtv/NQkWtxvHpQ9FO
         UO+EtzUaV6UMo3XKJy71A8OLe5WLisatUziqo2YxSsVrhIEYgKXNxeAKmCYZlaRrvArM
         G/+aPoYzbA824i0jK226jQqpfjUO05BMhv5CYsRQRWIEfTChuNR875tPNbzNf8Atsb3B
         ZDbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MqpI7yn2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s96sor18039273pjc.17.2019.08.04.15.49.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MqpI7yn2;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=j5bjFl/k0oxV1FIP4HazX0NuQurNmMvZSnaBil5PKNk=;
        b=MqpI7yn2v8JiaESKRamQoMhID5IYen684AVXtcKPVHm7ukeZx5WJLqHqdIEJqV0WrU
         VfCpQM5hioJATjULHPTYB3nfhDV1hZvNLdoXtUM170GmrlC8kjyYeFhBDtjPQS6eYlGi
         Z1KZbaNfekNsK96f9fHDqC8EM5JDem4jjQqa0uOUzUD0HnkcyB0RGrqGZafbKz+HSERm
         ycJb8r/hMPkJxrohrkltdvb3Bv5T3e9OF54rrvF1bh8OIMrv7vUbWFQiw+cjVGvVjkWZ
         fASWr56xEv6QUfwcZwREb2sSNIm1Ysoe7red/z7MjIlPR6uaG4NZls/tzbyEvLg9FjxD
         24hg==
X-Google-Smtp-Source: APXvYqwTnNt3iCmBWtT8pTi/FFYixGudghLt9/4mGGXij726CsdCF3vK7jbIkfaYxVJp0BLjNqynIA==
X-Received: by 2002:a17:90a:b908:: with SMTP id p8mr15231945pjr.94.1564958978299;
        Sun, 04 Aug 2019 15:49:38 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.36
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:37 -0700 (PDT)
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
Subject: [PATCH v2 12/34] vmci: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:53 -0700
Message-Id: <20190804224915.28669-13-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

