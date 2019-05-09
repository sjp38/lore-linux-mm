Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8215DC04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:32:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30C2E2177E
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 19:32:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30C2E2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CF0F6B0003; Thu,  9 May 2019 15:32:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 980966B0006; Thu,  9 May 2019 15:32:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 847266B0007; Thu,  9 May 2019 15:32:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 35ABC6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 15:32:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p14so2262232edc.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 12:32:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7y4z8bpKG/Cce8JVQIP7uMPttJ3Qh3TlIsnFT09bpXI=;
        b=jsC27vEsq80MLQH6y7Wt8YbMCEniT5NihdMyapwyoTd0gk4TAVfj37/+K6hHRpxS3K
         CJQMLewRajNJ4Qidmd4vk7J9pK/NyDhJguBYkuSdFTqS9yt373I4tctQjCtYI1IUuvlo
         xVRL03D3xMHiZE5u7smNgkhbYF74VX776kAJ73fdWEpHXCd17uECZ1lNceF5GMTjoMUK
         2LAhjqYeO/TJp0e+eKXYG0ZU2RivwfJ5HXTmC4CLUCMZAnIOF3LbV/b+FZYBEn0/DV6T
         s5TBf6uQT+0pxM/qNPPYsD2Mm+HacGnwA8J1foEnbPjLz+Pgwf+cYwlDPICVUKBnzS49
         r10A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXDL7BWFuT0XUM0BTA0DW/MYVW6AwVXzoHjoOMfMQQIxqEwDNkD
	VY+zTGxJJIuNGMsQokDazjQ5JptLKxLt3uCp4d+gOxHez/k+1a+zpBG8khFfzTRLw9zrXZDKm6r
	L549V4VBYR55lWNr1rhEFDY0Phw9wcVK9Mxl7DjKZOLR9jeip6GAB7slVDmslAHxHAA==
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr4915487ejb.45.1557430344677;
        Thu, 09 May 2019 12:32:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw80LeqMdLAb7S1MQ8FM/TwIpGtqpr5yqgQXbO6Kn55pdkzL7nDaZthcGJ9XQvePwDhtBzC
X-Received: by 2002:a17:906:e2c2:: with SMTP id gr2mr4915428ejb.45.1557430343434;
        Thu, 09 May 2019 12:32:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557430343; cv=none;
        d=google.com; s=arc-20160816;
        b=LRFY2EIIjeDLul66I8Smfp5woyHyGc7DpM6Qw1vPTNZHPQT07PN6yoKJ9mq500wAHG
         JBZrPjr10SofLZtThiMm3xwdIZKByGXSbF6KbPnbLDP1VX0qUrl3rlLhXz2ClL5zDH0A
         gzPqHD/ElepJhHFLWAt8JRv4IrJIlpGWF2OO/v3CiE4cdfC74T0u7tlSCcJIRXQ6qeXj
         Ydcxjr1C1nhPqtIy+1XJrZsXa7aeQwgeWj7avKMzS4RP2Js7nqwAHP6uc8YlNIi0EGcQ
         7S4rNInU9etDmif9/LpFBKo6ziQP8K3LRfYD/gJRwax6PFY666UiCmDgEeQtJRAKUFD8
         Qrcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7y4z8bpKG/Cce8JVQIP7uMPttJ3Qh3TlIsnFT09bpXI=;
        b=XfI3VRS1i3gTZZvXpGEkl9R+FYMz7rsZTWirpFzRpCCUTwySl5kooc0CdXGWpphDiE
         ZC2K0EFHFa2roGA2SDpWHvtdM4b7kDg8J99TOQ6vz/II2oCD6lcUveoTOPhC7ZrMrx9c
         kT4507Yot29PvpjleALSarV6/6hUjAu+dVHgFeSGK3HAWeN11IKEa4gH+HWjBR4HUoBF
         EpmVEMDjI+RewPyQ4/anTy7FRSqrR9AWp8UhnvTFrGigEuU6z2iyMQoiDS8c80f80Mb/
         /g5hYl6gmlvxs9e5fgOvHfq2IW6p66C0nMP11Iw7/fUeSQ9PZz5pFX3v0eJaJkyODkWU
         1+IA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x7si2237441edx.116.2019.05.09.12.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 12:32:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A7E6BAE16;
	Thu,  9 May 2019 19:32:22 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id ED4D81E3C7F; Thu,  9 May 2019 21:32:19 +0200 (CEST)
Date: Thu, 9 May 2019 21:32:19 +0200
From: Jan Kara <jack@suse.cz>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, stable@vger.kernel.org,
	Piotr Balcer <piotr.balcer@intel.com>, Yan Ma <yan.ma@intel.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Chandan Rajendra <chandan@linux.ibm.com>, Jan Kara <jack@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] mm/huge_memory: Fix vmf_insert_pfn_{pmd, pud}() crash,
 handle unaligned addresses
Message-ID: <20190509193219.GH23589@quack2.suse.cz>
References: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155741946350.372037.11148198430068238140.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 09-05-19 09:31:41, Dan Williams wrote:
> Starting with commit c6f3c5ee40c1 "mm/huge_memory.c: fix modifying of
> page protection by insert_pfn_pmd()" vmf_insert_pfn_pmd() internally
> calls pmdp_set_access_flags(). That helper enforces a pmd aligned
> @address argument via VM_BUG_ON() assertion.
> 
> Update the implementation to take a 'struct vm_fault' argument directly
> and apply the address alignment fixup internally to fix crash signatures
> like:
> 
>     kernel BUG at arch/x86/mm/pgtable.c:515!
>     invalid opcode: 0000 [#1] SMP NOPTI
>     CPU: 51 PID: 43713 Comm: java Tainted: G           OE     4.19.35 #1
>     [..]
>     RIP: 0010:pmdp_set_access_flags+0x48/0x50
>     [..]
>     Call Trace:
>      vmf_insert_pfn_pmd+0x198/0x350
>      dax_iomap_fault+0xe82/0x1190
>      ext4_dax_huge_fault+0x103/0x1f0
>      ? __switch_to_asm+0x40/0x70
>      __handle_mm_fault+0x3f6/0x1370
>      ? __switch_to_asm+0x34/0x70
>      ? __switch_to_asm+0x40/0x70
>      handle_mm_fault+0xda/0x200
>      __do_page_fault+0x249/0x4f0
>      do_page_fault+0x32/0x110
>      ? page_fault+0x8/0x30
>      page_fault+0x1e/0x30
> 
> Cc: <stable@vger.kernel.org>
> Fixes: c6f3c5ee40c1 ("mm/huge_memory.c: fix modifying of page protection by insert_pfn_pmd()")
> Reported-by: Piotr Balcer <piotr.balcer@intel.com>
> Tested-by: Yan Ma <yan.ma@intel.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Cc: Chandan Rajendra <chandan@linux.ibm.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Looks good to me. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> 
>  drivers/dax/device.c    |    6 ++----
>  fs/dax.c                |    6 ++----
>  include/linux/huge_mm.h |    6 ++----
>  mm/huge_memory.c        |   16 ++++++++++------
>  4 files changed, 16 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e428468ab661..996d68ff992a 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -184,8 +184,7 @@ static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
>  
>  	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>  
> -	return vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd, *pfn,
> -			vmf->flags & FAULT_FLAG_WRITE);
> +	return vmf_insert_pfn_pmd(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);
>  }
>  
>  #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
> @@ -235,8 +234,7 @@ static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
>  
>  	*pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
>  
> -	return vmf_insert_pfn_pud(vmf->vma, vmf->address, vmf->pud, *pfn,
> -			vmf->flags & FAULT_FLAG_WRITE);
> +	return vmf_insert_pfn_pud(vmf, *pfn, vmf->flags & FAULT_FLAG_WRITE);
>  }
>  #else
>  static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
> diff --git a/fs/dax.c b/fs/dax.c
> index e5e54da1715f..83009875308c 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1575,8 +1575,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct vm_fault *vmf, pfn_t *pfnp,
>  		}
>  
>  		trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> -		result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> -					    write);
> +		result = vmf_insert_pfn_pmd(vmf, pfn, write);
>  		break;
>  	case IOMAP_UNWRITTEN:
>  	case IOMAP_HOLE:
> @@ -1686,8 +1685,7 @@ dax_insert_pfn_mkwrite(struct vm_fault *vmf, pfn_t pfn, unsigned int order)
>  		ret = vmf_insert_mixed_mkwrite(vmf->vma, vmf->address, pfn);
>  #ifdef CONFIG_FS_DAX_PMD
>  	else if (order == PMD_ORDER)
> -		ret = vmf_insert_pfn_pmd(vmf->vma, vmf->address, vmf->pmd,
> -			pfn, true);
> +		ret = vmf_insert_pfn_pmd(vmf, pfn, FAULT_FLAG_WRITE);
>  #endif
>  	else
>  		ret = VM_FAULT_FALLBACK;
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 381e872bfde0..7cd5c150c21d 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -47,10 +47,8 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, pgprot_t newprot,
>  			int prot_numa);
> -vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> -			pmd_t *pmd, pfn_t pfn, bool write);
> -vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> -			pud_t *pud, pfn_t pfn, bool write);
> +vm_fault_t vmf_insert_pfn_pmd(struct vm_fault *vmf, pfn_t pfn, bool write);
> +vm_fault_t vmf_insert_pfn_pud(struct vm_fault *vmf, pfn_t pfn, bool write);
>  enum transparent_hugepage_flag {
>  	TRANSPARENT_HUGEPAGE_FLAG,
>  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46bf149..4310c6e9e5a3 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -793,11 +793,13 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  		pte_free(mm, pgtable);
>  }
>  
> -vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
> -			pmd_t *pmd, pfn_t pfn, bool write)
> +vm_fault_t vmf_insert_pfn_pmd(struct vm_fault *vmf, pfn_t pfn, bool write)
>  {
> +	unsigned long addr = vmf->address & PMD_MASK;
> +	struct vm_area_struct *vma = vmf->vma;
>  	pgprot_t pgprot = vma->vm_page_prot;
>  	pgtable_t pgtable = NULL;
> +
>  	/*
>  	 * If we had pmd_special, we could avoid all these restrictions,
>  	 * but we need to be consistent with PTEs and architectures that
> @@ -820,7 +822,7 @@ vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  
>  	track_pfn_insert(vma, &pgprot, pfn);
>  
> -	insert_pfn_pmd(vma, addr, pmd, pfn, pgprot, write, pgtable);
> +	insert_pfn_pmd(vma, addr, vmf->pmd, pfn, pgprot, write, pgtable);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(vmf_insert_pfn_pmd);
> @@ -869,10 +871,12 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  	spin_unlock(ptl);
>  }
>  
> -vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> -			pud_t *pud, pfn_t pfn, bool write)
> +vm_fault_t vmf_insert_pfn_pud(struct vm_fault *vmf, pfn_t pfn, bool write)
>  {
> +	unsigned long addr = vmf->address & PUD_MASK;
> +	struct vm_area_struct *vma = vmf->vma;
>  	pgprot_t pgprot = vma->vm_page_prot;
> +
>  	/*
>  	 * If we had pud_special, we could avoid all these restrictions,
>  	 * but we need to be consistent with PTEs and architectures that
> @@ -889,7 +893,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  
>  	track_pfn_insert(vma, &pgprot, pfn);
>  
> -	insert_pfn_pud(vma, addr, pud, pfn, pgprot, write);
> +	insert_pfn_pud(vma, addr, vmf->pud, pfn, pgprot, write);
>  	return VM_FAULT_NOPAGE;
>  }
>  EXPORT_SYMBOL_GPL(vmf_insert_pfn_pud);
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

