Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50255C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E820320693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:57:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L70HGCBp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E820320693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCDF38E0006; Tue, 30 Jul 2019 16:57:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C06BE8E0001; Tue, 30 Jul 2019 16:57:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BD0F8E0006; Tue, 30 Jul 2019 16:57:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65B8F8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:57:12 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q14so41641145pff.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:57:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=Dyq+ph1J23s2I/sw5y7E/GkVVMbF9RUjpeDbF1CtDTUen2Ibic5hA5kEl18qzfr2n7
         GnmQ3H622QfQP8U5G4a7Ahmt9s7bCLSvHiMCt6+iLJtghtEH0xItJM/A62j0hBmuZifN
         ezwDxcoHWyQJHogvr/sjZ7cFKH6iiRSt4Wv1i02AMmWIqUc/sEVngYLWxGBAcZJOTadJ
         LXCfJRcMnV38KlfFYSx8nE5QpRc8HEcCzsE3hZbC7sE60TxuMjE1i3D7IumtVTlKWlU0
         mKU2C/VZmNRSo/moF/j6iCgz7xgF7/MLDa8y/BuN8UYloZhsPwpmQZ3FQ8a4daGKzNsB
         iD7A==
X-Gm-Message-State: APjAAAXLidN5JSLBZZmL9X5Ow2CgE5F3jBhSRujg4hix3zw/Pnk/TjmA
	5WtqOfH/8EM9CLME8aplnjAullIDgZKWnqoRy5RnU5xR2WtFTIXldvTwuSyZhsRmSm76QDNTY4N
	lLfO/qcP+Emjq9D9o+NfSY5RulcuU5axSH3EiasWL9x3G4TPn362lTco5SOdjiijKAg==
X-Received: by 2002:a17:902:a504:: with SMTP id s4mr93922492plq.117.1564520232016;
        Tue, 30 Jul 2019 13:57:12 -0700 (PDT)
X-Received: by 2002:a17:902:a504:: with SMTP id s4mr93922471plq.117.1564520231304;
        Tue, 30 Jul 2019 13:57:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564520231; cv=none;
        d=google.com; s=arc-20160816;
        b=OhFHwt5gPkz/hpZvc0XTkcNBu0mXCl/UAPvfPdM9vhHMHcoDpy1Z7fwRlV64po0Otx
         jAle340C4vV6OFZGDM/tH+2Kjfb16SDsQN7oIn9wWRdZNuinMeV2QWvy8DSLv+eB8eqN
         EvsZAhSf5AtTXE2DrqDvhZzPElcnny6FIZff2CFuKy6PwmKnZ/tG8Z130bHyy5HEilyY
         xhReBU8wlZGiqRD/rbO+IMyS1GP2/bYPgrm9EcjnwjYfb2G6qTS/Df0Kgn0SrhWhCOpF
         UyLPK+ar43SjzdrrFBrKeDSfx6zZpchgL4qcIkWo8IuNYNDyD4+LueCbWdk198lzp5TP
         iRSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=wgqgdlLG4RQEjv3bJUgSNwcJ4kk+Y9xxEa9sZRzb/T4J1AtG9yknh0my3Nrx7aK1YO
         oo03j96hErM3LiXfiWGwWjnE41f4tAvWbi+fwElIP24PhxXikSJgffnTc+LaxCjnQeF0
         jm3l9XgHKdMsD64a5gsIaQ5bv+KKXQUpC2ufsOeOWuru9k2Menc7ecQXt0KWRQoUaD4G
         P2c8XWucAlN22QVe4Us7OTGfxWMcnz0YHUrRNCr9bxYBh/5FyOefrhbQIhCX3vqkAC3n
         KlfOtvQZbkkp1J2roIjuGvrTq6tMLrN5+X50gsVs+IBhXIFPUmGLPG1jHsp0Ea25z+3r
         KHxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L70HGCBp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q10sor78691752pls.59.2019.07.30.13.57.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 13:57:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=L70HGCBp;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SsIRGkPWeq5HvTZzTxF/TGZYHjIKFiRIBMhKcsnvtic=;
        b=L70HGCBpUUMrWcTYYa1tWt0fRX779kjwbp/s6gA95+/zzmpU3IMR+36XPu6QXWYkEz
         GEPYR7mAV3vyjYSmzzWYu6kjt+nQg1Jg4SangC+yzRJwehG6MkWlg16U5uguv1hf3kWq
         9Tqg0UJEIPLTyulc+AA/95D7pCfaH+LelJn5KxT6KTVfpFGLIfvySPSKZsZzkMs9nKuh
         QWj9L9d1BZ5D59hL8WBrevhlL1w7quzW43CxLhBc+4AyG43JuFNBmQt/xX6gXlBUF1zH
         xpHnUvhHUuhY3ZdNfG7F8rbdZ5KLVsX0Zf+N41sRw4UH+rRhS++YLT9LEFo089KwaEs6
         02wQ==
X-Google-Smtp-Source: APXvYqyy6VjZJUb9Skq0KrIp0ivrFjlnCTe9JAlvBAw+0GWE4YicDO+sW1ZwlcZNdADtE6J1EDk0/A==
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr114922168plb.26.1564520231026;
        Tue, 30 Jul 2019 13:57:11 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id 137sm80565678pfz.112.2019.07.30.13.57.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 13:57:10 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jens Axboe <axboe@kernel.dk>,
	Jerome Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-xfs@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	dri-devel@lists.freedesktop.org
Subject: [PATCH v4 2/3] drivers/gpu/drm/via: convert put_page() to put_user_page*()
Date: Tue, 30 Jul 2019 13:57:04 -0700
Message-Id: <20190730205705.9018-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190730205705.9018-1-jhubbard@nvidia.com>
References: <20190730205705.9018-1-jhubbard@nvidia.com>
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

