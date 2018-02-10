Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4BFB86B0280
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 19:38:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 202so4883772pgb.13
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 16:38:35 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id f7si2012350pgn.183.2018.02.09.16.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 16:38:34 -0800 (PST)
Subject: [PATCH v2 2/2] device-dax: implement ->pagesize() for smaps to
 report MMUPageSize
From: Dave Jiang <dave.jiang@intel.com>
Date: Fri, 09 Feb 2018 17:38:32 -0700
Message-ID: <151822311257.52376.12067958018820885784.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <151822289999.52376.4998780583577188804.stgit@djiang5-desk3.ch.intel.com>
References: <151822289999.52376.4998780583577188804.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, dan.j.williams@intel.com

From: Dan Williams <dan.j.williams@intel.com>

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
