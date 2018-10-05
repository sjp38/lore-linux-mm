Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC7256B0010
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 00:02:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i76-v6so7988129pfk.14
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 21:02:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4-v6sor5773457pgc.18.2018.10.04.21.02.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 21:02:33 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH v2 3/3] infiniband/mm: convert to the new put_user_page[s]() calls
Date: Thu,  4 Oct 2018 21:02:25 -0700
Message-Id: <20181005040225.14292-4-jhubbard@nvidia.com>
In-Reply-To: <20181005040225.14292-1-jhubbard@nvidia.com>
References: <20181005040225.14292-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

From: John Hubbard <jhubbard@nvidia.com>

For code that retains pages via get_user_pages*(),
release those pages via the new put_user_page(),
instead of put_page().

This prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2], [3], [4].

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

[3]https://lkml.kernel.org/r/20180710082100.mkdwngdv5kkrcz6n@quack2.suse.cz
    Bounce buffers (otherwise [2] is not really viable).

[4] https://lkml.kernel.org/r/20181003162115.GG24030@quack2.suse.cz
    Follow-up discussions.

CC: Doug Ledford <dledford@redhat.com>
CC: Jason Gunthorpe <jgg@ziepe.ca>
CC: Mike Marciniszyn <mike.marciniszyn@intel.com>
CC: Dennis Dalessandro <dennis.dalessandro@intel.com>
CC: Christian Benvenuti <benve@cisco.com>

CC: linux-rdma@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/infiniband/core/umem.c              |  2 +-
 drivers/infiniband/core/umem_odp.c          |  2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 11 ++++-------
 drivers/infiniband/hw/mthca/mthca_memfree.c |  6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 11 ++++-------
 drivers/infiniband/hw/qib/qib_user_sdma.c   |  8 ++++----
 drivers/infiniband/hw/usnic/usnic_uiom.c    |  2 +-
 7 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index a41792dbae1f..9430d697cb9f 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -60,7 +60,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 		page = sg_page(sg);
 		if (!PageDirty(page) && umem->writable && dirty)
 			set_page_dirty_lock(page);
-		put_page(page);
+		put_user_page(page);
 	}
 
 	sg_free_table(&umem->sg_head);
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 6ec748eccff7..6227b89cf05c 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -717,7 +717,7 @@ int ib_umem_odp_map_dma_pages(struct ib_umem *umem, u64 user_virt, u64 bcnt,
 					ret = -EFAULT;
 					break;
 				}
-				put_page(local_page_list[j]);
+				put_user_page(local_page_list[j]);
 				continue;
 			}
 
diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index e341e6dcc388..99ccc0483711 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -121,13 +121,10 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 			     size_t npages, bool dirty)
 {
-	size_t i;
-
-	for (i = 0; i < npages; i++) {
-		if (dirty)
-			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
-	}
+	if (dirty)
+		put_user_pages_dirty_lock(p, npages);
+	else
+		put_user_pages(p, npages);
 
 	if (mm) { /* during close after signal, mm can be NULL */
 		down_write(&mm->mmap_sem);
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index cc9c0c8ccba3..b8b12effd009 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -481,7 +481,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 
 	ret = pci_map_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
 	if (ret < 0) {
-		put_page(pages[0]);
+		put_user_page(pages[0]);
 		goto out;
 	}
 
@@ -489,7 +489,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 				 mthca_uarc_virt(dev, uar, i));
 	if (ret) {
 		pci_unmap_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
-		put_page(sg_page(&db_tab->page[i].mem));
+		put_user_page(sg_page(&db_tab->page[i].mem));
 		goto out;
 	}
 
@@ -555,7 +555,7 @@ void mthca_cleanup_user_db_tab(struct mthca_dev *dev, struct mthca_uar *uar,
 		if (db_tab->page[i].uvirt) {
 			mthca_UNMAP_ICM(dev, mthca_uarc_virt(dev, uar, i), 1);
 			pci_unmap_sg(dev->pdev, &db_tab->page[i].mem, 1, PCI_DMA_TODEVICE);
-			put_page(sg_page(&db_tab->page[i].mem));
+			put_user_page(sg_page(&db_tab->page[i].mem));
 		}
 	}
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 16543d5e80c3..1a5c64c8695f 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -40,13 +40,10 @@
 static void __qib_release_user_pages(struct page **p, size_t num_pages,
 				     int dirty)
 {
-	size_t i;
-
-	for (i = 0; i < num_pages; i++) {
-		if (dirty)
-			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
-	}
+	if (dirty)
+		put_user_pages_dirty_lock(p, num_pages);
+	else
+		put_user_pages(p, num_pages);
 }
 
 /*
diff --git a/drivers/infiniband/hw/qib/qib_user_sdma.c b/drivers/infiniband/hw/qib/qib_user_sdma.c
index 926f3c8eba69..14f94d823907 100644
--- a/drivers/infiniband/hw/qib/qib_user_sdma.c
+++ b/drivers/infiniband/hw/qib/qib_user_sdma.c
@@ -266,7 +266,7 @@ static void qib_user_sdma_init_frag(struct qib_user_sdma_pkt *pkt,
 	pkt->addr[i].length = len;
 	pkt->addr[i].first_desc = first_desc;
 	pkt->addr[i].last_desc = last_desc;
-	pkt->addr[i].put_page = put_page;
+	pkt->addr[i].put_page = put_user_page;
 	pkt->addr[i].dma_mapped = dma_mapped;
 	pkt->addr[i].page = page;
 	pkt->addr[i].kvaddr = kvaddr;
@@ -321,7 +321,7 @@ static int qib_user_sdma_page_to_frags(const struct qib_devdata *dd,
 		 * the caller can ignore this page.
 		 */
 		if (put) {
-			put_page(page);
+			put_user_page(page);
 		} else {
 			/* coalesce case */
 			kunmap(page);
@@ -635,7 +635,7 @@ static void qib_user_sdma_free_pkt_frag(struct device *dev,
 			kunmap(pkt->addr[i].page);
 
 		if (pkt->addr[i].put_page)
-			put_page(pkt->addr[i].page);
+			put_user_page(pkt->addr[i].page);
 		else
 			__free_page(pkt->addr[i].page);
 	} else if (pkt->addr[i].kvaddr) {
@@ -710,7 +710,7 @@ static int qib_user_sdma_pin_pages(const struct qib_devdata *dd,
 	/* if error, return all pages not managed by pkt */
 free_pages:
 	while (i < j)
-		put_page(pages[i++]);
+		put_user_page(pages[i++]);
 
 done:
 	return ret;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 9dd39daa602b..0f607f31c262 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -91,7 +91,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
 			pa = sg_phys(sg);
 			if (!PageDirty(page) && dirty)
 				set_page_dirty_lock(page);
-			put_page(page);
+			put_user_page(page);
 			usnic_dbg("pa: %pa\n", &pa);
 		}
 		kfree(chunk);
-- 
2.19.0
