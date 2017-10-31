Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82F9D280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so579153pgd.0
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:48 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p18si2721970pge.204.2017.10.31.16.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:47 -0700 (PDT)
Subject: [PATCH 03/15] dax: require 'struct page' by default for filesystem
 dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:21:50 -0700
Message-ID: <150949211070.24061.16943730658658180030.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, Gerald Schaefer <gerald.schaefer@de.ibm.com>

If a dax buffer from a device that does not map pages is passed to
read(2) or write(2) as a target for direct-I/O it triggers SIGBUS. If
gdb attempts to examine the contents of a dax buffer from a device that
does not map pages it triggers SIGBUS. If fork(2) is called on a process
with a dax mapping from a device that does not map pages it triggers
SIGBUS. 'struct page' is required otherwise several kernel code paths
break in surprising ways. Disable filesystem-dax on devices that do not
map pages.

In addition to needing pfn_to_page() to be valid we also require devmap
pages.  We need this to detect dax pages in the get_user_pages_fast()
path and so that we can stop managing the VM_MIXEDMAP flag. For DAX
drivers that have not supported get_user_pages() to date we allow them
to opt-in to supporting DAX with the CONFIG_FS_DAX_LIMITED configuration
option which requires ->direct_access() to return pfn_t_special() pfns.
This leaves DAX support in brd disabled and scheduled for removal.

Note that when the initial dax support was being merged a few years back
there was concern that struct page was unsuitable for use with next
generation persistent memory devices. The theoretical concern was that
struct page access, being such a hotly used data structure in the
kernel, would lead to media wear out. While that was a reasonable
conservative starting position it has not held true in practice. We have
long since committed to using devm_memremap_pages() to support higher
order kernel functionality that needs get_user_pages() and
pfn_to_page().

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/powerpc/platforms/Kconfig |    1 +
 arch/powerpc/sysdev/axonram.c  |    1 +
 drivers/dax/super.c            |   10 ++++++++++
 drivers/s390/block/Kconfig     |    1 +
 drivers/s390/block/dcssblk.c   |    1 +
 fs/Kconfig                     |    7 +++++++
 6 files changed, 21 insertions(+)

diff --git a/arch/powerpc/platforms/Kconfig b/arch/powerpc/platforms/Kconfig
index 4fd64d3f5c44..031313968f9a 100644
--- a/arch/powerpc/platforms/Kconfig
+++ b/arch/powerpc/platforms/Kconfig
@@ -296,6 +296,7 @@ config AXON_RAM
 	tristate "Axon DDR2 memory device driver"
 	depends on PPC_IBM_CELL_BLADE && BLOCK
 	select DAX
+	select FS_DAX_LIMITED
 	default m
 	help
 	  It registers one block device per Axon's DDR2 memory bank found
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index aaf540efb92c..c1abd443836f 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -172,6 +172,7 @@ static size_t axon_ram_copy_from_iter(struct dax_device *dax_dev, pgoff_t pgoff,
 
 static const struct dax_operations axon_ram_dax_ops = {
 	.direct_access = axon_ram_dax_direct_access,
+
 	.copy_from_iter = axon_ram_copy_from_iter,
 };
 
diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index b0cc8117eebe..66bcdf42c413 100644
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
@@ -123,6 +124,15 @@ int __bdev_dax_supported(struct super_block *sb, int blocksize)
 		return len < 0 ? len : -EIO;
 	}
 
+	if ((IS_ENABLED(CONFIG_FS_DAX_LIMITED) && pfn_t_special(pfn))
+			|| pfn_t_devmap(pfn))
+		/* pass */;
+	else {
+		pr_debug("VFS (%s): error: dax support not enabled\n",
+				sb->s_id);
+		return -EOPNOTSUPP;
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(__bdev_dax_supported);
diff --git a/drivers/s390/block/Kconfig b/drivers/s390/block/Kconfig
index 31f014b57bfc..594ae5fc8e9d 100644
--- a/drivers/s390/block/Kconfig
+++ b/drivers/s390/block/Kconfig
@@ -15,6 +15,7 @@ config BLK_DEV_XPRAM
 config DCSSBLK
 	def_tristate m
 	select DAX
+	select FS_DAX_LIMITED
 	prompt "DCSSBLK support"
 	depends on S390 && BLOCK
 	help
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 87756e28c29b..dbe07ab71e32 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -52,6 +52,7 @@ static size_t dcssblk_dax_copy_from_iter(struct dax_device *dax_dev,
 
 static const struct dax_operations dcssblk_dax_ops = {
 	.direct_access = dcssblk_dax_direct_access,
+
 	.copy_from_iter = dcssblk_dax_copy_from_iter,
 };
 
diff --git a/fs/Kconfig b/fs/Kconfig
index 7aee6d699fd6..b40128bf6d1a 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -58,6 +58,13 @@ config FS_DAX_PMD
 	depends on ZONE_DEVICE
 	depends on TRANSPARENT_HUGEPAGE
 
+# Selected by DAX drivers that do not expect filesystem DAX to support
+# get_user_pages() of DAX mappings. I.e. "limited" indicates no support
+# for fork() of processes with MAP_SHARED mappings or support for
+# direct-I/O to a DAX mapping.
+config FS_DAX_LIMITED
+	bool
+
 endif # BLOCK
 
 # Posix ACL utility routines

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
