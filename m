Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF3D6B256F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:13 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so6995720pla.2
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:23:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a3si6664081pld.252.2018.11.21.01.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 01:23:11 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAL9JbU6045445
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:11 -0500
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nw0kgankf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:23:10 -0500
Received: from localhost
	by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 21 Nov 2018 09:23:09 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V4 0/3] * mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
Date: Wed, 21 Nov 2018 14:52:56 +0530
Message-Id: <20181121092259.16482-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au, paulus@samba.org, David Gibson <david@gibson.dropbear.id.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
be able to start guest if we fail to allocate hash page table. We have observed
hash table allocation failure because we failed to migrate pages out of CMA region
because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
won't be able to migrate those pages. The pages are also pinned for the lifetime of the
guest.

Currently we support migration of non-compound pages. With THP and with the addition of
 hugetlb migration we can end up allocating compound pages from CMA region. This
patch series add support for migrating compound pages. The first path adds the helper
get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
CMA region before incrementing the reference count. 

Changes from V3:
* Move the hugetlb check before transhuge check
* Use compound head page when isolating hugetlb page

Aneesh Kumar K.V (3):
  mm: Add get_user_pages_cma_migrate
  powerpc/mm/iommu: Allow migration of cma allocated pages during
    mm_iommu_get
  powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing

 arch/powerpc/mm/mmu_context_iommu.c | 140 ++++++++--------------------
 include/linux/hugetlb.h             |   2 +
 include/linux/migrate.h             |   3 +
 mm/hugetlb.c                        |   4 +-
 mm/migrate.c                        | 132 ++++++++++++++++++++++++++
 5 files changed, 179 insertions(+), 102 deletions(-)

-- 
2.17.2
