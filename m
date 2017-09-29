Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16EA06B0266
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:27:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q75so6605931pfl.1
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 18:27:33 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 82si2334309pfx.595.2017.09.28.18.27.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 18:27:32 -0700 (PDT)
Subject: [PATCH v2 1/4] dax: quiet bdev_dax_supported()
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Sep 2017 18:21:06 -0700
Message-ID: <150664806686.36094.15885850593435187213.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-nvdimm@lists.01.org

Leave it to the caller to decide if bdev_dax_supported() failures are
errors worth emitting to the log.

Reported-by: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 30d8a5aedd23..b0cc8117eebe 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -92,21 +92,21 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
 	long len;
 
 	if (blocksize != PAGE_SIZE) {
-		pr_err("VFS (%s): error: unsupported blocksize for dax\n",
+		pr_debug("VFS (%s): error: unsupported blocksize for dax\n",
 				sb->s_id);
 		return -EINVAL;
 	}
 
 	err = bdev_dax_pgoff(bdev, 0, PAGE_SIZE, &pgoff);
 	if (err) {
-		pr_err("VFS (%s): error: unaligned partition for dax\n",
+		pr_debug("VFS (%s): error: unaligned partition for dax\n",
 				sb->s_id);
 		return err;
 	}
 
 	dax_dev = dax_get_by_host(bdev->bd_disk->disk_name);
 	if (!dax_dev) {
-		pr_err("VFS (%s): error: device does not support dax\n",
+		pr_debug("VFS (%s): error: device does not support dax\n",
 				sb->s_id);
 		return -EOPNOTSUPP;
 	}
@@ -118,7 +118,7 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
 	put_dax(dax_dev);
 
 	if (len < 1) {
-		pr_err("VFS (%s): error: dax access failed (%ld)\n",
+		pr_debug("VFS (%s): error: dax access failed (%ld)\n",
 				sb->s_id, len);
 		return len < 0 ? len : -EIO;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
