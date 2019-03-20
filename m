Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 846BFC10F0D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:44:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 404152186A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 15:44:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 404152186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D032E6B0284; Wed, 20 Mar 2019 11:44:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB2DD6B0286; Wed, 20 Mar 2019 11:44:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC7336B0287; Wed, 20 Mar 2019 11:44:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 998C36B0284
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 11:44:26 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z34so2842374qtz.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 08:44:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1opcehXOxSH7wA8Eu0VjLYRNvluZS+Y89WP40BM0xbA=;
        b=XdtIC/fUVLhvJupOnW24Tvh7yCzSzK24nfneaFDU2csMrYl1nGNEjz6ODzVSmtKclS
         8NCCSN0eGcvMch80tlI1iAd7H7/DyuyAjSVXB/1ulSz6fqz3Zncq1odjNlsGelImN2QM
         UgjDtN5WBmxQjk3mddM1iSGkF7QR6FFmTmDEoLz6JfREsUl2DKlHEf3K9YWcU1QC6WFC
         OG9+df9rto4jhjp9aDz1BnZfZ9RGyQRNp3Yg8zb7yfg/xjSkFnjV32luVFPcTWgtMWUi
         9rtVZm9/vQBcicEZA5QgorqL4JpTVuWraSMjI4s8PajNjabTKITO1nndAaMgfgwdkkEv
         x/KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPHydW2dwDt9C/ssKqOzCvj4dGlCUzhLabHxwegOctJWWIwGB4
	0e/KRO9lJnqyN1fiP57TeQXK2Z3nyDrB6ujzzUL4Td6aAW9PIkEuXv9PXoPsdk/p72VnXhWRT+Z
	lgV1bf1RjmeInwAN4lG/U9sZY+Kseuvjq0pUB0wznqJhjeHzDkoNNY+bRjotE8CA0Vw==
X-Received: by 2002:a05:620a:3dd:: with SMTP id r29mr7320380qkm.157.1553096666386;
        Wed, 20 Mar 2019 08:44:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxM8tEl02A8D0i9vvBAAihXU2aS3csmJVeSLAZ5jFlIsziwbjK5plRmbM8TTjyHmNwOfLr2
X-Received: by 2002:a05:620a:3dd:: with SMTP id r29mr7320315qkm.157.1553096665620;
        Wed, 20 Mar 2019 08:44:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553096665; cv=none;
        d=google.com; s=arc-20160816;
        b=QHCh3ShHE98DQ9ICSFByrZnQhLjRZkQJcOHmUWGLJy8pwVulnOkoP1jvs9PEEMoCh2
         DWhQDB0tpNuwrSLeRu+IU2hU8DAcufagCnA2n3z0OduOhtm2dS0KErGQzpQYurvF4IS8
         EcQVcQ45J5sxIE3xI0SxIo7rOEKaGUVzmeHNAs89d4py9IuUelZZOhf88b/vbJDZUpDe
         fisNsdvq/hKkXHCR9nSv7Sgcsh+4hUmqUtoMs3xu361gBCTvD+iEmQmRbRqQhvFI6A0c
         i1gWq3iBdnaJFp/cuCQ6cRNcAsIbOQLZ7pmAqg+KY+SMA6h2+iKV4GmpZUxwinVCw+S0
         FdoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1opcehXOxSH7wA8Eu0VjLYRNvluZS+Y89WP40BM0xbA=;
        b=F5VoxWEq/XqySMiNeum56PSVYvlGzHmzn+KG6L7GxrQjjjHu/uRYUs0l3EFDIsn2qA
         ApISBTROGOYdsb4aGPCp3WvZtUcDPA1bKEA/C51AOd4xrlkefy1hkdEeEM+FokAsSNd2
         RgGRnRDtuVf5htZqJG32G+1bvsMVlkCitRqG5gcWhQGMkLbg+Tsk8n3rYWiXk15iO4vW
         3JKP2sW8Orj7m6lBM2I7YO1vqOmNQ64BKb4+i764nnAU/a4rihQprHRZuvllq10cBZ2z
         U46S0sForWnynjhoeNaTzK3en8GHzLzlbm2PadlqC2RhKxTq3dBAJYsor2wHwtdEXhto
         huFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e11si1283143qkg.52.2019.03.20.08.44.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 08:44:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AA7F1C13071D;
	Wed, 20 Mar 2019 15:44:24 +0000 (UTC)
Received: from x230.aquini.net (dhcp-17-61.bos.redhat.com [10.18.17.61])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B2F9E5D73F;
	Wed, 20 Mar 2019 15:44:23 +0000 (UTC)
Date: Wed, 20 Mar 2019 11:44:20 -0400
From: Rafael Aquini <aquini@redhat.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: chrubis@suse.cz, vbabka@suse.cz, kirill@shutemov.name,
	osalvador@suse.de, akpm@linux-foundation.org,
	stable@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
Message-ID: <20190320154420.GE23194@x230.aquini.net>
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 20 Mar 2019 15:44:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 02:35:56AM +0800, Yang Shi wrote:
> When MPOL_MF_STRICT was specified and an existing page was already
> on a node that does not follow the policy, mbind() should return -EIO.
> But commit 6f4576e3687b ("mempolicy: apply page table walker on
> queue_pages_range()") broke the rule.
> 
> And, commit c8633798497c ("mm: mempolicy: mbind and migrate_pages
> support thp migration") didn't return the correct value for THP mbind()
> too.
> 
> If MPOL_MF_STRICT is set, ignore vma_migratable() to make sure it reaches
> queue_pages_to_pte_range() or queue_pages_pmd() to check if an existing
> page was already on a node that does not follow the policy.  And,
> non-migratable vma may be used, return -EIO too if MPOL_MF_MOVE or
> MPOL_MF_MOVE_ALL was specified.
> 
> Tested with https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c
> 
> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
> Reported-by: Cyril Hrubis <chrubis@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/mempolicy.c | 40 +++++++++++++++++++++++++++++++++-------
>  1 file changed, 33 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index abe7a67..401c817 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -447,6 +447,13 @@ static inline bool queue_pages_required(struct page *page,
>  	return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
>  }
>  
> +/*
> + * The queue_pages_pmd() may have three kind of return value.
> + * 1 - pages are placed on he right node or queued successfully.
> + * 0 - THP get split.
> + * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
> + *        page was already on a node that does not follow the policy.
> + */
>  static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  				unsigned long end, struct mm_walk *walk)
>  {
> @@ -456,7 +463,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  	unsigned long flags;
>  
>  	if (unlikely(is_pmd_migration_entry(*pmd))) {
> -		ret = 1;
> +		ret = -EIO;
>  		goto unlock;
>  	}
>  	page = pmd_page(*pmd);
> @@ -473,8 +480,15 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>  	ret = 1;
>  	flags = qp->flags;
>  	/* go to thp migration */
> -	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +		if (!vma_migratable(walk->vma)) {
> +			ret = -EIO;
> +			goto unlock;
> +		}
> +
>  		migrate_page_add(page, qp->pagelist, flags);
> +	} else
> +		ret = -EIO;
>  unlock:
>  	spin_unlock(ptl);
>  out:
> @@ -499,8 +513,10 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  	ptl = pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
>  		ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
> -		if (ret)
> +		if (ret > 0)
>  			return 0;
> +		else if (ret < 0)
> +			return ret;
>  	}
>  
>  	if (pmd_trans_unstable(pmd))
> @@ -521,11 +537,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  			continue;
>  		if (!queue_pages_required(page, qp))
>  			continue;
> -		migrate_page_add(page, qp->pagelist, flags);
> +		if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +			if (!vma_migratable(vma))
> +				break;
> +			migrate_page_add(page, qp->pagelist, flags);
> +		} else
> +			break;
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
> -	return 0;
> +	return addr != end ? -EIO : 0;
>  }
>  
>  static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
> @@ -595,7 +616,12 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>  	unsigned long endvma = vma->vm_end;
>  	unsigned long flags = qp->flags;
>  
> -	if (!vma_migratable(vma))
> +	/*
> +	 * Need check MPOL_MF_STRICT to return -EIO if possible
> +	 * regardless of vma_migratable
> +	 */ 
> +	if (!vma_migratable(vma) &&
> +	    !(flags & MPOL_MF_STRICT))
>  		return 1;
>  
>  	if (endvma > end)
> @@ -622,7 +648,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>  	}
>  
>  	/* queue pages from current vma */
> -	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +	if (flags & MPOL_MF_VALID)
>  		return 0;
>  	return 1;
>  }
> -- 
> 1.8.3.1
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

