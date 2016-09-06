Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA4DC6B0263
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 13:00:47 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so447044463pad.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 10:00:47 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id gu4si24728047pac.80.2016.09.06.09.52.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 09:52:30 -0700 (PDT)
Subject: [PATCH 1/5] dax: fix mapping size check
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:26 -0700
Message-ID: <147318056595.30325.8488744773976820879.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

pgoff_to_phys() validates that both the starting address and the length
of the mapping against the resource list.  We need to check for a
mapping size of PMD_SIZE not PAGE_SIZE in the pmd fault path.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 803f3953b341..29f600f2c447 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -459,7 +459,7 @@ static int __dax_dev_pmd_fault(struct dax_dev *dax_dev,
 	}
 
 	pgoff = linear_page_index(vma, pmd_addr);
-	phys = pgoff_to_phys(dax_dev, pgoff, PAGE_SIZE);
+	phys = pgoff_to_phys(dax_dev, pgoff, PMD_SIZE);
 	if (phys == -1) {
 		dev_dbg(dev, "%s: phys_to_pgoff(%#lx) failed\n", __func__,
 				pgoff);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
