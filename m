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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 373D1C32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E750920B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p2jdLnF+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E750920B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72E826B0276; Thu,  1 Aug 2019 22:20:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B7A66B0277; Thu,  1 Aug 2019 22:20:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55AC86B0278; Thu,  1 Aug 2019 22:20:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C6376B0276
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:46 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z14so39392657pgr.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=YVFSgldlCu4VStXc9EkVyc2wKSx0yv6JUIgenlzVEIxlPm+Lz5qu+oX0c9uFQhom4z
         bz3DmWvuCrNjmfyuFamey/Mi6Rvo9OTk79FKKWLpqaGWRNzQGHv+n3TMpcJPqjEzgp0A
         k6+OIxNROdTlu6U7b8N+qOITHmPvb9z1ha1ynViQeQgPuB09PS/7MIIVT83pX7eZj22d
         frJK1B56RSmHMJJY83mSLJbUFlkLT9R3OszsYSp+4ExuHx9/ydBC1+6LhSmnGJtB3QD1
         joGwr3sa5X74saeqd+6248ezapCYHSGZHdB+xMIdtaWH8qUqTTA4yF9mRbyQk+bOstTf
         FfNA==
X-Gm-Message-State: APjAAAUran9fbX8kWVESHd0ogSkJvR2S9LtNKz9mcY9wHknR+zZgI55g
	AiHiAtuZczbQjd6EJEiKWbGe1AAfcaLDsaDbRgy2NWgOhWxlzwvb8c3GiuMkk2VTpwjwGJWTWGi
	473DM4/7k9qxaHZbdePoiQCKqVZqH5sU5XmwcyMRjDLgWMoGWrsOCWHPFSJu/4cnNiQ==
X-Received: by 2002:a65:4108:: with SMTP id w8mr23428279pgp.263.1564712445684;
        Thu, 01 Aug 2019 19:20:45 -0700 (PDT)
X-Received: by 2002:a65:4108:: with SMTP id w8mr23428246pgp.263.1564712445041;
        Thu, 01 Aug 2019 19:20:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712445; cv=none;
        d=google.com; s=arc-20160816;
        b=fWku9JpEo44p6UZUe+2gnKPHQ7YJsPetQR2pJ5HVq5qKUk6bqqSPIqCLqEH75CxYU2
         Hm8abJ7HXIsrll8xrJFx1sYaazSGecz+cZY2DcPMOpirKWFgv8htLuFdP1UgfBsBLQEy
         qJAUNoxp/VvYs8Xjqjrc0BcgK7Y3X7SS+282Nd4W3OYzgJNXBPZoX8DIcSLreVElsXjS
         51gFnnr/rRBQDRscclCWKl91SwTLhoV8jco0+jO4KiHuRhBhWh2mTIuFxM418CUBegfg
         8bnQRZiUrWsaQxYoxdSDTk97V5MM3iWnCZZXP0stemZHrQFm0xGKstuk4vXm2zzF1EAI
         qiBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=h7LYTqZBiMVXG/4sVJdOfjPUtRPAHUsG9Ap63qpfsGk9E6ZELJVDOUkdd2zhzjLMad
         h3SeRXe9rpOcBPckKyTRzYTkyAlFUyJ4kCS4U6gxUEB2IanHrtzpO92NeUp/Li6dFu0W
         A+dVJZpM8mCcXZBu5TxW5iYk6NrNcyMI0CcPtVXId2y4V8LFvJRm+TbqKYbTeito0h5V
         +iriqN6j9OTKQDfZDxZzpkoqwV8DP2hP0S5gKKtzCpnTQJh06pvB52KyXZaLy5tpxIgz
         UrXm4sQtg4kkG6vcVTS1o/mub9pilEAL6av/rBk/9rc7BO2kfGa9stVOpQ4M4ReR5os0
         YVXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p2jdLnF+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor8431721pjm.3.2019.08.01.19.20.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=p2jdLnF+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6GC3vp7Kgk6wrS2t1aIFSliRmKpmpPmHRVTf1Sq+2hE=;
        b=p2jdLnF+o2jszv2jswOdGKVlOI6oap0/O8UoWJ6UXd1vWJ7ZTNuGXBJzfbZP+U3/qi
         otCtgNo0FYJGbVJMagQHVxCjJNv9DsL+tAgpbtcseuLRjx2D2oJRJvb8QUEovItoJ4yu
         tqM1+sKVNJqdRAOn+U29/OmuIVN0dCZaqyMULYrLeNzvWGSINvgRw2ctCEPTtpJHvG4Y
         9Lt1J9Pu4o6vmxc1Dlj1+fWckvxFMkS2v0xzgYEyRXbpmL6oLpAd8HeumDihMK2pn/qS
         boIjYLobOad+m+G9IYsoBFXJgOFcyiWgGfoj3yVWjcIkFyKdq3aTzC8VwLjAVimMrt3Q
         7cZw==
X-Google-Smtp-Source: APXvYqyrk8OHD0K9x3jg/zl4sLls8epCiHibtZqTP4ohZ230SxHbnF+YASroUXHGf8XghjTINYs0fA==
X-Received: by 2002:a17:90a:b394:: with SMTP id e20mr1897367pjr.76.1564712444816;
        Thu, 01 Aug 2019 19:20:44 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:44 -0700 (PDT)
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
	Alexander Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH 21/34] fs/exec.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:52 -0700
Message-Id: <20190802022005.5117-22-jhubbard@nvidia.com>
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

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/exec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/exec.c b/fs/exec.c
index f7f6a140856a..ee442151582f 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -227,7 +227,7 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 static void put_arg_page(struct page *page)
 {
-	put_page(page);
+	put_user_page(page);
 }
 
 static void free_arg_pages(struct linux_binprm *bprm)
-- 
2.22.0

