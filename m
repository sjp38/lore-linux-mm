Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E49BB6B0273
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:11:08 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t26-v6so2008758pfh.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:11:08 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id q3-v6si30597304plb.238.2018.07.16.10.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:11:07 -0700 (PDT)
Subject: [PATCH v2 07/14] libnvdimm,
 pmem: Allow a NULL-pfn to ->direct_access()
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:00:58 -0700
Message-ID: <153176045824.12695.14255237229973044333.stgit@dwillia2-desk3.amr.corp.intel.com>
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

pmem_direct_access() needs to check the validity of pointer pfn for NULL
assignment. If pfn equals to NULL, it doesn't need to calculate the
value. This is in support of asynchronous memmap init and avoid page
lookups when possible.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pmem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index e8ac6f244d2b..c430536320a5 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -228,7 +228,8 @@ __weak long __pmem_direct_access(struct pmem_device *pmem, pgoff_t pgoff,
 					PFN_PHYS(nr_pages))))
 		return -EIO;
 	*kaddr = pmem->virt_addr + offset;
-	*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
+	if (pfn)
+		*pfn = phys_to_pfn_t(pmem->phys_addr + offset, pmem->pfn_flags);
 
 	/*
 	 * If badblocks are present, limit known good range to the
