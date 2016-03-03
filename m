Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A2B20828DF
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 16:53:44 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 4so22183876pfd.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 13:53:44 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id o9si660336pfa.130.2016.03.03.13.53.43
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 13:53:43 -0800 (PST)
Subject: [PATCH v2 3/3] libnvdimm,
 pfn: 'resource'-address and 'size' attributes for pfn devices
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 03 Mar 2016 13:53:20 -0800
Message-ID: <20160303215320.1014.89145.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20160303215304.1014.69931.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Haozhong Zhang <haozhong.zhang@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Currenty with a raw mode pmem namespace the physical memory address range for
the device can be obtained via /sys/block/pmemX/device/{resource|size}.  Add
similar attributes for pfn instances that takes the struct page memmap and
section padding into account.

Reported-by: Haozhong Zhang <haozhong.zhang@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn_devs.c |   56 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 14642617a153..a43942ffc173 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -205,11 +205,67 @@ static ssize_t namespace_store(struct device *dev,
 }
 static DEVICE_ATTR_RW(namespace);
 
+static ssize_t resource_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc;
+
+	device_lock(dev);
+	if (dev->driver) {
+		struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
+		u64 offset = __le64_to_cpu(pfn_sb->dataoff);
+		struct nd_namespace_common *ndns = nd_pfn->ndns;
+		u32 start_pad = __le32_to_cpu(pfn_sb->start_pad);
+		struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
+
+		rc = sprintf(buf, "%#llx\n", (unsigned long long) nsio->res.start
+				+ start_pad + offset);
+	} else {
+		/* no address to convey if the pfn instance is disabled */
+		rc = -ENXIO;
+	}
+	device_unlock(dev);
+
+	return rc;
+}
+static DEVICE_ATTR_RO(resource);
+
+static ssize_t size_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn(dev);
+	ssize_t rc;
+
+	device_lock(dev);
+	if (dev->driver) {
+		struct nd_pfn_sb *pfn_sb = nd_pfn->pfn_sb;
+		u64 offset = __le64_to_cpu(pfn_sb->dataoff);
+		struct nd_namespace_common *ndns = nd_pfn->ndns;
+		u32 start_pad = __le32_to_cpu(pfn_sb->start_pad);
+		u32 end_trunc = __le32_to_cpu(pfn_sb->end_trunc);
+		struct nd_namespace_io *nsio = to_nd_namespace_io(&ndns->dev);
+
+		rc = sprintf(buf, "%llu\n", (unsigned long long)
+				resource_size(&nsio->res) - start_pad
+				- end_trunc - offset);
+	} else {
+		/* no size to convey if the pfn instance is disabled */
+		rc = -ENXIO;
+	}
+	device_unlock(dev);
+
+	return rc;
+}
+static DEVICE_ATTR_RO(size);
+
 static struct attribute *nd_pfn_attributes[] = {
 	&dev_attr_mode.attr,
 	&dev_attr_namespace.attr,
 	&dev_attr_uuid.attr,
 	&dev_attr_align.attr,
+	&dev_attr_resource.attr,
+	&dev_attr_size.attr,
 	NULL,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
