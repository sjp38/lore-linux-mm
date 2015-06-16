Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D2E3D6B0038
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 17:15:42 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so22571955pdj.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 14:15:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tv5si2887991pbc.226.2015.06.16.14.15.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 14:15:41 -0700 (PDT)
Date: Tue, 16 Jun 2015 14:15:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-Id: <20150616141540.adc40130139151bf19f07ff9@linux-foundation.org>
In-Reply-To: <1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
	<1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Sun, 14 Jun 2015 18:04:43 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:

> This patch makes swapin readahead to improve thp collapse rate.
> When khugepaged scanned pages, there can be a few of the pages
> in swap area.
> 
> With the patch THP can collapse 4kB pages into a THP when
> there are up to max_ptes_swap swap ptes in a 2MB range.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. I force
> the system to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area.
> 
> Without the patch, system did not swap in readahead.
> THP rate was %47 of the program of the memory, it
> did not change over time.
> 
> With this patch, after 10 minutes of waiting khugepaged had
> collapsed %99 of the program's memory.
> 
> ...
>
> +/*
> + * Bring missing pages in from swap, to complete THP collapse.
> + * Only done if khugepaged_scan_pmd believes it is worthwhile.
> + *
> + * Called and returns without pte mapped or spinlocks held,
> + * but with mmap_sem held to protect against vma changes.
> + */
> +
> +static void __collapse_huge_page_swapin(struct mm_struct *mm,
> +					struct vm_area_struct *vma,
> +					unsigned long address, pmd_t *pmd,
> +					pte_t *pte)
> +{
> +	unsigned long _address;
> +	pte_t pteval = *pte;
> +	int swap_pte = 0;
> +
> +	pte = pte_offset_map(pmd, address);
> +	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
> +	     pte++, _address += PAGE_SIZE) {
> +		pteval = *pte;
> +		if (is_swap_pte(pteval)) {
> +			swap_pte++;
> +			do_swap_page(mm, vma, _address, pte, pmd, 0x0, pteval);
> +			/* pte is unmapped now, we need to map it */
> +			pte = pte_offset_map(pmd, _address);
> +		}
> +	}
> +	pte--;
> +	pte_unmap(pte);
> +	trace_mm_collapse_huge_page_swapin(mm, vma->vm_start, swap_pte);
> +}

This is doing a series of synchronous reads.  That will be sloooow on
spinning disks.

This function should be significantly faster if it first gets all the
necessary I/O underway.  I don't think we have a function which exactly
does this.  Perhaps generalise swapin_readahead() or open-code
something like

	blk_start_plug(...);
	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
	     pte++, _address += PAGE_SIZE) {
		if (is_swap_pte(*pte)) {
			read_swap_cache_async(...);
		}
	}
	blk_finish_plug(...);


If you do make a change such as this, please benchmark its effects. 
Not on SSD ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
