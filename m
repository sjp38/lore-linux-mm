Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 710316B0273
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:59:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a12-v6so4261482pfn.12
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:59:45 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j135-v6si6084553pfd.207.2018.07.04.23.59.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:59:43 -0700 (PDT)
Subject: [PATCH 08/13] s390/block/dcssblk: check the validity of the pointer
 pfn
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 23:49:45 -0700
Message-ID: <153077338570.40830.10517740093746798315.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153077334130.40830.2714147692560185329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Huaisheng Ye <yehs1@lenovo.com>, Jan Kara <jack@suse.cz>, vishal.l.verma@intel.com, hch@lst.de, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Huaisheng Ye <yehs1@lenovo.com>

direct_access needs to check the validity of pointer pfn for NULL
assignment. If pfn equals to NULL, it doesn't need to calculate the value.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/s390/block/dcssblk.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index ed607288e696..a645b2c93c34 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -923,8 +923,9 @@ __dcssblk_direct_access(struct dcssblk_dev_info *dev_info, pgoff_t pgoff,
 
 	dev_sz = dev_info->end - dev_info->start + 1;
 	*kaddr = (void *) dev_info->start + offset;
-	*pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset),
-			PFN_DEV|PFN_SPECIAL);
+	if (pfn)
+		*pfn = __pfn_to_pfn_t(PFN_DOWN(dev_info->start + offset),
+				PFN_DEV|PFN_SPECIAL);
 
 	return (dev_sz - offset) / PAGE_SIZE;
 }
