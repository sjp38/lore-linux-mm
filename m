Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 333A46B025F
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:14:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a10so2602584pgq.3
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 10:14:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 3si1623973plv.303.2017.11.29.10.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 10:14:07 -0800 (PST)
Subject: [PATCH v3 4/4] IB/core: disable memory registration of
 fileystem-dax vmas
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 29 Nov 2017 10:05:51 -0800
Message-ID: <151197875158.26211.7203330105253426435.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-nvdimm@lists.01.org, linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Moyer <jmoyer@redhat.com>, stable@vger.kernel.org, hch@lst.de, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, linux-mm@kvack.org, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>

Until there is a solution to the dma-to-dax vs truncate problem it is
not safe to allow RDMA to create long standing memory registrations
against filesytem-dax vmas.

Cc: Sean Hefty <sean.hefty@intel.com>
Cc: Doug Ledford <dledford@redhat.com>
Cc: Hal Rosenstock <hal.rosenstock@gmail.com>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: <linux-rdma@vger.kernel.org>
Cc: <stable@vger.kernel.org>
Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
Reported-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/infiniband/core/umem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 21e60b1e2ff4..130606c3b07c 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -191,7 +191,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	sg_list_start = umem->sg_head.sgl;
 
 	while (npages) {
-		ret = get_user_pages(cur_base,
+		ret = get_user_pages_longterm(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
 				     gup_flags, page_list, vma_list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
