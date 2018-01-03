Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 49C2C6B034B
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 09:00:54 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id h10so824335qke.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 06:00:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 87si858816qku.465.2018.01.03.06.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 06:00:53 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w03DxbWO068333
	for <linux-mm@kvack.org>; Wed, 3 Jan 2018 09:00:53 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f8xx9mfux-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Jan 2018 09:00:51 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 3 Jan 2018 14:00:47 -0000
Subject: Re: [PATCH 2/3] mm, migrate: remove reason argument from new_page_t
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-3-mhocko@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 3 Jan 2018 19:30:38 +0530
MIME-Version: 1.0
In-Reply-To: <20180103082555.14592-3-mhocko@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <f31b8830-db49-05a2-9a64-d27476fd206c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/03/2018 01:55 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> No allocation callback is using this argument anymore. new_page_node
> used to use this parameter to convey node_id resp. migration error
> up to move_pages code (do_move_page_to_node_array). The error status
> never made it into the final status field and we have a better way
> to communicate node id to the status field now. All other allocation
> callbacks simply ignored the argument so we can drop it finally.

There is a migrate_pages() call in powerpc which needs to be changed
as well. It was failing the build on powerpc.

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index e0a2d8e..91ee223 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -75,8 +75,7 @@ bool mm_iommu_preregistered(struct mm_struct *mm)
 /*
  * Taken from alloc_migrate_target with changes to remove CMA allocations
  */
-struct page *new_iommu_non_cma_page(struct page *page, unsigned long private,
-                                       int **resultp)
+struct page *new_iommu_non_cma_page(struct page *page, unsigned long private)
 {
        gfp_t gfp_mask = GFP_USER;
        struct page *new_page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
