Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB17C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:45:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBC502173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:45:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBC502173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 757226B026C; Thu, 28 Mar 2019 17:45:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7067B6B0272; Thu, 28 Mar 2019 17:45:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F6376B0275; Thu, 28 Mar 2019 17:45:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 264E76B026C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:45:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d15so125419pgt.14
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:45:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5bwzjt4gPbQm5LUVXTZS70hJ9s/CiJgh7A/KpHzv40U=;
        b=A8lnUcD55gG1CKxPi6BnIUBoTE5dCOv6Z/iEPol4n6Gq6Xy/EIaxHDsqJQsNeEv6t3
         2vW/C1hEyta2lXrVgvgPjAVwlAjOkF3a50MkV5NsY/zpHXa8shDnDAzgwt5dDaJq5Cwv
         2NBYQfPh/ZLz1eaewPL+y6EWHlkksz/MQUtp09UMMzj8H/PcrrCNTICBAcCp3sQ9NF63
         URgJdwyj64lS2/qI1HrzjYPzk0JW9Tgj4GXv/XTxiu55KHrSgJDjYG2AyErDkFI9tTaH
         UQdi3MAHH1RNSCwnExHZyF/9S76yzT9cvRsPlu1OE0I2eJFAzhEuMRZtCfo5yZ2LgCS2
         3trA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUU381xyc72iGsAox6WqIK02fGq+XcOMTRyzDvssbom+4z0jRlc
	6JW9Pejv6+p3GzI0Qdh0nAJZwg8LDc/dwEg6a8EC1/+n6mCaeMf21eUtlbo4XjrUy7idtIdYlqO
	9l44cdI9WqG5Uyj3fUlFxdbEfBBqozDQ/OzkaRVPSXpepu/G4f94RO0mlwNgk0sL23w==
X-Received: by 2002:a17:902:f302:: with SMTP id gb2mr582571plb.51.1553809500791;
        Thu, 28 Mar 2019 14:45:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHCQm7+tNoWhp4Z4r8WiQzlOMz6UVTqo/ugBt6dyLbyJkp/N4qwF1DYMAjcEB2uNPF6xV0
X-Received: by 2002:a17:902:f302:: with SMTP id gb2mr582516plb.51.1553809499933;
        Thu, 28 Mar 2019 14:44:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553809499; cv=none;
        d=google.com; s=arc-20160816;
        b=VNkY8y0bO9eoINEgznFcaayPFF94889kNHecP5V6voz4YnMu0A4kdcsowwGgNocDSh
         SKoiCVfncS44JgmzsyxxUEY2wo70h/LCCe+SSCQlIDEnQ0WkZLn2GgniaHEZQqa4W2hP
         kaV0ZdhPj68IHbqAvD0v3n9vOQypFj+VrlraI4CjzaDnEvDFrPsQd4+0Xlm9ljOzQZ7O
         NWWoPelYsVhTUZO23DC/M1TgApv96rh3TxPNoq7XRSDFwus4gXGRF4PsSldUxdAGxkD/
         thDWXbi4GpcheEpFmbew7kVtrJYNTr/Ws6/ddUB1FaK2faaAIsF/TB2ucGmDBX57JdNi
         qbkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5bwzjt4gPbQm5LUVXTZS70hJ9s/CiJgh7A/KpHzv40U=;
        b=sljPrhF/ZEktJwQ1ogKPLAEDdA9rHzGdjU4M9iLK+tFVEdWfC0GdgHdr2D4GpzKZg9
         7aXCN1D2AC1zBKEE6elF4pGItIYXp7mHfR9oLQWb2VoA+dSaogM4tChu10TdVL9Dbz0B
         1XE1OWECCNSkT1r3ZCDPvIldY53gx8o506ZuJMuXlBDMy6dtKIjICCetTDYAGZuO32aB
         HL7SPRenz2BiHXhWbE1eiPS77XDbmY4NvarNqZq+TSqwg8ilf70ySSOLwD1dk4fsywUf
         jDYUpMk/7KNBm8ydtZXlo5utetp8EftR6GQNXacLarwo/n5T8pvJga1EIaOiXV1pTegx
         UHbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id u18si127783pfm.84.2019.03.28.14.44.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:44:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 14:44:59 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="138155203"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 28 Mar 2019 14:44:58 -0700
Date: Thu, 28 Mar 2019 06:43:51 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 05/11] mm/hmm: improve and rename hmm_vma_fault() to
 hmm_range_fault() v2
Message-ID: <20190328134351.GD31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-6-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-6-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:05AM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> Rename for consistency between code, comments and documentation. Also
> improves the comments on all the possible returns values. Improve the
> function by returning the number of populated entries in pfns array.
> 
> Changes since v1:
>     - updated documentation
>     - reformated some comments
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  Documentation/vm/hmm.rst |  8 +---
>  include/linux/hmm.h      | 13 +++++-
>  mm/hmm.c                 | 91 +++++++++++++++++-----------------------
>  3 files changed, 52 insertions(+), 60 deletions(-)
> 
> diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> index d9b27bdadd1b..61f073215a8d 100644
> --- a/Documentation/vm/hmm.rst
> +++ b/Documentation/vm/hmm.rst
> @@ -190,13 +190,7 @@ When the device driver wants to populate a range of virtual addresses, it can
>  use either::
>  
>    long hmm_range_snapshot(struct hmm_range *range);
> -  int hmm_vma_fault(struct vm_area_struct *vma,
> -                    struct hmm_range *range,
> -                    unsigned long start,
> -                    unsigned long end,
> -                    hmm_pfn_t *pfns,
> -                    bool write,
> -                    bool block);
> +  long hmm_range_fault(struct hmm_range *range, bool block);
>  
>  The first one (hmm_range_snapshot()) will only fetch present CPU page table
>  entries and will not trigger a page fault on missing or non-present entries.
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 32206b0b1bfd..e9afd23c2eac 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -391,7 +391,18 @@ bool hmm_vma_range_done(struct hmm_range *range);
>   *
>   * See the function description in mm/hmm.c for further documentation.
>   */
> -int hmm_vma_fault(struct hmm_range *range, bool block);
> +long hmm_range_fault(struct hmm_range *range, bool block);
> +
> +/* This is a temporary helper to avoid merge conflict between trees. */
> +static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> +{
> +	long ret = hmm_range_fault(range, block);
> +	if (ret == -EBUSY)
> +		ret = -EAGAIN;
> +	else if (ret == -EAGAIN)
> +		ret = -EBUSY;
> +	return ret < 0 ? ret : 0;
> +}
>  
>  /* Below are for HMM internal use only! Not to be used by device driver! */
>  void hmm_mm_destroy(struct mm_struct *mm);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 91361aa74b8b..7860e63c3ba7 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -336,13 +336,13 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
>  	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
>  	ret = handle_mm_fault(vma, addr, flags);
>  	if (ret & VM_FAULT_RETRY)
> -		return -EBUSY;
> +		return -EAGAIN;
>  	if (ret & VM_FAULT_ERROR) {
>  		*pfn = range->values[HMM_PFN_ERROR];
>  		return -EFAULT;
>  	}
>  
> -	return -EAGAIN;
> +	return -EBUSY;
>  }
>  
>  static int hmm_pfns_bad(unsigned long addr,
> @@ -368,7 +368,7 @@ static int hmm_pfns_bad(unsigned long addr,
>   * @fault: should we fault or not ?
>   * @write_fault: write fault ?
>   * @walk: mm_walk structure
> - * Returns: 0 on success, -EAGAIN after page fault, or page fault error
> + * Returns: 0 on success, -EBUSY after page fault, or page fault error
>   *
>   * This function will be called whenever pmd_none() or pte_none() returns true,
>   * or whenever there is no page directory covering the virtual address range.
> @@ -391,12 +391,12 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
>  
>  			ret = hmm_vma_do_fault(walk, addr, write_fault,
>  					       &pfns[i]);
> -			if (ret != -EAGAIN)
> +			if (ret != -EBUSY)
>  				return ret;
>  		}
>  	}
>  
> -	return (fault || write_fault) ? -EAGAIN : 0;
> +	return (fault || write_fault) ? -EBUSY : 0;
>  }
>  
>  static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
> @@ -527,11 +527,11 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
>  	uint64_t orig_pfn = *pfn;
>  
>  	*pfn = range->values[HMM_PFN_NONE];
> -	cpu_flags = pte_to_hmm_pfn_flags(range, pte);
> -	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> -			   &fault, &write_fault);
> +	fault = write_fault = false;
>  
>  	if (pte_none(pte)) {
> +		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, 0,
> +				   &fault, &write_fault);

This really threw me until I applied the patches to a tree.  It looks like this
is just optimizing away a pte_none() check.  The only functional change which
was mentioned was returning the number of populated pfns.  So I spent a bit of
time trying to figure out why hmm_pte_need_fault() needed to move _here_ to do
that...  :-(

It would have been nice to have said something about optimizing in the commit
message.

>  		if (fault || write_fault)
>  			goto fault;
>  		return 0;
> @@ -570,7 +570,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
>  				hmm_vma_walk->last = addr;
>  				migration_entry_wait(vma->vm_mm,
>  						     pmdp, addr);
> -				return -EAGAIN;
> +				return -EBUSY;
>  			}
>  			return 0;
>  		}
> @@ -578,6 +578,10 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
>  		/* Report error for everything else */
>  		*pfn = range->values[HMM_PFN_ERROR];
>  		return -EFAULT;
> +	} else {
> +		cpu_flags = pte_to_hmm_pfn_flags(range, pte);
> +		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
> +				   &fault, &write_fault);

Looks like the same situation as above.

>  	}
>  
>  	if (fault || write_fault)
> @@ -628,7 +632,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  		if (fault || write_fault) {
>  			hmm_vma_walk->last = addr;
>  			pmd_migration_entry_wait(vma->vm_mm, pmdp);
> -			return -EAGAIN;
> +			return -EBUSY;

While I am at it.  Why are we swapping EAGAIN and EBUSY everywhere?

Ira

>  		}
>  		return 0;
>  	} else if (!pmd_present(pmd))
> @@ -856,53 +860,34 @@ bool hmm_vma_range_done(struct hmm_range *range)
>  EXPORT_SYMBOL(hmm_vma_range_done);
>  
>  /*
> - * hmm_vma_fault() - try to fault some address in a virtual address range
> + * hmm_range_fault() - try to fault some address in a virtual address range
>   * @range: range being faulted
>   * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
> - * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
> + * Returns: number of valid pages in range->pfns[] (from range start
> + *          address). This may be zero. If the return value is negative,
> + *          then one of the following values may be returned:
> + *
> + *           -EINVAL  invalid arguments or mm or virtual address are in an
> + *                    invalid vma (ie either hugetlbfs or device file vma).
> + *           -ENOMEM: Out of memory.
> + *           -EPERM:  Invalid permission (for instance asking for write and
> + *                    range is read only).
> + *           -EAGAIN: If you need to retry and mmap_sem was drop. This can only
> + *                    happens if block argument is false.
> + *           -EBUSY:  If the the range is being invalidated and you should wait
> + *                    for invalidation to finish.
> + *           -EFAULT: Invalid (ie either no valid vma or it is illegal to access
> + *                    that range), number of valid pages in range->pfns[] (from
> + *                    range start address).
>   *
>   * This is similar to a regular CPU page fault except that it will not trigger
> - * any memory migration if the memory being faulted is not accessible by CPUs.
> + * any memory migration if the memory being faulted is not accessible by CPUs
> + * and caller does not ask for migration.
>   *
>   * On error, for one virtual address in the range, the function will mark the
>   * corresponding HMM pfn entry with an error flag.
> - *
> - * Expected use pattern:
> - * retry:
> - *   down_read(&mm->mmap_sem);
> - *   // Find vma and address device wants to fault, initialize hmm_pfn_t
> - *   // array accordingly
> - *   ret = hmm_vma_fault(range, write, block);
> - *   switch (ret) {
> - *   case -EAGAIN:
> - *     hmm_vma_range_done(range);
> - *     // You might want to rate limit or yield to play nicely, you may
> - *     // also commit any valid pfn in the array assuming that you are
> - *     // getting true from hmm_vma_range_monitor_end()
> - *     goto retry;
> - *   case 0:
> - *     break;
> - *   case -ENOMEM:
> - *   case -EINVAL:
> - *   case -EPERM:
> - *   default:
> - *     // Handle error !
> - *     up_read(&mm->mmap_sem)
> - *     return;
> - *   }
> - *   // Take device driver lock that serialize device page table update
> - *   driver_lock_device_page_table_update();
> - *   hmm_vma_range_done(range);
> - *   // Commit pfns we got from hmm_vma_fault()
> - *   driver_unlock_device_page_table_update();
> - *   up_read(&mm->mmap_sem)
> - *
> - * YOU MUST CALL hmm_vma_range_done() AFTER THIS FUNCTION RETURN SUCCESS (0)
> - * BEFORE FREEING THE range struct OR YOU WILL HAVE SERIOUS MEMORY CORRUPTION !
> - *
> - * YOU HAVE BEEN WARNED !
>   */
> -int hmm_vma_fault(struct hmm_range *range, bool block)
> +long hmm_range_fault(struct hmm_range *range, bool block)
>  {
>  	struct vm_area_struct *vma = range->vma;
>  	unsigned long start = range->start;
> @@ -974,7 +959,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  	do {
>  		ret = walk_page_range(start, range->end, &mm_walk);
>  		start = hmm_vma_walk.last;
> -	} while (ret == -EAGAIN);
> +		/* Keep trying while the range is valid. */
> +	} while (ret == -EBUSY && range->valid);
>  
>  	if (ret) {
>  		unsigned long i;
> @@ -984,6 +970,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  			       range->end);
>  		hmm_vma_range_done(range);
>  		hmm_put(hmm);
> +		return ret;
>  	} else {
>  		/*
>  		 * Transfer hmm reference to the range struct it will be drop
> @@ -993,9 +980,9 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
>  		range->hmm = hmm;
>  	}
>  
> -	return ret;
> +	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>  }
> -EXPORT_SYMBOL(hmm_vma_fault);
> +EXPORT_SYMBOL(hmm_range_fault);
>  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>  
>  
> -- 
> 2.17.2
> 

