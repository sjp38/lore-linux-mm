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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A24DFC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BA332173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="K8d7XfBV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BA332173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC3B6B026B; Tue,  6 Aug 2019 21:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 744356B026C; Tue,  6 Aug 2019 21:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 599726B026D; Tue,  6 Aug 2019 21:34:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 17C796B026B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g21so57192221pfb.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=gZoMCSPpVznwBLae6krcrJp3UcjCN6xK9l913pbLg1FeGMNRsS81vAKYGyiozLHNCE
         iB401N586LbyTklGmWLFna7AG5N8eV/gP2y6kVSURAb7KBFM4XDx9OFbGqhcfeFor5t2
         r+q582SM0y01e4KSRg9fXJ1ZXYeSc6KFZGJEkq2eH05aaqKtAoqjtZQWL9rYzSHJ96Yx
         jTupadXtqDnHgn3QWGrqRWfmRcNkB+Xyw9zFIJ6HYhgP8bGQRz9BMExO5s4+EDpy6+b7
         8kvGEtPBasL8Y6GTIOwSyVzsIYwHnORN24qYHmk2c5+nPz25/mlveVhly6hgIam+TqzZ
         R57w==
X-Gm-Message-State: APjAAAVRY6SLXvNCz8g0LhMgSr6K3svOgNZzLSZ6iKbz6WB9xhoqpscg
	RnXxQWjy78qshZMyNxyfg4vSIAv5qEdw5kVTVngQLvX2Tr7dDRUOM1iNA5/uyDZ22e2qYBl8uxp
	Rm1y6ZV+cVSH95K6P03DAQmsEQE2sW/ElJTC0FI9vzo29RlOXvee5hhq+XZjgRvLHhA==
X-Received: by 2002:a65:50c5:: with SMTP id s5mr5553969pgp.368.1565141644679;
        Tue, 06 Aug 2019 18:34:04 -0700 (PDT)
X-Received: by 2002:a65:50c5:: with SMTP id s5mr5553926pgp.368.1565141643943;
        Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141643; cv=none;
        d=google.com; s=arc-20160816;
        b=VNw7jIlpLsDwtEchkyRCxAtaxfQxPXK9JGGhIe69omr5UziW/OMTz1HnTCbZXB4mZO
         nUivWoqnY0XKNH3lzJkXzJOsQcPBJ5ltV5395YJCzQoypZlS1NmQFRXHngDqttD+saL5
         PbEN5Isy5mFDx6zBDAs25oV0AbaR1aEYxYjJVTNyNa60CnnB6Wu53OpRAXnOLIercEp3
         PY29WoJ9+07XfwQmUO2idmESYZxf+JMjOz9HPiFdyuIZLskhoSPLQcK/sthpIA9ftBOi
         wdhdW+VBJZJcpawgxN6Vx5l0M2kHUpUn5wPmFRYhpPERyD7TeG033CtZTt0eWQ67s+wl
         arUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=bImSv/T+2utyuAv/4kvI9ak12Id0ApFgssXlcZ7RGopoyG9Y3tmPRPwcBZhOFbaNq7
         NB4T7XW0k1eGClaWOuYSKg30E/pSULGpChClNY90VjXCB7DmMGf3J2EU36Y6l2U9PAL7
         0v8sTU6j1Eiiv2SLtgQdbbyZKYM69ImG7jg7ztlUAXJVnlMPKAG2gGvA3H7KdMHrjNls
         znPTd0j6cNbV+vZ/R/YI4s4N230pszFKETMrcVyh8DOMH8CcDm1EWcsiTS8Nw+7xCmXM
         M4smwzCSP9HKZx9HnLfrMGPlEAN0r09ipiU7a1/Lc4cQ01mE9ZtKLui8ckWakiVUBFAE
         sosQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8d7XfBV;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor104345175pln.14.2019.08.06.18.34.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=K8d7XfBV;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=wKnEf1dGeTf0vHOLp5WCTJvqak8NT8hcLNnzrVdQpMI=;
        b=K8d7XfBVJ8I/mb7D/So0s6zKV29K6nxqxOt+bscjBjWDfj0QC4+NZ8AYd4oczxdsUX
         7wYPGKgQnoRkCSwDEzT5rYkfZH7JJhJa6zaR/ydsa7uoMZJ2HjI2/BwiodCRxy0cgQ7K
         XR5LIHl94MzAJMcKyHWewTAlNkEf03nHhilsBgX1FcYreTK5la4X960fbNds2SN0gwIm
         bKXQLrcvXV5StThdICG212KTTY6r0QHSstMpGRVtwfJea1D8uaBa/9MN3hrGQMnPOq1P
         vjikEXBKeoKeYn0bHuTZu93yS1xwpaeL4dzZeJbSwqGj8iWMWHA9ZukGsRqP3BMDHZZx
         L72g==
X-Google-Smtp-Source: APXvYqyq3BsS9DZUg5HbsH/cxAQFP71mzzuud27zN7KWsFT/18m4ES12yBRl2dAxm3nkOU3YhT47jw==
X-Received: by 2002:a17:902:e30b:: with SMTP id cg11mr5920567plb.335.1565141643695;
        Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:03 -0700 (PDT)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	"Guilherme G . Piccoli" <gpiccoli@linux.vnet.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v3 12/41] genwqe: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:11 -0700
Message-Id: <20190807013340.9706-13-jhubbard@nvidia.com>
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

This changes the release code slightly, because each page slot in the
page_list[] array is no longer checked for NULL. However, that check
was wrong anyway, because the get_user_pages() pattern of usage here
never allowed for NULL entries within a range of pinned pages.

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Cc: Frank Haverkamp <haver@linux.vnet.ibm.com>
Cc: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/genwqe/card_utils.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/misc/genwqe/card_utils.c b/drivers/misc/genwqe/card_utils.c
index 2e1c4d2905e8..2a888f31d2c5 100644
--- a/drivers/misc/genwqe/card_utils.c
+++ b/drivers/misc/genwqe/card_utils.c
@@ -517,24 +517,13 @@ int genwqe_free_sync_sgl(struct genwqe_dev *cd, struct genwqe_sgl *sgl)
 /**
  * genwqe_free_user_pages() - Give pinned pages back
  *
- * Documentation of get_user_pages is in mm/gup.c:
- *
- * If the page is written to, set_page_dirty (or set_page_dirty_lock,
- * as appropriate) must be called after the page is finished with, and
- * before put_page is called.
+ * The pages may have been written to, so we call put_user_pages_dirty_lock(),
+ * rather than put_user_pages().
  */
 static int genwqe_free_user_pages(struct page **page_list,
 			unsigned int nr_pages, int dirty)
 {
-	unsigned int i;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (page_list[i] != NULL) {
-			if (dirty)
-				set_page_dirty_lock(page_list[i]);
-			put_page(page_list[i]);
-		}
-	}
+	put_user_pages_dirty_lock(page_list, nr_pages, dirty);
 	return 0;
 }
 
-- 
2.22.0

