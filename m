Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 006846B027E
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:11:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id t20-v6so3861184pgu.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:11:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j185-v6si986431pgc.419.2018.07.16.10.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:11:33 -0700 (PDT)
Subject: [PATCH v2 09/14] s390,
 dcssblk: Allow a NULL-pfn to ->direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:01:08 -0700
Message-ID: <153176046886.12695.7487453664953251895.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Huaisheng Ye <yehs1@lenovo.com>, Jan Kara <jack@suse.cz>, vishal.l.verma@intel.com, hch@lst.de, linux-mm@kvack.orgjack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

From: Huaisheng Ye <yehs1@lenovo.com>

dcssblk_direct_access() needs to check the validity of pointer pfn for
NULL assignment. If pfn equals to NULL, it doesn't need to calculate the
value. This is in support of asynchronous memmap init and avoid page
lookups when possible.

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
