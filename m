Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E26398E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id z6so23968322qtj.21
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:54:51 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l13si2641803qtq.121.2019.01.14.01.54.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 01:54:50 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0E9mhlb011886
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:50 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q0kw2t31v-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:54:50 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Mon, 14 Jan 2019 09:54:49 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V7 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
Date: Mon, 14 Jan 2019 15:24:32 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli <aarcange@redhat.com>, mpe@ellerman.id.au
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
patch series add support for migrating compound pages. 

Changes from V6:
* use get_user_pages_longterm instead of get_user_pages_cma_migrate()

Changes from V5:
* Add PF_MEMALLOC_NOCMA
* remote __GFP_THISNODE when allocating target page for migration

Changes from V4:
* use __GFP_NOWARN when allocating pages to avoid page allocation failure warnings.

Changes from V3:
* Move the hugetlb check before transhuge check
* Use compound head page when isolating hugetlb page


Aneesh Kumar K.V (4):
  mm/cma: Add PF flag to force non cma alloc
  mm: Update get_user_pages_longterm to migrate pages allocated from CMA
    region
  powerpc/mm/iommu: Allow migration of cma allocated pages during
    mm_iommu_do_alloc
  powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing

 arch/powerpc/mm/mmu_context_iommu.c | 146 ++++++--------------
 include/linux/hugetlb.h             |   2 +
 include/linux/mm.h                  |   3 +-
 include/linux/sched.h               |   1 +
 include/linux/sched/mm.h            |  48 +++++--
 mm/gup.c                            | 200 ++++++++++++++++++++++++----
 mm/hugetlb.c                        |   4 +-
 7 files changed, 267 insertions(+), 137 deletions(-)

-- 
2.20.1
