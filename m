From: Zhang Yi <yi.z.zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH V2 3/4] mm: add a function to differentiate the pages is from
 DAX device memory
Date: Wed, 11 Jul 2018 01:03:51 +0800
Message-ID: <a0d220839ce0414f13e9394dffcd9abe8689dafe.1531241281.git.yi.z.zhang__22800.4142678857$1531211011$gmane$org@linux.intel.com>
References: <cover.1531241281.git.yi.z.zhang@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <cover.1531241281.git.yi.z.zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
To: kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org, pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jack-AlSwsSmVLrQ@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, yu.c.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, yi.z.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: linux-mm.kvack.org

DAX driver hotplug the device memory and move it to memory zone, these
pages will be marked reserved flag, however, some other kernel componet
will misconceive these pages are reserved mmio (ex: we map these dev_dax
or fs_dax pages to kvm for DIMM/NVDIMM backend). Together with the type
MEMORY_DEVICE_FS_DAX, we can use is_dax_page() to differentiate the pages
is DAX device memory or not.

Signed-off-by: Zhang Yi <yi.z.zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Zhang Yu <yu.c.zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 include/linux/mm.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6e19265..9f0f690 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -856,6 +856,13 @@ static inline bool is_device_public_page(const struct page *page)
 		page->pgmap->type == MEMORY_DEVICE_PUBLIC;
 }
 
+static inline bool is_dax_page(const struct page *page)
+{
+	return is_zone_device_page(page) &&
+		(page->pgmap->type == MEMORY_DEVICE_FS_DAX ||
+		page->pgmap->type == MEMORY_DEVICE_DEV_DAX);
+}
+
 #else /* CONFIG_DEV_PAGEMAP_OPS */
 static inline void dev_pagemap_get_ops(void)
 {
@@ -879,6 +886,11 @@ static inline bool is_device_public_page(const struct page *page)
 {
 	return false;
 }
+
+static inline bool is_dax_page(const struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline void get_page(struct page *page)
-- 
2.7.4
