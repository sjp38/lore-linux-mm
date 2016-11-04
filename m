Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1F6280274
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 03:02:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i88so18026519pfk.3
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:02:46 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id a65si14609116pfb.18.2016.11.04.00.02.44
        for <linux-mm@kvack.org>;
        Fri, 04 Nov 2016 00:02:45 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com> <1478115245-32090-17-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-17-git-send-email-aarcange@redhat.com>
Subject: Re: [PATCH 16/33] userfaultfd: hugetlbfs: add userfaultfd hugetlb hook
Date: Fri, 04 Nov 2016 15:02:29 +0800
Message-ID: <07a501d23669$6903d310$3b0b7930$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, "'Dr. David Alan Gilbert'" <dgilbert@redhat.com>, 'Shaohua Li' <shli@fb.com>, 'Pavel Emelyanov' <xemul@parallels.com>, 'Mike Rapoport' <rppt@linux.vnet.ibm.com>

> 
> From: Mike Kravetz <mike.kravetz@oracle.com>
> 
> When processing a hugetlb fault for no page present, check the vma to
> determine if faults are to be handled via userfaultfd.  If so, drop the
> hugetlb_fault_mutex and call handle_userfault().
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com> 

>  mm/hugetlb.c | 33 +++++++++++++++++++++++++++++++++
>  1 file changed, 33 insertions(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index baf7fd4..7247f8c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -32,6 +32,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/node.h>
> +#include <linux/userfaultfd_k.h>
>  #include "internal.h"
> 
>  int hugepages_treat_as_movable;
> @@ -3589,6 +3590,38 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		size = i_size_read(mapping->host) >> huge_page_shift(h);
>  		if (idx >= size)
>  			goto out;
> +
> +		/*
> +		 * Check for page in userfault range
> +		 */
> +		if (userfaultfd_missing(vma)) {
> +			u32 hash;
> +			struct fault_env fe = {
> +				.vma = vma,
> +				.address = address,
> +				.flags = flags,
> +				/*
> +				 * Hard to debug if it ends up being
> +				 * used by a callee that assumes
> +				 * something about the other
> +				 * uninitialized fields... same as in
> +				 * memory.c
> +				 */
> +			};
> +
> +			/*
> +			 * hugetlb_fault_mutex must be dropped before
> +			 * handling userfault.  Reacquire after handling
> +			 * fault to make calling code simpler.
> +			 */
> +			hash = hugetlb_fault_mutex_hash(h, mm, vma, mapping,
> +							idx, address);
> +			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> +			ret = handle_userfault(&fe, VM_UFFD_MISSING);
> +			mutex_lock(&hugetlb_fault_mutex_table[hash]);
> +			goto out;
> +		}
> +
>  		page = alloc_huge_page(vma, address, 0);
>  		if (IS_ERR(page)) {
>  			ret = PTR_ERR(page);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
