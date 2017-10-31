Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF3D280244
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 19:28:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so575050pga.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 16:28:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p18si2721970pge.204.2017.10.31.16.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 16:28:49 -0700 (PDT)
Subject: [PATCH 09/15] tools/testing/nvdimm: add 'bio_delay' mechanism
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 31 Oct 2017 16:22:24 -0700
Message-ID: <150949214412.24061.1436576623974467007.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hch@lst.de

In support of testing truncate colliding with dma add a mechanism that
delays the completion of block I/O requests by a programmable number of
seconds. This allows a truncate operation to be issued while page
references are held for direct-I/O.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 tools/testing/nvdimm/Kbuild           |    1 +
 tools/testing/nvdimm/test/iomap.c     |   62 +++++++++++++++++++++++++++++++++
 tools/testing/nvdimm/test/nfit.c      |   34 ++++++++++++++++++
 tools/testing/nvdimm/test/nfit_test.h |    1 +
 4 files changed, 98 insertions(+)

diff --git a/tools/testing/nvdimm/Kbuild b/tools/testing/nvdimm/Kbuild
index d870520da68b..5946cf3afe74 100644
--- a/tools/testing/nvdimm/Kbuild
+++ b/tools/testing/nvdimm/Kbuild
@@ -15,6 +15,7 @@ ldflags-y += --wrap=insert_resource
 ldflags-y += --wrap=remove_resource
 ldflags-y += --wrap=acpi_evaluate_object
 ldflags-y += --wrap=acpi_evaluate_dsm
+ldflags-y += --wrap=bio_endio
 
 DRIVERS := ../../../drivers
 NVDIMM_SRC := $(DRIVERS)/nvdimm
diff --git a/tools/testing/nvdimm/test/iomap.c b/tools/testing/nvdimm/test/iomap.c
index e1f75a1914a1..1f5d7182ca9c 100644
--- a/tools/testing/nvdimm/test/iomap.c
+++ b/tools/testing/nvdimm/test/iomap.c
@@ -10,6 +10,7 @@
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  * General Public License for more details.
  */
+#include <linux/workqueue.h>
 #include <linux/memremap.h>
 #include <linux/rculist.h>
 #include <linux/export.h>
@@ -18,6 +19,7 @@
 #include <linux/types.h>
 #include <linux/pfn_t.h>
 #include <linux/acpi.h>
+#include <linux/bio.h>
 #include <linux/io.h>
 #include <linux/mm.h>
 #include "nfit_test.h"
@@ -388,4 +390,64 @@ union acpi_object * __wrap_acpi_evaluate_dsm(acpi_handle handle, const guid_t *g
 }
 EXPORT_SYMBOL(__wrap_acpi_evaluate_dsm);
 
+static DEFINE_SPINLOCK(bio_lock);
+static struct bio *biolist;
+int bio_do_queue;
+
+static void run_bio(struct work_struct *work)
+{
+	struct delayed_work *dw = container_of(work, typeof(*dw), work);
+	struct bio *bio, *next;
+
+	pr_info("%s\n", __func__);
+	spin_lock(&bio_lock);
+	bio_do_queue = 0;
+	bio = biolist;
+	biolist = NULL;
+	spin_unlock(&bio_lock);
+
+	while (bio) {
+		next = bio->bi_next;
+		bio->bi_next = NULL;
+		bio_endio(bio);
+		bio = next;
+	}
+	kfree(dw);
+}
+
+void nfit_test_inject_bio_delay(int sec)
+{
+	struct delayed_work *dw = kzalloc(sizeof(*dw), GFP_KERNEL);
+
+	spin_lock(&bio_lock);
+	if (!bio_do_queue) {
+		pr_info("%s: %d seconds\n", __func__, sec);
+		INIT_DELAYED_WORK(dw, run_bio);
+		bio_do_queue = 1;
+		schedule_delayed_work(dw, sec * HZ);
+		dw = NULL;
+	}
+	spin_unlock(&bio_lock);
+}
+EXPORT_SYMBOL_GPL(nfit_test_inject_bio_delay);
+
+void __wrap_bio_endio(struct bio *bio)
+{
+	int did_q = 0;
+
+	spin_lock(&bio_lock);
+	if (bio_do_queue) {
+		bio->bi_next = biolist;
+		biolist = bio;
+		did_q = 1;
+	}
+	spin_unlock(&bio_lock);
+
+	if (did_q)
+		return;
+
+	bio_endio(bio);
+}
+EXPORT_SYMBOL_GPL(__wrap_bio_endio);
+
 MODULE_LICENSE("GPL v2");
diff --git a/tools/testing/nvdimm/test/nfit.c b/tools/testing/nvdimm/test/nfit.c
index bef419d4266d..2c871c8b4a56 100644
--- a/tools/testing/nvdimm/test/nfit.c
+++ b/tools/testing/nvdimm/test/nfit.c
@@ -656,6 +656,39 @@ static const struct attribute_group *nfit_test_dimm_attribute_groups[] = {
 	NULL,
 };
 
+static ssize_t bio_delay_show(struct device_driver *drv, char *buf)
+{
+	return sprintf(buf, "0\n");
+}
+
+static ssize_t bio_delay_store(struct device_driver *drv, const char *buf,
+		size_t count)
+{
+	unsigned long delay;
+	int rc = kstrtoul(buf, 0, &delay);
+
+	if (rc < 0)
+		return rc;
+
+	nfit_test_inject_bio_delay(delay);
+	return count;
+}
+DRIVER_ATTR_RW(bio_delay);
+
+static struct attribute *nfit_test_driver_attributes[] = {
+	&driver_attr_bio_delay.attr,
+	NULL,
+};
+
+static struct attribute_group nfit_test_driver_attribute_group = {
+	.attrs = nfit_test_driver_attributes,
+};
+
+static const struct attribute_group *nfit_test_driver_attribute_groups[] = {
+	&nfit_test_driver_attribute_group,
+	NULL,
+};
+
 static int nfit_test0_alloc(struct nfit_test *t)
 {
 	size_t nfit_size = sizeof(struct acpi_nfit_system_address) * NUM_SPA
@@ -1905,6 +1938,7 @@ static struct platform_driver nfit_test_driver = {
 	.remove = nfit_test_remove,
 	.driver = {
 		.name = KBUILD_MODNAME,
+		.groups = nfit_test_driver_attribute_groups,
 	},
 	.id_table = nfit_test_id,
 };
diff --git a/tools/testing/nvdimm/test/nfit_test.h b/tools/testing/nvdimm/test/nfit_test.h
index d3d63dd5ed38..0d818d2adaf7 100644
--- a/tools/testing/nvdimm/test/nfit_test.h
+++ b/tools/testing/nvdimm/test/nfit_test.h
@@ -46,4 +46,5 @@ void nfit_test_setup(nfit_test_lookup_fn lookup,
 		nfit_test_evaluate_dsm_fn evaluate);
 void nfit_test_teardown(void);
 struct nfit_test_resource *get_nfit_res(resource_size_t resource);
+void nfit_test_inject_bio_delay(int sec);
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
