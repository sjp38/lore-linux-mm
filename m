Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 494B2C31E44
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E237E2086D
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:33:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="aGF0m5qD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E237E2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772F96B0003; Tue, 11 Jun 2019 22:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7243C6B0005; Tue, 11 Jun 2019 22:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6121A6B0008; Tue, 11 Jun 2019 22:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15F466B0003
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:33:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a21so23460403edt.23
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=MAd9VAiJz95Llz8BbTxV4sHt55dwKHdH+hoX3bTDkOM=;
        b=EeqpN1qpqx35zC9OGwdWicuIsIipJnbgvNTmlbqUt5JAiWgGULCdLf0DAser4FpM/J
         FpKAtacFbRfvVIlMFq01VEcyYHPBq7kbReOr7tP0/anp3ycZR6Mbj+ZA9kUbQMK5b/mi
         WGCBCTF3H31yqYPZHOpeIOdcaoYrTdcysvjhh5spEDhD8TN/KZx4xheRXjz4dg8zyvq5
         ycmX+QcLvwEUpdEFf4VcPyRoKqjqa4Ud63+7nww874SBu9ofA/GQLLpxVBF0ujEQFhJH
         2BWDeyrS9CkGo72Gpw/35XYSK7EHVKqd9wRYc/eFJSyLxLxoZV9ICtREElIag6rZw4Jn
         jo+g==
X-Gm-Message-State: APjAAAUhPBNmQT37kGi+ZMQ7w0j+hFD1Kxiro79vn7nj9w5mwdHQlwo2
	w4Gj8iEUram+p4/C1BLLvh6bSZGifybVIlIyeNX00kEBSaLkmn+OYIYxVczd3fRlNapKmSnZ/kq
	kSdc0mEqcREDb6nCY4lZsOAQY6HGzQ/FEGmhDYjbZ9Pn8AEOBZvbWB1xMmsv4hKheCg==
X-Received: by 2002:a50:8828:: with SMTP id b37mr42720006edb.266.1560306818525;
        Tue, 11 Jun 2019 19:33:38 -0700 (PDT)
X-Received: by 2002:a50:8828:: with SMTP id b37mr42719956edb.266.1560306817762;
        Tue, 11 Jun 2019 19:33:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560306817; cv=none;
        d=google.com; s=arc-20160816;
        b=XXhkwpCP0fWlqNuIox8YlN7KSptPEL3D7/49VikCg/IACUwZb6HLiona38YCFgn8jw
         aYuaS76dAKen7LM12BhvqVXwD5PjoeDgLITOEHrMhT5H8dOBr64cm7DK/WEtLMtiyKPu
         IehquZZriDqzOKYuFHIwEedo5fBsDKpkiMbdGBaLhZXwaBLrzZX+zZ/9hy/2MLbyqY1/
         flDgIcPxFdK1JRz0v51UEISjQ8db/fbTsn7DoX3Vd0lJ6cExaoYhxlyOKiPNDN2+ilqa
         3ueK+zU4gO3US/6RSH/ATnMzj9iRC8/31cEpXmlyhToNUrIr1ZvODfxFxOxnDKxKqt1a
         q+tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=MAd9VAiJz95Llz8BbTxV4sHt55dwKHdH+hoX3bTDkOM=;
        b=ruaBQ3JOMAtHOYypG2kLNQFiQSTzTWhOmzswDIGe7Od94XiE47MPT/0i9avJkwB6+B
         goX9vuIn7fUzUYVgmt7W+o9wldf2q4lt044k31fBIfinIAkTKuFINZSJ6llI8fb4LgLQ
         ktpymkwBFu5o3jjipJMq8wT/etfFQlxdxYEmE7kHcU/NL4GIkL7a07gLt7PPKz/KMlKb
         rsJXdtrJmoqpNVdtPErxULBfbEXqtgCWhBX6YItM60IbaTN41uz/OIOvMdTVqazbzJbG
         raeoNUHfscXNEDhEicwHUqWwsXmveSDxmU1pOPlbHS6XoNE2emUm5PtnTlrBXjuvGaiV
         ltMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=aGF0m5qD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ka5sor4776468ejb.12.2019.06.11.19.33.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 19:33:37 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=aGF0m5qD;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=MAd9VAiJz95Llz8BbTxV4sHt55dwKHdH+hoX3bTDkOM=;
        b=aGF0m5qDaDj87qvNo5iPDYjLHNHkvWmDaEpCNpwbFSa4HzQDh4bwYk/ghq2akBh7gf
         mvYvGFQKDZIuN9zsuuccUcDr6CwuBRbat9mNrwjJNqAHXk5LoA66Npn1J32iT2rcDfpw
         f+i5zMYkljrX+ld9mYuVrJTtg30/15VL5s9Sh6uBssTfZ57JtMnhkfDzQKGLfLD7rQjV
         yZWlPSz0HiFXV9SmWRGoEhN14rWIRN5p0NtTtgElcRvgA+7FrrckEiVoMyoE3ze2sQbQ
         dYnPsIewsFSO+WvWMcODJaKcHE2ujN58RlX4DWlbu9H2vKMtJdLSA9GH2kSSCsbTERm9
         IihA==
X-Google-Smtp-Source: APXvYqyhtZl/3SjW+LtLwuO7S7BeZoKmz1DOjU/1ktZsjjlPzNNDP6SQvVctNXiGwdDMlV9oY2pG6A==
X-Received: by 2002:a17:906:53c1:: with SMTP id p1mr5138534ejo.241.1560306817323;
        Tue, 11 Jun 2019 19:33:37 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id i31sm4161836edd.90.2019.06.11.19.33.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 19:33:36 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id C01BA10081B; Wed, 12 Jun 2019 05:33:36 +0300 (+03)
Date: Wed, 12 Jun 2019 05:33:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: Re: [RFC PATCH v2 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190612023336.hbqs2ag4bv2qv2eh@box>
References: <1559937063-8323-1-git-send-email-larry.bassel@oracle.com>
 <1559937063-8323-3-git-send-email-larry.bassel@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559937063-8323-3-git-send-email-larry.bassel@oracle.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 12:51:03PM -0700, Larry Bassel wrote:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3a54c9d..1c1ed4e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4653,9 +4653,9 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>  }
>  
>  #ifdef CONFIG_ARCH_HAS_HUGE_PMD_SHARE
> -static unsigned long page_table_shareable(struct vm_area_struct *svma,
> -				struct vm_area_struct *vma,
> -				unsigned long addr, pgoff_t idx)
> +unsigned long page_table_shareable(struct vm_area_struct *svma,
> +				   struct vm_area_struct *vma,
> +				   unsigned long addr, pgoff_t idx)
>  {
>  	unsigned long saddr = ((idx - svma->vm_pgoff) << PAGE_SHIFT) +
>  				svma->vm_start;
> @@ -4678,7 +4678,7 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
>  	return saddr;
>  }
>  
> -static bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
> +bool vma_shareable(struct vm_area_struct *vma, unsigned long addr)
>  {
>  	unsigned long base = addr & PUD_MASK;
>  	unsigned long end = base + PUD_SIZE;

This is going to be build error. mm/hugetlb.o doesn't build unlessp CONFIG_HUGETLBFS=y.

And I think both functions doesn't cover all DAX cases: VMA can be not
aligned (due to vm_start and/or vm_pgoff) to 2M even if the file has 2M
ranges allocated. See transhuge_vma_suitable().

And as I said before, nothing guarantees contiguous 2M ranges on backing
storage.

And in general I found piggybacking on hugetlb hacky.

The solution has to stand on its own with own justification. Saying it
worked for hugetlb and it has to work here would not fly. hugetlb is much
more restrictive on use cases. THP has more corner cases.

> diff --git a/mm/memory.c b/mm/memory.c
> index ddf20bd..1ca8f75 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3932,6 +3932,109 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_ARCH_HAS_HUGE_PMD_SHARE
> +static pmd_t *huge_pmd_offset(struct mm_struct *mm,
> +			      unsigned long addr, unsigned long sz)
> +{
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd = pgd_offset(mm, addr);
> +	if (!pgd_present(*pgd))
> +		return NULL;
> +	p4d = p4d_offset(pgd, addr);
> +	if (!p4d_present(*p4d))
> +		return NULL;
> +
> +	pud = pud_offset(p4d, addr);
> +	if (sz != PUD_SIZE && pud_none(*pud))
> +		return NULL;
> +	/* hugepage or swap? */
> +	if (pud_huge(*pud) || !pud_present(*pud))
> +		return (pmd_t *)pud;

So do we or do we not support PUD pages? This is just broken.
> +
> +	pmd = pmd_offset(pud, addr);
> +	if (sz != PMD_SIZE && pmd_none(*pmd))
> +		return NULL;
> +	/* hugepage or swap? */
> +	if (pmd_huge(*pmd) || !pmd_present(*pmd))
> +		return pmd;
> +
> +	return NULL;
> +}
> +

-- 
 Kirill A. Shutemov

