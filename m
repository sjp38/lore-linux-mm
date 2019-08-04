Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DC76C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4488B217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L35X2QFh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4488B217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EF226B0271; Sun,  4 Aug 2019 18:49:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A0C46B0272; Sun,  4 Aug 2019 18:49:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED35F6B0273; Sun,  4 Aug 2019 18:49:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6E626B0271
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so52215723pfi.6
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=JpVW956QnFNh6e2PxaV4cNXF7MvKlJdzHdf9KjlWoC7oSUlDEy5rdDpomGUk2ech8l
         Y498dcK6NJCC5vt4z82xBHJbQhPJpP9CeSWHc85GMlTfmS/JGZrbKTs7yM+0aNf5VvGj
         u7Ioh1BQmR0VH+EiilQEpdtFbMkg9rL/qwOuytIfWo7/XrDTdOgV2aWWosKlFnxvHJDJ
         hfcPM6a3TAx9SrxgJJ4nFKYYBwoGLpjZbxn3Hgu9nBRmNFhpm/tDx9Zno2370qIQEhzJ
         CSVnnUqAZrQ3Arq9D/sgJROk3o7aHe/yHhpLOIa1HD7JkKCQNX4y8FpH5t6idP9tKkwu
         rhJQ==
X-Gm-Message-State: APjAAAVgAN51AodMOeFHIPqFH8/hjuusWNhKwSqknB17f8x1IWU2u7vh
	Qm/OVZMcFPFOCZ+/slMq1rxOYezXF3h9I7a+x0izDuyn1tJPxRh1BDmBTMy3XDGIBNVMiZAU12X
	NbNEKZ8uY6iNlq91kxyi2weokBn4JB0BS1wW2FPmeOFNuwqLjbpPDNBJCdo/1RrSJPw==
X-Received: by 2002:a63:f91c:: with SMTP id h28mr40923950pgi.397.1564958987360;
        Sun, 04 Aug 2019 15:49:47 -0700 (PDT)
X-Received: by 2002:a63:f91c:: with SMTP id h28mr40923919pgi.397.1564958986654;
        Sun, 04 Aug 2019 15:49:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958986; cv=none;
        d=google.com; s=arc-20160816;
        b=sUYjO1aWp4R4zuC/qR0pWUuSDMN4ep3MKy8DXZXa94V8sx2Ql9oYRjPavl3n+LLwwO
         GlnCzDWm2tK3nAtAHTAtqbqHLSyMLGOsnfQJ6TsG+FYRQy7mor3Sf5BwdZT9Cq/Z8qCX
         TLWZZ5N+ibrJlc+tj1An3ZEgfGkUjjJNFJdl7VQj8h0mVl8HBDTc1SceHfMmTnaj71wT
         Is9oza8Cq6hbiLqfGUcFIz4ihEwTu6ytCg6M0+MvthL71d/T8cnDi5V/wMK1AQafKVRW
         HYkLHJ3+1wkRS7n4GYRhUPpQVGt6/STsY7EeOJpIOBXviSmhoC8nXgG804yAbUKbhtKV
         QbuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=QuE7hp8/oUpJ7cXxkcGD/8fG8DpfC1JBnLTmQ7pbnso3J3yccY8OniahSfTX9I6Jnl
         cKp5j+aW8DB+EBCNy05eE/iSqfBoIpanGKAwRzCzK288y1BZ/l0vQwyn7h/evhZNeKKQ
         hCjnv1kU5KpHhLdsC8Oa8CWUfJd6HdCF8QMiADlOoUZE78K7TgYUCb/nWWwGRRNoQgMN
         6fzU/0YyYiENYMCc+9NiPa9F5ECL5XsLLSws5+3ivCLHn7m4nvOABcv1LYO7XO41QqOx
         VAGlnrZg6XyW8N/zj2RMn3fTmA0agkxaSEyMOvJlkeaFn5ZcAmnCcCjyh6C1+EkJXz1R
         rdaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L35X2QFh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2sor56929071pge.58.2019.08.04.15.49.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L35X2QFh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1X33MY8P1PVcaLkCZcp6PkXiHV9wvPThIXgNE9TFbj4=;
        b=L35X2QFh0M4JIQvOmPagjixwdLqggClkiY/ITRED3vd5cYmML5rpnhsQYVeJG55L7X
         lfpM/Rw8+9+KW1xLlbUjjd2pEukAuHL9FPW2brNIFLNAAe+xFNLiBhvXwHgfebwSPh6b
         PQimMsMZnxgRdBC8pyrRMZ9Xs902qjGDWwSRlQpLzHZkXMK6vYaJ7jNHAlwygvXZxKWD
         HRNszvS/yLW3PMoeuHrejzjB7JHf9PJVVvjCC1Gi8OYeSyaj8QqsLJjtyVPXxwKbhU1l
         56SfAsWTx6H5Myy0JvyaDz6KAPklX1grAzJq4JD5PKOSOMwKa+X4MP3JYOJahIqu806a
         4oGw==
X-Google-Smtp-Source: APXvYqzQPIYoNRubdZIOtSxTDDzyPgcMaQ5zki3KNapO18w6JwMFrcpCjaVO/4MzoXfe6L31Al4dig==
X-Received: by 2002:a65:6859:: with SMTP id q25mr22221333pgt.181.1564958986332;
        Sun, 04 Aug 2019 15:49:46 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:45 -0700 (PDT)
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
	Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH v2 17/34] vfio: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:58 -0700
Message-Id: <20190804224915.28669-18-jhubbard@nvidia.com>
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

Cc: Alex Williamson <alex.williamson@redhat.com>
Cc: kvm@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/vfio/vfio_iommu_type1.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 054391f30fa8..5a5461a14299 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -320,9 +320,9 @@ static int put_pfn(unsigned long pfn, int prot)
 {
 	if (!is_invalid_reserved_pfn(pfn)) {
 		struct page *page = pfn_to_page(pfn);
-		if (prot & IOMMU_WRITE)
-			SetPageDirty(page);
-		put_page(page);
+		bool dirty = prot & IOMMU_WRITE;
+
+		put_user_pages_dirty_lock(&page, 1, dirty);
 		return 1;
 	}
 	return 0;
@@ -356,7 +356,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		 */
 		if (ret > 0 && vma_is_fsdax(vmas[0])) {
 			ret = -EOPNOTSUPP;
-			put_page(page[0]);
+			put_user_page(page[0]);
 		}
 	}
 	up_read(&mm->mmap_sem);
-- 
2.22.0

