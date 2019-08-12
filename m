Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A6FC0650F
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:51:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9657A2084D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 01:51:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tN18OW3e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9657A2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 162036B0006; Sun, 11 Aug 2019 21:51:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EE2A6B0008; Sun, 11 Aug 2019 21:51:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAAA06B000A; Sun, 11 Aug 2019 21:50:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0179.hostedemail.com [216.40.44.179])
	by kanga.kvack.org (Postfix) with ESMTP id C579B6B0006
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 21:50:59 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 6DDF2181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:59 +0000 (UTC)
X-FDA: 75812097438.11.pest42_5fe1c4f6c471b
X-HE-Tag: pest42_5fe1c4f6c471b
X-Filterd-Recvd-Size: 9407
Received: from mail-pl1-f193.google.com (mail-pl1-f193.google.com [209.85.214.193])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 01:50:58 +0000 (UTC)
Received: by mail-pl1-f193.google.com with SMTP id c14so47178321plo.0
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 18:50:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=5JtiWY0w31kuQOtn3l4X+8CaJzkxiVZy5vK9oZwhAyM=;
        b=tN18OW3egtBoEIE9QN2L83YpkIuEmn8E/2vatlX2Rt8/d5Cz4UgSVajiq6e/mKLtaS
         Y249S8PkRKY1XNNQCc1ShRk2rwVcEYBgq5dc/KhKvRDosjYbqzTKzsXamCtfiXYDc9Xp
         e09h33F7vAARQiFw/FG8VCiqdIkvyyhBlY/mp3fdDfxf6u2KTJYoHRQkFO45IwfAa5bo
         gJG8IrKfVZKwLlhGy/t3ERaR2nPJMfzZ5Lyz1p0oex5y7bLt3zvVM2vRFJ5rXSFt80t5
         3snZBb+hSDGsUlRyup/QfXn5z03seNoHqcPJopyWhki+dM/QX6bD5iOeLfhwkSMlhTih
         Gj3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=5JtiWY0w31kuQOtn3l4X+8CaJzkxiVZy5vK9oZwhAyM=;
        b=mH82FJAUnHWjJI+lW4WXJENEq74Byg0YiLC003B+tidZm7Cd2IqxdlCbeYKxPg2JG4
         Gko8YjVH3UbyqDZEQCLTkSnkRgz62PNMwvck5SSHOmXU2teeFrzCR+TGnRb96Z1jaD+t
         YhBBNTuHVImMRTVehFBi8BYTzNNQBUFYrTbtmhnjQequulTb6YWtsKVWvs2M2QD4/jId
         4I+zh07ZET+3QXcf4CCZnlg3L5YdMla/TwZ2FfBY+QGt9xuNkHZm7AFCVT3VcOsyb8Fc
         5NPNaJuF+z1F2viVS/+PLQDCap7nChfV7a3V0qHF33dlV1e8vUFfFpS97tU73irBur9n
         BaTA==
X-Gm-Message-State: APjAAAUTch1EWetnnKRFNEk6Nj9LkA1Wog8xGvBvHJs5ddQDh1u76Yfp
	iOXhrO24t7Z0TOFQaz1wD1c=
X-Google-Smtp-Source: APXvYqzBXwirWl6l+fEmHVCahvbTNzZTrBy2+Jlu3deIQj1LEMtfht+Rr+eRVfWYnMxSvK5SOCC2EQ==
X-Received: by 2002:a17:902:e311:: with SMTP id cg17mr3605017plb.183.1565574657941;
        Sun, 11 Aug 2019 18:50:57 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id j20sm100062363pfr.113.2019.08.11.18.50.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 18:50:57 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Date: Sun, 11 Aug 2019 18:50:44 -0700
Message-Id: <20190812015044.26176-3-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190812015044.26176-1-jhubbard@nvidia.com>
References: <20190812015044.26176-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

This is the "vaddr_pin_pages" corresponding variant to
get_user_pages_remote(), but with FOLL_PIN semantics: the implementation
sets FOLL_PIN. That, in turn, means that the pages must ultimately be
released by put_user_page*()--typically, via vaddr_unpin_pages*().

Note that the put_user_page*() requirement won't be truly
required until all of the call sites have been converted, and
the tracking of pages is actually activated.

Also introduce vaddr_unpin_pages(), in order to have a simpler
call for the error handling cases.

Use both of these new calls in the Infiniband drive, replacing
get_user_pages_remote() and put_user_pages().

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem_odp.c | 15 +++++----
 include/linux/mm.h                 |  7 +++++
 mm/gup.c                           | 50 ++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core=
/umem_odp.c
index 53085896d718..fdff034a8a30 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -534,7 +534,7 @@ static int ib_umem_odp_map_dma_single_page(
 	}
=20
 out:
-	put_user_page(page);
+	vaddr_unpin_pages(&page, 1, &umem_odp->umem.vaddr_pin);
=20
 	if (remove_existing_mapping) {
 		ib_umem_notifier_start_account(umem_odp);
@@ -635,9 +635,10 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *um=
em_odp, u64 user_virt,
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages =3D get_user_pages_remote(owning_process, owning_mm,
+		npages =3D vaddr_pin_pages_remote(owning_process, owning_mm,
 				user_virt, gup_num_pages,
-				flags, local_page_list, NULL, NULL);
+				flags, local_page_list, NULL, NULL,
+				&umem_odp->umem.vaddr_pin);
 		up_read(&owning_mm->mmap_sem);
=20
 		if (npages < 0) {
@@ -657,7 +658,8 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *ume=
m_odp, u64 user_virt,
 					ret =3D -EFAULT;
 					break;
 				}
-				put_user_page(local_page_list[j]);
+				vaddr_unpin_pages(&local_page_list[j], 1,
+						  &umem_odp->umem.vaddr_pin);
 				continue;
 			}
=20
@@ -684,8 +686,9 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *ume=
m_odp, u64 user_virt,
 			 * ib_umem_odp_map_dma_single_page().
 			 */
 			if (npages - (j + 1) > 0)
-				put_user_pages(&local_page_list[j+1],
-					       npages - (j + 1));
+				vaddr_unpin_pages(&local_page_list[j+1],
+						  npages - (j + 1),
+						  &umem_odp->umem.vaddr_pin);
 			break;
 		}
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 61b616cd9243..2bd76ad8787e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1606,6 +1606,13 @@ int __account_locked_vm(struct mm_struct *mm, unsi=
gned long pages, bool inc,
 long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
 		     unsigned int gup_flags, struct page **pages,
 		     struct vaddr_pin *vaddr_pin);
+long vaddr_pin_pages_remote(struct task_struct *tsk, struct mm_struct *m=
m,
+			    unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas, int *locked,
+			    struct vaddr_pin *vaddr_pin);
+void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
+		       struct vaddr_pin *vaddr_pin);
 void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_=
pages,
 				  struct vaddr_pin *vaddr_pin, bool make_dirty);
 bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *=
page);
diff --git a/mm/gup.c b/mm/gup.c
index 85f09958fbdc..bb95adfaf9b6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2518,6 +2518,38 @@ long vaddr_pin_pages(unsigned long addr, unsigned =
long nr_pages,
 }
 EXPORT_SYMBOL(vaddr_pin_pages);
=20
+/**
+ * vaddr_pin_pages pin pages by virtual address and return the pages to =
the
+ * user.
+ *
+ * @tsk:	the task_struct to use for page fault accounting, or
+ *		NULL if faults are not to be recorded.
+ * @mm:		mm_struct of target mm
+ * @addr:	start address
+ * @nr_pages:	number of pages to pin
+ * @gup_flags:	flags to use for the pin
+ * @pages:	array of pages returned
+ * @vaddr_pin:	initialized meta information this pin is to be associated
+ * with.
+ *
+ * This is the "vaddr_pin_pages" corresponding variant to
+ * get_user_pages_remote(), but with FOLL_PIN semantics: the implementat=
ion sets
+ * FOLL_PIN. That, in turn, means that the pages must ultimately be rele=
ased
+ * by put_user_page().
+ */
+long vaddr_pin_pages_remote(struct task_struct *tsk, struct mm_struct *m=
m,
+			    unsigned long start, unsigned long nr_pages,
+			    unsigned int gup_flags, struct page **pages,
+			    struct vm_area_struct **vmas, int *locked,
+			    struct vaddr_pin *vaddr_pin)
+{
+	gup_flags |=3D FOLL_TOUCH | FOLL_REMOTE | FOLL_PIN;
+
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
+				       locked, gup_flags, vaddr_pin);
+}
+EXPORT_SYMBOL(vaddr_pin_pages_remote);
+
 /**
  * vaddr_unpin_pages_dirty_lock - counterpart to vaddr_pin_pages
  *
@@ -2536,3 +2568,21 @@ void vaddr_unpin_pages_dirty_lock(struct page **pa=
ges, unsigned long nr_pages,
 	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, make_dirty);
 }
 EXPORT_SYMBOL(vaddr_unpin_pages_dirty_lock);
+
+/**
+ * vaddr_unpin_pages - simple, non-dirtying counterpart to vaddr_pin_pag=
es
+ *
+ * @pages: array of pages returned
+ * @nr_pages: number of pages in pages
+ * @vaddr_pin: same information passed to vaddr_pin_pages
+ *
+ * Like vaddr_unpin_pages_dirty_lock, but for non-dirty pages. Useful in=
 putting
+ * back pages in an error case: they were never made dirty.
+ */
+void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
+		       struct vaddr_pin *vaddr_pin)
+{
+	__put_user_pages_dirty_lock(vaddr_pin, pages, nr_pages, false);
+}
+EXPORT_SYMBOL(vaddr_unpin_pages);
+
--=20
2.22.0


