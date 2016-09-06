Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4AF36B0261
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 12:59:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so285442014pfv.1
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 09:59:26 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id m9si7522340pan.86.2016.09.06.09.52.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 09:52:35 -0700 (PDT)
Subject: [PATCH 2/5] dax: fix offset to physical address translation
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:31 -0700
Message-ID: <147318057109.30325.17721163157375660986.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

In pgoff_to_phys() 'pgoff' is already relative to base of the dax
device, so we only need to compare if the current offset is within the
current resource extent.  Otherwise, we are double accounting the
resource start offset when translating pgoff to a physical address.

Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/dax.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/dax/dax.c b/drivers/dax/dax.c
index 29f600f2c447..4653f84cabe7 100644
--- a/drivers/dax/dax.c
+++ b/drivers/dax/dax.c
@@ -357,16 +357,18 @@ static int check_vma(struct dax_dev *dax_dev, struct vm_area_struct *vma,
 static phys_addr_t pgoff_to_phys(struct dax_dev *dax_dev, pgoff_t pgoff,
 		unsigned long size)
 {
+	phys_addr_t phys, offset;
 	struct resource *res;
-	phys_addr_t phys;
 	int i;
 
+	offset = pgoff * PAGE_SIZE;
 	for (i = 0; i < dax_dev->num_resources; i++) {
 		res = &dax_dev->res[i];
-		phys = pgoff * PAGE_SIZE + res->start;
-		if (phys >= res->start && phys <= res->end)
+		if (offset < resource_size(res)) {
+			phys = offset + res->start;
 			break;
-		pgoff -= PHYS_PFN(resource_size(res));
+		}
+		offset -= resource_size(res);
 	}
 
 	if (i < dax_dev->num_resources) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
