Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE68C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:52:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB1B2214AE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:52:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB1B2214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BF446B0003; Tue, 23 Apr 2019 13:52:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56D0B6B0005; Tue, 23 Apr 2019 13:52:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45D006B0007; Tue, 23 Apr 2019 13:52:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E94A96B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:52:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id j44so7698402eda.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:52:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9cK1low0cdZTmXzlVvdo+OE2oi9lIMPaxtkx31fLyLs=;
        b=JzmDesE9cRXH0QYDVvJGJEfjaCL0lJiPWgyfGPIfwMdvehnfXkv7TZKy6QjrtbFhCm
         DYon0Qy8WCh7TsjV0lL6JFriP39qAs9Iif6PSONabPTNWAIAw/gD2LfaJI95qYH/LfKH
         g4Wj2J6vDuiClLLNPzvC4itRxT75ohWIUK3Ro9d3VUvWt0CY8hzBXGy+uSmOS6G94qou
         Y3p3Ihby9mCUAR3VEx33gmGLDYZbTUpxO9nQGYqUPSQDPWCzrzFz0LzM6wELfOyMqjT4
         5K8Ttek6LrCBdp9ii2PicEgOqfei6moqBi6bRUFqWsVs922448OKTyR9EpuHPk9NJUox
         oqjQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXeiH6zN6Q5BCrky2kEJQ5FRhL2vcMzDALHRSo8x5rWXCMgawe6
	VkgOvr75QGiwOgfMNEUAF0QPJSH1/79+UbPTobAAn8NxVPVH8Hxf+CnrtKdsfjIWIIyL/y0BkUM
	liL6qOx3BbW4Jec2EPcWM1yltl3cKPPP1NNDXioQuhDHERet1iN8hirFfiRSk158=
X-Received: by 2002:a50:aeb6:: with SMTP id e51mr16937252edd.76.1556041975491;
        Tue, 23 Apr 2019 10:52:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4Gh0Sasc7SLMKBboOUGOKIzQgsWYYLuQdYMJZXduVojCGUEsI3NwhTMVl0PtAI9dohAS4
X-Received: by 2002:a50:aeb6:: with SMTP id e51mr16937205edd.76.1556041974766;
        Tue, 23 Apr 2019 10:52:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556041974; cv=none;
        d=google.com; s=arc-20160816;
        b=dKKQ7ehGWZWWD1yZgB2tmg/FlyPaN7KHKAXolLZpMSNXjNxSsvAUqoY8iaLS6m1+mK
         zRGzgGPO8aGMcTxOQXut8YgTqHQ/ojXJ4ZvFEBEJD3ipkwyZhJvft64X6rqZvoz6Z+PR
         w66k/WACIYv7PNkmB66wViTL1+tTpPlA4do99F0dH0C8gkyRmS7hp5b2W4TQqlM8GYMg
         1waF48AETkscujuJRUbK7xkHQ6Ud5ENCYzfxwBrb+2lODM6XI7V2oSL+nP4/wdPtc8US
         1VKfmesIbnE2aohbnLdsawK6sNcroeXCv9y/sPDQ2AiqqOZzXrYowsnJHdabsd71VOhr
         dVhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9cK1low0cdZTmXzlVvdo+OE2oi9lIMPaxtkx31fLyLs=;
        b=tE5XbmoZxQpgu4XM6bWnVGdVkvS+8QFOQLRkN3la4xep8WTYbdD//MlRdfkDXEt9q0
         l27Lo5IWK+W6NWQ5QH7ZSsr8n2C9Oson9cJVX7GyuinD1BuusrA9Q5Y8vFINkU81GO1U
         pqsIzpQ3WIgdtUjDCXEtf9ZEiGBiOZcFztj1a3+dyyQIZTc0NsdGYeYeiCItShsVklmt
         VMWqBlBzalXmD8zbrO3FW4/RtsrGlfj/x8OeIrjkVIZPzqHDFC59Fh3xjG84f3hJfMsq
         notEOipyx/TFJn8XvMJrqWcMMSDa/o7XW/X3U6TNCyDqwJm5roXLQDQ5SwHcUUzuAxcE
         chcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b23si3527248ejq.15.2019.04.23.10.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 10:52:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 009C3AF92;
	Tue, 23 Apr 2019 17:52:53 +0000 (UTC)
Date: Tue, 23 Apr 2019 19:52:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: vbabka@suse.cz, rientjes@google.com, kirill@shutemov.name,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: thp: fix false negative of shmem vma's THP
 eligibility
Message-ID: <20190423175252.GP25106@dhcp22.suse.cz>
References: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556037781-57869-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 24-04-19 00:43:01, Yang Shi wrote:
> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.  For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:
> 
> 7fc92ec00000-7fc92f000000 rw-s 00000000 00:14 27764 /dev/shm/test
> Size:               4096 kB
> ...
> [snip]
> ...
> ShmemPmdMapped:     4096 kB
> ...
> [snip]
> ...
> THPeligible:    0
> 
> And, /proc/meminfo does show THP allocated and PMD mapped too:
> 
> ShmemHugePages:     4096 kB
> ShmemPmdMapped:     4096 kB
> 
> This doesn't make too much sense.  The anonymous THP flag should not
> intervene shmem THP.  Calling shmem_huge_enabled() with checking
> MMF_DISABLE_THP sounds good enough.  And, we could skip stack and
> dax vma check since we already checked if the vma is shmem already.

Kirill, can we get a confirmation that this is really intended behavior
rather than an omission please? Is this documented? What is a global
knob to simply disable THP system wise?

I have to say that the THP tuning API is one giant mess :/

Btw. this patch also seem to fix khugepaged behavior because it previously
ignored both VM_NOHUGEPAGE and MMF_DISABLE_THP.

> Fixes: 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each vma")
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: Check VM_NOHUGEPAGE per Michal Hocko
> 
>  mm/huge_memory.c | 4 ++--
>  mm/shmem.c       | 3 +++
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 165ea46..5881e82 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -67,8 +67,8 @@ bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  {
>  	if (vma_is_anonymous(vma))
>  		return __transparent_hugepage_enabled(vma);
> -	if (vma_is_shmem(vma) && shmem_huge_enabled(vma))
> -		return __transparent_hugepage_enabled(vma);
> +	if (vma_is_shmem(vma))
> +		return shmem_huge_enabled(vma);
>  
>  	return false;
>  }
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2275a0f..6f09a31 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3873,6 +3873,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	loff_t i_size;
>  	pgoff_t off;
>  
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		return false;
>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
>  	if (shmem_huge == SHMEM_HUGE_DENY)
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

