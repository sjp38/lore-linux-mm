Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id E80628E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 23:51:26 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a18so1363469pga.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 20:51:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p4si10628351pli.432.2019.01.07.20.51.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 20:51:25 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x084mt3k089755
	for <linux-mm@kvack.org>; Mon, 7 Jan 2019 23:51:25 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pvf8kqr4m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Jan 2019 23:51:24 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 8 Jan 2019 04:51:23 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [PATCH V6 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
Date: Tue,  8 Jan 2019 10:21:06 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
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
patch series add support for migrating compound pages. The first path adds the helper
get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
CMA region before incrementing the reference count. 

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
  mm: Add get_user_pages_cma_migrate
  powerpc/mm/iommu: Allow migration of cma allocated pages during
    mm_iommu_get
  powerpc/mm/iommu: Allow large IOMMU page size only for hugetlb backing

 arch/powerpc/mm/mmu_context_iommu.c | 144 ++++++++-------------------
 include/linux/hugetlb.h             |   2 +
 include/linux/migrate.h             |   3 +
 include/linux/sched.h               |   1 +
 include/linux/sched/mm.h            |  36 +++++--
 mm/hugetlb.c                        |   4 +-
 mm/migrate.c                        | 149 ++++++++++++++++++++++++++++
 7 files changed, 227 insertions(+), 112 deletions(-)

-- 
2.20.1
