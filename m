Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D082C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:24:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC11D2133F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:24:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Y30zmGP3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC11D2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 670816B000C; Fri, 16 Aug 2019 22:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F9636B000E; Fri, 16 Aug 2019 22:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49DB66B0010; Fri, 16 Aug 2019 22:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0024.hostedemail.com [216.40.44.24])
	by kanga.kvack.org (Postfix) with ESMTP id 0F3B26B000C
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:24:25 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 94E17181AC9CB
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:24:24 +0000 (UTC)
X-FDA: 75830325648.14.geese11_609cafa3e713d
X-HE-Tag: geese11_609cafa3e713d
X-Filterd-Recvd-Size: 7825
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:24:23 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5765590000>; Fri, 16 Aug 2019 19:24:25 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 16 Aug 2019 19:24:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 16 Aug 2019 19:24:22 -0700
Received: from HQMAIL105.nvidia.com (172.20.187.12) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 17 Aug
 2019 02:24:21 +0000
Received: from hqnvemgw02.nvidia.com (172.16.227.111) by HQMAIL105.nvidia.com
 (172.20.187.12) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Sat, 17 Aug 2019 02:24:21 +0000
Received: from blueforge.nvidia.com (Not Verified[10.110.48.28]) by hqnvemgw02.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d5765550005>; Fri, 16 Aug 2019 19:24:21 -0700
From: <jhubbard@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ira Weiny
	<ira.weiny@intel.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>
Subject: [RFC PATCH v2 3/3] mm/gup: introduce vaddr_pin_pages_remote(), and invoke it
Date: Fri, 16 Aug 2019 19:24:19 -0700
Message-ID: <20190817022419.23304-4-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817022419.23304-1-jhubbard@nvidia.com>
References: <20190817022419.23304-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566008665; bh=jhSONwSyzrn/izs91P2wXpXqszQlhZsN0gR467gTsjs=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-NVConfidentiality:
	 Content-Transfer-Encoding:Content-Type;
	b=Y30zmGP3pyJ+i5kjKmTIFHrsqeTMoSxdM8vX1S/23NKbMNSIiKjV7dVPnuKsRPg6v
	 AOrcco59tMpMfHoitfbXVIX9cRglCfBNwIgxVjkvS2yx1ZbSzbv2fc3pkrO1dxtIYx
	 4hXSLlFwh4FUyb4+4zC4CecqdFSTu1ORzqaQhivViQEG6gz0XdNK6RGl2Jh/hrGDoU
	 M2mqRuc0e2pB46DVKNfTZG9dKBn/4wqddlMu7PNSbepRkFDfsKqrrFobOH7HGxPfKd
	 Bi1iSW1c7CQKoQx2MNmyHk0lzqdk5lbrfs73pZmrTvnScY7SkXfdwLir3EbFdU5PD4
	 wE3LRPxfTRXNQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

vaddr_pin_user_pages_remote() is the "vaddr_pin_pages" corresponding
variant to get_user_pages_remote(): it adds the ability to handle
FOLL_PIN, FOLL_LONGTERM, or both.

Note that the put_user_page*() requirement won't be truly required until
all of the call sites have been converted, and the tracking of pages is
activated.

Also, change process_vm_rw_single_vec() to invoke the new function.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/mm.h     |  5 +++++
 mm/gup.c               | 33 +++++++++++++++++++++++++++++++++
 mm/process_vm_access.c | 23 ++++++++++++++---------
 3 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e7de424bf5e..849b509e9f89 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1606,6 +1606,11 @@ int __account_locked_vm(struct mm_struct *mm, unsign=
ed long pages, bool inc,
 long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
 		     unsigned int gup_flags, struct page **pages,
 		     struct vaddr_pin *vaddr_pin);
+long vaddr_pin_user_pages_remote(struct task_struct *tsk, struct mm_struct=
 *mm,
+				 unsigned long start, unsigned long nr_pages,
+				 unsigned int gup_flags, struct page **pages,
+				 struct vm_area_struct **vmas, int *locked,
+				 struct vaddr_pin *vaddr_pin);
 void vaddr_unpin_pages(struct page **pages, unsigned long nr_pages,
 		       struct vaddr_pin *vaddr_pin, bool make_dirty);
 bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *pa=
ge);
diff --git a/mm/gup.c b/mm/gup.c
index e49096d012ea..d7ce9b38178f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2522,3 +2522,36 @@ void vaddr_unpin_pages(struct page **pages, unsigned=
 long nr_pages,
 	__put_user_pages_dirty_lock(pages, nr_pages, make_dirty, vaddr_pin);
 }
 EXPORT_SYMBOL(vaddr_unpin_pages);
+
+/**
+ * vaddr_pin_user_pages_remote() - pin pages by virtual address and return=
 the
+ * pages to the user.
+ *
+ * @tsk:	the task_struct to use for page fault accounting, or
+ *		NULL if faults are not to be recorded.
+ * @mm:		mm_struct of target mm
+ * @addr:	start address
+ * @nr_pages:	number of pages to pin
+ * @gup_flags:	flags to use for the pin. Please see FOLL_* documentation i=
n
+ *		mm.h.
+ * @pages:	array of pages returned
+ * @vaddr_pin:  If FOLL_LONGTERM is set, then vaddr_pin should point to an
+ * initialized struct that contains the owning mm and file. Otherwise, vad=
dr_pin
+ * should be set to NULL.
+ *
+ * This is the "vaddr_pin_pages" corresponding variant to
+ * get_user_pages_remote(), but with the ability to handle FOLL_PIN,
+ * FOLL_LONGTERM, or both.
+ */
+long vaddr_pin_user_pages_remote(struct task_struct *tsk, struct mm_struct=
 *mm,
+				 unsigned long start, unsigned long nr_pages,
+				 unsigned int gup_flags, struct page **pages,
+				 struct vm_area_struct **vmas, int *locked,
+				 struct vaddr_pin *vaddr_pin)
+{
+	gup_flags |=3D FOLL_TOUCH | FOLL_REMOTE;
+
+	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
+				       locked, gup_flags, vaddr_pin);
+}
+EXPORT_SYMBOL(vaddr_pin_user_pages_remote);
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 357aa7bef6c0..e08c1f760ad4 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -96,7 +96,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		flags |=3D FOLL_WRITE;
=20
 	while (!rc && nr_pages && iov_iter_count(iter)) {
-		int pages =3D min(nr_pages, max_pages_per_loop);
+		int pinned_pages =3D min(nr_pages, max_pages_per_loop);
 		int locked =3D 1;
 		size_t bytes;
=20
@@ -106,14 +106,18 @@ static int process_vm_rw_single_vec(unsigned long add=
r,
 		 * current/current->mm
 		 */
 		down_read(&mm->mmap_sem);
-		pages =3D get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+
+		flags |=3D FOLL_PIN;
+		pinned_pages =3D vaddr_pin_user_pages_remote(task, mm, pa,
+							   pinned_pages, flags,
+							   process_pages, NULL,
+							   &locked, NULL);
 		if (locked)
 			up_read(&mm->mmap_sem);
-		if (pages <=3D 0)
+		if (pinned_pages <=3D 0)
 			return -EFAULT;
=20
-		bytes =3D pages * PAGE_SIZE - start_offset;
+		bytes =3D pinned_pages * PAGE_SIZE - start_offset;
 		if (bytes > len)
 			bytes =3D len;
=20
@@ -122,10 +126,11 @@ static int process_vm_rw_single_vec(unsigned long add=
r,
 					 vm_write);
 		len -=3D bytes;
 		start_offset =3D 0;
-		nr_pages -=3D pages;
-		pa +=3D pages * PAGE_SIZE;
-		while (pages)
-			put_page(process_pages[--pages]);
+		nr_pages -=3D pinned_pages;
+		pa +=3D pinned_pages * PAGE_SIZE;
+
+		/* If vm_write is set, the pages need to be made dirty: */
+		vaddr_unpin_pages(process_pages, pinned_pages, NULL, vm_write);
 	}
=20
 	return rc;
--=20
2.22.1


