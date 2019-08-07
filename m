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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C832C32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E60232173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:33:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D48he9iw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E60232173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BABE6B000C; Tue,  6 Aug 2019 21:33:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74F146B000D; Tue,  6 Aug 2019 21:33:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AF636B000E; Tue,  6 Aug 2019 21:33:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 090456B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:33:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so57164562pfb.21
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:33:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=VUgl83izOav+DaIaKtnEm/t4W7IS+JgXn/YdUX6ObWAl1d6FtZsV1yTS0MDUM6jsay
         HQReQbb52sH/qvh0c2qSvu9pG1v+6TVkVpeE6cvqi/XVGieyuRpexoXuY6wtmj97ZGWz
         aYSFjyY3+klbf1LOggy03nk1KDdJVB6Q1xHyOHGEwHAaDgGF04jZ0S+ti/4sO1dpvlc0
         xnwUS5pVHZ21v35miltANIOBqTvwrvbc9LmY2dnGGGmaM7Z97vkRszevRvOIGKkOz0U7
         9it7AaJJsiWIHXyHE4jUe1ATOv05hrbYCTODykbPLUz6GqTUQh14oT/YAZ8kyQ0OfDCn
         1Qiw==
X-Gm-Message-State: APjAAAVwRjUXOQXaqbtkPEa/yBAsaGUKsqzhI5AQfYZwZI4sgp+L7S34
	ZJCZyn6MirOxopfMialEN5Xj39Owj+60gA6uVzzvlBWcmnDfXQ/ipa1Se9h52pDZHOHu+oQ5UOr
	k06tjcMnoD7+/1I1P4NJZlKi+0AveqLW/UJVIWobteVfmJKTwkZR14RZmkeXd9Y9Nng==
X-Received: by 2002:a63:e010:: with SMTP id e16mr5461798pgh.285.1565141633659;
        Tue, 06 Aug 2019 18:33:53 -0700 (PDT)
X-Received: by 2002:a63:e010:: with SMTP id e16mr5461753pgh.285.1565141632745;
        Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141632; cv=none;
        d=google.com; s=arc-20160816;
        b=P531W28CrNYiRey5wvuljH7dL7ko7QnaF7oZstgWKnkQNVXFf0zrmHF3BS/qUpKrUf
         ZD42To6oEqNATC4W39+5TH5ifDfMvPEcEq3izQvc7MB1DE5QSuQabs8qvHDTkLiDWnWz
         6xOlxTK0Rm7EaXaTUmczlE/4MVhWZeHBEXw7tvjKtFl2e3U9Xg5zhFXQO3jcuhSegE/b
         77D4ZWttp5R3rECJXrNvYPiRJC10FtGzPfWZ+b/HsuYhA3eDyU7oKwS2+AAhS0t1EMzg
         x3tzbgqHxIvRQzxwOVSlHCf9ucUshJaF/bQPTDoOS1Hy+tLidOSIJAurQG6aEfq6ZFeX
         Gavw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=iH0i2AUQVhKxF4xDCM3nfexsI93vRcDbDOlAiGaFo0Pndgk4S9Nma6kZuxHCCE/NiY
         vTRsQfiauvftOJzdDWe161YTk3HBYwUnHskTVhpkMLgIhi4LnUMb12f8JoArgUib3tu+
         bkLgkAABMPzL6iVV9RNDSSZLJ4kubRuUVKbR6PV9gody5jBkLkK5kYEKFsw+OzS+a6Um
         JWVWPcGHCSuJS40J063/yjEmdv6jSaZXgmW+NVcCm3k/4oizd69lv1d/EYNeTD+TMYON
         oxJRHmRrlCdZXBvrdI6A5PUjJDvVz8QK4MJpzXJPk3T6+Wiztyt1kSxUe25NV7pwqsbp
         S7HA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D48he9iw;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor106051275pli.56.2019.08.06.18.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D48he9iw;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WGaquJbd5n3vWHVjzVcVo6+uSZsjc3dg9cLGAnxVc2E=;
        b=D48he9iwy4Ni5qMxjRsQe5pMA51Ifn5pyuXezWFqJsv4KqB2UjEmI492A+H3zjBozl
         z4vxBXelaWALb4vc9TiVQD3xffg2JpycIgMryRj7DdNlQnLoLTJRT2Pr6AqdUldNm96s
         mYxTY6jOTBKy5nq3H5sJhLnHjju1CLRU8H+bKZdHFr7DowwoqkFP2M9FXdH0qDJ2nJJ/
         ss8voK0KQx4e801oBm16bmWlzeZbPR02TnPcDNJm+WHvvx9pL8SRfhdK+3B1hDFHty8B
         eCloTAbKTVyukUiotzfMnjDTWGmB31ermFBDzmeDTGPpsb9KGnZpeSIajIf3hrjzGw2F
         MknQ==
X-Google-Smtp-Source: APXvYqyUH791dwLub9+aSF5x8hGs1SuLVkdyMKqfaB808Vqluqgizufg0qdY3/pJKJrf/LUH7OWf8Q==
X-Received: by 2002:a17:902:29e6:: with SMTP id h93mr5591074plb.297.1565141632504;
        Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.33.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:33:52 -0700 (PDT)
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
	Jeff Layton <jlayton@kernel.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	Sage Weil <sage@redhat.com>,
	"David S . Miller" <davem@davemloft.net>
Subject: [PATCH v3 05/41] net/ceph: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:04 -0700
Message-Id: <20190807013340.9706-6-jhubbard@nvidia.com>
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

Acked-by: Jeff Layton <jlayton@kernel.org>

Cc: Ilya Dryomov <idryomov@gmail.com>
Cc: Sage Weil <sage@redhat.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: ceph-devel@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 net/ceph/pagevec.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 64305e7056a1..c88fff2ab9bd 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -12,13 +12,7 @@
 
 void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
 {
-	int i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty_lock(pages[i]);
-		put_page(pages[i]);
-	}
+	put_user_pages_dirty_lock(pages, num_pages, dirty);
 	kvfree(pages);
 }
 EXPORT_SYMBOL(ceph_put_page_vector);
-- 
2.22.0

