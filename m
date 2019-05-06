Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80F02C04AAA
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 09:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38BE02082F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 09:28:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38BE02082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA3E76B0003; Mon,  6 May 2019 05:28:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C547F6B0006; Mon,  6 May 2019 05:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C1A6B0007; Mon,  6 May 2019 05:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D26D6B0003
	for <linux-mm@kvack.org>; Mon,  6 May 2019 05:28:39 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id o65so1400199lfe.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 02:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1xHA8J2HdFsE28d9fPQk7myjnMGhxmRbHEUD0QEyWeE=;
        b=BHbI2me6ZGf3GvpxrRcS9U0iFTliTc6BUnPbZNPxEsso83q2jdk8/DZbWKf/Wz/0qU
         2qLP+H/UZayWVR9A479gwROrYPivnLyDa+bxNmug8yO7N84gDEeEU0B6N+93sSAKB71Y
         pdIzRLNIpj1FX1pz0oCRQzQiEia0AAUK2PsRUhTmeJSyHO32W6l038T2RWA7+5jcZbxl
         LWhLufFGvoY4cVLxb1nSnq01hx8laR7gDHAdcMkEk6OTg6f96Qm1P9X7iggS5TPltud5
         NkAccZMcIOYxqsD25Cp6KjFWq+HK+RXKruXcFvcofsOnXaSoWlkJ34Rj4vlkWOJyrw6M
         0LWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUUhA1Clrh/DZ9M/W9G3VVo03DV3gebyJTAcvX3jBzuljaCBvzr
	/CeKVF0/+GxO90nMBIleaIj/LG4Bk/GGITw+lbiSKH1m6KnTA0ArKue97XqnNmAMbJ75+5Zivbr
	c4Ta15VLaIi0850cLvqHezs99qv0UODKaYPPO8NpsFI64RgIiOX5V9985cSoVAF9jug==
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr11485994lja.49.1557134918578;
        Mon, 06 May 2019 02:28:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMYUABbXYnMGlk3rj2j/Nw5vbUow01N/ZlTKGo8OQ8ZdO3HYXpxGYG0sKKvG7sQyPL1cbz
X-Received: by 2002:a2e:4a1a:: with SMTP id x26mr11485951lja.49.1557134917495;
        Mon, 06 May 2019 02:28:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557134917; cv=none;
        d=google.com; s=arc-20160816;
        b=mvnU+09xkMn0mJ2IW6l/cFKpoDaTKyhICQYXpUDlmMaeRfqxToVDPA5vCjJd7ClORY
         EKQShIuhEuEXC4x48AVBOEOmgzPy2PYGCZ7fcCJ8fYChi2NSc66WOJw0beNGJG48LovA
         uFrvl0+eatH27eZ99/1HKiJVCTVX0ixjVUse21+KwlYKVXc93K3j+qtnBmI+dxxK+TFq
         ZFM6d+W5p2ex7SmMN8JpObYX5lHLVZaKe/DiYd82die5wgNo+8Iw6h9r+f/AYu5N7r/m
         Y9oUDkhXqcP4VUEVs30j6wfB1M14fJjGPGLPVMpic/c88syyH0X6kX0PLsrLMAJn1/2O
         lJGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=1xHA8J2HdFsE28d9fPQk7myjnMGhxmRbHEUD0QEyWeE=;
        b=0A7U+oWQRFYQSfCY0yW56oAKyowHjxkShtPAWrudfeOUAzEORr/QEdg+w3l/cKZqDB
         IXUEVsjD2k+GwyIww21rSu/JnczRMf8JGrCa+S4+EvbkBBiO0mw6nLweUHHQpzrGR4Y7
         r5b+b2ykiMytrbIPp6f+R0O/TfTxOg3nU2PGrufpQVS0sGLQR9uPdMbVpp+OvxJMVwj4
         unWw3/6Zc9+Sr+TWe2Wf6LAw3BAv7Loyuumd+/4VMq+ylmTjJbR/IaqB0x1p6MT9a8yG
         y+V9FJaBEKrojkzFc7UF0nJgrLwAnp10PI1D+PXo+4e0ChZUN6cpsFbjYz452O8yYV6M
         FRNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j15si7429149lji.192.2019.05.06.02.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 02:28:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hNZv4-0002jm-38; Mon, 06 May 2019 12:28:22 +0300
Subject: Re: [PATCH v3 2/2] prctl_set_mm: downgrade mmap_sem to read lock
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>, gorcunov@gmail.com
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <0a48e0a2-a282-159e-a56e-201fbc0faa91@virtuozzo.com>
 <20190502125203.24014-1-mkoutny@suse.com>
 <20190502125203.24014-3-mkoutny@suse.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <961c4d8a-982f-720b-490b-dfb4dae7be25@virtuozzo.com>
Date: Mon, 6 May 2019 12:28:21 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190502125203.24014-3-mkoutny@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.05.2019 15:52, Michal Koutný wrote:
> The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
> semaphore taken.") added synchronization of reading argument/environment
> boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
> arg_lock to protect arg_start|end and env_start|end in mm_struct")
> avoided the coarse use of mmap_sem in similar situations. But there
> still remained two places that (mis)use mmap_sem.
> 
> get_cmdline should also use arg_lock instead of mmap_sem when it reads the
> boundaries.
> 
> The second place that should use arg_lock is in prctl_set_mm. By
> protecting the boundaries fields with the arg_lock, we can downgrade
> mmap_sem to reader lock (analogous to what we already do in
> prctl_set_mm_map).
> 
> v2: call find_vma without arg_lock held
> v3: squashed get_cmdline arg_lock patch
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Mateusz Guzik <mguzik@redhat.com>
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> Co-developed-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  kernel/sys.c | 10 ++++++++--
>  mm/util.c    |  4 ++--
>  2 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 5e0a5edf47f8..14be57840511 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2122,9 +2122,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = -EINVAL;
>  
> -	down_write(&mm->mmap_sem);
> +	/*
> +	 * arg_lock protects concurent updates of arg boundaries, we need mmap_sem for
> +	 * a) concurrent sys_brk, b) finding VMA for addr validation.
> +	 */
> +	down_read(&mm->mmap_sem);
>  	vma = find_vma(mm, addr);
>  
> +	spin_lock(&mm->arg_lock);
>  	prctl_map.start_code	= mm->start_code;
>  	prctl_map.end_code	= mm->end_code;
>  	prctl_map.start_data	= mm->start_data;
> @@ -2212,7 +2217,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = 0;
>  out:
> -	up_write(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
> +	up_read(&mm->mmap_sem);
>  	return error;
>  }
>  
> diff --git a/mm/util.c b/mm/util.c
> index 43a2984bccaa..5cf0e84a0823 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>  	if (!mm->arg_end)
>  		goto out_mm;	/* Shh! No looking before we're done */
>  
> -	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  	arg_start = mm->arg_start;
>  	arg_end = mm->arg_end;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
>  
>  	len = arg_end - arg_start;
>  
> 

