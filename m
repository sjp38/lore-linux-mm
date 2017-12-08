Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B49EA6B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 22:39:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so6864415pgv.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 19:39:16 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s188si4798032pgc.270.2017.12.07.19.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 19:39:15 -0800 (PST)
Subject: [PATCH 2/2] device-dax: implement ->pagesize() for smaps to report
 MMUPageSize
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 07 Dec 2017 19:31:00 -0800
Message-ID: <151270386082.21215.150215755680990629.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Given that device-dax is making similar page mapping size guarantees as
hugetlbfs, emit the size in smaps and any other kernel path that
requests the mapping size of a vma.

Reported-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/device.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index 7b0bf825c4e7..b57cd5a7b0bd 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -439,10 +439,20 @@ static int dev_dax_split(struct vm_area_struct *vma, unsigned long addr)
 	return 0;
 }
 
+static unsigned long dev_dax_pagesize(struct vm_area_struct *vma)
+{
+	struct file *filp = vma->vm_file;
+	struct dev_dax *dev_dax = filp->private_data;
+	struct dax_region *dax_region = dev_dax->region;
+
+	return dax_region->align;
+}
+
 static const struct vm_operations_struct dax_vm_ops = {
 	.fault = dev_dax_fault,
 	.huge_fault = dev_dax_huge_fault,
 	.split = dev_dax_split,
+	.pagesize = dev_dax_pagesize,
 };
 
 static int dax_mmap(struct file *filp, struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
