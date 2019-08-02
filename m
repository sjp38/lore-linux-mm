Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D512DC19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 909D421773
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hA+dHc1d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 909D421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5A106B0275; Thu,  1 Aug 2019 22:20:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6FCC6B0276; Thu,  1 Aug 2019 22:20:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C351C6B0277; Thu,  1 Aug 2019 22:20:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8E36F6B0275
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:44 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so47142985pfd.3
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NpCZQ4VK8hzAbP37Qxye6UhXG/4cH2zDttwN2tDhLJk=;
        b=fDCPM2zT6ks6Go6ik94Sj3EZSaLBQK1d/BTuGWyGmqJlV1/T3Scyg6JF0y8q9ndQdI
         Htky3r1N54M/w0Kv2u5bFNtcjpv6mOXvLytQLi/apoUsRtRuqo/ME6gIv5f20W2l3aq7
         0O+NUxlpOHEWF8o9HFL9skkakHfxpNCNgBN2OA8OzqVoHee9eiZ9aNEci/dHhgN3vAGY
         BwmGqbgxx30Wd1P/l8/V369ZRoB/28zBCTX/BD6Df17f6KmzkPiu0ci7eSF3GPQuLwVs
         HV/RFpBwVNlGCCzYf1NtQZU8OlussEmXAZ6roiwZS3TjwfbXjS1cJtYSkvNdcV7asI2S
         BFFg==
X-Gm-Message-State: APjAAAU9txjmcLc2n3IDNP0Pd2KrE70YR/RswaOISbKhC515f6MEjKaR
	DSatXI00mwih7D2jVRCDuxx6g85zllMdXvShXzw6bbFMkLCoc53cP3s0fkguLiDGdcSrQ//ffnU
	x3//sLdkvVJ+tXdxQNljkQOAq9zhkKt8CDSd0wK48RX3IymZ1Qw0gzK6L+KyEQPnXJw==
X-Received: by 2002:a62:cf07:: with SMTP id b7mr57179432pfg.217.1564712444278;
        Thu, 01 Aug 2019 19:20:44 -0700 (PDT)
X-Received: by 2002:a62:cf07:: with SMTP id b7mr57179382pfg.217.1564712443671;
        Thu, 01 Aug 2019 19:20:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712443; cv=none;
        d=google.com; s=arc-20160816;
        b=tUU58na/SNXDgQVdS/5fqEE/av2kbH7TZ4b7QfzfhNnko7PdZmadkgnVlV7ZMxMwOO
         RiTapO2wFsUkBY4jifzGeQwD3IS8OJdxPY2kgbS7mV6KBA6EREHbSusq5ygiPTGhRz9/
         j2299pJOSW1fetM26LewVtASJDEediGeLWrEXPHihBw8InSknNQ8QjIGUXlph6XpVZVO
         CjNdYpEE7fFzI6Km03rpshGXLtW6TGu17NqLKO4obm2HzafNW1ndNBTIU89eVtgLeoH3
         jRj/igvPoeIp+62uQZEYh0+eokXy1uCZ7wZtxWgEd/H8zVKuUuqS0uBoUpOypjyHujTy
         79AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NpCZQ4VK8hzAbP37Qxye6UhXG/4cH2zDttwN2tDhLJk=;
        b=HRmX4pQ04ZX0jhUtfqeV0ePc+cINtdSO9Hk8vt2COjD8VtJEjF0JMZJkrdnucD2j5a
         e6aQ+1z5lef6eZXgqkkIz80Qgio4pFIdu7T+KirRB10NsQEPfE0pxpA2uNcOclA8x90m
         gg1eIHzY9DoUWNc3d2VX9430cS5waX4vS2L4u+uxlNUIIyj5JJJYByOlRAJSkLbkYmig
         bujmTkrhwDx6rm/cuBwC30d/ApRGkCbAR7MTTgOJRVAHS1H4bGta9ceSJWvWctn3O3oe
         QzWHUf6B4D4qI4MbzRxNGKm+ob5PTJF6LGj/f09ui/rQncpZVG6g7A4q6asDLenxHKc9
         yvLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hA+dHc1d;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor54950272pfi.28.2019.08.01.19.20.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=hA+dHc1d;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NpCZQ4VK8hzAbP37Qxye6UhXG/4cH2zDttwN2tDhLJk=;
        b=hA+dHc1dKtzF01UNAT1GCb910It9M6OYeo1UwisVEiPximZ0Uizqhd58Gx7EN+cwqG
         oOXAC9GpXS9cMgyPAFeZsWw6yiG5HTsH6dTfrkzHKXhkxbTehvYO/DkXd3o8uGT1hUxz
         8W3I7PS2I6VpD8By/LG/APt7ortKYREWRihQ/MahJgv1XZqDU9aXSO+0f9WVFU4wcOzF
         PifhANph7r1h1aR2sJtcNbzpatSVDPr8LOmoCCwtkUnv/6xTTuq0KjPRlt5jI5AQn0Bo
         qGRQZk7nx9WeapKs5M+9pdwyKPbEullYlAI/CW2M7lTdWIAU5bo5Tw/OmRhRr64X9QFj
         r+xA==
X-Google-Smtp-Source: APXvYqwoCf/Pdnvn5s1n1tJ64nDODMRXeExgk7vpJhyWgRCwW2Xl8gxjUqSaBtscPD/0WWSuL29y+g==
X-Received: by 2002:a62:fb18:: with SMTP id x24mr55563811pfm.231.1564712443423;
        Thu, 01 Aug 2019 19:20:43 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:42 -0700 (PDT)
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
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Juergen Gross <jgross@suse.com>
Subject: [PATCH 20/34] xen: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:51 -0700
Message-Id: <20190802022005.5117-21-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: xen-devel@lists.xenproject.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/xen/gntdev.c  | 5 +----
 drivers/xen/privcmd.c | 7 +------
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 4c339c7e66e5..2586b3df2bb6 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -864,10 +864,7 @@ static int gntdev_get_page(struct gntdev_copy_batch *batch, void __user *virt,
 
 static void gntdev_put_pages(struct gntdev_copy_batch *batch)
 {
-	unsigned int i;
-
-	for (i = 0; i < batch->nr_pages; i++)
-		put_page(batch->pages[i]);
+	put_user_pages(batch->pages, batch->nr_pages);
 	batch->nr_pages = 0;
 }
 
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 2f5ce7230a43..29e461dbee2d 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -611,15 +611,10 @@ static int lock_pages(
 
 static void unlock_pages(struct page *pages[], unsigned int nr_pages)
 {
-	unsigned int i;
-
 	if (!pages)
 		return;
 
-	for (i = 0; i < nr_pages; i++) {
-		if (pages[i])
-			put_page(pages[i]);
-	}
+	put_user_pages(pages, nr_pages);
 }
 
 static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
-- 
2.22.0

