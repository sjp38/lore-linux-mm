Return-Path: <SRS0=QXz1=VL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B591C742D2
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 19:11:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BDB620644
	for <linux-mm@archiver.kernel.org>; Sun, 14 Jul 2019 19:11:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="J6HG5WoH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BDB620644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99B446B0003; Sun, 14 Jul 2019 15:11:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9729D6B0006; Sun, 14 Jul 2019 15:11:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 887F56B0007; Sun, 14 Jul 2019 15:11:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53A1E6B0003
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 15:11:27 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so7399011plj.19
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 12:11:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=wTnR4jFSZHgDyQlzGAnxJLHPwWt9ff7eR4/YXCAXskI=;
        b=pQ2HsEFCMeLpwnjJYrjKaNT2BfWXgJ+521xTIKuKTFKFADqbe8z62AliLfMrFn6M+l
         4fxUBLTbDiUoqLs0EfoxgjJKp4iATb5YJYVhxUCfa1Hb1q9zn/ZVi/nMtgoeHuC7y0v5
         an3sX1b7Q8czLACNV7IUzH0JCPw7eddw84FR/2+vP/2A1EEyCr/n28Vo0mh67Da/ItF3
         OR8z6KMwhGq85iZw7yqsCJpdQxpshv04dvefLBXpU7DuBF5iNeuc6/uLfmSPNGrVQFz4
         kDqEt1P9AvBZDohtcFk6P13MIJmuzESAFlHJrViB3Dz15N4iOJeTVDSH4i6z+d7XgcHr
         Uv7A==
X-Gm-Message-State: APjAAAWro7MR53Oe7AFfLZffKbnsc9fZQ13UFsgyl9MIRDYR7oFlF6Py
	1uXjO9ttUC/LQ7k/zweq5btG/GRakPM5U5Mf1y/8kgKZr6EwuUtO67j2w6V+3KG0QBdnMyuxxaB
	Rk7CDXcUvOe6G5FDxM38kOSAs8OYHIlDcQFaA5UL78Ej8oURTdKMPbm3gfUWKh5/LQg==
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr25306721plb.25.1563131486796;
        Sun, 14 Jul 2019 12:11:26 -0700 (PDT)
X-Received: by 2002:a17:902:f082:: with SMTP id go2mr25306603plb.25.1563131485185;
        Sun, 14 Jul 2019 12:11:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563131485; cv=none;
        d=google.com; s=arc-20160816;
        b=NdOEOaSAQAAF2YEN33X7LgB2MOMzYUr8PIvWh+2OHJj4iA4Ahak4EBuoroFQMmrAg5
         gX/5G1RfHKA4QroDHz7tqKsC9Y4KQlpgPLWP6GGf/Gt7fWnU4V1UJFxErNqJVOwVO5bd
         lsMOqpCM2tlREjr9bcmWuq8Lk3C+6xMOep6iaZda2YHbKXpg0YxUnObKexVE1Z5432QE
         b3IdzAcdkpyaX+mfQ8Zf8lHVarwRVjGhSivdXSNq6NHV3KDA+NtieYtorrhJxddtnSj3
         oZJXm/XeR5gG3iqS9pnbnVdGSSa2Y6D5NzKjY8iZ3chWOgnwA+t2B0iv+Glwwwg1FIRh
         Kk8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=wTnR4jFSZHgDyQlzGAnxJLHPwWt9ff7eR4/YXCAXskI=;
        b=SV6SxkLtcUz0dTyZ/kPvpeH2xtspfnLQHHyXUVypcO7ykPiNN/jlg9HxrUZiVgza/+
         nmbE2LkYr8tC0GiPGOtxY9D0o9aCJ031s31E4k4kLofZy6T5TOtHcDrEnOAc0ai0CBzy
         /qWU5982YFICuEHDyJVSZQw//oyWHaDVZPjXC/bHDxmkCsCUFO1F8eqinYjSP8IMICqz
         EqswOt+KRjAWArPkZJaUiUHh/PQOmXbfie3huwiBmd9wpx3RrS1kWF32Bh4lGx+SM/pw
         qH0jPD5OVGlXDtJ/nl2NMXlwBBLb6TAE1xHw3wk6HAHVTLUUolRPzkaUuBft9Ow6qinQ
         Z5Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J6HG5WoH;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14sor5193920pgr.57.2019.07.14.12.11.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jul 2019 12:11:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=J6HG5WoH;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=wTnR4jFSZHgDyQlzGAnxJLHPwWt9ff7eR4/YXCAXskI=;
        b=J6HG5WoHErAl5v76PYLUAOefrG8S1mG5ji2ajAmi5iUq3zdhofWNi8R7FD/ZClvCkS
         YZRIbPxD9g4+z4/DKU3BnFzdBGd4B6hqacPQJCYiMAyTsjeQD0VnMRdVjMwT5iXX3Wf8
         K+dbgDP1QPuW9rFsXWNsx8mrnpo7er2XDn6BWvY/4l765HNnJzRdfTLFd1FC4ox/btui
         ANCUJV2jLkQANmaHn5GDebVXYHTnQ3iJntGgl9m+NUdNzEI4foq7AImezy1e0F0aWScj
         VTeFTRsX3XhDhFo4Vbx8wmcHarhMhRhIWCsne9M3/awdd48pqQRhjBDTphYabLqRYTaO
         N99A==
X-Google-Smtp-Source: APXvYqyoHwB+daqurf2TSePudMpL8bWbCxyh/0egoU2EbeU8TkfMkMtKnPM0Ke06j90ArJCf2o75Kg==
X-Received: by 2002:a63:bf01:: with SMTP id v1mr22482786pgf.278.1563131484751;
        Sun, 14 Jul 2019 12:11:24 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id m6sm15239358pfb.151.2019.07.14.12.11.22
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 14 Jul 2019 12:11:24 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: akpm@linux-foundation.org,
	ira.weiny@intel.com,
	jhubbard@nvidia.com
Cc: Bharath Vedartham <linux.bhar@gmail.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dimitri Sivanich <sivanich@sgi.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Jesper Dangaard Brouer <hawk@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Enrico Weigelt <info@metux.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Alexios Zavras <alexios.zavras@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Matt Sickler <Matt.Sickler@daktronics.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Keith Busch <keith.busch@intel.com>,
	YueHaibing <yuehaibing@huawei.com>,
	linux-media@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	netdev@vger.kernel.org,
	bpf@vger.kernel.org,
	xdp-newbies@vger.kernel.org
Subject: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
Date: Mon, 15 Jul 2019 00:38:34 +0530
Message-Id: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch converts all call sites of get_user_pages
to use put_user_page*() instead of put_page*() functions to
release reference to gup pinned pages.

This is a bunch of trivial conversions which is a part of an effort
by John Hubbard to solve issues with gup pinned pages and 
filesystem writeback.

The issue is more clearly described in John Hubbard's patch[1] where
put_user_page*() functions are introduced.

Currently put_user_page*() simply does put_page but future implementations
look to change that once treewide change of put_page callsites to 
put_user_page*() is finished.

The lwn article describing the issue with gup pinned pages and filesystem 
writeback [2].

This patch has been tested by building and booting the kernel as I don't
have the required hardware to test the device drivers.

I did not modify gpu/drm drivers which use release_pages instead of
put_page() to release reference of gup pinned pages as I am not clear
whether release_pages and put_page are interchangable. 

[1] https://lkml.org/lkml/2019/3/26/1396

[2] https://lwn.net/Articles/784574/

Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/media/v4l2-core/videobuf-dma-sg.c | 3 +--
 drivers/misc/sgi-gru/grufault.c           | 2 +-
 drivers/staging/kpc2000/kpc_dma/fileops.c | 4 +---
 drivers/vfio/vfio_iommu_type1.c           | 2 +-
 fs/io_uring.c                             | 7 +++----
 mm/gup_benchmark.c                        | 6 +-----
 net/xdp/xdp_umem.c                        | 7 +------
 7 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 66a6c6c..d6eeb43 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -349,8 +349,7 @@ int videobuf_dma_free(struct videobuf_dmabuf *dma)
 	BUG_ON(dma->sglen);
 
 	if (dma->pages) {
-		for (i = 0; i < dma->nr_pages; i++)
-			put_page(dma->pages[i]);
+		put_user_pages(dma->pages, dma->nr_pages);
 		kfree(dma->pages);
 		dma->pages = NULL;
 	}
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 4b713a8..61b3447 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
-	put_page(page);
+	put_user_page(page);
 	return 0;
 }
 
diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
index 6166587..26dceed 100644
--- a/drivers/staging/kpc2000/kpc_dma/fileops.c
+++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
@@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
 	sg_free_table(&acd->sgt);
  err_dma_map_sg:
  err_alloc_sg_table:
-	for (i = 0 ; i < acd->page_count ; i++){
-		put_page(acd->user_pages[i]);
-	}
+	put_user_pages(acd->user_pages, acd->page_count);
  err_get_user_pages:
 	kfree(acd->user_pages);
  err_alloc_userpages:
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index add34ad..c491524 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -369,7 +369,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		 */
 		if (ret > 0 && vma_is_fsdax(vmas[0])) {
 			ret = -EOPNOTSUPP;
-			put_page(page[0]);
+			put_user_page(page[0]);
 		}
 	}
 	up_read(&mm->mmap_sem);
diff --git a/fs/io_uring.c b/fs/io_uring.c
index 4ef62a4..b4a4549 100644
--- a/fs/io_uring.c
+++ b/fs/io_uring.c
@@ -2694,10 +2694,9 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
 			 * if we did partial map, or found file backed vmas,
 			 * release any pages we did get
 			 */
-			if (pret > 0) {
-				for (j = 0; j < pret; j++)
-					put_page(pages[j]);
-			}
+			if (pret > 0)
+				put_user_pages(pages, pret);
+
 			if (ctx->account_mem)
 				io_unaccount_mem(ctx->user, nr_pages);
 			kvfree(imu->bvec);
diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
index 7dd602d..15fc7a2 100644
--- a/mm/gup_benchmark.c
+++ b/mm/gup_benchmark.c
@@ -76,11 +76,7 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
 	gup->size = addr - gup->addr;
 
 	start_time = ktime_get();
-	for (i = 0; i < nr_pages; i++) {
-		if (!pages[i])
-			break;
-		put_page(pages[i]);
-	}
+	put_user_pages(pages, nr_pages);
 	end_time = ktime_get();
 	gup->put_delta_usec = ktime_us_delta(end_time, start_time);
 
diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
index 9c6de4f..6103e19 100644
--- a/net/xdp/xdp_umem.c
+++ b/net/xdp/xdp_umem.c
@@ -173,12 +173,7 @@ static void xdp_umem_unpin_pages(struct xdp_umem *umem)
 {
 	unsigned int i;
 
-	for (i = 0; i < umem->npgs; i++) {
-		struct page *page = umem->pgs[i];
-
-		set_page_dirty_lock(page);
-		put_page(page);
-	}
+	put_user_pages_dirty_lock(umem->pgs, umem->npgs);
 
 	kfree(umem->pgs);
 	umem->pgs = NULL;
-- 
1.8.3.1

