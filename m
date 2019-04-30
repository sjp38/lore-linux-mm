Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C1DEC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:56:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01D2921670
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 08:56:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01D2921670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C6296B0003; Tue, 30 Apr 2019 04:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 677026B0005; Tue, 30 Apr 2019 04:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 567096B0007; Tue, 30 Apr 2019 04:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E70E36B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 04:56:00 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 140so2631857ljj.17
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 01:56:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LukcHgUQaGJXh28ZEJOz1zFynhdWtgCfC8B+x85eEdo=;
        b=cwM8b4cHQoBVLwrQdR8jWAyghX0Vg1tcdHIAXnuZbZmcdMNYJFk6fcJu4/oOT7WAO2
         4kyIUzmA0/tFy0+SLDOS/cqDUnQ+Y7KclLUnxLc2aFhGhYn7zG0zjb9niScFs5mAbl3q
         58XFL1qNpfniZS6T/65t2AoNxWNkb0cilIiNhQUgCCUcTFe6lFKK1N+xx7HsVzqh7kgq
         RuKtfGNkw/Qx4lIcnWjDe1Cg1cyOshvhqS5VQ6LdRpCaDo5QHjK+RSTpkRRIzdEs/xrn
         TJ152+qlmXNRVrnkYUqomXKYOhg2GxsSOeUpx3Cad40HDGgDRSlLPScTU67EqD814nTO
         Ti9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVgZ86/67IAtCaKw+eWOtuB3aITd1C568DszGDsLUXGGyXnEy8i
	UeN4Rz1iZoUWjTm/7Cq8R3likkA9kIvaE11etqjA44noaYbzmz+xYbfIWILzikQMPJJ+zJ0PyZw
	LSzJGup0giv72rCwrzfTvIyxNjK3HWENOEFhrf68dCrnH6rb3m7LkfCeQu5Y4/Lwz6w==
X-Received: by 2002:a19:f243:: with SMTP id d3mr1104362lfk.168.1556614560207;
        Tue, 30 Apr 2019 01:56:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZB+0iTjvvW6mvKLlNA7rfvoUeM4tLS+uroEdlTsJr5mpZP8UlhJNG1gb2Y0vBW5SKmg90
X-Received: by 2002:a19:f243:: with SMTP id d3mr1104322lfk.168.1556614559135;
        Tue, 30 Apr 2019 01:55:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556614559; cv=none;
        d=google.com; s=arc-20160816;
        b=h8vh6qZKkQqp4VRfShsFzLLbMbAoV13ZcMYwDsmgusC6BUJzaG9y43cGo5FuRLxe/j
         /0hLrK6OEvjq5VFHFcfNEbLM40NYyiwrM514U8aN1RF+rlla7y8HVp9y0Qd9BkuHICtm
         9tyjhnUMt41QrDqrj7VcgwhWh+J55loAz24X9l5xcZrAVmjcm8beqg2TlW//8QBx/xJy
         DkuVkXMPrV3fiaXgIZr3CwaIBFAmR3UfmV6vVJdqosoQRe3qiGciuyTBsoA1ALfq+UbR
         yIuPVuefg5cuTtDMixPbLLjQwj2sQGbqiSnhSv2o8TM+qifu/zgtAmXTpqTc5gq/iUi2
         GGbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LukcHgUQaGJXh28ZEJOz1zFynhdWtgCfC8B+x85eEdo=;
        b=qoaqSIchpOU+Pw7R4lR+UzX5SrdcfuZCCdTZchr0oPOHHb7AJ1hOhj5sus73MFqGq3
         OgSXCrY1KjWPHlmu/pRxHMFzQ55hsICayIYTNdeSc+lNXKki1KCYSHTxhlCTerNTVtPb
         DbdlZOgqYQZKnjzWJi5pInZOIb9sZWyUqDxSjKSjxJtt1eIXp21DOBo4jdVhE9PTQuZF
         JKC0F5FctDL5oQ1F3LnxmfspD5Vrj70csKaLxpDsFjFe8XqDcc8pjJz+HZodF8jVYPiX
         Ym3735o2OOucy6jKjBeIZVv828IKjt02QFlkUvVQDYbx+amWNq/gCOdrwSMsPUlgNVOY
         iwww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e3si16747854lfn.35.2019.04.30.01.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 01:55:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hLOYF-0007NC-34; Tue, 30 Apr 2019 11:55:47 +0300
Subject: Re: [PATCH 3/3] prctl_set_mm: downgrade mmap_sem to read lock
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>, gorcunov@gmail.com
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-4-mkoutny@suse.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <af8f7958-06aa-7134-c750-b7a994368e89@virtuozzo.com>
Date: Tue, 30 Apr 2019 11:55:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190430081844.22597-4-mkoutny@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2019 11:18, Michal Koutný wrote:
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect
> arg_start|end and env_start|end in mm_struct") we use arg_lock for
> boundaries modifications. Synchronize prctl_set_mm with this lock and
> keep mmap_sem for reading only (analogous to what we already do in
> prctl_set_mm_map).
> 
> v2: call find_vma without arg_lock held
> 
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> CC: Laurent Dufour <ldufour@linux.ibm.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> ---
>  kernel/sys.c | 10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index e1acb444d7b0..641fda756575 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -2123,9 +2123,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
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
> @@ -2213,7 +2218,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  
>  	error = 0;
>  out:
> -	up_write(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
> +	up_read(&mm->mmap_sem);
>  	return error;

Hm, shouldn't spin_lock()/spin_unlock() pair go as a fixup to existing code
in a separate patch? 

Without them, the existing code has a problem at least in get_mm_cmdline().

