Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 77F8E6B0072
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 13:39:02 -0400 (EDT)
Received: by wgv5 with SMTP id 5so43084529wgv.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:39:02 -0700 (PDT)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id la1si9110811wjc.209.2015.06.17.10.39.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 10:39:01 -0700 (PDT)
Received: by wgv5 with SMTP id 5so43083918wgv.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:39:00 -0700 (PDT)
Date: Wed, 17 Jun 2015 20:38:56 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [RFC 3/3] mm: make swapin readahead to improve thp collapse rate
Message-ID: <20150617173856.GA3970@debian>
References: <1434294283-8699-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434294283-8699-4-git-send-email-ebru.akagunduz@gmail.com>
 <20150616141540.adc40130139151bf19f07ff9@linux-foundation.org>
 <5580E774.3070307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5580E774.3070307@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Tue, Jun 16, 2015 at 11:20:20PM -0400, Rik van Riel wrote:
> On 06/16/2015 05:15 PM, Andrew Morton wrote:
> > On Sun, 14 Jun 2015 18:04:43 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:
> > 
> >> This patch makes swapin readahead to improve thp collapse rate.
> >> When khugepaged scanned pages, there can be a few of the pages
> >> in swap area.
> >>
> >> With the patch THP can collapse 4kB pages into a THP when
> >> there are up to max_ptes_swap swap ptes in a 2MB range.
> >>
> >> The patch was tested with a test program that allocates
> >> 800MB of memory, writes to it, and then sleeps. I force
> >> the system to swap out all. Afterwards, the test program
> >> touches the area by writing, it skips a page in each
> >> 20 pages of the area.
> >>
> >> Without the patch, system did not swap in readahead.
> >> THP rate was %47 of the program of the memory, it
> >> did not change over time.
> >>
> >> With this patch, after 10 minutes of waiting khugepaged had
> >> collapsed %99 of the program's memory.
> >>
> >> ...
> >>
> >> +/*
> >> + * Bring missing pages in from swap, to complete THP collapse.
> >> + * Only done if khugepaged_scan_pmd believes it is worthwhile.
> >> + *
> >> + * Called and returns without pte mapped or spinlocks held,
> >> + * but with mmap_sem held to protect against vma changes.
> >> + */
> >> +
> >> +static void __collapse_huge_page_swapin(struct mm_struct *mm,
> >> +					struct vm_area_struct *vma,
> >> +					unsigned long address, pmd_t *pmd,
> >> +					pte_t *pte)
> >> +{
> >> +	unsigned long _address;
> >> +	pte_t pteval = *pte;
> >> +	int swap_pte = 0;
> >> +
> >> +	pte = pte_offset_map(pmd, address);
> >> +	for (_address = address; _address < address + HPAGE_PMD_NR*PAGE_SIZE;
> >> +	     pte++, _address += PAGE_SIZE) {
> >> +		pteval = *pte;
> >> +		if (is_swap_pte(pteval)) {
> >> +			swap_pte++;
> >> +			do_swap_page(mm, vma, _address, pte, pmd, 0x0, pteval);
> >> +			/* pte is unmapped now, we need to map it */
> >> +			pte = pte_offset_map(pmd, _address);
> >> +		}
> >> +	}
> >> +	pte--;
> >> +	pte_unmap(pte);
> >> +	trace_mm_collapse_huge_page_swapin(mm, vma->vm_start, swap_pte);
> >> +}
> > 
> > This is doing a series of synchronous reads.  That will be sloooow on
> > spinning disks.
> >
> > This function should be significantly faster if it first gets all the
> > necessary I/O underway.  I don't think we have a function which exactly
> > does this.  Perhaps generalise swapin_readahead() or open-code
> > something like
> 
> Looking at do_swap_page() and __lock_page_or_retry(), I guess
> there already is a way to do the above.
> 
> Passing a "flags" of FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT
> to do_swap_page() should result in do_swap_page() returning with
> the pte unmapped and the mmap_sem still held if the page was not
> immediately available to map into the pte (trylock_page succeeds).
> 
> Ebru, can you try passing the above as the flags argument to
> do_swap_page(), and see what happens?

I will try and resent the patch series.

Thanks for suggestions.

Ebru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
