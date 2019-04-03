Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87C33C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1526A206B7
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 04:58:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="cee1tRDV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1526A206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC0906B027D; Wed,  3 Apr 2019 00:58:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6EE46B027E; Wed,  3 Apr 2019 00:58:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 937526B0280; Wed,  3 Apr 2019 00:58:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4977D6B027D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 00:58:49 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z9so12207967wrn.21
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 21:58:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5Xx4genmEdABRp8M8MXS027ZxRTOx9uvlqGNm1L1b1w=;
        b=GSA7FVaPfQYt/QBrz+niixQB0EHmKk8f56iQfhlNYYhrU/LIX15Hz4wFmyMICZU9tz
         SJ0aoTQnWgc8rMGKciOGtGuUjX+5Elm8qeGUDHYOivpYkEc+ztOTeCGUVqWlmOwzjA8O
         1rad1LH4JqXTFG/M48KASq3qVvZALhYVsKQYX8Cb0CeSPn09J7Em92nxLxtTBaIGwUQ6
         zt3GNunUJJzQq7zfKtW0NscDppIM/XF6AWsk4XoxrGWVwAQ018MnvQe55venrbCvvnd5
         9YRUwmQL7YXyYtpiksdfao/8SUL8ZdRUcvejgVDS38cIVQ64ZEMj3CSsSvyDG0qrhyv4
         fdZg==
X-Gm-Message-State: APjAAAVh1oj8OF3TO0TMzarE0oBJcmUg/9MFMFsBw7VgWVJQsOZFEie3
	n8t3dqlfRf4N4Fj5qWpQU7JACnvPwuPNwjCFKis3RRbvxMuSraVnRUEzVT3TAuiJXuLrlunEdiu
	yLjmRXKuJcSBa//XOHoSk1ovcpBSIlmxBl0nmLWflpCuMRgbsfdxMzpguBzzPP/CAkw==
X-Received: by 2002:a1c:e70b:: with SMTP id e11mr428213wmh.17.1554267528647;
        Tue, 02 Apr 2019 21:58:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM4rptU2KJEiN3PYahXxA+LvnpBqtTxQRpJxqeEJXG6CKMecvy6x3G58QPbiTKL3HdKL6N
X-Received: by 2002:a1c:e70b:: with SMTP id e11mr428178wmh.17.1554267527764;
        Tue, 02 Apr 2019 21:58:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554267527; cv=none;
        d=google.com; s=arc-20160816;
        b=EmR47LAwZ0T43mT2IWb3LVlKI8HcxAJUgw876wJ5pSROk7FOhqdu349ccbF9ZELVmw
         r65ax7/ptxUWE0TwmK3Z0g21Jr+l7nKre5JADtVXmCZ4iUHhPiUr4lzmbmy9nTHaGXub
         TNIa1QzYG1qktIzZh/oYmY5q94HBuavw4KaoE0na0zFHso0dOB0/OJxsGCYhbqrZa9PY
         fXiDLJrhqKC5Pi95QGZHbkUDEJIvS++tWLxhGp3hVieq53467015sDp6IGJt1maPxiz3
         40clbGplT5+YvF1WILe8dksd3AhMKI5DIonzHD3acl+6MfJx8rrqJqZzBBQQJo8YiK4h
         MWtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=5Xx4genmEdABRp8M8MXS027ZxRTOx9uvlqGNm1L1b1w=;
        b=WZyhGx5wMBluBWm1Wb/1NIeoKuYMn3CaIE9St9iGkI/xJHmojIezy4bmbTMgyBp99m
         zvIDX+VTt+i2fOZ7plIIORxRIW2n31kwIBcg4gzvVupAcFH434PPpULce/oebDHtWdOX
         nbjSOZ7kQGojgHCGXq2LSBwWVflB8yIZFtkKxRgCVZzYzBACspy/xNXZaxVQR/hG5PNI
         x/1cmISTmisMfwkpDaLqC6eDT4uxjuuw+3I8L1khfE6EXhGUEGfBMSPlLA0CrP9kslb3
         ATZdPrggB8XoWUZEpzujov9kmQq2hE6SfubRgvw0+cHF2Bx2eOkWmLdoY8aCXoYc0gek
         QJiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=cee1tRDV;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s203si8918257wmf.64.2019.04.02.21.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 21:58:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=cee1tRDV;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Yv462mQhz9v10H;
	Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=cee1tRDV; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id b0OESs7l_U4k; Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Yv460ZLGz9v10G;
	Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1554267526; bh=5Xx4genmEdABRp8M8MXS027ZxRTOx9uvlqGNm1L1b1w=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=cee1tRDVuPk9wSU+tEnnQ/bqtnIB5O5LeGWg8FraP8t+qFAlORylURzsAbMcexA+8
	 rbq0YKaqgPsiURROfC97Dzbpi1QrJaIY8STSv1SrtJEOXOHVl4ivLJQtVHkBK/e0Si
	 TvHGEndf7CYwgGWe2XUMvsFHDZCQPBHUv3IGPccE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id DD5C68B77E;
	Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id fYq4xKXsmjq7; Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 455128B754;
	Wed,  3 Apr 2019 06:58:46 +0200 (CEST)
Subject: Re: [PATCH 5/6] powerpc/mmu: drop mmap_sem now that locked_vm is
 atomic
To: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org
Cc: Davidlohr Bueso <dave@stgolabs.net>, Alexey Kardashevskiy
 <aik@ozlabs.ru>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>,
 linuxppc-dev@lists.ozlabs.org
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-6-daniel.m.jordan@oracle.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <964bd5b0-f1e5-7bf0-5c58-18e75c550841@c-s.fr>
Date: Wed, 3 Apr 2019 06:58:45 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190402204158.27582-6-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 02/04/2019 à 22:41, Daniel Jordan a écrit :
> With locked_vm now an atomic, there is no need to take mmap_sem as
> writer.  Delete and refactor accordingly.

Could you please detail the change ? It looks like this is not the only 
change. I'm wondering what the consequences are.

Before we did:
- lock
- calculate future value
- check the future value is acceptable
- update value if future value acceptable
- return error if future value non acceptable
- unlock

Now we do:
- atomic update with future (possibly too high) value
- check the new value is acceptable
- atomic update back with older value if new value not acceptable and 
return error

So if a concurrent action wants to increase locked_vm with an acceptable 
step while another one has temporarily set it too high, it will now fail.

I think we should keep the previous approach and do a cmpxchg after 
validating the new value.

Christophe

> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Davidlohr Bueso <dave@stgolabs.net>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: <linux-mm@kvack.org>
> Cc: <linuxppc-dev@lists.ozlabs.org>
> Cc: <linux-kernel@vger.kernel.org>
> ---
>   arch/powerpc/mm/mmu_context_iommu.c | 27 +++++++++++----------------
>   1 file changed, 11 insertions(+), 16 deletions(-)
> 
> diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
> index 8038ac24a312..a4ef22b67c07 100644
> --- a/arch/powerpc/mm/mmu_context_iommu.c
> +++ b/arch/powerpc/mm/mmu_context_iommu.c
> @@ -54,34 +54,29 @@ struct mm_iommu_table_group_mem_t {
>   static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
>   		unsigned long npages, bool incr)
>   {
> -	long ret = 0, locked, lock_limit;
> +	long ret = 0;
> +	unsigned long lock_limit;
>   	s64 locked_vm;
>   
>   	if (!npages)
>   		return 0;
>   
> -	down_write(&mm->mmap_sem);
> -	locked_vm = atomic64_read(&mm->locked_vm);
>   	if (incr) {
> -		locked = locked_vm + npages;
>   		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> -		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> +		locked_vm = atomic64_add_return(npages, &mm->locked_vm);
> +		if (locked_vm > lock_limit && !capable(CAP_IPC_LOCK)) {
>   			ret = -ENOMEM;
> -		else
> -			atomic64_add(npages, &mm->locked_vm);
> +			atomic64_sub(npages, &mm->locked_vm);
> +		}
>   	} else {
> -		if (WARN_ON_ONCE(npages > locked_vm))
> -			npages = locked_vm;
> -		atomic64_sub(npages, &mm->locked_vm);
> +		locked_vm = atomic64_sub_return(npages, &mm->locked_vm);
> +		WARN_ON_ONCE(locked_vm < 0);
>   	}
>   
> -	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%ld %ld/%ld\n",
> -			current ? current->pid : 0,
> -			incr ? '+' : '-',
> -			npages << PAGE_SHIFT,
> -			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
> +	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%lu %lld/%lu\n",
> +			current ? current->pid : 0, incr ? '+' : '-',
> +			npages << PAGE_SHIFT, locked_vm << PAGE_SHIFT,
>   			rlimit(RLIMIT_MEMLOCK));
> -	up_write(&mm->mmap_sem);
>   
>   	return ret;
>   }
> 

