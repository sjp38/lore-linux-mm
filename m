Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A622BC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ED47222B5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 12:03:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ED47222B5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E16808E0002; Wed, 13 Feb 2019 07:03:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC66D8E0001; Wed, 13 Feb 2019 07:03:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDBC78E0002; Wed, 13 Feb 2019 07:03:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BA788E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:03:34 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f125so1516148pgc.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:03:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BjyLCkH94blh0570abCQwKznOBsBy8Sm5Ol5ahnKV/s=;
        b=j0iu/MN1zcLDctCfislQ4qviF8EjVRf9izFyVXl7dDDxa98Y5mtVzAkWrkySJY9yT4
         zGQD5DveC6RYTfKRRVhhGOPg55loLy3FZfRh8l6973sfE9BvwyzJaUUbNrrOR0E7BytI
         AeGBXTyAKLB6JpZDi2rTrlzvf/QwzAbfJmxxkcjEuPUaPgUYIxVN1bOm4QWwFxWKmPhW
         QL4RWoehU+Qc1eBBKhEaPiZ8iAZmXzjUHSJ+oNacAbg30e3R6i58R4HwyPnhXEe5hbW+
         5F6s+WEBsd6DTndSaD7OzVpSWOp2DjF4h2iCn6gGiS7wixgJ9TRPYlunAXSv1Ae6wqYQ
         iq0w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuYdBTpy1a24yOImV26NqDxArzK9BIU07LdjltG4wOmZ+8b5lmTx
	YpdmnAyvqyJEgk8TxYEuxHCZ/XV4j72Ew+iDG7/J9UmH9bhM2APdniW1KPT49KSOd0atyRZ8Qej
	b+st01n72TChzY9EEk5diD9HK4vfkIVSgO3/u2tFXnb3wMD6yMbE/wn+nNegANmw=
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr157472pls.338.1550059414216;
        Wed, 13 Feb 2019 04:03:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IawZlzSxprD22JgA5giwyj8jW789lx8FXV4B64tOqVvjhHxrbU2PAlq/2FB6/Eh4iZGutiA
X-Received: by 2002:a17:902:b615:: with SMTP id b21mr157407pls.338.1550059413517;
        Wed, 13 Feb 2019 04:03:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550059413; cv=none;
        d=google.com; s=arc-20160816;
        b=F/KbbH4bx5sZhWk7IIYUsWPCY8Tp/ePVdH1EmPgYhOkAfxNCXTUKgRPDkDCHZlD1/0
         yVSnu5gzR4DmbSnFdWMF4BdBgB51eNT8PnohL5lKT8nRkoYpyU5Zz86gTmfChU0tNSWy
         HM6w8uFFoIy/Wk2wVVuYz70qBOr5WyTDtR878gOZCMHphxl0LNfQmGTvje6XdFq3l/mI
         ZKdUWjoTfVaZVTrHfAecGocO6KxKWZAkRAVeoqc+ydSjklVUXcaPiyg08ogVbeKAFMXq
         sQr5JwQ7Sk9YH1Yehams1MmGOtrDZ4/ReFqzXHsgEvwJDpODxmFEfTBKuPnRI9f0xtqi
         mCxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BjyLCkH94blh0570abCQwKznOBsBy8Sm5Ol5ahnKV/s=;
        b=IEANPK8e0IYEIeu1wuK1jCQfUoIfkMxeK2NmkJkd6jrxFQ0P+uW7pIl1MtcR0pR7gF
         x6r89UNBGD3b8TpSVrFshYMunLcUEXgqt/jqvqQzj5Q5uL/B+ax8QwU2A+BswLf/+NNp
         ItXBW/CqAczRYOqoXZNB9HGnYl3uaPZG47rDuPVlDcA38wReZDhCUH6Nmivn8BbabyoP
         mf+aeXP/JfG7+7Nrsaam7zVwKzK19NXREYtQvWwTP6G8VZBhoLXxh2hRgDCJEqlO+/Zu
         p62p3RRCAc20YZSY8k6uxRytdCtMhAgeP2CnwP4D5QjvRvSSBJeF/SHsgF7p04lKkMOI
         yzOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d13si15799344plr.403.2019.02.13.04.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 04:03:33 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D23A0ACAE;
	Wed, 13 Feb 2019 12:03:31 +0000 (UTC)
Date: Wed, 13 Feb 2019 13:03:30 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: gregkh@linuxfoundation.org, linux-mm <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Hugh Dickins <hughd@google.com>, Liu Bo <bo.liu@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: Re: [PATCH] mm: Fix the pgtable leak
Message-ID: <20190213120330.GD4525@dhcp22.suse.cz>
References: <20190213112900.33963-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213112900.33963-1-minchan@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-02-19 20:29:00, Minchan Kim wrote:
> [1] was backported to v4.9 stable tree but it introduces pgtable
> memory leak because with fault retrial, preallocated pagetable
> could be leaked in second iteration.
> To fix the problem, this patch backport [2].
> 
> [1] 5cf3e5ff95876, mm, memcg: fix reclaim deadlock with writeback
> [2] b0b9b3df27d10, mm: stop leaking PageTables
> 
> Fixes: 5cf3e5ff95876 ("mm, memcg: fix reclaim deadlock with writeback")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Liu Bo <bo.liu@linux.alibaba.com>
> Cc: <stable@vger.kernel.org> [4.9]
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Thanks for catching this dependency. Do I assume it correctly that this
is stable-4.9 only?

> ---
>  mm/memory.c | 21 +++++++++++++++------
>  1 file changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 35d8217bb0467..47248dc0b9e1a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3329,15 +3329,24 @@ static int do_fault(struct fault_env *fe)
>  {
>  	struct vm_area_struct *vma = fe->vma;
>  	pgoff_t pgoff = linear_page_index(vma, fe->address);
> +	int ret;
>  
>  	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
>  	if (!vma->vm_ops->fault)
> -		return VM_FAULT_SIGBUS;
> -	if (!(fe->flags & FAULT_FLAG_WRITE))
> -		return do_read_fault(fe, pgoff);
> -	if (!(vma->vm_flags & VM_SHARED))
> -		return do_cow_fault(fe, pgoff);
> -	return do_shared_fault(fe, pgoff);
> +		ret = VM_FAULT_SIGBUS;
> +	else if (!(fe->flags & FAULT_FLAG_WRITE))
> +		ret = do_read_fault(fe, pgoff);
> +	else if (!(vma->vm_flags & VM_SHARED))
> +		ret = do_cow_fault(fe, pgoff);
> +	else
> +		ret = do_shared_fault(fe, pgoff);
> +
> +	/* preallocated pagetable is unused: free it */
> +	if (fe->prealloc_pte) {
> +		pte_free(vma->vm_mm, fe->prealloc_pte);
> +		fe->prealloc_pte = 0;
> +	}
> +	return ret;
>  }
>  
>  static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
> -- 
> 2.20.1.791.gb4d0f1c61a-goog
> 

-- 
Michal Hocko
SUSE Labs

