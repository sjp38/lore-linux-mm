Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B179C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0645B2199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 04:30:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t+zktHb7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0645B2199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB2CD8E0003; Mon, 22 Jul 2019 00:30:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3E046B0008; Mon, 22 Jul 2019 00:30:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A05D78E0003; Mon, 22 Jul 2019 00:30:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A11D6B0007
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 00:30:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so19105266pla.7
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 21:30:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Buo/x1ku3lZhKwc/x7LZHJLCV0/VJfVJkEd+jUfSemQ=;
        b=PJpbhbt1yKqOzOI251rugPEWER8vgMfPPkXui1MGi2ouzYG/xxqosZMnWmIWnQ2hjp
         sFtPOpWLmX7Ln99nSTwK/NSVzoeHRd74DYdPNaGRTfXQMIbUJHaZ/2nUWyC7CzMDTCY0
         W3QQSABnc18SIoEwfZ2aftHHo/82hj9oiklsY5IrIgBwar2tawJqw/ecNMJPMBOqZDxO
         Ig5DYpX+ZcBbCMtNCL7UPaLJrV2KYj8tYF7VSHhiKEUG2RcYic1qO1g4TJNEmaTlh2/y
         y8ZU1w1TWtJLNUyIK5FHIDDUFP4SwNz59iY5hUPGGZ4XNvnTT0MEEyOa05QesYwceWw+
         qbWg==
X-Gm-Message-State: APjAAAXKNkcb1IM7lfAzaYYHialfmnXRVGwVpB8gTH5edtNRGVNRh8Dq
	dwTGi2smUHVTrp+P3nmbZLOisYSELaCDqHA1/+9GsYGQY8ZCKjt8BScrDRPbwaKqSMpSW2Qguw5
	tS8sGwYhz5S86bsozGWCnrqkqLWxy3cqOphLU6w/l+LYfLanwlyhQor380MFcNkDLvQ==
X-Received: by 2002:a17:90a:4806:: with SMTP id a6mr75200525pjh.38.1563769820987;
        Sun, 21 Jul 2019 21:30:20 -0700 (PDT)
X-Received: by 2002:a17:90a:4806:: with SMTP id a6mr75200415pjh.38.1563769819758;
        Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563769819; cv=none;
        d=google.com; s=arc-20160816;
        b=FnW445Rf9BMjay5TGjLMaujano7wZ1CBD02q1xqH6KyruzYZZzek+NNhwt4lZICmPF
         AQd+Ex8ukzkeUomF+wX/YEKBV3LYxPpzf7NPxePA8mpO4OlZzeuONPPqiEPzKXm2DatO
         YNrDpjkWLUGeJJ0jz7aqa4PpH16kUPQUDqos6gEVnFx7F99EQcy6ScSJhY9uUBIEqstB
         CfaPItVODz5HTBAy3bK4JPjy+oAe/JfZKPcON71NXw5+LzWehjapkV59CKq6DDMAt0c7
         Rx3JT7ed2mMOehRkJgT7oimO3FEHFw4ihjkOnBysvECgaaVdTww26/JARQHZx/YZEYXt
         n9oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Buo/x1ku3lZhKwc/x7LZHJLCV0/VJfVJkEd+jUfSemQ=;
        b=Y+D2qxRkcN0fJzXjxlXADCx+kvMLqYAJ7GJtGpAVoDB+mYcOkStFlzLI0qILvNzsCY
         nhNJ4zCuwszDsou9vyS3y74tIsq04NZB6r8hxNbxgCFXFOoF6EoFCC6LRGD7V6Mz5to7
         HMLG5ARqN1uaitwBrHbOhg1RxyTXFanm2h6xPQ7vej8FDSzph3IXbu+hBoB9NMHjeja3
         rcDAR2VjUgEFJTiSnylvr/+Aux4HhLZjyp5rQAj/zrVuUJaNzLegNbq221VsftU+BYZf
         xgWqfUehunSoSMF3x9209RAkMAh92iSG9GRfxwwnlXr2GqLQwwqVzPR1IRP0FP61EOuS
         sSOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t+zktHb7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor46686448pju.23.2019.07.21.21.30.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t+zktHb7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Buo/x1ku3lZhKwc/x7LZHJLCV0/VJfVJkEd+jUfSemQ=;
        b=t+zktHb7vIG4ts5I2ltkQHV48J0ZrgypJDZXuh8Drmfq8ZU2ILeEdq1vHcQdIM9gdw
         V6T9AQozh+PvM/HqMIqy5Tm11lI/PpLyTVp0Vd74SuF5mClFEjFXDGjMIfpge1xQoCsm
         IhnhiaeU9cdQMTgVUWSOM6j8abtFujQkLro/ZEGxc5vfgAlJ/A2fXKxi+6ua/RqGJsAJ
         aF9WRDRmvUFsceuLPU8ZX2StoJI42RECfxqG70NX1cGm7d70CaK3aiDy2ueHCoMs6WN3
         fMhhkyT7kmlOi6Ja/WZU2mwWlGLAtDglCCekSpcUu5Vy9dQccxZDeZv6fJknPIHGCBXz
         Jv+w==
X-Google-Smtp-Source: APXvYqz665JUdaZ8/qhWBT5//AwERdP9iGLvt+InEi3nlWem4n0SFx0hcOfAG8MfqjlewAESAxZqZQ==
X-Received: by 2002:a17:90a:9488:: with SMTP id s8mr76721358pjo.2.1563769819486;
        Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id t96sm34285690pjb.1.2019.07.21.21.30.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 21:30:19 -0700 (PDT)
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
Subject: [PATCH 3/3] gup: new put_user_page_dirty*() helpers
Date: Sun, 21 Jul 2019 21:30:12 -0700
Message-Id: <20190722043012.22945-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190722043012.22945-1-jhubbard@nvidia.com>
References: <20190722043012.22945-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

While converting call sites to use put_user_page*() [1], quite a few
places ended up needing a single-page routine to put and dirty a
page.

Provide put_user_page_dirty() and put_user_page_dirty_lock(),
and use them in a few places: net/xdp, drm/via/, drivers/infiniband.

Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jan Kara <jack@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/gpu/drm/via/via_dmablit.c        |  2 +-
 drivers/infiniband/core/umem.c           |  2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c |  2 +-
 include/linux/mm.h                       | 10 ++++++++++
 net/xdp/xdp_umem.c                       |  2 +-
 5 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 219827ae114f..d30b2d75599f 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -189,7 +189,7 @@ via_free_sg_info(struct pci_dev *pdev, drm_via_sg_info_t *vsg)
 		for (i = 0; i < vsg->num_pages; ++i) {
 			if (NULL != (page = vsg->pages[i])) {
 				if (!PageReserved(page) && (DMA_FROM_DEVICE == vsg->direction))
-					put_user_pages_dirty(&page, 1);
+					put_user_page_dirty(page);
 				else
 					put_user_page(page);
 			}
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 08da840ed7ee..a7337cc3ca20 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -55,7 +55,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 	for_each_sg_page(umem->sg_head.sgl, &sg_iter, umem->sg_nents, 0) {
 		page = sg_page_iter_page(&sg_iter);
 		if (umem->writable && dirty)
-			put_user_pages_dirty_lock(&page, 1);
+			put_user_page_dirty_lock(page);
 		else
 			put_user_page(page);
 	}
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 0b0237d41613..d2ded624fb2a 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -76,7 +76,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
 			page = sg_page(sg);
 			pa = sg_phys(sg);
 			if (dirty)
-				put_user_pages_dirty_lock(&page, 1);
+				put_user_page_dirty_lock(page);
 			else
 				put_user_page(page);
 			usnic_dbg("pa: %pa\n", &pa);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..c0584c6d9d78 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1061,6 +1061,16 @@ void put_user_pages_dirty(struct page **pages, unsigned long npages);
 void put_user_pages_dirty_lock(struct page **pages, unsigned long npages);
 void put_user_pages(struct page **pages, unsigned long npages);
 
+static inline void put_user_page_dirty(struct page *page)
+{
+	put_user_pages_dirty(&page, 1);
+}
+
+static inline void put_user_page_dirty_lock(struct page *page)
+{
+	put_user_pages_dirty_lock(&page, 1);
+}
+
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
 #define SECTION_IN_PAGE_FLAGS
 #endif
diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 9cbbb96c2a32..1d122e52c6de 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -171,7 +171,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 	for (i = 0; i < umem->npgs; i++) {
 		struct page *page = umem->pgs[i];
 
-		put_user_pages_dirty_lock(&page, 1);
+		put_user_page_dirty_lock(page);
 	}
 
 	kfree(umem->pgs);
-- 
2.22.0

