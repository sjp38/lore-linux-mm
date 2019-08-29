Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ABCCC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 09:06:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10CE2233A1
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 09:06:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10CE2233A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D8806B0006; Thu, 29 Aug 2019 05:06:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 488E46B000C; Thu, 29 Aug 2019 05:06:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3760E6B000D; Thu, 29 Aug 2019 05:06:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 08CD86B0006
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 05:06:06 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A9A8040EC
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:06:05 +0000 (UTC)
X-FDA: 75874883490.11.waves39_52386b800b91e
X-HE-Tag: waves39_52386b800b91e
X-Filterd-Recvd-Size: 15258
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 09:06:04 +0000 (UTC)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7T957D3018793
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 05:06:03 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2up9y33np8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 05:06:02 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 29 Aug 2019 10:05:59 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 29 Aug 2019 10:05:55 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7T95sMe47382722
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 09:05:54 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B0D3742045;
	Thu, 29 Aug 2019 09:05:54 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D710442041;
	Thu, 29 Aug 2019 09:05:53 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.160])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 29 Aug 2019 09:05:53 +0000 (GMT)
Date: Thu, 29 Aug 2019 12:05:52 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
        Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
        Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Thomas Hellstrom <thellstrom@vmware.com>
Subject: Re: [PATCH 1/3] mm: split out a new pagewalk.h header from mm.h
References: <20190828141955.22210-1-hch@lst.de>
 <20190828141955.22210-2-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828141955.22210-2-hch@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19082909-4275-0000-0000-0000035E9E85
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082909-4276-0000-0000-00003870D526
Message-Id: <20190829090551.GB16471@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-29_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=941 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908290100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 04:19:53PM +0200, Christoph Hellwig wrote:
> Add a new header for the two handful of users of the walk_page_range /
> walk_page_vma interface instead of polluting all users of mm.h with it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Thomas Hellstrom <thellstrom@vmware.com>
> Reviewed-by: Steven Price <steven.price@arm.com>
> ---
>  arch/openrisc/kernel/dma.c              |  1 +
>  arch/powerpc/mm/book3s64/subpage_prot.c |  2 +-
>  arch/s390/mm/gmap.c                     |  2 +-
>  fs/proc/task_mmu.c                      |  2 +-
>  include/linux/mm.h                      | 46 ---------------------
>  include/linux/pagewalk.h                | 54 +++++++++++++++++++++++++
>  mm/hmm.c                                |  2 +-
>  mm/madvise.c                            |  1 +
>  mm/memcontrol.c                         |  2 +-
>  mm/mempolicy.c                          |  2 +-
>  mm/migrate.c                            |  1 +
>  mm/mincore.c                            |  2 +-
>  mm/mprotect.c                           |  2 +-
>  mm/pagewalk.c                           |  2 +-
>  14 files changed, 66 insertions(+), 55 deletions(-)
>  create mode 100644 include/linux/pagewalk.h
> 
> diff --git a/arch/openrisc/kernel/dma.c b/arch/openrisc/kernel/dma.c
> index b41a79fcdbd9..c7812e6effa2 100644
> --- a/arch/openrisc/kernel/dma.c
> +++ b/arch/openrisc/kernel/dma.c
> @@ -16,6 +16,7 @@
>   */
>  
>  #include <linux/dma-noncoherent.h>
> +#include <linux/pagewalk.h>
>  
>  #include <asm/cpuinfo.h>
>  #include <asm/spr_defs.h>
> diff --git a/arch/powerpc/mm/book3s64/subpage_prot.c b/arch/powerpc/mm/book3s64/subpage_prot.c
> index 9ba07e55c489..236f0a861ecc 100644
> --- a/arch/powerpc/mm/book3s64/subpage_prot.c
> +++ b/arch/powerpc/mm/book3s64/subpage_prot.c
> @@ -7,7 +7,7 @@
>  #include <linux/kernel.h>
>  #include <linux/gfp.h>
>  #include <linux/types.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hugetlb.h>
>  #include <linux/syscalls.h>
>  
> diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
> index 39c3a6e3d262..cf80feae970d 100644
> --- a/arch/s390/mm/gmap.c
> +++ b/arch/s390/mm/gmap.c
> @@ -9,7 +9,7 @@
>   */
>  
>  #include <linux/kernel.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/swap.h>
>  #include <linux/smp.h>
>  #include <linux/spinlock.h>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 731642e0f5a0..8857da830b86 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1,5 +1,5 @@
>  // SPDX-License-Identifier: GPL-2.0
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/vmacache.h>
>  #include <linux/hugetlb.h>
>  #include <linux/huge_mm.h>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..7cf955feb823 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1430,54 +1430,8 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long address,
>  void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>  		unsigned long start, unsigned long end);
>  
> -/**
> - * mm_walk - callbacks for walk_page_range
> - * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry
> - *	       this handler should only handle pud_trans_huge() puds.
> - *	       the pmd_entry or pte_entry callbacks will be used for
> - *	       regular PUDs.
> - * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> - *	       this handler is required to be able to handle
> - *	       pmd_trans_huge() pmds.  They may simply choose to
> - *	       split_huge_page() instead of handling it explicitly.
> - * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> - * @pte_hole: if set, called for each hole at all levels
> - * @hugetlb_entry: if set, called for each hugetlb entry
> - * @test_walk: caller specific callback function to determine whether
> - *             we walk over the current vma or not. Returning 0
> - *             value means "do page table walk over the current vma,"
> - *             and a negative one means "abort current page table walk
> - *             right now." 1 means "skip the current vma."
> - * @mm:        mm_struct representing the target process of page table walk
> - * @vma:       vma currently walked (NULL if walking outside vmas)
> - * @private:   private data for callbacks' usage
> - *
> - * (see the comment on walk_page_range() for more details)
> - */
> -struct mm_walk {
> -	int (*pud_entry)(pud_t *pud, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pte_entry)(pte_t *pte, unsigned long addr,
> -			 unsigned long next, struct mm_walk *walk);
> -	int (*pte_hole)(unsigned long addr, unsigned long next,
> -			struct mm_walk *walk);
> -	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
> -			     unsigned long addr, unsigned long next,
> -			     struct mm_walk *walk);
> -	int (*test_walk)(unsigned long addr, unsigned long next,
> -			struct mm_walk *walk);
> -	struct mm_struct *mm;
> -	struct vm_area_struct *vma;
> -	void *private;
> -};
> -
>  struct mmu_notifier_range;
>  
> -int walk_page_range(unsigned long addr, unsigned long end,
> -		struct mm_walk *walk);
> -int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
>  void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
>  		unsigned long end, unsigned long floor, unsigned long ceiling);
>  int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
> diff --git a/include/linux/pagewalk.h b/include/linux/pagewalk.h
> new file mode 100644
> index 000000000000..df278a94086d
> --- /dev/null
> +++ b/include/linux/pagewalk.h
> @@ -0,0 +1,54 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _LINUX_PAGEWALK_H
> +#define _LINUX_PAGEWALK_H
> +
> +#include <linux/mm.h>
> +
> +/**
> + * mm_walk - callbacks for walk_page_range
> + * @pud_entry: if set, called for each non-empty PUD (2nd-level) entry

Sorry for jumping late, can we remove the level numbers here and below?
PUD can be non-existent, 2nd or 3rd (from top) and PTE can be from 2nd to
5th...

I'd completely drop the numbers and mark PTE as "lowest level".

> + *	       this handler should only handle pud_trans_huge() puds.
> + *	       the pmd_entry or pte_entry callbacks will be used for
> + *	       regular PUDs.
> + * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
> + *	       this handler is required to be able to handle
> + *	       pmd_trans_huge() pmds.  They may simply choose to
> + *	       split_huge_page() instead of handling it explicitly.
> + * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
> + * @pte_hole: if set, called for each hole at all levels
> + * @hugetlb_entry: if set, called for each hugetlb entry
> + * @test_walk: caller specific callback function to determine whether
> + *             we walk over the current vma or not. Returning 0
> + *             value means "do page table walk over the current vma,"
> + *             and a negative one means "abort current page table walk
> + *             right now." 1 means "skip the current vma."
> + * @mm:        mm_struct representing the target process of page table walk
> + * @vma:       vma currently walked (NULL if walking outside vmas)
> + * @private:   private data for callbacks' usage
> + *
> + * (see the comment on walk_page_range() for more details)
> + */
> +struct mm_walk {
> +	int (*pud_entry)(pud_t *pud, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pmd_entry)(pmd_t *pmd, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pte_entry)(pte_t *pte, unsigned long addr,
> +			 unsigned long next, struct mm_walk *walk);
> +	int (*pte_hole)(unsigned long addr, unsigned long next,
> +			struct mm_walk *walk);
> +	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
> +			     unsigned long addr, unsigned long next,
> +			     struct mm_walk *walk);
> +	int (*test_walk)(unsigned long addr, unsigned long next,
> +			struct mm_walk *walk);
> +	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +	void *private;
> +};
> +
> +int walk_page_range(unsigned long addr, unsigned long end,
> +		struct mm_walk *walk);
> +int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
> +
> +#endif /* _LINUX_PAGEWALK_H */
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 4882b83aeccb..26916ff6c8df 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -8,7 +8,7 @@
>   * Refer to include/linux/hmm.h for information about heterogeneous memory
>   * management or HMM for short.
>   */
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hmm.h>
>  #include <linux/init.h>
>  #include <linux/rmap.h>
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 968df3aa069f..80a78bb16782 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -20,6 +20,7 @@
>  #include <linux/file.h>
>  #include <linux/blkdev.h>
>  #include <linux/backing-dev.h>
> +#include <linux/pagewalk.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/shmem_fs.h>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6f5c0c517c49..4c3af5d71ab1 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -25,7 +25,7 @@
>  #include <linux/page_counter.h>
>  #include <linux/memcontrol.h>
>  #include <linux/cgroup.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/sched/mm.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/hugetlb.h>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 65e0874fce17..3a96def1e796 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -68,7 +68,7 @@
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
>  
>  #include <linux/mempolicy.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/highmem.h>
>  #include <linux/hugetlb.h>
>  #include <linux/kernel.h>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 962cb62c621f..c9c73a35aca7 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -38,6 +38,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/gfp.h>
> +#include <linux/pagewalk.h>
>  #include <linux/pfn_t.h>
>  #include <linux/memremap.h>
>  #include <linux/userfaultfd_k.h>
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 4fe91d497436..3b051b6ab3fe 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -10,7 +10,7 @@
>   */
>  #include <linux/pagemap.h>
>  #include <linux/gfp.h>
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/mman.h>
>  #include <linux/syscalls.h>
>  #include <linux/swap.h>
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index bf38dfbbb4b4..cc73318dbc25 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -9,7 +9,7 @@
>   *  (C) Copyright 2002 Red Hat Inc, All Rights Reserved
>   */
>  
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/hugetlb.h>
>  #include <linux/shm.h>
>  #include <linux/mman.h>
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index c3084ff2569d..8a92a961a2ee 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -1,5 +1,5 @@
>  // SPDX-License-Identifier: GPL-2.0
> -#include <linux/mm.h>
> +#include <linux/pagewalk.h>
>  #include <linux/highmem.h>
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
> -- 
> 2.20.1
> 
> 

-- 
Sincerely yours,
Mike.


