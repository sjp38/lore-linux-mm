Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41156C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 02:25:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E370020673
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 02:25:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E370020673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EA846B0003; Sun, 23 Jun 2019 22:25:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 473DE8E0002; Sun, 23 Jun 2019 22:25:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 314628E0001; Sun, 23 Jun 2019 22:25:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9B0C6B0003
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:25:21 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so6455510plo.10
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 19:25:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=i62MDUco+L88u+gho4OXVi2QGt71UcWNN0qob8xe0Ws=;
        b=Jh98xvDLyf/i2loVX/DPK/d5nE0Sv4fq8gKosYE/eioON6PjbSN4q8t0s6BJBVCIK+
         HBa1pN8HjmTxNd0dm/OmutaLYRkrA1D8f+9gYsG+ab6nRDbigRhkyJw9Rp4d9VrCBCau
         hXn1P9/YQMuvd393Uf9CnMS8Ty0BL9uonAhhg5lqZqjsd7CyHHFtZEfy9NnHXjfgo9Kv
         XBQGw5N+7/fcV5EeIm5hugie/sWFh98h8nBM2re+ciXS4W6HZkhvSDC9hxfrzBedlYNP
         2oyGaGd214DFVdpD7nfBboOdu1xACl2om5hudkGLmqudso7vkXmVP2/eSyklma5ciOUb
         CHUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV15mkwz/YoBeUBJxqG9xAVr57YBD6rM0uMKuc+7HsatPJxzUPf
	SmzPpaZk4YhVg/IzKrk9+/tqRsQxyDVPdstLxFkOVCXw5d8HJOoDKY/XgMXBuXa6euD5g9aaHoU
	5jWBTSICIX4m32VHdwwXCM0USWZjgHlFdcp3TW6fZp5u9Y2Lb2wzgy/W19Y2/oEMkTA==
X-Received: by 2002:a17:902:846:: with SMTP id 64mr20317941plk.265.1561343121539;
        Sun, 23 Jun 2019 19:25:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznpADUUtuy9kL1OUuPcKifiXaKNzEFAx6osMQoqiYhNTH3x0rX9yuAFIcNU+TzScgaoYu4
X-Received: by 2002:a17:902:846:: with SMTP id 64mr20317900plk.265.1561343120714;
        Sun, 23 Jun 2019 19:25:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561343120; cv=none;
        d=google.com; s=arc-20160816;
        b=uczNxjDFngCbRlm6SNg90+ejw/hbUUEcPVhmHGoVeZb/LZzEcKtbceuNmIdxLyTrxH
         z07bAGprEg8bc35zmyMGT8z60W3yn3b6KLH5/TYay+FFCK+1ATsY2ALRvZKiZBzuMGIT
         TnBmUAzoU/4K1WGNeXWvGmlBU+JIFNcL7jQx/XeH9y3GrElPy8XNwhkbT5Hte1k/b009
         l778lRrGpwgLgtynLn3gkimA+eYJADYSBWmr95Eh/RqBC7z1ER5VDEhSJCuiybJ8Be23
         MGsdxSh1/a/rFSH8zEyzOl9ESoSdpBQ13q/e7dStlS4uNWcOXM/nawtAkny/S4MVjEqT
         IOJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=i62MDUco+L88u+gho4OXVi2QGt71UcWNN0qob8xe0Ws=;
        b=LkCA8sPFf5d9Dcl2UBZPnt1VC6QrXrWCo5/53mgGGW89QAYOJXEN4XTV+gobXqraIU
         nEWrmVkWdmIBgpRzxeanIeobp2+oPKng3JmC9oQbXNxlCCYU1SPqdz8dSj6hAFSZqJWF
         HiF7gw1qx8tHFwBynRSvTvjzjevKx/xSg9WOIzj7skuDHoHroiCnc76S1T20ekSKroPg
         PDgaXDI+kCgAlx/yHlvZjVKqbuCtQI7or19qGg5zVsY6ASJPrAdpXfz0SPGpYc60KbZh
         M9xu8ki0mtxgcbJIJAzU75u66sC5ey45usN5xcciF/735p3YsOGuhbBhj0Trq66iUpeT
         EQdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id t1si8989531pgv.169.2019.06.23.19.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 19:25:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jun 2019 19:25:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,410,1557212400"; 
   d="scan'208";a="171832130"
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by orsmga002.jf.intel.com with ESMTP; 23 Jun 2019 19:25:17 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Ming Lei <ming.lei@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [PATCH -mm] mm, swap: Fix THP swap out
Date: Mon, 24 Jun 2019 10:23:36 +0800
Message-Id: <20190624022336.12465-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

0-Day test system reported some OOM regressions for several
THP (Transparent Huge Page) swap test cases.  These regressions are
bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
fail when swapping out THP.  That causes the OOM.

As in the patch description of 6861428921b5 ("block: always define
BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
THP to swap space.  So the issue is fixed via doing that in
get_swap_bio().

BTW: I remember I have checked the THP swap code when
6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
and thought the THP swap code needn't to be changed.  But apparently,
I was wrong.  I should have done this at that time.

Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/page_io.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d0e048..4ab997f84061 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -29,10 +29,9 @@
 static struct bio *get_swap_bio(gfp_t gfp_flags,
 				struct page *page, bio_end_io_t end_io)
 {
-	int i, nr = hpage_nr_pages(page);
 	struct bio *bio;
 
-	bio = bio_alloc(gfp_flags, nr);
+	bio = bio_alloc(gfp_flags, 1);
 	if (bio) {
 		struct block_device *bdev;
 
@@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_end_io = end_io;
 
-		for (i = 0; i < nr; i++)
-			bio_add_page(bio, page + i, PAGE_SIZE, 0);
-		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
+		__bio_add_page(bio, page, PAGE_SIZE * hpage_nr_pages(page), 0);
 	}
 	return bio;
 }
-- 
2.20.1

