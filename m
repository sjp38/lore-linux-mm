Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC1BF6B0271
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 10:56:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so61850382pfj.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 07:56:20 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s21si5540085pfj.274.2017.10.10.07.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 07:56:19 -0700 (PDT)
Subject: [PATCH v8 10/14] device-dax: wire up ->lease_direct()
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 10 Oct 2017 07:49:54 -0700
Message-ID: <150764699451.16882.18368970483709189847.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150764693502.16882.15848797003793552156.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, linux-rdma@vger.kernel.org, linux-api@vger.kernel.org, iommu@lists.linux-foundation.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

The only event that will break a lease_direct lease in the device-dax
case is the device shutdown path where the physical pages might get
assigned to another device.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/Kconfig       |    1 +
 drivers/dax/device.c      |    4 ++++
 fs/Kconfig                |    4 ++++
 fs/Makefile               |    3 ++-
 fs/mapdirect.c            |    3 ++-
 include/linux/mapdirect.h |    5 ++++-
 6 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index b79aa8f7a497..be03d4dbe646 100644
--- a/drivers/dax/Kconfig
+++ b/drivers/dax/Kconfig
@@ -8,6 +8,7 @@ if DAX
 config DEV_DAX
 	tristate "Device DAX: direct access mapping device"
 	depends on TRANSPARENT_HUGEPAGE
+	depends on FILE_LOCKING
 	help
 	  Support raw access to differentiated (persistence, bandwidth,
 	  latency...) memory via an mmap(2) capable character
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e9f3b3e4bbf4..fa75004185c4 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -10,6 +10,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/mapdirect.h>
 #include <linux/pagemap.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -430,6 +431,7 @@ static int dev_dax_fault(struct vm_fault *vmf)
 static const struct vm_operations_struct dax_vm_ops = {
 	.fault = dev_dax_fault,
 	.huge_fault = dev_dax_huge_fault,
+	.lease_direct = map_direct_lease,
 };
 
 static int dax_mmap(struct file *filp, struct vm_area_struct *vma)
@@ -540,8 +542,10 @@ static void kill_dev_dax(struct dev_dax *dev_dax)
 {
 	struct dax_device *dax_dev = dev_dax->dax_dev;
 	struct inode *inode = dax_inode(dax_dev);
+	const bool wait = true;
 
 	kill_dax(dax_dev);
+	break_layout(inode, wait);
 	unmap_mapping_range(inode->i_mapping, 0, 0, 1);
 }
 
diff --git a/fs/Kconfig b/fs/Kconfig
index a7b31a96a753..3668cfb046d5 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -59,6 +59,10 @@ config FS_DAX_PMD
 	depends on ZONE_DEVICE
 	depends on TRANSPARENT_HUGEPAGE
 
+config DAX_MAP_DIRECT
+	bool
+	default FS_DAX || DEV_DAX
+
 endif # BLOCK
 
 # Posix ACL utility routines
diff --git a/fs/Makefile b/fs/Makefile
index c0e791d235d8..21b8fb104656 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,7 +29,8 @@ obj-$(CONFIG_TIMERFD)		+= timerfd.o
 obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_USERFAULTFD)	+= userfaultfd.o
 obj-$(CONFIG_AIO)               += aio.o
-obj-$(CONFIG_FS_DAX)		+= dax.o mapdirect.o
+obj-$(CONFIG_FS_DAX)		+= dax.o
+obj-$(CONFIG_DAX_MAP_DIRECT)	+= mapdirect.o
 obj-$(CONFIG_FS_ENCRYPTION)	+= crypto/
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
diff --git a/fs/mapdirect.c b/fs/mapdirect.c
index c6954033fc1a..dd4a16f9ffc6 100644
--- a/fs/mapdirect.c
+++ b/fs/mapdirect.c
@@ -218,7 +218,7 @@ static const struct lock_manager_operations lease_direct_lm_ops = {
 	.lm_change = lease_direct_lm_change,
 };
 
-static struct lease_direct *map_direct_lease(struct vm_area_struct *vma,
+struct lease_direct *map_direct_lease(struct vm_area_struct *vma,
 		void (*lds_break_fn)(void *), void *lds_owner)
 {
 	struct file *file = vma->vm_file;
@@ -272,6 +272,7 @@ static struct lease_direct *map_direct_lease(struct vm_area_struct *vma,
 	kfree(lds);
 	return ERR_PTR(rc);
 }
+EXPORT_SYMBOL_GPL(map_direct_lease);
 
 struct lease_direct *generic_map_direct_lease(struct vm_area_struct *vma,
 		void (*break_fn)(void *), void *owner)
diff --git a/include/linux/mapdirect.h b/include/linux/mapdirect.h
index e0df6ac5795a..6695fdcf8009 100644
--- a/include/linux/mapdirect.h
+++ b/include/linux/mapdirect.h
@@ -26,13 +26,15 @@ struct lease_direct {
 	struct lease_direct_state *lds;
 };
 
-#if IS_ENABLED(CONFIG_FS_DAX)
+#if IS_ENABLED(CONFIG_DAX_MAP_DIRECT)
 struct map_direct_state *map_direct_register(int fd, struct vm_area_struct *vma);
 bool test_map_direct_valid(struct map_direct_state *mds);
 void generic_map_direct_open(struct vm_area_struct *vma);
 void generic_map_direct_close(struct vm_area_struct *vma);
 struct lease_direct *generic_map_direct_lease(struct vm_area_struct *vma,
 		void (*ld_break_fn)(void *), void *ld_owner);
+struct lease_direct *map_direct_lease(struct vm_area_struct *vma,
+		void (*lds_break_fn)(void *), void *lds_owner);
 void map_direct_lease_destroy(struct lease_direct *ld);
 #else
 static inline struct map_direct_state *map_direct_register(int fd,
@@ -47,6 +49,7 @@ static inline bool test_map_direct_valid(struct map_direct_state *mds)
 #define generic_map_direct_open NULL
 #define generic_map_direct_close NULL
 #define generic_map_direct_lease NULL
+#define map_direct_lease NULL
 static inline void map_direct_lease_destroy(struct lease_direct *ld)
 {
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
