Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1C8FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:31:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6036B2184C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:31:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6036B2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16C506B0292; Thu, 28 Mar 2019 17:31:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11F1E6B0293; Thu, 28 Mar 2019 17:31:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02776B0294; Thu, 28 Mar 2019 17:31:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B14F46B0292
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:31:25 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v5so173069plo.4
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:31:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+CUkkRBrVqylgu0JTQsmVvIhVll3rWac3wUQrbGBBNU=;
        b=MG4WxwVrWAvm7cClBkoGN5SpE396TCC9NwNfgcySVk6cJS7GwKGn4ivmQANZIoUfE5
         GzqNtbBknnW8TME2pBWJfLsu1kCvtlpmwF5JIHvMDX67tjoMM//4Jqefyi8/1tSjshO1
         RhDDoYNF4YxNSZiKr37ztxXCdaQ16OKTHezJabT1D1g9GJHtkh/qYUwTGNRt+5iQI6vk
         bpZ6TximB8tN8JbhOHGGYmub0dIi/Q6uSZRLnkFRXf30vb8dI4v5BJGbq6fJWBA1Q+AR
         B8jGRVkmdNr7ywiR5IbAvNXCUBwOW17eAug22oRhjNZzaZ80ya48/RtwfWsiFz/wDd0/
         DwqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX3S6R0Fd6ibjcA0WxCzc/m28NBER2LFQDE09VMCN+M1viyW7cD
	PwX+rf+T5ud8zIxW3Z1dQ/Ue8ntmXfTgmDdrAPsro2dfPfgKgrWFOVqmE88RhuvKZvng9HvjwY1
	ejhFykkZgV1e+vn77INMFc7Tujo4UaCVgzJy4XFjMKMVOcYL9ZUNQgdT0ViAac8qDWw==
X-Received: by 2002:a17:902:8a4:: with SMTP id 33mr43907230pll.7.1553808685324;
        Thu, 28 Mar 2019 14:31:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8dO+MHKrZRhB4YEF+sNnrMmLyvzz0my3+Ef+Y13qhattGRCy5lL+la0Mvkijxqh9pcYMu
X-Received: by 2002:a17:902:8a4:: with SMTP id 33mr43907163pll.7.1553808684487;
        Thu, 28 Mar 2019 14:31:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553808684; cv=none;
        d=google.com; s=arc-20160816;
        b=ivbyWjvrE+wa7Z6jvJB6J8S0m7YQ//Loa2Y2TQnVDYUGyoHvnbZLsbkLUUWNEQMAgG
         mWbIf9Wm/5MD9SAPC3QmIFvCybaO/XY1fFKnKxlgJ1PbNHBJP6b6BLzlONPoAp2InYnV
         tFMbQYsYZgEvq+OIgG4Q+vWUba2MIqFZ9/oJy5G7/oybKDEhAH/JXUsnjuZ7jG6uXlY2
         Mj6RNoyQ4/ZU+l3/FNBhpE3IpOh/hlbvtumTJsBNllYm/dFtTAYD9Vc8yhi+LAA1KKwM
         th1Z/edhIcnFD0AEIch3drn0E2jY/C68lf7LPOTMhgC3fcP7kMFGBdxUJukaOhURBkXu
         pCvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=+CUkkRBrVqylgu0JTQsmVvIhVll3rWac3wUQrbGBBNU=;
        b=P/R9zJ2vZ44ctn+ujsHJ1HTFMaA04y5FoTWpZGa2jRwPMTE/3kb28JK3OzPC9tQj/i
         BY8REA7OveMFHgSRmp+hv17Nndwe0b8sGWk4G6ZV7LhnxkhTwx3iDSJzHYUqArUnizm3
         GAqHWg4J77hdh3qGPGVRUqK4NRneJZASCTVofIbXpptcioU5jDqZ1cnM7V+rtZPeWkf3
         0ghRAMi4zIsU5NZ1x1D1a0uYgpZ8XZdRCcAuxx2V6Q0bl+F9vkyHmNPAhH7HqC7/aN0s
         SL4Qc+V4cbNGcfSHmMAJMIERxHqzl/PslBGiwYqC+c+5W1pw62aCY9BLADdrGrBiPyBq
         CQlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id k17si185254pls.66.2019.03.28.14.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:31:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 14:31:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="331663600"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga006.fm.intel.com with ESMTP; 28 Mar 2019 14:31:19 -0700
Date: Thu, 28 Mar 2019 06:30:12 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 04/11] mm/hmm: improve and rename hmm_vma_get_pfns()
 to hmm_range_snapshot() v2
Message-ID: <20190328133012.GC31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-5-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-5-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:04AM -0400, Jerome Glisse wrote:
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
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  Documentation/vm/hmm.rst | 26 ++++++++++++++++++--------
>  include/linux/hmm.h      |  4 ++--
>  mm/hmm.c                 | 31 +++++++++++++++++--------------
>  3 files changed, 37 insertions(+), 24 deletions(-)
> 
> diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> index 44205f0b671f..d9b27bdadd1b 100644
> --- a/Documentation/vm/hmm.rst
> +++ b/Documentation/vm/hmm.rst
> @@ -189,11 +189,7 @@ the driver callback returns.
>  When the device driver wants to populate a range of virtual addresses, it can
>  use either::
>  
> -  int hmm_vma_get_pfns(struct vm_area_struct *vma,
> -                      struct hmm_range *range,
> -                      unsigned long start,
> -                      unsigned long end,
> -                      hmm_pfn_t *pfns);
> +  long hmm_range_snapshot(struct hmm_range *range);
>    int hmm_vma_fault(struct vm_area_struct *vma,
>                      struct hmm_range *range,
>                      unsigned long start,
> @@ -202,7 +198,7 @@ When the device driver wants to populate a range of virtual addresses, it can
>                      bool write,
>                      bool block);
>  
> -The first one (hmm_vma_get_pfns()) will only fetch present CPU page table
> +The first one (hmm_range_snapshot()) will only fetch present CPU page table
>  entries and will not trigger a page fault on missing or non-present entries.
>  The second one does trigger a page fault on missing or read-only entry if the
>  write parameter is true. Page faults use the generic mm page fault code path
> @@ -220,19 +216,33 @@ Locking with the update() callback is the most important aspect the driver must
>   {
>        struct hmm_range range;
>        ...
> +
> +      range.start = ...;
> +      range.end = ...;
> +      range.pfns = ...;
> +      range.flags = ...;
> +      range.values = ...;
> +      range.pfn_shift = ...;
> +
>   again:
> -      ret = hmm_vma_get_pfns(vma, &range, start, end, pfns);
> -      if (ret)
> +      down_read(&mm->mmap_sem);
> +      range.vma = ...;
> +      ret = hmm_range_snapshot(&range);
> +      if (ret) {
> +          up_read(&mm->mmap_sem);
>            return ret;
> +      }
>        take_lock(driver->update);
>        if (!hmm_vma_range_done(vma, &range)) {
>            release_lock(driver->update);
> +          up_read(&mm->mmap_sem);
>            goto again;
>        }
>  
>        // Use pfns array content to update device page table
>  
>        release_lock(driver->update);
> +      up_read(&mm->mmap_sem);
>        return 0;
>   }
>  
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 716fc61fa6d4..32206b0b1bfd 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -365,11 +365,11 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
>   * table invalidation serializes on it.
>   *
>   * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
> - * hmm_vma_get_pfns() WITHOUT ERROR !
> + * hmm_range_snapshot() WITHOUT ERROR !
>   *
>   * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
>   */
> -int hmm_vma_get_pfns(struct hmm_range *range);
> +long hmm_range_snapshot(struct hmm_range *range);
>  bool hmm_vma_range_done(struct hmm_range *range);
>  
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 213b0beee8d3..91361aa74b8b 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -698,23 +698,25 @@ static void hmm_pfns_special(struct hmm_range *range)
>  }
>  
>  /*
> - * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
> - * @range: range being snapshotted
> - * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
> - *          vma permission, 0 success
> + * hmm_range_snapshot() - snapshot CPU page table for a range
> + * @range: range
> + * Returns: number of valid pages in range->pfns[] (from range start
> + *          address). This may be zero. If the return value is negative,
> + *          then one of the following values may be returned:
> + *
> + *           -EINVAL  invalid arguments or mm or virtual address are in an
> + *                    invalid vma (ie either hugetlbfs or device file vma).
> + *           -EPERM   For example, asking for write, when the range is
> + *                    read-only
> + *           -EAGAIN  Caller needs to retry
> + *           -EFAULT  Either no valid vma exists for this range, or it is
> + *                    illegal to access the range
>   *
>   * This snapshots the CPU page table for a range of virtual addresses. Snapshot
>   * validity is tracked by range struct. See hmm_vma_range_done() for further
>   * information.
> - *
> - * The range struct is initialized here. It tracks the CPU page table, but only
> - * if the function returns success (0), in which case the caller must then call
> - * hmm_vma_range_done() to stop CPU page table update tracking on this range.
> - *
> - * NOT CALLING hmm_vma_range_done() IF FUNCTION RETURNS 0 WILL LEAD TO SERIOUS
> - * MEMORY CORRUPTION ! YOU HAVE BEEN WARNED !
>   */
> -int hmm_vma_get_pfns(struct hmm_range *range)
> +long hmm_range_snapshot(struct hmm_range *range)
>  {
>  	struct vm_area_struct *vma = range->vma;
>  	struct hmm_vma_walk hmm_vma_walk;
> @@ -768,6 +770,7 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	hmm_vma_walk.fault = false;
>  	hmm_vma_walk.range = range;
>  	mm_walk.private = &hmm_vma_walk;
> +	hmm_vma_walk.last = range->start;
>  
>  	mm_walk.vma = vma;
>  	mm_walk.mm = vma->vm_mm;
> @@ -784,9 +787,9 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	 * function return 0).
>  	 */
>  	range->hmm = hmm;
> -	return 0;
> +	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>  }
> -EXPORT_SYMBOL(hmm_vma_get_pfns);
> +EXPORT_SYMBOL(hmm_range_snapshot);
>  
>  /*
>   * hmm_vma_range_done() - stop tracking change to CPU page table over a range
> -- 
> 2.17.2
> 

