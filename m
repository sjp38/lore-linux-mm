Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF3816B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 06:37:19 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 43so1658312pla.17
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 03:37:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si9355129pfi.238.2017.12.10.03.37.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 10 Dec 2017 03:37:18 -0800 (PST)
Date: Sun, 10 Dec 2017 12:37:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, hugetlbfs: introduce ->pagesize() to
 vm_operations_struct
Message-ID: <20171210113715.GE20234@dhcp22.suse.cz>
References: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151270385525.21215.16828596212056611775.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151270385525.21215.16828596212056611775.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>

On Thu 07-12-17 19:30:55, Dan Williams wrote:
> When device-dax is operating in huge-page mode we want it to behave like
> hugetlbfs and report the MMU page mapping size that is being enforced by
> the vma. Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce
> ->split() to vm_operations_struct" it would be messy to teach
> vma_mmu_pagesize() about device-dax page mapping sizes in the same
> (hstate) way that hugetlbfs communicates this attribute.  Instead, these
> patches introduce a new ->pagesize() vm operation.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Reported-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

My build battery choked on the following
In file included from drivers/infiniband/core/umem_odp.c:41:0:
./include/linux/hugetlb.h: In function 'vma_kernel_pagesize':
./include/linux/hugetlb.h:262:32: error: dereferencing pointer to incomplete type
  if (vma->vm_ops && vma->vm_ops->pagesize)
                                ^
./include/linux/hugetlb.h:263:21: error: dereferencing pointer to incomplete type
   return vma->vm_ops->pagesize(vma);

I thought that adding #include <linux/mm.h> into linux/hugetlb.h would
be sufficient but then it failed for powerpc defconfig which overrides
vma_kernel_pagesize
In file included from ./include/linux/hugetlb.h:452:0,
                 from arch/powerpc/mm/hugetlbpage.c:14:
./arch/powerpc/include/asm/hugetlb.h:131:26: error: redefinition of 'vma_mmu_pagesize'
 #define vma_mmu_pagesize vma_mmu_pagesize
                          ^
arch/powerpc/mm/hugetlbpage.c:563:15: note: in expansion of macro 'vma_mmu_pagesize'
 unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
               ^
In file included from arch/powerpc/mm/hugetlbpage.c:14:0:
./include/linux/hugetlb.h:275:29: note: previous definition of 'vma_mmu_pagesize' was here
 static inline unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)

So it looks this needs something more laborous.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
