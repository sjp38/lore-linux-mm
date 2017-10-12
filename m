Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 42BB86B0038
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:26:09 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so6125638wmu.2
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:26:09 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r138si261163wmd.164.2017.10.12.07.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 07:26:07 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9CEAK7h061828
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:26:06 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dj7a01h4w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 10:26:06 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 12 Oct 2017 15:26:04 +0100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9CEQ1On25493534
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 14:26:02 GMT
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9CEPq3D025275
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 01:25:52 +1100
Subject: Re: [RFC PATCH 0/3] Add mmap(MAP_CONTIG) support
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <f1737666-b65e-38e2-94af-129e66031503@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 12 Oct 2017 19:55:54 +0530
MIME-Version: 1.0
In-Reply-To: <f1737666-b65e-38e2-94af-129e66031503@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5a4de449-69b0-a9a4-c0bb-27198f4793c7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On 10/12/2017 04:06 PM, Anshuman Khandual wrote:
> On 10/12/2017 07:16 AM, Mike Kravetz wrote:
>> The following is a 'possible' way to add such functionality.  I just
>> did what was easy and pre-allocated contiguous pages which are used
>> to populate the mapping.  I did not use any of the higher order
>> allocators such as alloc_contig_range.  Therefore, it is limited to
> Just tried with a small prototype with an implementation similar to that
> of alloc_gigantic_page() where we scan the zones (applicable zonelist)
> for contiguous valid PFN range and try allocating with alloc_contig_range.
> Will share it soon.
> 

With this patch on top of the series can allocate little more than
twice of 1UL << (MAX_ORDER - 1) number of pages on POWER. But the
problem is it keeps on reducing every attempt till it reaches
1UL << (MAX_ORDER - 1). Will look into it.

diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/include/uapi/asm/mman.h
index 03c06ba..ce13b36 100644
--- a/arch/powerpc/include/uapi/asm/mman.h
+++ b/arch/powerpc/include/uapi/asm/mman.h
@@ -28,5 +28,6 @@
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
 #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
+#define MAP_CONTIG	0x80000		/* back with contiguous pages */
 
 #endif /* _UAPI_ASM_POWERPC_MMAN_H */
diff --git a/mm/mmap.c b/mm/mmap.c
index aee7917..4e6588d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1568,6 +1568,60 @@ struct mmap_arg_struct {
 }
 #endif /* __ARCH_WANT_SYS_OLD_MMAP */
 
+static bool is_pfn_range_valid(struct zone *z,
+	unsigned long start_pfn, unsigned long nr_pages)
+{
+	unsigned long i, end_pfn = start_pfn + nr_pages;
+	struct page *page;
+
+	for (i = start_pfn; i < end_pfn; i++) {
+		if (!pfn_valid(i))
+			return false;
+
+		page = pfn_to_page(i);
+		if (page_zone(page) != z)
+			return false;
+
+		if (PageReserved(page))
+			return false;
+
+		if (page_count(page) > 0)
+			return false;
+
+		if (PageHuge(page))
+			return false;
+	}
+	return true;
+}
+
+struct page *
+alloc_pages_vma_contig(gfp_t gfp, int order, struct vm_area_struct *vma,
+		unsigned long addr, int node, bool hugepage)
+{
+	struct zonelist *zonelist = node_zonelist(node, gfp);
+	struct zoneref *z;
+	struct zone *zone;
+	unsigned long pfn, nr_pages, flags, ret;
+
+	nr_pages = 1 << order;
+	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp), NULL) {
+		spin_lock_irqsave(&zone->lock, flags);
+		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
+		while (zone_spans_pfn(zone, pfn + nr_pages - 1)) {
+			if (is_pfn_range_valid(zone, pfn, nr_pages)) {
+				spin_unlock_irqrestore(&zone->lock, flags);
+				ret = alloc_contig_range(pfn, pfn + nr_pages, MIGRATE_MOVABLE, gfp);
+				if (!ret)
+					return pfn_to_page(pfn);
+				spin_lock_irqsave(&zone->lock, flags);
+			}
+			pfn += nr_pages;
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+	}
+	return NULL;
+}
+
 /*
  * Attempt to allocate a contiguous range of pages to back the
  * specified vma.  vm_private_data is used as a 'pointer' to the
@@ -1588,11 +1642,19 @@ static long __alloc_vma_contig_range(struct vm_area_struct *vma)
 	 * allocations < MAX_ORDER in size.  However, this should really
 	 * handle arbitrary size allocations.
 	 */
+
+	/*
 	if (order >= MAX_ORDER)
 		return -ENOMEM;
 
-	vma->vm_private_data = alloc_pages_vma(gfp, order, vma, vma->vm_start,
-						numa_node_id(), false);
+	*/
+
+	if (order >= MAX_ORDER)
+		vma->vm_private_data = alloc_pages_vma_contig(gfp, order, vma,
+					vma->vm_start, numa_node_id(), false);
+	else
+		vma->vm_private_data = alloc_pages_vma(gfp, order, vma,
+					vma->vm_start, numa_node_id(), false);
 	if (!vma->vm_private_data)
 		return -ENOMEM;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
