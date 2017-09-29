Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C12176B0268
	for <linux-mm@kvack.org>; Thu, 28 Sep 2017 21:27:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p87so6578917pfj.4
        for <linux-mm@kvack.org>; Thu, 28 Sep 2017 18:27:38 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f15si2310948pgr.305.2017.09.28.18.27.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Sep 2017 18:27:37 -0700 (PDT)
Subject: [PATCH v2 2/4] dax: disable filesystem dax on devices that do not
 map pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 28 Sep 2017 18:21:12 -0700
Message-ID: <150664807247.36094.11168730579639072446.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

If a dax buffer from a device that does not map pages is passed to
read(2) or write(2) as a target for direct-I/O it triggers SIGBUS. If
gdb attempts to examine the contents of a dax buffer from a device that
does not map pages it triggers SIGBUS. If fork(2) is called on a process
with a dax mapping from a device that does not map pages it triggers
SIGBUS. 'struct page' is required otherwise several kernel code paths
break in surprising ways. Disable filesystem-dax on devices that do not
map pages.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index b0cc8117eebe..491d4859c644 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -15,6 +15,7 @@
 #include <linux/mount.h>
 #include <linux/magic.h>
 #include <linux/genhd.h>
+#include <linux/pfn_t.h>
 #include <linux/cdev.h>
 #include <linux/hash.h>
 #include <linux/slab.h>
@@ -123,6 +124,12 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
 		return len < 0 ? len : -EIO;
 	}
 
+	if (!pfn_t_has_page(pfn)) {
+		pr_debug("VFS (%s): error: dax support not enabled\n",
+				sb->s_id);
+		return -EOPNOTSUPP;
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__bdev_dax_supported);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
