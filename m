Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE5E8C46477
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:12:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A62392084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:12:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A62392084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 200F86B0003; Wed, 19 Jun 2019 08:12:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B28E8E0002; Wed, 19 Jun 2019 08:12:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07B018E0001; Wed, 19 Jun 2019 08:12:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA41B6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:12:54 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so25871143eda.9
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=bTZ34gjzzP0Jy0ADECXUetaZX9fMfNzVu8DZSO8np30=;
        b=b+9nYgthE6ihY0scv+Ossm5kfToJyOx6IivVEdpza46mLNPemj2flhuc/zxQHf24Jg
         S9AHbn1lH7GdtoLgPHFFPelKobRVi1M0+7d2TBks4SrqqWR1BEJzZtbvvRSk5/7wdJ4w
         XN1She17ZDx+hMYLT3HbLS/fncwmSWD0CWDiG0mpPqFf7UeLLBgsXGCYuFQ3Ujv80AJu
         avo72dSUwt2zOWMjydYhUA9nEKfXBh7FwsyrZtoc02imRIAAn2FrCY20UBHWl3Cby7zr
         LwmU3iuW1F5jpEgoMFmBS9KIkEfK+HRZUb/dZwk6M879R2Q12LsF8/58GcULlx0fC1BI
         u/bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXjbVgTFniU4WQxdMaYGUutUjo+KzFrTpuvt+BW3J9zjOrvemWm
	6OLl2FNi3YqEOhOoMrzh9RjxFoF3Wq6ma5EWAUn3j2l0CYDcYaew/jp8HRGXiByvcrEDfKYQhUt
	HWZZraxG++8ua0b+pU56p9ErQ+Za9ZDvZ3tTs1i8WeGVWZKmTWi72Pe1XYV07W+zmUQ==
X-Received: by 2002:a50:fc18:: with SMTP id i24mr67870957edr.249.1560946374266;
        Wed, 19 Jun 2019 05:12:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynv8+XrxStqKz3Uw6Vpf70NVEBOR/h75OT2Agi5NJv2decyMIGYUQZv1za2C4MOy+f2rns
X-Received: by 2002:a50:fc18:: with SMTP id i24mr67870884edr.249.1560946373590;
        Wed, 19 Jun 2019 05:12:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560946373; cv=none;
        d=google.com; s=arc-20160816;
        b=CnwlMQ7D2oROTl79NKzjTO3UDiSNCdIrpgKvLvmiGcvWYng/tXWwsTrKYfsOtD/bxA
         qBPf4t/UWHfYu3PwJ3OZq0s8JGFr91Lv/qa1mvO+wrN3SJxLvvmV7yY78ET/gyeJEWxb
         IKKcOSGrd2R2xGEfVwtPQd9egydsvslFRkS03mU+LtGLFic2AWe8v7SVx4lkyGM7ip2a
         1rF1EK4HscERBAKGbTJuMy26ybUerDVwjcFF7q2iU/WOf13axmNj34TsE7+cPJ/tiOFq
         QITmcAnJxuwz34iXq1N9M5m72AimQb47MLQ5egh960ALAIw5vlteFXR6susuhyrti9IM
         UHiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=bTZ34gjzzP0Jy0ADECXUetaZX9fMfNzVu8DZSO8np30=;
        b=BcsMkTHIZv/M7wzy6Onsa1umlbukHdZzm5zy+T8nAgJap9XczsoQgl0flPs39DPnC7
         PMuIrJLvGv+UPIrvWS/N66BRj9nL2nKDeBnhaUm0JWjXnbLpNZVXiCeRixc9tiFyjLJZ
         P/XZFwow9MUi9lXEuhrFWsyPLt86O5ddMASqkWQ4b42m3W7lD5J8Ip/4y+5lOO7/bIP5
         tOQA+E5USLcoWp8ctWK8YVSmVnONywQ3j3/wSTEZvfV5tOcUjxO33FcqxLbwTwKVmylU
         MSzoAYMeJbebmg6+EMuXnkcU39N/bf/cVgbjrZ4EkG8B9xFlGDGfuDpEqn/JTBvYEg3x
         2Y9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u14si10689368ejm.334.2019.06.19.05.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 05:12:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1536FAC54;
	Wed, 19 Jun 2019 12:12:53 +0000 (UTC)
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
To: Yang Shi <yang.shi@linux.alibaba.com>, hughd@google.com,
 kirill.shutemov@linux.intel.com, mhocko@suse.com, rientjes@google.com,
 akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com>
 <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz>
Date: Wed, 19 Jun 2019 14:12:35 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/13/19 6:44 AM, Yang Shi wrote:
> The commit 7635d9cbe832 ("mm, thp, proc: report THP eligibility for each
> vma") introduced THPeligible bit for processes' smaps. But, when checking
> the eligibility for shmem vma, __transparent_hugepage_enabled() is
> called to override the result from shmem_huge_enabled().  It may result
> in the anonymous vma's THP flag override shmem's.  For example, running a
> simple test which create THP for shmem, but with anonymous THP disabled,
> when reading the process's smaps, it may show:

...

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 01d4eb0..6a13882 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -796,7 +796,8 @@ static int show_smap(struct seq_file *m, void *v)
>  
>  	__show_smap(m, &mss);
>  
> -	seq_printf(m, "THPeligible:    %d\n", transparent_hugepage_enabled(vma));
> +	seq_printf(m, "THPeligible:		%d\n",
> +		   transparent_hugepage_enabled(vma));
>  
>  	if (arch_pkeys_enabled())
>  		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4bc2552..36f0225 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -65,10 +65,15 @@
>  
>  bool transparent_hugepage_enabled(struct vm_area_struct *vma)
>  {
> +	/* The addr is used to check if the vma size fits */
> +	unsigned long addr = (vma->vm_end & HPAGE_PMD_MASK) - HPAGE_PMD_SIZE;
> +
> +	if (!transhuge_vma_suitable(vma, addr))
> +		return false;

Sorry for replying rather late, and not in the v2 thread, but unlike
Hugh I'm not convinced that we should include vma size/alignment in the
test for reporting THPeligible, which was supposed to reflect
administrative settings and madvise hints. I guess it's mostly a matter
of personal feeling. But one objective distinction is that the admin
settings and madvise do have an exact binary result for the whole VMA,
while this check is more fuzzy - only part of the VMA's span might be
properly sized+aligned, and THPeligible will be 1 for the whole VMA.

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
> index 1bb3b8d..a807712 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -3872,6 +3872,9 @@ bool shmem_huge_enabled(struct vm_area_struct *vma)
>  	loff_t i_size;
>  	pgoff_t off;
>  
> +	if ((vma->vm_flags & VM_NOHUGEPAGE) ||
> +	    test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
> +		return false;
>  	if (shmem_huge == SHMEM_HUGE_FORCE)
>  		return true;
>  	if (shmem_huge == SHMEM_HUGE_DENY)
> 

