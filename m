Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E00AE6B000D
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:34:41 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id h21-v6so4373121oib.16
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:34:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d124-v6si1989051oif.2.2018.10.04.01.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:34:40 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w948Xj22043621
	for <linux-mm@kvack.org>; Thu, 4 Oct 2018 04:34:39 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mwd7e5p5x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Oct 2018 04:34:39 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 4 Oct 2018 09:34:36 +0100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: Re: [PATCH V3 0/2] mm/kvm/vfio/ppc64: Migrate compound pages out of CMA region
In-Reply-To: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com>
References: <20180918115839.22154-1-aneesh.kumar@linux.ibm.com>
Date: Thu, 04 Oct 2018 14:04:29 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87y3beaz56.fsf@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


Hi Andrew,

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
> be able to start guest if we fail to allocate hash page table. We have observed
> hash table allocation failure because we failed to migrate pages out of CMA region
> because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
> the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
> won't be able to migrate those pages. The pages are also pinned for the lifetime of the
> guest.
>
> Currently we support migration of non-compound pages. With THP and with the addition of
>  hugetlb migration we can end up allocating compound pages from CMA region. This
> patch series add support for migrating compound pages. The first path adds the helper
> get_user_pages_cma_migrate() which pin the page making sure we migrate them out of
> CMA region before incrementing the reference count. 
>
> Aneesh Kumar K.V (2):
>   mm: Add get_user_pages_cma_migrate
>   powerpc/mm/iommu: Allow migration of cma allocated pages during
>     mm_iommu_get
>
>  arch/powerpc/mm/mmu_context_iommu.c | 120 ++++++++-----------------
>  include/linux/hugetlb.h             |   2 +
>  include/linux/migrate.h             |   3 +
>  mm/hugetlb.c                        |   4 +-
>  mm/migrate.c                        | 132 ++++++++++++++++++++++++++++
>  5 files changed, 174 insertions(+), 87 deletions(-)

Any feedback on this.

-aneesh
