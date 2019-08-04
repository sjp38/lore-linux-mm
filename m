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
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCED1C32751
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F71820882
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 21:40:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H+p30VSj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F71820882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 606076B0006; Sun,  4 Aug 2019 17:40:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B86E6B0007; Sun,  4 Aug 2019 17:40:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 409796B0008; Sun,  4 Aug 2019 17:40:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0756F6B0006
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 17:40:50 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j22so52079825pfe.11
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 14:40:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=Q2RkGAGYwPO+B+qQUWYypNR1lb6VWWwfShw8fcnTTgR77cQU6n2h0e1EfjAibSoE8Y
         Q/DhImLZtwaq30vdSnFXJ1XbxHYYCwvQ/EKRVXXp7dJZGo3CxOO7M3SP93atgA+FWAV6
         OZBc+aGkjy0UVO2h2IINlCWPaBwnww3eiCH89BNV/syrTa7L7b96tM+TkbdrhvPYQVN9
         Ge/HL3Fcr9+uD69+4tAeFmIWRwp8dHAVuhsJ0MrUNj12rCd2vrsY7sCT6/yaejkCgdfT
         G/uqITHtyNpK8kYgDp/py+CzCujsMkVqdo9DF77YmTr7GL5vWed8dON8rxT6BLiv9w6A
         NGVw==
X-Gm-Message-State: APjAAAVtLfFD5xpaR3gRwz3mO7TrnU2m/KNt6dyclfDRNCYySlI/xOW+
	Q+Q+G2I1xyJMkTjf2cu2gQ7JKPFZQIqMflx4s9UbISAc4mY8yKfFICAroPh4O0xguZu7QNuDrTg
	WQgfkTeYmLLOce9cqG07io7YwHb1ejWOmU08EbrRDEJMSiR0Hg2AYj7dDlZTj1yeIdw==
X-Received: by 2002:a63:f941:: with SMTP id q1mr134591492pgk.350.1564954849622;
        Sun, 04 Aug 2019 14:40:49 -0700 (PDT)
X-Received: by 2002:a63:f941:: with SMTP id q1mr134591445pgk.350.1564954848779;
        Sun, 04 Aug 2019 14:40:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564954848; cv=none;
        d=google.com; s=arc-20160816;
        b=hGt4Kfa3lHYoGfyXst7i4UsK1NRTfShOqE9vLkoU0y486476kOO6wFm+tJcKgn6I3+
         QKU4Ni3GR8aSdMjqBP+6Qv7UarFR7L7hpmZMFSHFoDHZG2ouhx/gHnokWDkOMuZKoQ4Z
         qPU3ESLyLJdoTdGbs7bkco1HiU1EGmUDMMatheQUD9v/gJ7LZaRHVEi8ERT7ZMURBLWI
         +JR+wx9fuHuyfvI3rbzr6SMcJ1uVsTbE8nM1c6C0MdM4LKtP9M+cnGwIHmrkXoVznoY9
         yx7sGIIi7ZBxcMSi1xm4nmI3BfBwjI8n8uECM3dz3M633OxqrQUCgX05i7Wu+OL3iDsg
         3dow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=lnhxwRotnzJj1Ci6ZNRfJBW6zZcmLhPLofVu+Qo4wC3b2dGPKuj0Fzp0xGRisgBHZB
         eW52uEblgYD6OhaKgIb0HRKvo+dAbkD7O8I8DwIgtO7Wc8W6vDuy3cr5IlPcEmLcZD5j
         mui8o2/iHBYZVMEFWGXI1GqfIw6EPr0lMTsHz7xU7yuiueGz9yo8MdRd/pWvNRnhvYKx
         ciZQCKBP8NSm6OYYS/bzYkO62OJNeDAyM8edndMw7IAjPj7ij0hbVkoBFMXtxOAKs0+8
         cJCAG7IdeQTAFMiIne7AMhB32hIGNPek/M9CbN8TKDSKBKQVWwMiHXe6ZdAK/Qm9Mf4O
         0gbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H+p30VSj;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f30sor15846751plf.49.2019.08.04.14.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 14:40:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=H+p30VSj;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=H+p30VSjG2bf5AhOggB5BMZsW4m9risk1SBKygWZEa4RLF2QVvj46onSB9Iu63cBhz
         /42BdWC1CpQTI/gGo4HQcAmlqUhbQCDZyO1er4CKT+ES4DgPE9pjxTxvrM2Ml2etyUAT
         1Jtn0wq64e1geuJnx4qMRvHAZBG/LKpdwbNiHwhnrbMTIkPJsHZzbHJBHtuUZ+gVzsbV
         zw4cg6zSDS23YxXKB9O6N3MS4xcetMMvqcuy9hwn1XOQsF1ghps+HImfUVntNxOD9trO
         /ykc4DpaFmLktsZjHWpryrOPu7Yfj6Ao/n7wqskKVhmAebiL+EbFEYmmU1Z31P50MkGX
         IaUA==
X-Google-Smtp-Source: APXvYqydipLt//yx7Zzw8Y7M/UPDM4z+2keifWIA9ZuDE301mL9AEMh6QPc9OqCc5SJgqPJLA9fETg==
X-Received: by 2002:a17:902:16f:: with SMTP id 102mr136326006plb.94.1564954848548;
        Sun, 04 Aug 2019 14:40:48 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 143sm123751024pgc.6.2019.08.04.14.40.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 14:40:47 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	Christoph Hellwig <hch@lst.de>,
	Daniel Vetter <daniel@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	David Airlie <airlied@linux.ie>,
	"David S . Miller" <davem@davemloft.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Ming Lei <ming.lei@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>,
	Yan Zheng <zyan@redhat.com>,
	netdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org,
	linux-rdma@vger.kernel.org,
	bpf@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH v6 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 14:40:41 -0700
Message-Id: <20190804214042.4564-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804214042.4564-1-jhubbard@nvidia.com>
References: <20190804214042.4564-1-jhubbard@nvidia.com>
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

Also reverse the order of a comparison, in order to placate
checkpatch.pl.

Cc: David Airlie <airlied@linux.ie>
Cc: Daniel Vetter <daniel@ffwll.ch>
Cc: dri-devel@lists.freedesktop.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 062067438f1d..b5b5bf0ba65e 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -171,7 +171,6 @@ via_map_blit_for_device(struct pci_dev *pdev,
 static void
 via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 {
-	struct page *page;
 	int i;
 
 	switch (vsg->state) {
@@ -186,13 +185,8 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		kfree(vsg->desc_pages);
 		/* fall through */
 	case dr_via_pages_locked:
-		for (i = 0; i < vsg->num_pages; ++i) {
-			if (NULL != (page = vsg->pages[i])) {
-				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					SetPageDirty(page);
-				put_page(page);
-			}
-		}
+		put_user_pages_dirty_lock(vsg->pages, vsg->num_pages,
+					  (vsg->direction == DMA_FROM_DEVICE));
 		/* fall through */
 	case dr_via_pages_alloc:
 		vfree(vsg->pages);
-- 
2.22.0

