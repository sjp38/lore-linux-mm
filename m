Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id E9D136B0083
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 18:33:18 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so717154pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 15:33:18 -0800 (PST)
Date: Wed, 14 Nov 2012 15:33:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5 08/11] thp: setup huge zero page on non-write page
 fault
In-Reply-To: <1352300463-12627-9-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1211141531110.22537@chino.kir.corp.google.com>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com> <1352300463-12627-9-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index f36bc7d..41f05f1 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -726,6 +726,16 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  			return VM_FAULT_OOM;
>  		if (unlikely(khugepaged_enter(vma)))
>  			return VM_FAULT_OOM;
> +		if (!(flags & FAULT_FLAG_WRITE)) {
> +			pgtable_t pgtable;
> +			pgtable = pte_alloc_one(mm, haddr);
> +			if (unlikely(!pgtable))
> +				goto out;

No use in retrying, just return VM_FAULT_OOM.

> +			spin_lock(&mm->page_table_lock);
> +			set_huge_zero_page(pgtable, mm, vma, haddr, pmd);
> +			spin_unlock(&mm->page_table_lock);
> +			return 0;
> +		}
>  		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
>  					  vma, haddr, numa_node_id(), 0);
>  		if (unlikely(!page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
