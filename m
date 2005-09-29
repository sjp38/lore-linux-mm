Date: Wed, 28 Sep 2005 23:10:29 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 2/3 htlb-fault] Demand faulting for huge pages
Message-Id: <20050928231029.6dd60fc3.akpm@osdl.org>
In-Reply-To: <1127939538.26401.36.camel@localhost.localdomain>
References: <1127939141.26401.32.camel@localhost.localdomain>
	<1127939538.26401.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Adam Litke <agl@us.ibm.com> wrote:
>
> +int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  +			unsigned long address, int write_access)
>  +{
>  +	pte_t *ptep;
>  +	int rc = VM_FAULT_MINOR;
>  +
>  +	spin_lock(&mm->page_table_lock);
>  +
>  +	ptep = huge_pte_alloc(mm, address);
>  +	if (!ptep) {
>  +		rc = VM_FAULT_SIGBUS;
>  +		goto out;
>  +	}
>  +	if (pte_none(*ptep))
>  +		rc = hugetlb_pte_fault(mm, vma, address, write_access);
>  +out:
>  +	if (rc == VM_FAULT_MINOR)
>  +		flush_tlb_page(vma, address);
>  +
>  +	spin_unlock(&mm->page_table_lock);
>  +	return rc;
>  +}

label `out' can be moved down a couple of lines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
