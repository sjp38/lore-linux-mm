Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 96AAC6B0044
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:10:37 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id i17so2836918qcy.26
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:37 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id q67si1266427qgd.122.2014.08.29.12.10.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 Aug 2014 12:10:37 -0700 (PDT)
Received: by mail-qg0-f54.google.com with SMTP id q107so2731141qgd.13
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:10:37 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [RFC PATCH 5/6] iommu: new api to map an array of page frame number into a domain.
Date: Fri, 29 Aug 2014 15:10:14 -0400
Message-Id: <1409339415-3626-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
References: <1409339415-3626-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Haggai Eran <haggaie@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

New user of iommu can share the same mapping for device in same domain.
Which allow saving resources. For this a new iommu domain callback is
needed. This add the core support for the callback.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/iommu.h | 145 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 145 insertions(+)

diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index 20f9a52..ff6983f 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -97,6 +97,9 @@ enum iommu_attr {
  * @domain_has_cap: domain capabilities query
  * @add_device: add device to iommu grouping
  * @remove_device: remove device from iommu grouping
+ * @domain_map_directory: Map a directory of pages.
+ * @domain_update_directory: Update a directory of pages mapping.
+ * @domain_unmap_directory: Unmap a directory of pages.
  * @domain_get_attr: Query domain attributes
  * @domain_set_attr: Change domain attributes
  * @pgsize_bitmap: bitmap of supported page sizes
@@ -130,6 +133,26 @@ struct iommu_ops {
 	/* Get the numer of window per domain */
 	u32 (*domain_get_windows)(struct iommu_domain *domain);
 
+	int (*domain_map_directory)(struct iommu_domain *domain,
+				    unsigned long npages,
+				    unsigned long *pfns,
+				    unsigned long pfn_mask,
+				    unsigned long pfn_shift,
+				    unsigned long pfn_valid,
+				    unsigned long pfn_write,
+				    dma_addr_t *iova_base);
+	int (*domain_update_directory)(struct iommu_domain *domain,
+				       unsigned long npages,
+				       unsigned long *pfns,
+				       unsigned long pfn_mask,
+				       unsigned long pfn_shift,
+				       unsigned long pfn_valid,
+				       unsigned long pfn_write,
+				       dma_addr_t iova_base);
+	int (*domain_unmap_directory)(struct iommu_domain *domain,
+				      unsigned long npages,
+				      dma_addr_t iova);
+
 	unsigned long pgsize_bitmap;
 };
 
@@ -240,6 +263,97 @@ static inline int report_iommu_fault(struct iommu_domain *domain,
 	return ret;
 }
 
+/* iommu_domain_map_directory() - Map a directory of pages into a given domain.
+ *
+ * @domain: Domain into which mapping should happen.
+ * @npages: The maximum number of page to map.
+ * @pfns: The pfns directory array.
+ * @pfn_mask: The pfn mask (pfn_for_i = (pfns[i] & pfn_mask) >> pfn_shift).
+ * @pfn_shift: The pfn shift (pfn_for_i = (pfns[i] & pfn_mask) >> pfn_shift).
+ * @pfn_valid: An entry in the array is valid if (pfns[i] & pfn_valid).
+ * @pfn_write: An entry should be mapped write if (pfns[i] & pfn_write)
+ * @iova_base: Base io virtual address at which directory is mapped on success.
+ * Returns: Number of mapped pages on success, negative errno otherwise.
+ *
+ * This allow to map contiguously a directory of pages into a specific domain.
+ * On success it sets the base io virtual address at which the directory is
+ * mapped and it returns the number of page successfully mapped. Each entry in
+ * the directory can either be a valid page in read only or in read and write
+ * depending on flags and there can be gaps.
+ */
+static inline int iommu_domain_map_directory(struct iommu_domain *domain,
+					     unsigned long npages,
+					     unsigned long *pfns,
+					     unsigned long pfn_mask,
+					     unsigned long pfn_shift,
+					     unsigned long pfn_valid,
+					     unsigned long pfn_write,
+					     dma_addr_t *iova_base)
+{
+	if (!domain->ops->domain_map_directory)
+		return -EINVAL;
+	return domain->ops->domain_map_directory(domain, npages, pfns,
+						 pfn_mask, pfn_shift,
+						 pfn_valid, pfn_write,
+						 iova_base);
+}
+
+/* iommu_domain_update_directory() - Update a directory mapping of pages.
+ *
+ * @domain: Domain into which mapping exist.
+ * @npages: The maximum number of page to map.
+ * @pfns: The pfns directory array.
+ * @pfn_mask: The pfn mask (pfn_for_i = (pfns[i] & pfn_mask) >> pfn_shift).
+ * @pfn_shift: The pfn shift (pfn_for_i = (pfns[i] & pfn_mask) >> pfn_shift).
+ * @pfn_valid: An entry in the array is valid if (pfns[i] & pfn_valid).
+ * @pfn_write: An entry should be mapped write if (pfns[i] & pfn_write)
+ * @iova_base: Base io virtual address at which directory is mapped.
+ * Returns: Number of mapped (positive) or unmapped (negative) pages.
+ *
+ * This allow to update a previously successfull directory mapping of pages,
+ * either by adding or removing or replacing pages or modifying page mapping
+ * (read only to read and write or read and write to read only). It returns
+ * the number of new or removed mapping. Modified mapping are not counted.
+ * So if return value is positive it means there is an increase in the number
+ * of valid mapped entry. If it is negative it means there is a decrease in
+ * the number of valid mapped entry. In all case |return| <= npages.
+ */
+static inline int iommu_domain_update_directory(struct iommu_domain *domain,
+						unsigned long npages,
+						unsigned long *pfns,
+						unsigned long pfn_mask,
+						unsigned long pfn_shift,
+						unsigned long pfn_valid,
+						unsigned long pfn_write,
+						dma_addr_t iova_base)
+{
+	if (!domain->ops->domain_update_directory)
+		return -EINVAL;
+	return domain->ops->domain_update_directory(domain, npages, pfns,
+						    pfn_mask, pfn_shift,
+						    pfn_valid, pfn_write,
+						    iova_base);
+}
+
+/* iommu_domain_unmap_directory() - Unmap a directory of pages in a domain.
+ *
+ * @domain: Domain into which mapping should happen.
+ * @npages: The maximum number of page to map.
+ * @iova_base: Base io virtual address at which directory is mapped.
+ * Returns: Number of unmapped pages.
+ *
+ * This allow to unmap a previously successfull directory mapping of pages. It
+ * free the iova and return the number of valid unmapped entries.
+ */
+static inline int iommu_domain_unmap_directory(struct iommu_domain *domain,
+					       unsigned long npages,
+					       dma_addr_t iova_base)
+{
+	if (!domain->ops->domain_unmap_directory)
+		return 0;
+	return domain->ops->domain_unmap_directory(domain, npages, iova_base);
+}
+
 #else /* CONFIG_IOMMU_API */
 
 struct iommu_ops {};
@@ -424,6 +538,37 @@ static inline void iommu_device_unlink(struct device *dev, struct device *link)
 {
 }
 
+static inline int iommu_domain_map_directory(struct iommu_domain *domain,
+					     unsigned long npages,
+					     unsigned long *pfns,
+					     unsigned long pfn_mask,
+					     unsigned long pfn_shift,
+					     unsigned long pfn_valid,
+					     unsigned long pfn_write,
+					     dma_addr_t *iova_base)
+{
+	return -EINVAL;
+}
+
+static inline int iommu_domain_update_directory(struct iommu_domain *domain,
+						unsigned long npages,
+						unsigned long *pfns,
+						unsigned long pfn_mask,
+						unsigned long pfn_shift,
+						unsigned long pfn_valid,
+						unsigned long pfn_write,
+						dma_addr_t iova_base)
+{
+	return -EINVAL;
+}
+
+static inline void iommu_domain_unmap_directory(struct iommu_domain *domain,
+						unsigned long npages,
+						dma_addr_t iova_base)
+{
+	return;
+}
+
 #endif /* CONFIG_IOMMU_API */
 
 #endif /* __LINUX_IOMMU_H */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
