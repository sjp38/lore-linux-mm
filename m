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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF1E8C41532
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98C4A217D9
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rRmTjwmK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98C4A217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 697416B0279; Sun,  4 Aug 2019 18:50:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61FF46B027A; Sun,  4 Aug 2019 18:50:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425716B027B; Sun,  4 Aug 2019 18:50:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 084A16B0279
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so52185104pfy.20
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=T+imdOppc0HFhM++W0fufUOSx2qmyd+JMvRzlUkKIXjsdlIYLbQ29S+ZJYdZomfzbv
         gkbuXSGGDzk2aA+nCKA5E3cFenAvg95JU0QuQ/Mrvo5ZZa9xltFtwpFjVvBtBvljCBod
         eRdR7yCiZNfsH75HtZGpY616zHCqA6UZHv5+gblVP+X8ElmAj0Fm2wY5D0D1CGi5Ar6h
         Rn9rYmBUf4P4bGUNdwRGKfOcdU4CER3xD10qZ7K1np0ukzI7u5Blz5A5ad404sNdvgFM
         fpRLXEPhjuUgOme8xmkPiYWAnU4qkgBXGUG4v/jCVEVvx6XLO4H8lFJGDqSDX2kXV+jN
         bPmw==
X-Gm-Message-State: APjAAAWEBvxGm3Oo/092cbbliDMYeo7PsA8BD7PlK8/KvniXkx0fF4MH
	Q9SuPUKKt9zhblZDA2l0i2EGPDdIKS8UsliG23axCuDiFaSnCMO0IbC8mZXUs4bi8M7tzOlrwLF
	u9E1E6YaxUJ4MZvR4xE40mOschby0MNI10BhE1LVQgXaeeH0MRt+LrVsz7kWwPva5+A==
X-Received: by 2002:a17:90a:9488:: with SMTP id s8mr15654762pjo.2.1564958999736;
        Sun, 04 Aug 2019 15:49:59 -0700 (PDT)
X-Received: by 2002:a17:90a:9488:: with SMTP id s8mr15654745pjo.2.1564958999182;
        Sun, 04 Aug 2019 15:49:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958999; cv=none;
        d=google.com; s=arc-20160816;
        b=azWCm4gQy4gqjm1gZDWBbSmRsxswgofEjXZzXCY/AeYKGKaR0rI541bEVvi2Yspzkd
         61MD52OATj831KAo3pkMutBSucbwaJEeo1uMR6GY4C17lsODGAc8E/sanEdGIIo7kUL7
         2KvEuGk6BdldHXab/tvzfdUNNkAVUzGyakOgxWDqYW/0DuytJSBRrqnBfibfHyPZzMQW
         ufaRE4WeJpXlU/b4XkxVaPA8HBErryIYQhgX79WYpeTVMVQLZKjkebP5uuP4WGRjNiyq
         BcieKxxVW0yjhMTXEK4OxaaaGVWsURYclm2BCgElIp0HZ3aeRhxQgAyt7uY/Wt/WjWg9
         d4IA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=KjZTamVIupoDtnWUpfvGQQTzXNNdNt8zdC7o7qfqkqtUWWsjvVq+Ho+8hHVjtL1fhG
         I4noGNCME3aUy1zx2guU47rC0NsHCOjMUW/cUclF0vTcJHfdoCZUMn2kA8C+QxAxlEVT
         hLAvtl3Hdj9swmyoP1TwMAUGrp1nJM/GtVGbMMyCUHaEWYVDaYaQwqfax1kTwSBFiVFN
         Kn5LmsOFYMpdpGMqzUbZyC1PLk0wVJoxODyGDeGQnNZ+hoJKsH1azNazHmMHf5Z/FlUI
         UYmMzhcvBoaAyZIsDJfta1Lq4+QEssA/v+TeTrrUzlmYBTsvaeP8VJ4Z/LuoFguHbE5A
         Guug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rRmTjwmK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor57123303pgn.35.2019.08.04.15.49.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rRmTjwmK;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=rRmTjwmKQyZXs+w2fc61p+6blqitgFt44VDlq2hBJa3msEqsCjE3iMA0N59ImENjx1
         pWxFmzHovpTywgJof2duXF6btSgoIVe+p+WICBao5KO8pBkE9NcaTV9gfxHpi58Jd393
         DFKgJ0xyVx8/IYN8IUERTh2Rxf2HWoXWnWj+XPN7lRyL0wmkPmCXMh8pOjTaDWP9OB/k
         giTYlSTz/ZRaJt6cAxVDISU3w6TbcicUIO0JMUvDlHhqw/CPHipUdbC11SYdC5WWsNXd
         vc/vSbii+ZbRuDVkTzr0tcFTEidEPQ4hRCQUhyIepPPKxZC6v01QDasnaLKNedkEXXRF
         M2wA==
X-Google-Smtp-Source: APXvYqwlrqrBPfbU3uzw56VyHFJ2u/Wv2Z0KkmEAsOsnKmMeY4aJMueEUB/6oS1u2+NCnzOVxWkmSA==
X-Received: by 2002:a63:4a51:: with SMTP id j17mr133593330pgl.284.1564958998921;
        Sun, 04 Aug 2019 15:49:58 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:58 -0700 (PDT)
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
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 25/34] mm/frame_vector.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:06 -0700
Message-Id: <20190804224915.28669-26-jhubbard@nvidia.com>
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

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/frame_vector.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..f590badac776 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -120,7 +120,6 @@ EXPORT_SYMBOL(get_vaddr_frames);
  */
 void put_vaddr_frames(struct frame_vector *vec)
 {
-	int i;
 	struct page **pages;
 
 	if (!vec->got_ref)
@@ -133,8 +132,7 @@ void put_vaddr_frames(struct frame_vector *vec)
 	 */
 	if (WARN_ON(IS_ERR(pages)))
 		goto out;
-	for (i = 0; i < vec->nr_frames; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, vec->nr_frames);
 	vec->got_ref = false;
 out:
 	vec->nr_frames = 0;
-- 
2.22.0

