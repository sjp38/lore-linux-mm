Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 333A0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:54:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D45412183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 00:54:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D45412183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60C526B0006; Thu, 28 Mar 2019 20:54:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BD416B0007; Thu, 28 Mar 2019 20:54:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A9CC6B0008; Thu, 28 Mar 2019 20:54:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0E88D6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 20:54:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x5so484789pll.2
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:54:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1y9NWh28oUJrB/ryfuIj4nxGTSDl30jBJpu7Inkj1+8=;
        b=XW983/idZu0OVBQzJ29ZoSLR6SVZXwtaGyBFjH2F/L0DKetAf3/BKxMa+TmdLfMb1B
         F+LsYUvOd4gETntFOI/BnCKDmdh7Xc2hvjwgUCvmTikpv8fo2y3Td4odO4nk9FbP4GNn
         FsQCoM9INeeCrrcbxxIdPnM8sLPO1SSvr841QZjsDoNZHRPbttJ167YG6HDOtDNcQd13
         RqnUS4KdX5LQRnR9nCOYQdHJMG5V9rPniGfWDNNb7U0lsk8VJLtAtoEd2Y4Rqr0GH+3R
         ySfkS8aBf4H2E5Iw+41NYSkWMr+mpRpKmuhU9vfW2W7RQDA1/l3MvuJbK90Kd2B08fSb
         AXTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXar39dCxLnoye+jDNyPJpTDqKKFoIHfihjeVCjkbFbHSAgnYSV
	RDTQwpo4LM+gsFnQL3LSa8B/n+uoYSGT7jNrVT9kkJDILt/xLhQdh/m/gjllsj6xWnFdh9Jr1PR
	TQtv6ZwZyU69WuWxJzMqZjJ1DyEdYTp3bFYI+fY3I95yJiKF5fDHpHOxcT1X12U75kA==
X-Received: by 2002:a63:f146:: with SMTP id o6mr42224599pgk.360.1553820892667;
        Thu, 28 Mar 2019 17:54:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOxgcxS1JeEt1Ax0yvRhTjioWHoIf62R8BuguTh6wb/l0Pz99Lr0NWNytTxBoXGrDt2Le4
X-Received: by 2002:a63:f146:: with SMTP id o6mr42224542pgk.360.1553820891601;
        Thu, 28 Mar 2019 17:54:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553820891; cv=none;
        d=google.com; s=arc-20160816;
        b=vh9BjZq9NKYcxhZJ+tVdvFR0HvxjGFn4YujqJG/YcG53BjY5a/FYAHT2J4u2LADaZw
         bWVyEtBK2n6iiyzVWLpW39LFo86PNkuoYkpIV5eLOSXezmOg4O9MAoBNeh+eT9D/526q
         yG9BelR4NPM67wFJE3LACLSULX0WfFt9fEWdYfK11p4EZ9KZeorzfCEU3EVhi0jKg2F3
         KpkckgbPf31ABPExPBO1ygHDeGjLcwLCQQuOlJtKHrHahTijwTViAmDTsHaQxsS4jxXS
         KWRJxwgTqHXw2prxlASy0dpZW7yTLNdxd7HUIwwAai/Ca3qYX6jagRK32TMt2+ZNtnmO
         9+gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1y9NWh28oUJrB/ryfuIj4nxGTSDl30jBJpu7Inkj1+8=;
        b=aAl2p4144wktFzdjo3EMgLueHpgPXyPGMFk0hw7twCQw8At8Wvpurp7VhlC3ID6+Q2
         w9xg6+AvI+JcN5aH9uzxcNJ8yVqyOzRMm2S0lBSHUy5FMGf/9quN5K7zI4sw3rJmHJkE
         kPCF8Yo4aK9zqk7JbEOd1rCEF2+Aluv8/ZlFXqKfHXKgcGQBqFIo0Q78db8fcTjQg5p/
         /2bEnce2xzIzLHVF2FnkldY2QYfKkl8HcWz/4ZEAHCywj3I7TqhPOyZ9sDeR5aEERJt1
         xq9jG/qNjwBgmJuFwop/r7NRkB0oGu0dkB6CNlUEt++azSmzsZDpMVd54fs6kkrSSkOM
         nDhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 138si500444pfa.199.2019.03.28.17.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 17:54:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 17:54:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="144783633"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 28 Mar 2019 17:54:50 -0700
Date: Thu, 28 Mar 2019 09:53:43 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 08/11] mm/hmm: mirror hugetlbfs (snapshoting, faulting
 and DMA mapping) v2
Message-ID: <20190328165343.GG31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-9-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-9-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:08AM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> HMM mirror is a device driver helpers to mirror range of virtual address.
> It means that the process jobs running on the device can access the same
> virtual address as the CPU threads of that process. This patch adds support
> for hugetlbfs mapping (ie range of virtual address that are mmap of a
> hugetlbfs).
> 
> Changes since v1:
>     - improved commit message
>     - squashed: Arnd Bergmann: fix unused variable warnings
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  include/linux/hmm.h |  29 ++++++++--
>  mm/hmm.c            | 126 +++++++++++++++++++++++++++++++++++++++-----
>  2 files changed, 138 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 13bc2c72f791..f3b919b04eda 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -181,10 +181,31 @@ struct hmm_range {
>  	const uint64_t		*values;
>  	uint64_t		default_flags;
>  	uint64_t		pfn_flags_mask;
> +	uint8_t			page_shift;
>  	uint8_t			pfn_shift;
>  	bool			valid;
>  };
>  
> +/*
> + * hmm_range_page_shift() - return the page shift for the range
> + * @range: range being queried
> + * Returns: page shift (page size = 1 << page shift) for the range
> + */
> +static inline unsigned hmm_range_page_shift(const struct hmm_range *range)
> +{
> +	return range->page_shift;
> +}
> +
> +/*
> + * hmm_range_page_size() - return the page size for the range
> + * @range: range being queried
> + * Returns: page size for the range in bytes
> + */
> +static inline unsigned long hmm_range_page_size(const struct hmm_range *range)
> +{
> +	return 1UL << hmm_range_page_shift(range);
> +}
> +
>  /*
>   * hmm_range_wait_until_valid() - wait for range to be valid
>   * @range: range affected by invalidation to wait on
> @@ -438,7 +459,7 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
>   *          struct hmm_range range;
>   *          ...
>   *
> - *          ret = hmm_range_register(&range, mm, start, end);
> + *          ret = hmm_range_register(&range, mm, start, end, page_shift);
>   *          if (ret)
>   *              return ret;
>   *
> @@ -498,7 +519,8 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
>  int hmm_range_register(struct hmm_range *range,
>  		       struct mm_struct *mm,
>  		       unsigned long start,
> -		       unsigned long end);
> +		       unsigned long end,
> +		       unsigned page_shift);
>  void hmm_range_unregister(struct hmm_range *range);
>  long hmm_range_snapshot(struct hmm_range *range);
>  long hmm_range_fault(struct hmm_range *range, bool block);
> @@ -529,7 +551,8 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  	range->pfn_flags_mask = -1UL;
>  
>  	ret = hmm_range_register(range, range->vma->vm_mm,
> -				 range->start, range->end);
> +				 range->start, range->end,
> +				 PAGE_SHIFT);
>  	if (ret)
>  		return (int)ret;
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 4fe88a196d17..64a33770813b 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -387,11 +387,13 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
>  	struct hmm_vma_walk *hmm_vma_walk = walk->private;
>  	struct hmm_range *range = hmm_vma_walk->range;
>  	uint64_t *pfns = range->pfns;
> -	unsigned long i;
> +	unsigned long i, page_size;
>  
>  	hmm_vma_walk->last = addr;
> -	i = (addr - range->start) >> PAGE_SHIFT;
> -	for (; addr < end; addr += PAGE_SIZE, i++) {
> +	page_size = 1UL << range->page_shift;

NIT: page_size = hmm_range_page_size(range);

??

Otherwise:

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> +	i = (addr - range->start) >> range->page_shift;
> +
> +	for (; addr < end; addr += page_size, i++) {
>  		pfns[i] = range->values[HMM_PFN_NONE];
>  		if (fault || write_fault) {
>  			int ret;
> @@ -703,6 +705,69 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  	return 0;
>  }
>  
> +static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
> +				      unsigned long start, unsigned long end,
> +				      struct mm_walk *walk)
> +{
> +#ifdef CONFIG_HUGETLB_PAGE
> +	unsigned long addr = start, i, pfn, mask, size, pfn_inc;
> +	struct hmm_vma_walk *hmm_vma_walk = walk->private;
> +	struct hmm_range *range = hmm_vma_walk->range;
> +	struct vm_area_struct *vma = walk->vma;
> +	struct hstate *h = hstate_vma(vma);
> +	uint64_t orig_pfn, cpu_flags;
> +	bool fault, write_fault;
> +	spinlock_t *ptl;
> +	pte_t entry;
> +	int ret = 0;
> +
> +	size = 1UL << huge_page_shift(h);
> +	mask = size - 1;
> +	if (range->page_shift != PAGE_SHIFT) {
> +		/* Make sure we are looking at full page. */
> +		if (start & mask)
> +			return -EINVAL;
> +		if (end < (start + size))
> +			return -EINVAL;
> +		pfn_inc = size >> PAGE_SHIFT;
> +	} else {
> +		pfn_inc = 1;
> +		size = PAGE_SIZE;
> +	}
> +
> +
> +	ptl = huge_pte_lock(hstate_vma(walk->vma), walk->mm, pte);
> +	entry = huge_ptep_get(pte);
> +
> +	i = (start - range->start) >> range->page_shift;
> +	orig_pfn = range->pfns[i];
> +	range->pfns[i] = range->values[HMM_PFN_NONE];
> +	cpu_flags = pte_to_hmm_pfn_flags(range, entry);
> +	fault = write_fault = false;
> +	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> +			   &fault, &write_fault);
> +	if (fault || write_fault) {
> +		ret = -ENOENT;
> +		goto unlock;
> +	}
> +
> +	pfn = pte_pfn(entry) + (start & mask);
> +	for (; addr < end; addr += size, i++, pfn += pfn_inc)
> +		range->pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> +	hmm_vma_walk->last = end;
> +
> +unlock:
> +	spin_unlock(ptl);
> +
> +	if (ret == -ENOENT)
> +		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> +
> +	return ret;
> +#else /* CONFIG_HUGETLB_PAGE */
> +	return -EINVAL;
> +#endif
> +}
> +
>  static void hmm_pfns_clear(struct hmm_range *range,
>  			   uint64_t *pfns,
>  			   unsigned long addr,
> @@ -726,6 +791,7 @@ static void hmm_pfns_special(struct hmm_range *range)
>   * @mm: the mm struct for the range of virtual address
>   * @start: start virtual address (inclusive)
>   * @end: end virtual address (exclusive)
> + * @page_shift: expect page shift for the range
>   * Returns 0 on success, -EFAULT if the address space is no longer valid
>   *
>   * Track updates to the CPU page table see include/linux/hmm.h
> @@ -733,16 +799,23 @@ static void hmm_pfns_special(struct hmm_range *range)
>  int hmm_range_register(struct hmm_range *range,
>  		       struct mm_struct *mm,
>  		       unsigned long start,
> -		       unsigned long end)
> +		       unsigned long end,
> +		       unsigned page_shift)
>  {
> -	range->start = start & PAGE_MASK;
> -	range->end = end & PAGE_MASK;
> +	unsigned long mask = ((1UL << page_shift) - 1UL);
> +
>  	range->valid = false;
>  	range->hmm = NULL;
>  
> -	if (range->start >= range->end)
> +	if ((start & mask) || (end & mask))
> +		return -EINVAL;
> +	if (start >= end)
>  		return -EINVAL;
>  
> +	range->page_shift = page_shift;
> +	range->start = start;
> +	range->end = end;
> +
>  	range->hmm = hmm_register(mm);
>  	if (!range->hmm)
>  		return -EFAULT;
> @@ -809,6 +882,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
>   */
>  long hmm_range_snapshot(struct hmm_range *range)
>  {
> +	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
>  	unsigned long start = range->start, end;
>  	struct hmm_vma_walk hmm_vma_walk;
>  	struct hmm *hmm = range->hmm;
> @@ -825,15 +899,26 @@ long hmm_range_snapshot(struct hmm_range *range)
>  			return -EAGAIN;
>  
>  		vma = find_vma(hmm->mm, start);
> -		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
> +		if (vma == NULL || (vma->vm_flags & device_vma))
>  			return -EFAULT;
>  
> -		/* FIXME support hugetlb fs/dax */
> -		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
> +		/* FIXME support dax */
> +		if (vma_is_dax(vma)) {
>  			hmm_pfns_special(range);
>  			return -EINVAL;
>  		}
>  
> +		if (is_vm_hugetlb_page(vma)) {
> +			struct hstate *h = hstate_vma(vma);
> +
> +			if (huge_page_shift(h) != range->page_shift &&
> +			    range->page_shift != PAGE_SHIFT)
> +				return -EINVAL;
> +		} else {
> +			if (range->page_shift != PAGE_SHIFT)
> +				return -EINVAL;
> +		}
> +
>  		if (!(vma->vm_flags & VM_READ)) {
>  			/*
>  			 * If vma do not allow read access, then assume that it
> @@ -859,6 +944,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>  		mm_walk.hugetlb_entry = NULL;
>  		mm_walk.pmd_entry = hmm_vma_walk_pmd;
>  		mm_walk.pte_hole = hmm_vma_walk_hole;
> +		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
>  
>  		walk_page_range(start, end, &mm_walk);
>  		start = end;
> @@ -877,7 +963,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
>   *          then one of the following values may be returned:
>   *
>   *           -EINVAL  invalid arguments or mm or virtual address are in an
> - *                    invalid vma (ie either hugetlbfs or device file vma).
> + *                    invalid vma (for instance device file vma).
>   *           -ENOMEM: Out of memory.
>   *           -EPERM:  Invalid permission (for instance asking for write and
>   *                    range is read only).
> @@ -898,6 +984,7 @@ EXPORT_SYMBOL(hmm_range_snapshot);
>   */
>  long hmm_range_fault(struct hmm_range *range, bool block)
>  {
> +	const unsigned long device_vma = VM_IO | VM_PFNMAP | VM_MIXEDMAP;
>  	unsigned long start = range->start, end;
>  	struct hmm_vma_walk hmm_vma_walk;
>  	struct hmm *hmm = range->hmm;
> @@ -917,15 +1004,25 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  		}
>  
>  		vma = find_vma(hmm->mm, start);
> -		if (vma == NULL || (vma->vm_flags & VM_SPECIAL))
> +		if (vma == NULL || (vma->vm_flags & device_vma))
>  			return -EFAULT;
>  
> -		/* FIXME support hugetlb fs/dax */
> -		if (is_vm_hugetlb_page(vma) || vma_is_dax(vma)) {
> +		/* FIXME support dax */
> +		if (vma_is_dax(vma)) {
>  			hmm_pfns_special(range);
>  			return -EINVAL;
>  		}
>  
> +		if (is_vm_hugetlb_page(vma)) {
> +			if (huge_page_shift(hstate_vma(vma)) !=
> +			    range->page_shift &&
> +			    range->page_shift != PAGE_SHIFT)
> +				return -EINVAL;
> +		} else {
> +			if (range->page_shift != PAGE_SHIFT)
> +				return -EINVAL;
> +		}
> +
>  		if (!(vma->vm_flags & VM_READ)) {
>  			/*
>  			 * If vma do not allow read access, then assume that it
> @@ -952,6 +1049,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>  		mm_walk.hugetlb_entry = NULL;
>  		mm_walk.pmd_entry = hmm_vma_walk_pmd;
>  		mm_walk.pte_hole = hmm_vma_walk_hole;
> +		mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
>  
>  		do {
>  			ret = walk_page_range(start, end, &mm_walk);
> -- 
> 2.17.2
> 

