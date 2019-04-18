Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81CBBC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DF8320869
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:59:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DF8320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA5E26B026F; Thu, 18 Apr 2019 16:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2EF36B0270; Thu, 18 Apr 2019 16:59:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6DD6B0271; Thu, 18 Apr 2019 16:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2846B026F
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:59:17 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so2721107qkb.12
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Kym11LYO4Nkc1jbQpiaaqi7GnnxQid3teqnegPF6rnY=;
        b=t/qteDomDwsvXSV0dzBePbDQKfMCxDwkb4zteRGQnxDYXF2KPRz1camJQISNbKm4ad
         8TMWZZlQgoQgag74cC9sBgXFn5HpTtN0sWJZlzH6eIWeUe3n6v9me6sdPh0tsuGaKbNr
         /goai8krQZGmXBNV7HCPz0TsIXJIcOxzT+7Be8riCJid5209xsEt1Jmwlz2fAU1VZNGa
         EiEEIukBbk1dn0FtKluUIRtU3B5tAi0WCs21q7onGH+vT6LqRrAjai4OsjsWuc6J6XaA
         PRDAn2P/CnOBBrruaPZnAbF/sVuRhQAcgu/8emkCbp8PsDQxa8lwvB2jPC2M0chrnIas
         DwQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzdaoJ3jgbSLih6kMRREJIPG6SRbde5vPeIL7MHl1LKY57tmU1
	9pcRiYBWLtvqsGg96Y6IwTKZx8k3aaej7Ae+WDOjOMDzSWzArOZjp6MTtDkuJLSPosRi4A2liV+
	LaZD4eqd2L7Mxda6Tdlepu+LnVFjWpCvDbc4v0aLGpw8kiwj+dxNUvSJw0HIwJ4V1uQ==
X-Received: by 2002:a37:a650:: with SMTP id p77mr130398qke.256.1555621157280;
        Thu, 18 Apr 2019 13:59:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyULZ5DfoKRA+GKzX/EY5BLewKznIuKdet8pDdVhg7sjR+CBXaN+m5rZyqJirvg7pnKRL8j
X-Received: by 2002:a37:a650:: with SMTP id p77mr130354qke.256.1555621156505;
        Thu, 18 Apr 2019 13:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555621156; cv=none;
        d=google.com; s=arc-20160816;
        b=TPoedUJCREBTyH0FHBRnLTvVds/3HYUW59SLkw+s5IJLwAk+nnDGOmOuEhAPhvBJXR
         gbqETmBDhI3dsgqm6aa3ympaJMasGDO5nz+21DvLDd+rG7km/4aHmJ2QlAoJGVBFQdBq
         GxTwLNp79eOIlt9ZbW6sr1nFFHqydn/pxZ9reL66FnqXBWlHdIHJq6UCJJMXhmkxpNU7
         3irFAkoutZQAjPKcn39xzfeqAFN1jUBK8MCkUhnMF6U4+bLVBS8wXvSGt07K6cVs9SfH
         p5xakiuLtWuPIpBtQwrErKyw5JOMpTUJXhQ7t8c81QlEyN62WqvQTLGjTiyrUAMBQu3+
         g2uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Kym11LYO4Nkc1jbQpiaaqi7GnnxQid3teqnegPF6rnY=;
        b=C1/2j4RjZ3spvgD7Ia3tVvjKI5ta2THzAgm2pG2hEr8GfDLawwGBdUh147yTQED1YL
         KdIa3CASBlsGZmNxe+rwtYWN+YpIO8mP2VrTh25fEGyIFAcx+g8+J4rlGMi4PgolVVXz
         TBSEM9yxBg04N9BeRvqZSBaw6ou2OJ0wl05slR8aNxqQo2GWS9kLsmOrFOU24a6RwnVj
         1B9ThxJYIGyXUvtbbK4WZm3l/gU3azlZu1Yyg52MnX0SqMedQi+eHnjrqOBT/SjjhWtz
         uUk+IYd1ULqHDvp2ibbf/FuWW3rukja9ZYxqRijqfXeSdcIudhm/kQ+Vlzr47V2UMua/
         icOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e18si898028qkm.85.2019.04.18.13.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 194283082EF1;
	Thu, 18 Apr 2019 20:59:15 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E7365600C5;
	Thu, 18 Apr 2019 20:59:08 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:59:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 17/28] userfaultfd: wp: support swap and page migration
Message-ID: <20190418205907.GL3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-18-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190320020642.4000-18-peterx@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 18 Apr 2019 20:59:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:31AM +0800, Peter Xu wrote:
> For either swap and page migration, we all use the bit 2 of the entry to
> identify whether this entry is uffd write-protected.  It plays a similar
> role as the existing soft dirty bit in swap entries but only for keeping
> the uffd-wp tracking for a specific PTE/PMD.
> 
> Something special here is that when we want to recover the uffd-wp bit
> from a swap/migration entry to the PTE bit we'll also need to take care
> of the _PAGE_RW bit and make sure it's cleared, otherwise even with the
> _PAGE_UFFD_WP bit we can't trap it at all.
> 
> Note that this patch removed two lines from "userfaultfd: wp: hook
> userfault handler to write protection fault" where we try to remove the
> VM_FAULT_WRITE from vmf->flags when uffd-wp is set for the VMA.  This
> patch will still keep the write flag there.
> 
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Some missing thing see below.

[...]

> diff --git a/mm/memory.c b/mm/memory.c
> index 6405d56debee..c3d57fa890f2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -736,6 +736,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  				pte = swp_entry_to_pte(entry);
>  				if (pte_swp_soft_dirty(*src_pte))
>  					pte = pte_swp_mksoft_dirty(pte);
> +				if (pte_swp_uffd_wp(*src_pte))
> +					pte = pte_swp_mkuffd_wp(pte);
>  				set_pte_at(src_mm, addr, src_pte, pte);
>  			}
>  		} else if (is_device_private_entry(entry)) {

You need to handle the is_device_private_entry() as the migration case
too.



> @@ -2825,6 +2827,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  	flush_icache_page(vma, page);
>  	if (pte_swp_soft_dirty(vmf->orig_pte))
>  		pte = pte_mksoft_dirty(pte);
> +	if (pte_swp_uffd_wp(vmf->orig_pte)) {
> +		pte = pte_mkuffd_wp(pte);
> +		pte = pte_wrprotect(pte);
> +	}
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
>  	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
>  	vmf->orig_pte = pte;
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 181f5d2718a9..72cde187d4a1 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -241,6 +241,8 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
>  		entry = pte_to_swp_entry(*pvmw.pte);
>  		if (is_write_migration_entry(entry))
>  			pte = maybe_mkwrite(pte, vma);
> +		else if (pte_swp_uffd_wp(*pvmw.pte))
> +			pte = pte_mkuffd_wp(pte);
>  
>  		if (unlikely(is_zone_device_page(new))) {
>  			if (is_device_private_page(new)) {

You need to handle is_device_private_page() case ie mark its swap
as uffd_wp

> @@ -2301,6 +2303,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  			swp_pte = swp_entry_to_pte(entry);
>  			if (pte_soft_dirty(pte))
>  				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> +			if (pte_uffd_wp(pte))
> +				swp_pte = pte_swp_mkuffd_wp(swp_pte);
>  			set_pte_at(mm, addr, ptep, swp_pte);
>
>  			/*
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 855dddb07ff2..96c0f521099d 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -196,6 +196,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				newpte = swp_entry_to_pte(entry);
>  				if (pte_swp_soft_dirty(oldpte))
>  					newpte = pte_swp_mksoft_dirty(newpte);
> +				if (pte_swp_uffd_wp(oldpte))
> +					newpte = pte_swp_mkuffd_wp(newpte);
>  				set_pte_at(mm, addr, pte, newpte);
>  
>  				pages++;

Need to handle is_write_device_private_entry() case just below
that chunk.

Cheers,
Jérôme

