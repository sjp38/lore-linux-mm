Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF39B6B0275
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:11:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so3835760pgp.4
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:11:13 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y34-v6si30665418plb.17.2018.07.16.10.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:11:12 -0700 (PDT)
Subject: [PATCH v2 10/14] filesystem-dax: Do not request a pfn when not
 required
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:01:14 -0700
Message-ID: <153176047420.12695.9821577651771886595.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Huaisheng Ye <yehs1@lenovo.com>, Jan Kara <jack@suse.cz>, vishal.l.verma@intel.com, hch@lst.de, linux-mm@kvack.orgjack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

From: Huaisheng Ye <yehs1@lenovo.com>

Some functions within fs/dax don't need to get pfn from direct_access.
In support of allowing memmap initialization to run in the background
elide requests for pfns when not required.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 641192808bb6..28264ff4e343 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -647,7 +647,6 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
 {
 	void *vto, *kaddr;
 	pgoff_t pgoff;
-	pfn_t pfn;
 	long rc;
 	int id;
 
@@ -656,7 +655,7 @@ static int copy_user_dax(struct block_device *bdev, struct dax_device *dax_dev,
 		return rc;
 
 	id = dax_read_lock();
-	rc = dax_direct_access(dax_dev, pgoff, PHYS_PFN(size), &kaddr, &pfn);
+	rc = dax_direct_access(dax_dev, pgoff, PHYS_PFN(size), &kaddr, NULL);
 	if (rc < 0) {
 		dax_read_unlock(id);
 		return rc;
@@ -1052,15 +1051,13 @@ int __dax_zero_page_range(struct block_device *bdev,
 		pgoff_t pgoff;
 		long rc, id;
 		void *kaddr;
-		pfn_t pfn;
 
 		rc = bdev_dax_pgoff(bdev, sector, PAGE_SIZE, &pgoff);
 		if (rc)
 			return rc;
 
 		id = dax_read_lock();
-		rc = dax_direct_access(dax_dev, pgoff, 1, &kaddr,
-				&pfn);
+		rc = dax_direct_access(dax_dev, pgoff, 1, &kaddr, NULL);
 		if (rc < 0) {
 			dax_read_unlock(id);
 			return rc;
@@ -1116,7 +1113,6 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		ssize_t map_len;
 		pgoff_t pgoff;
 		void *kaddr;
-		pfn_t pfn;
 
 		if (fatal_signal_pending(current)) {
 			ret = -EINTR;
@@ -1128,7 +1124,7 @@ dax_iomap_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 			break;
 
 		map_len = dax_direct_access(dax_dev, pgoff, PHYS_PFN(size),
-				&kaddr, &pfn);
+				&kaddr, NULL);
 		if (map_len < 0) {
 			ret = map_len;
 			break;
