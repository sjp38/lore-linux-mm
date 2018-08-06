Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 009206B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:27:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f8-v6so3999759eds.6
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:27:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u24-v6si7170712edi.415.2018.08.06.02.27.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 02:27:56 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:27:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v6 10/13] mm, memory_failure: Teach memory_failure()
 about dev_pagemap pages
Message-ID: <20180806092751.sfnilnqie2dlvblk@quack2.suse.cz>
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153154382187.34503.3838107575957710423.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <153154382187.34503.3838107575957710423.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-07-18 21:50:21, Dan Williams wrote:
>     mce: Uncorrected hardware memory error in user-access at af34214200
>     {1}[Hardware Error]: It has been corrected by h/w and requires no further action
>     mce: [Hardware Error]: Machine check events logged
>     {1}[Hardware Error]: event severity: corrected
>     Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
>     [..]
>     Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
>     mce: Memory error not recovered
> 
> In contrast to typical memory, dev_pagemap pages may be dax mapped. With
> dax there is no possibility to map in another page dynamically since dax
> establishes 1:1 physical address to file offset associations. Also
> dev_pagemap pages associated with NVDIMM / persistent memory devices can
> internal remap/repair addresses with poison. While memory_failure()
> assumes that it can discard typical poisoned pages and keep them
> unmapped indefinitely, dev_pagemap pages may be returned to service
> after the error is cleared.
> 
> Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
> dev_pagemap pages that have poison consumed by userspace. Mark the
> memory as UC instead of unmapping it completely to allow ongoing access
> via the device driver (nd_pmem). Later, nd_pmem will grow support for
> marking the page back to WB when the error is cleared.
> 
> Cc: Jan Kara <jack@suse.cz>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jerome Glisse <jglisse@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

I'm not very familiar with memory failure code but at least from DAX POV
and from my rudimentary understanding of memory-failure the patch looks
sane to me.

								Honza

> ---
>  include/linux/mm.h  |    1 
>  mm/memory-failure.c |  125 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 124 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index a0fbb9ffe380..374e5e9284f7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2725,6 +2725,7 @@ enum mf_action_page_type {
>  	MF_MSG_TRUNCATED_LRU,
>  	MF_MSG_BUDDY,
>  	MF_MSG_BUDDY_2ND,
> +	MF_MSG_DAX,
>  	MF_MSG_UNKNOWN,
>  };
>  
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8a81680d00dd..effaa7c7a1a4 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -55,6 +55,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memory_hotplug.h>
>  #include <linux/mm_inline.h>
> +#include <linux/memremap.h>
>  #include <linux/kfifo.h>
>  #include <linux/ratelimit.h>
>  #include "internal.h"
> @@ -263,6 +264,40 @@ void shake_page(struct page *p, int access)
>  }
>  EXPORT_SYMBOL_GPL(shake_page);
>  
> +static unsigned long dev_pagemap_mapping_size(struct page *page,
> +		struct vm_area_struct *vma)
> +{
> +	unsigned long address = vma_address(page, vma);
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +
> +	pgd = pgd_offset(vma->vm_mm, address);
> +	if (!pgd_present(*pgd))
> +		return 0;
> +	p4d = p4d_offset(pgd, address);
> +	if (!p4d_present(*p4d))
> +		return 0;
> +	pud = pud_offset(p4d, address);
> +	if (!pud_present(*pud))
> +		return 0;
> +	if (pud_devmap(*pud))
> +		return PUD_SIZE;
> +	pmd = pmd_offset(pud, address);
> +	if (!pmd_present(*pmd))
> +		return 0;
> +	if (pmd_devmap(*pmd))
> +		return PMD_SIZE;
> +	pte = pte_offset_map(pmd, address);
> +	if (!pte_present(*pte))
> +		return 0;
> +	if (pte_devmap(*pte))
> +		return PAGE_SIZE;
> +	return 0;
> +}
> +
>  /*
>   * Failure handling: if we can't find or can't kill a process there's
>   * not much we can do.	We just print a message and ignore otherwise.
> @@ -292,7 +327,10 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>  	}
>  	tk->addr = page_address_in_vma(p, vma);
>  	tk->addr_valid = 1;
> -	tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
> +	if (is_zone_device_page(p))
> +		tk->size_shift = ilog2(dev_pagemap_mapping_size(p, vma));
> +	else
> +		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
>  
>  	/*
>  	 * In theory we don't have to kill when the page was
> @@ -300,7 +338,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>  	 * likely very rare kill anyways just out of paranoia, but use
>  	 * a SIGKILL because the error is not contained anymore.
>  	 */
> -	if (tk->addr == -EFAULT) {
> +	if (tk->addr == -EFAULT || tk->size_shift == 0) {
>  		pr_info("Memory failure: Unable to find user space address %lx in %s\n",
>  			page_to_pfn(p), tsk->comm);
>  		tk->addr_valid = 0;
> @@ -514,6 +552,7 @@ static const char * const action_page_types[] = {
>  	[MF_MSG_TRUNCATED_LRU]		= "already truncated LRU page",
>  	[MF_MSG_BUDDY]			= "free buddy page",
>  	[MF_MSG_BUDDY_2ND]		= "free buddy page (2nd try)",
> +	[MF_MSG_DAX]			= "dax page",
>  	[MF_MSG_UNKNOWN]		= "unknown page",
>  };
>  
> @@ -1111,6 +1150,83 @@ static int memory_failure_hugetlb(unsigned long pfn, int flags)
>  	return res;
>  }
>  
> +static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
> +		struct dev_pagemap *pgmap)
> +{
> +	struct page *page = pfn_to_page(pfn);
> +	const bool unmap_success = true;
> +	unsigned long size = 0;
> +	struct to_kill *tk;
> +	LIST_HEAD(tokill);
> +	int rc = -EBUSY;
> +	loff_t start;
> +
> +	/*
> +	 * Prevent the inode from being freed while we are interrogating
> +	 * the address_space, typically this would be handled by
> +	 * lock_page(), but dax pages do not use the page lock. This
> +	 * also prevents changes to the mapping of this pfn until
> +	 * poison signaling is complete.
> +	 */
> +	if (!dax_lock_mapping_entry(page))
> +		goto out;
> +
> +	if (hwpoison_filter(page)) {
> +		rc = 0;
> +		goto unlock;
> +	}
> +
> +	switch (pgmap->type) {
> +	case MEMORY_DEVICE_PRIVATE:
> +	case MEMORY_DEVICE_PUBLIC:
> +		/*
> +		 * TODO: Handle HMM pages which may need coordination
> +		 * with device-side memory.
> +		 */
> +		goto unlock;
> +	default:
> +		break;
> +	}
> +
> +	/*
> +	 * Use this flag as an indication that the dax page has been
> +	 * remapped UC to prevent speculative consumption of poison.
> +	 */
> +	SetPageHWPoison(page);
> +
> +	/*
> +	 * Unlike System-RAM there is no possibility to swap in a
> +	 * different physical page at a given virtual address, so all
> +	 * userspace consumption of ZONE_DEVICE memory necessitates
> +	 * SIGBUS (i.e. MF_MUST_KILL)
> +	 */
> +	flags |= MF_ACTION_REQUIRED | MF_MUST_KILL;
> +	collect_procs(page, &tokill, flags & MF_ACTION_REQUIRED);
> +
> +	list_for_each_entry(tk, &tokill, nd)
> +		if (tk->size_shift)
> +			size = max(size, 1UL << tk->size_shift);
> +	if (size) {
> +		/*
> +		 * Unmap the largest mapping to avoid breaking up
> +		 * device-dax mappings which are constant size. The
> +		 * actual size of the mapping being torn down is
> +		 * communicated in siginfo, see kill_proc()
> +		 */
> +		start = (page->index << PAGE_SHIFT) & ~(size - 1);
> +		unmap_mapping_range(page->mapping, start, start + size, 0);
> +	}
> +	kill_procs(&tokill, flags & MF_MUST_KILL, !unmap_success, pfn, flags);
> +	rc = 0;
> +unlock:
> +	dax_unlock_mapping_entry(page);
> +out:
> +	/* drop pgmap ref acquired in caller */
> +	put_dev_pagemap(pgmap);
> +	action_result(pfn, MF_MSG_DAX, rc ? MF_FAILED : MF_RECOVERED);
> +	return rc;
> +}
> +
>  /**
>   * memory_failure - Handle memory failure of a page.
>   * @pfn: Page Number of the corrupted page
> @@ -1133,6 +1249,7 @@ int memory_failure(unsigned long pfn, int flags)
>  	struct page *p;
>  	struct page *hpage;
>  	struct page *orig_head;
> +	struct dev_pagemap *pgmap;
>  	int res;
>  	unsigned long page_flags;
>  
> @@ -1145,6 +1262,10 @@ int memory_failure(unsigned long pfn, int flags)
>  		return -ENXIO;
>  	}
>  
> +	pgmap = get_dev_pagemap(pfn, NULL);
> +	if (pgmap)
> +		return memory_failure_dev_pagemap(pfn, flags, pgmap);
> +
>  	p = pfn_to_page(pfn);
>  	if (PageHuge(p))
>  		return memory_failure_hugetlb(pfn, flags);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
