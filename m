Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 350378E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 01:40:01 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v138-v6so3314436pgb.7
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 22:40:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d132-v6sor1043817pgc.394.2018.09.27.22.39.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 22:39:59 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 3/4] infiniband/mm: convert to the new put_user_page() call
Date: Thu, 27 Sep 2018 22:39:47 -0700
Message-Id: <20180928053949.5381-3-jhubbard@nvidia.com>
In-Reply-To: <20180928053949.5381-1-jhubbard@nvidia.com>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>

From: John Hubbard <jhubbard@nvidia.com>

For code that retains pages via get_user_pages*(),
release those pages via the new put_user_page(),
instead of put_page().

This prepares for eventually fixing the problem described
in [1], and is following a plan listed in [2].

[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] https://lkml.kernel.org/r/20180709080554.21931-1-jhubbard@nvidia.com
    Proposed steps for fixing get_user_pages() + DMA problems.

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
 drivers/infiniband/core/umem.c              | 2 +-
 drivers/infiniband/core/umem_odp.c          | 2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     | 2 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c | 6 +++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 2 +-
 drivers/infiniband/hw/qib/qib_user_sdma.c   | 8 ++++----
 drivers/infiniband/hw/usnic/usnic_uiom.c    | 2 +-
 7 files changed, 12 insertions(+), 12 deletions(-)

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
index e341e6dcc388..c7516029af33 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -126,7 +126,7 @@ void hfi1_release_user_pages(struct mm_struct *mm, struct page **p,
 	for (i = 0; i < npages; i++) {
 		if (dirty)
 			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
+		put_user_page(p[i]);
 	}
 
 	if (mm) { /* during close after signal, mm can be NULL */
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
index 16543d5e80c3..3f8fd42dd7fc 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -45,7 +45,7 @@ static void __qib_release_user_pages(struct page **p, size_t num_pages,
 	for (i = 0; i < num_pages; i++) {
 		if (dirty)
 			set_page_dirty_lock(p[i]);
-		put_page(p[i]);
+		put_user_page(p[i]);
 	}
 }
 
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
