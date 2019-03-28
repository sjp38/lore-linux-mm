Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97CF0C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 479E12173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 02:05:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 479E12173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED8B86B000D; Thu, 28 Mar 2019 22:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E87A96B000E; Thu, 28 Mar 2019 22:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D759C6B0010; Thu, 28 Mar 2019 22:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A01B06B000D
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 22:05:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 33so536683pgv.17
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=npeFvWz1UKVM4wlSOd5g612PH6kgpRLjs4ih0B9n87s=;
        b=RVg1di8QFoyzppE/2Y62CLoKlPcChZaYKZB2mI2MVbjf2RT4MTS/6z06vY4I5PyDXD
         35hK1EGZPfVaoMQhGdGFynJPenZwolXq1xlJhfDcz5kDHeSBJGNaND4e2h36P1Lv3kTs
         tP6ZKPJVmuMtYQTRB5t/jF3epI60Ry+sMoJXRRZ5VGbTsZRa17nGJ053VOi/Ax8Ht8tn
         7Ekk6kIenUZ8JtTUk56aMeRIMkTZEoPcGZJ6TYytJSwqsPdfER+OLjWdqWHIgv6prLco
         PUacA4oQFYAnOK5yBRcgA7dKCHVWIwmYkalkQqzCz3HMuKSl25d3wQHxjs5hByz7SehN
         LnXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX72AMMCj8nG5HOsmxWQOCLg2Yd9f9FY/5XD0RMQ6BrQQuyVOkO
	wmgQl40wfqZc19dCNuS0TPmoFMgevjBOsNwwDia2qiZb1jkCmjotF0hfhtaNYZgOlW6JHBBGvHN
	fIuRVTmA+Ace4DzlElgwlJbQFq+zzIOIoVXXVXtKqbp0h4laLFuVMSKwkMo1ZRHhoIQ==
X-Received: by 2002:a17:902:bb0d:: with SMTP id l13mr11127692pls.141.1553825134320;
        Thu, 28 Mar 2019 19:05:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRHTh1SGO4Io5YX/Z8vN2DWuF0wChLRg/I1H5E4y46qeQvHf6urfz2iqz9t6IvGN2zJA+N
X-Received: by 2002:a17:902:bb0d:: with SMTP id l13mr11127644pls.141.1553825133605;
        Thu, 28 Mar 2019 19:05:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553825133; cv=none;
        d=google.com; s=arc-20160816;
        b=iIZXMZoNNZFwTSAWFJRfUKKRiVtNE/LOwK2Szw6i0txCiQ/ZZBkHLOU0/Kh7L5izKy
         WCu+OA9RF+74R9js03W0h763tJiEczObIVpL+qyv4UDDTUqeaPylS0geYYnr1Hq0EDlb
         m9FhAotq4UsXDRL3he1qUjzY/f0OaeG5pN1Lps05XlzoHpoHKIbeLBc+0n6P6TubkfTW
         5v5QGGxYATb7bOaaNWIacTVARv4iYZ9CsxCEOBE+Y9lpeuxjDzVehCUJ9Rbg7A0BdnJd
         5nNWTRyjXBlGeLF9lVLzYujaBZpoDKPkmkuY2vWoXOU3rtJals25oPOHcpvve2y/K/pb
         kKog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=npeFvWz1UKVM4wlSOd5g612PH6kgpRLjs4ih0B9n87s=;
        b=wOq1ntwHjNW0Z0Oe3/Nv/rUEix68au/GcTPZE8LXjmNYK7GEsTeM6s6R9PStJUDNsk
         8RA9MRngJ7eEmzToPYTxMStmrGJIyb16T+rQhrmhRbfGZNJUyB+t+jJ4SjnFrNqTC4ni
         W1Ht0vje0MScFDxz2cZqWarV0YrqqpvLJgJP3ze1eowv2kqqzknO7HJZexapRbKtxAnq
         pr9+8EJKdMa3p4rLHaaQ6FxOruDMlTfjE/Qui2Soayt5OVXiyEiF5mVbvkjqtjwOykaF
         O9EZiZ7c4MquPRLHVEvW5Wf2QYyF1agVp7BMmoyiuQVwgrIh609S8hvJm0llSBL7YWYB
         TTGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 140si667913pga.460.2019.03.28.19.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 19:05:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 19:05:32 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="138333451"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 28 Mar 2019 19:05:32 -0700
Date: Thu, 28 Mar 2019 11:04:26 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 09/11] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem v2
Message-ID: <20190328180425.GI31324@iweiny-DESK2.sc.intel.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-10-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190325144011.10560-10-jglisse@redhat.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 10:40:09AM -0400, Jerome Glisse wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> HMM mirror is a device driver helpers to mirror range of virtual address.
> It means that the process jobs running on the device can access the same
> virtual address as the CPU threads of that process. This patch adds support
> for mirroring mapping of file that are on a DAX block device (ie range of
> virtual address that is an mmap of a file in a filesystem on a DAX block
> device). There is no reason to not support such case when mirroring virtual
> address on a device.
> 
> Note that unlike GUP code we do not take page reference hence when we
> back-off we have nothing to undo.
> 
> Changes since v1:
>     - improved commit message
>     - squashed: Arnd Bergmann: fix unused variable warning in hmm_vma_walk_pud
> 
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/hmm.c | 132 ++++++++++++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 111 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 64a33770813b..ce33151c6832 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -325,6 +325,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
>  
>  struct hmm_vma_walk {
>  	struct hmm_range	*range;
> +	struct dev_pagemap	*pgmap;
>  	unsigned long		last;
>  	bool			fault;
>  	bool			block;
> @@ -499,6 +500,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
>  				range->flags[HMM_PFN_VALID];
>  }
>  
> +static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
> +{
> +	if (!pud_present(pud))
> +		return 0;
> +	return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
> +				range->flags[HMM_PFN_WRITE] :
> +				range->flags[HMM_PFN_VALID];
> +}
> +
>  static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  			      unsigned long addr,
>  			      unsigned long end,
> @@ -520,8 +530,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  		return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
>  
>  	pfn = pmd_pfn(pmd) + pte_index(addr);
> -	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
> +	for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
> +		if (pmd_devmap(pmd)) {
> +			hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
> +					      hmm_vma_walk->pgmap);
> +			if (unlikely(!hmm_vma_walk->pgmap))
> +				return -EBUSY;
> +		}
>  		pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> +	}
> +	if (hmm_vma_walk->pgmap) {
> +		put_dev_pagemap(hmm_vma_walk->pgmap);
> +		hmm_vma_walk->pgmap = NULL;
> +	}
>  	hmm_vma_walk->last = end;
>  	return 0;
>  }
> @@ -608,10 +629,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
>  	if (fault || write_fault)
>  		goto fault;
>  
> +	if (pte_devmap(pte)) {
> +		hmm_vma_walk->pgmap = get_dev_pagemap(pte_pfn(pte),
> +					      hmm_vma_walk->pgmap);
> +		if (unlikely(!hmm_vma_walk->pgmap))
> +			return -EBUSY;
> +	} else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte)) {
> +		*pfn = range->values[HMM_PFN_SPECIAL];
> +		return -EFAULT;
> +	}
> +
>  	*pfn = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;

	<tag>

>  	return 0;
>  
>  fault:
> +	if (hmm_vma_walk->pgmap) {
> +		put_dev_pagemap(hmm_vma_walk->pgmap);
> +		hmm_vma_walk->pgmap = NULL;
> +	}
>  	pte_unmap(ptep);
>  	/* Fault any virtual address we were asked to fault */
>  	return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> @@ -699,12 +734,83 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
>  			return r;
>  		}
>  	}
> +	if (hmm_vma_walk->pgmap) {
> +		put_dev_pagemap(hmm_vma_walk->pgmap);
> +		hmm_vma_walk->pgmap = NULL;
> +	}


Why is this here and not in hmm_vma_handle_pte()?  Unless I'm just getting
tired this is the corresponding put when hmm_vma_handle_pte() returns 0 above
at <tag> above.

Ira

