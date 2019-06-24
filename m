Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24399C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:47:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B926D20652
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 12:47:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="a2aeOwwq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B926D20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 513056B0003; Mon, 24 Jun 2019 08:47:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C2FE8E0003; Mon, 24 Jun 2019 08:47:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 365038E0002; Mon, 24 Jun 2019 08:47:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC1EE6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:47:43 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so20364020eda.2
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 05:47:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5R1XuJC9DE2YVjPQXPWriy0pxsYFqY6xXdBGHnrUnJs=;
        b=ZmAtyFIpGo93WE8+tkxnbKp9l++s8vTkIgfCntfyR44h5G37R69t0Foys6Q0aXl3P8
         ROg14sX7ui4x50/51bgUlTERezWimq04Kcwssu8ubmra0/28xivl8itbNHICpuEt+NlX
         pNLMEQVbka+eknGp1L0AItHCOPSm79KduTkRKS5nDO/N6RsgFa/VgvVIOTdHq0HDYzcn
         0rvr29aPFVRKTJn+b7NvP3MjFzVdEPWF92mLyazijv/EK44vPx7dTCeBpsB0MdCBiJ7G
         zUFevp9TL3zFA42cF3vldpBoNG8ZeNkVYUrKKUhNmVsgPiD2mZFeRDFBSK+3nzXrKYpc
         eD4Q==
X-Gm-Message-State: APjAAAUnuMznbiBeNqTQ1TTXmXIV89kQ8E2G8aS1+IMhqFinstyHAhXN
	30RKlDltkpTLzJ5OC4I3PuHpLG1VrEpGQoLOvNRghgsjGipvEo+WpJVdm5GWxGBdpuxW/07Ijjx
	kOc1bKpVc5KyI3lnrXiPi74ma/qjdTBM5v8CPYQ1iwXpnQdzNYvYB0MA2pzDvHlpUHQ==
X-Received: by 2002:a17:906:944f:: with SMTP id z15mr19424982ejx.137.1561380463424;
        Mon, 24 Jun 2019 05:47:43 -0700 (PDT)
X-Received: by 2002:a17:906:944f:: with SMTP id z15mr19424931ejx.137.1561380462538;
        Mon, 24 Jun 2019 05:47:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561380462; cv=none;
        d=google.com; s=arc-20160816;
        b=diN63dgpAfU8BNAqOCueH6hZtB1dQ0jK6Al6naBWqKM4YvB+n5X3e3tcMIcX1fBE4h
         OvDoux7WMwM4iF4PpGJ7K7szKCy7VNgBhErblnndiWu3j9Jd6UUJZZH1MT5xvJ48a/Wl
         AgCF2HlkF3H02LWjjS3IB7KfXZCsd+l0EXUZORLSj9UvdKaBeAZHTUJo2EdSMxeO+kGT
         3LimPm32yIkTb+hzpWev/BzJ6HLi5spT/8uStJvtXdB6SVyd0Xwr7OcmozSFYFTwGTER
         JZPWLa5HPh+DpbOeynANHbsDLU1uih5pkGbdbS3nmOkaV58p/y0YM+XW/A/pUerPN91t
         F5Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5R1XuJC9DE2YVjPQXPWriy0pxsYFqY6xXdBGHnrUnJs=;
        b=Ci4UbSif33CNwNIQUjn7IlHpgjIRSWmrdUrm/F4pzjCKiGtNbJiaHctxHGKO3x6oUT
         0usZyTxb7mgW3NPRywv5W0HGpWh7yUX5PE5QPuLN0dkV67HoI8flkaCm9fDxbDXyb4e7
         HCbj+jF1aONKnKgjljk316759hGk3mGYYGFufyZibSDMeZpEXCYh5OiK+MMFd92bYyJD
         CilQZ1VstZNLpdcNn/2KVKfun6yudK1KX6SewDMImAMjCQCXXl674UVmLLZSjmjHJxUE
         pDUMlrWdTEUQ/MOhQbkeTdZTRzTmld6s+n+90wvqf4WDHfEARRJLXI8wnaZa7umv2dPs
         6srQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=a2aeOwwq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cw2sor3311897ejb.24.2019.06.24.05.47.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 05:47:42 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=a2aeOwwq;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5R1XuJC9DE2YVjPQXPWriy0pxsYFqY6xXdBGHnrUnJs=;
        b=a2aeOwwqRc9sdanvz4ex1HZ3aDnbv42+RPlV99fm907NTH5b2ydB4YRrV8RXAsEsrg
         ZktJtepV3h00JBNvjW79HzJUAmHQOEibl375GFp3YLKds2zjIP2HuW0/fuhRBybWokZ5
         xOTpPtThyzge4iQ3ia1LpIffvCMUCkyjG01tU2HRseOpLuubnP3MlMoIMGwL6/EJJ4nX
         +GxOr+mOTru/UXDm0fZPauhHI2X/LF+35LNRW5E4b44TtqnOHeV1RUqSfAedXTcD1hFG
         6PVQaIJTnIbsXo1yxe6hHrj0L5DRk8ZnZtBXYVhaqEBEdPPH/Ym081LI3qjegmyeYuqD
         NSZg==
X-Google-Smtp-Source: APXvYqw6YlhAC3oIiA9s+aVARSckup/URDhBj1oaqoxAsYqXrJAtuunouiuEqz7c66HAgftkpi/aGg==
X-Received: by 2002:a17:907:2114:: with SMTP id qn20mr112521670ejb.138.1561380462147;
        Mon, 24 Jun 2019 05:47:42 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f7sm3884261edb.12.2019.06.24.05.47.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 05:47:41 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id D1CEA10439E; Mon, 24 Jun 2019 15:47:46 +0300 (+03)
Date: Mon, 24 Jun 2019 15:47:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	hdanton@sina.com
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190624124746.7evd2hmbn3qg3tfs@box>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-6-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190623054749.4016638-6-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 22, 2019 at 10:47:48PM -0700, Song Liu wrote:
> This patch is (hopefully) the first step to enable THP for non-shmem
> filesystems.
> 
> This patch enables an application to put part of its text sections to THP
> via madvise, for example:
> 
>     madvise((void *)0x600000, 0x200000, MADV_HUGEPAGE);
> 
> We tried to reuse the logic for THP on tmpfs.
> 
> Currently, write is not supported for non-shmem THP. khugepaged will only
> process vma with VM_DENYWRITE. The next patch will handle writes, which
> would only happen when the vma with VM_DENYWRITE is unmapped.
> 
> An EXPERIMENTAL config, READ_ONLY_THP_FOR_FS, is added to gate this
> feature.
> 
> Acked-by: Rik van Riel <riel@surriel.com>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  mm/Kconfig      | 11 ++++++
>  mm/filemap.c    |  4 +--
>  mm/khugepaged.c | 90 ++++++++++++++++++++++++++++++++++++++++---------
>  mm/rmap.c       | 12 ++++---
>  4 files changed, 96 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..0a8fd589406d 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -762,6 +762,17 @@ config GUP_BENCHMARK
>  
>  	  See tools/testing/selftests/vm/gup_benchmark.c
>  
> +config READ_ONLY_THP_FOR_FS
> +	bool "Read-only THP for filesystems (EXPERIMENTAL)"
> +	depends on TRANSPARENT_HUGE_PAGECACHE && SHMEM
> +
> +	help
> +	  Allow khugepaged to put read-only file-backed pages in THP.
> +
> +	  This is marked experimental because it is a new feature. Write
> +	  support of file THPs will be developed in the next few release
> +	  cycles.
> +
>  config ARCH_HAS_PTE_SPECIAL
>  	bool
>  
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 5f072a113535..e79ceccdc6df 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -203,8 +203,8 @@ static void unaccount_page_cache_page(struct address_space *mapping,
>  		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
>  		if (PageTransHuge(page))
>  			__dec_node_page_state(page, NR_SHMEM_THPS);
> -	} else {
> -		VM_BUG_ON_PAGE(PageTransHuge(page), page);
> +	} else if (PageTransHuge(page)) {
> +		__dec_node_page_state(page, NR_FILE_THPS);
>  	}
>  
>  	/*
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 158cad542627..090127e4e185 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -48,6 +48,7 @@ enum scan_result {
>  	SCAN_CGROUP_CHARGE_FAIL,
>  	SCAN_EXCEED_SWAP_PTE,
>  	SCAN_TRUNCATED,
> +	SCAN_PAGE_HAS_PRIVATE,
>  };
>  
>  #define CREATE_TRACE_POINTS
> @@ -404,7 +405,11 @@ static bool hugepage_vma_check(struct vm_area_struct *vma,
>  	    (vm_flags & VM_NOHUGEPAGE) ||
>  	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
>  		return false;
> -	if (shmem_file(vma->vm_file)) {
> +
> +	if (shmem_file(vma->vm_file) ||
> +	    (IS_ENABLED(CONFIG_READ_ONLY_THP_FOR_FS) &&
> +	     vma->vm_file &&
> +	     (vm_flags & VM_DENYWRITE))) {
>  		if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE))
>  			return false;
>  		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
> @@ -456,8 +461,9 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>  	unsigned long hstart, hend;
>  
>  	/*
> -	 * khugepaged does not yet work on non-shmem files or special
> -	 * mappings. And file-private shmem THP is not supported.
> +	 * khugepaged only supports read-only files for non-shmem files.
> +	 * khugepaged does not yet work on special mappings. And
> +	 * file-private shmem THP is not supported.
>  	 */
>  	if (!hugepage_vma_check(vma, vm_flags))
>  		return 0;
> @@ -1287,12 +1293,12 @@ static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
>  }
>  
>  /**
> - * collapse_file - collapse small tmpfs/shmem pages into huge one.
> + * collapse_file - collapse filemap/tmpfs/shmem pages into huge one.
>   *
>   * Basic scheme is simple, details are more complex:
>   *  - allocate and lock a new huge page;
>   *  - scan page cache replacing old pages with the new one
> - *    + swap in pages if necessary;
> + *    + swap/gup in pages if necessary;
>   *    + fill in gaps;
>   *    + keep old pages around in case rollback is required;
>   *  - if replacing succeeds:
> @@ -1316,7 +1322,11 @@ static void collapse_file(struct mm_struct *mm,
>  	LIST_HEAD(pagelist);
>  	XA_STATE_ORDER(xas, &mapping->i_pages, start, HPAGE_PMD_ORDER);
>  	int nr_none = 0, result = SCAN_SUCCEED;
> +	bool is_shmem = shmem_file(file);
>  
> +#ifndef CONFIG_READ_ONLY_THP_FOR_FS
> +	VM_BUG_ON(!is_shmem);
> +#endif

	VM_BUG_ON(!IS_ENABLED(CONFIG_READ_ONLY_THP_FOR_FS) && !is_shmem);

>  	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
>  
>  	/* Only allocate from the target node */
> @@ -1348,7 +1358,8 @@ static void collapse_file(struct mm_struct *mm,
>  	} while (1);
>  
>  	__SetPageLocked(new_page);
> -	__SetPageSwapBacked(new_page);
> +	if (is_shmem)
> +		__SetPageSwapBacked(new_page);
>  	new_page->index = start;
>  	new_page->mapping = mapping;
>  
> @@ -1363,7 +1374,7 @@ static void collapse_file(struct mm_struct *mm,
>  		struct page *page = xas_next(&xas);
>  
>  		VM_BUG_ON(index != xas.xa_index);
> -		if (!page) {
> +		if (is_shmem && !page) {
>  			/*
>  			 * Stop if extent has been truncated or hole-punched,
>  			 * and is now completely empty.
> @@ -1384,7 +1395,7 @@ static void collapse_file(struct mm_struct *mm,
>  			continue;
>  		}
>  
> -		if (xa_is_value(page) || !PageUptodate(page)) {
> +		if (is_shmem && (xa_is_value(page) || !PageUptodate(page))) {
>  			xas_unlock_irq(&xas);
>  			/* swap in or instantiate fallocated page */
>  			if (shmem_getpage(mapping->host, index, &page,
> @@ -1392,6 +1403,23 @@ static void collapse_file(struct mm_struct *mm,
>  				result = SCAN_FAIL;
>  				goto xa_unlocked;
>  			}
> +		} else if (!page || xa_is_value(page)) {
> +			xas_unlock_irq(&xas);
> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
> +						  index, PAGE_SIZE);
> +			lru_add_drain();

Why?

> +			page = find_lock_page(mapping, index);
> +			if (unlikely(page == NULL)) {
> +				result = SCAN_FAIL;
> +				goto xa_unlocked;
> +			}
> +		} else if (!PageUptodate(page)) {

Maybe we should try wait_on_page_locked() here before give up?

> +			VM_BUG_ON(is_shmem);
> +			result = SCAN_FAIL;
> +			goto xa_locked;
> +		} else if (!is_shmem && PageDirty(page)) {
> +			result = SCAN_FAIL;
> +			goto xa_locked;
>  		} else if (trylock_page(page)) {
>  			get_page(page);
>  			xas_unlock_irq(&xas);
-- 
 Kirill A. Shutemov

