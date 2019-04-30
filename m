Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3606C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:28:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B48F20835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:28:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B48F20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8CD76B0005; Tue, 30 Apr 2019 05:28:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3DB56B000D; Tue, 30 Apr 2019 05:28:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07DD6B000E; Tue, 30 Apr 2019 05:28:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 579C56B0005
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:28:00 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id v18so2664081lja.21
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:28:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=sBdO13YhmQ8OC+eKLHf0I6IxcUnbyhq+63Svo5AJIHw=;
        b=FyRc9u2AJ1ZQEt3eBOHM7krZtRIeDSMgf7Ig2wf4HOf8we6W17k9R60/B5SZJiFfZI
         F86pkKnpf98uZO9AB6FCq5no60ATUyzw6v54kDmtFeRn2Gv05Ho+ixbVSdRnoULGb28P
         8pAi3pk82Zh7LQZNtm91grIynVoAOzEeHFQVJ6Zzl8n8CjjhbZVZjprEEa3d71z3HwYa
         tjzcXIHsGwcNjPLLQdRtvlujoLKFyabmPfjIBiOEkXFlQVUwtx7KHfjXcLf6H0UpeAGZ
         hkD3mowUSKYR2+Cx0xX9Ja5AkRqwz2S/Ylvs2EXzhY1tEf8RKi04vBfog3JCSiqDQIB7
         I24A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAXbmP0CX24m3xgaseV2jKt0cSXLIew/cOMH11ybuQ/GvxOzoFVP
	Y++SGdkv3ijqPK9p1waeTKlZjAW/Gmv6sODYAO6uQ8cJ4dO9Wg+fyfp6Pbite7RR5WeOyP8csXj
	Rn3KeEJJIK4+IcRtnS/HDfaum7CyG5hDKNaWSIFB7q+2EO5amWNUCwca8VqXsTNyO8w==
X-Received: by 2002:a2e:2e17:: with SMTP id u23mr14391621lju.187.1556616479773;
        Tue, 30 Apr 2019 02:27:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsvY7i2naaoDNgBIdfh7TpigVmH0h3S4jG+51AjuTUSRmfVYFYstR3Tw5HgDBGsLtKtTAp
X-Received: by 2002:a2e:2e17:: with SMTP id u23mr14391577lju.187.1556616478694;
        Tue, 30 Apr 2019 02:27:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556616478; cv=none;
        d=google.com; s=arc-20160816;
        b=dSzL9+i7Bl910Aa0hyg5UjV5US3NpWXk9zhz7lqnzeZmWqXJdR6DhjtpCziepKis9G
         V6yid7JfUN/8Eqrz3uOhazGlJRSP4St6eFDOv88Q+lXlOn7EyN0k7M4GwLw6wQRh740Q
         q7Wbylb8ZhQ38bVPE6JFAhxyW9zSQcxvLz9FeyXsIF+xWC6XNcutmnxLPtMvCPFcUrWe
         7Vu4Rtqvkz950I/lLnzTOjHIMiTCIx017V3/hLv8jKZgJRecTaCkzq+w8ygzxAQyZhzc
         qpYISzwZCYvKIcwhseXwXD47F16gZYksUT8OP0m2NQuMA2NsoUMSX4qlg9p/GLyv3Sp9
         9zNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=sBdO13YhmQ8OC+eKLHf0I6IxcUnbyhq+63Svo5AJIHw=;
        b=XAojhSx34GGUeHQdxdTnTqoyD0BqWzp54/pNBDInz8gk1i/Ejx8gKcpLwnCH9KnBC7
         Y6GgBjIEnLmM3qzmLKunVekyeYWUBKzzLM1lWJem7k02Gk3VyQFXi4i5zpKERpeuCftz
         MZT8gbfJWRs/6F26am89uVCMPLhYRfSGNwFY1sCBG6JobvZpBHS+s4myP01invE//fpV
         ogeOyKGrViim6cDUhBoi3+1erhl0i3jonmWiLmVbbfg7+IAhvD9CMucjmvonIbiGMCD5
         mvKfahc2b31VLqpbW2AbDu/llodVtZesSSUXB2ltOWg7NKSqP0oGu/Mtdg3sbum9Af+a
         CvyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id j21si11321213lfj.85.2019.04.30.02.27.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 02:27:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hLP3E-0007aV-RU; Tue, 30 Apr 2019 12:27:48 +0300
Subject: Re: [PATCH 2/3] prctl_set_mm: Refactor checks from validate_prctl_map
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>, gorcunov@gmail.com
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-3-mkoutny@suse.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <e5353968-5c1b-7706-e5cc-8fb47f70c9ca@virtuozzo.com>
Date: Tue, 30 Apr 2019 12:27:48 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190430081844.22597-3-mkoutny@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2019 11:18, Michal Koutný wrote:
> Despite comment of validate_prctl_map claims there are no capability
> checks, it is not completely true since commit 4d28df6152aa ("prctl:
> Allow local CAP_SYS_ADMIN changing exe_file"). Extract the check out of
> the function and make the function perform purely arithmetic checks.
> 
> This patch should not change any behavior, it is mere refactoring for
> following patch.
> 
> CC: Kirill Tkhai <ktkhai@virtuozzo.com>
> CC: Cyrill Gorcunov <gorcunov@gmail.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  kernel/sys.c | 45 ++++++++++++++++++++-------------------------
>  1 file changed, 20 insertions(+), 25 deletions(-)
> 
> diff --git a/kernel/sys.c b/kernel/sys.c
> index 12df0e5434b8..e1acb444d7b0 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -1882,10 +1882,12 @@ static int prctl_set_mm_exe_file(struct mm_struct *mm, unsigned int fd)
>  }
>  
>  /*
> + * Check arithmetic relations of passed addresses.
> + *
>   * WARNING: we don't require any capability here so be very careful
>   * in what is allowed for modification from userspace.
>   */
> -static int validate_prctl_map(struct prctl_mm_map *prctl_map)
> +static int validate_prctl_map_addr(struct prctl_mm_map *prctl_map)
>  {
>  	unsigned long mmap_max_addr = TASK_SIZE;
>  	struct mm_struct *mm = current->mm;
> @@ -1949,24 +1951,6 @@ static int validate_prctl_map(struct prctl_mm_map *prctl_map)
>  			      prctl_map->start_data))
>  			goto out;
>  
> -	/*
> -	 * Someone is trying to cheat the auxv vector.
> -	 */
> -	if (prctl_map->auxv_size) {
> -		if (!prctl_map->auxv || prctl_map->auxv_size > sizeof(mm->saved_auxv))
> -			goto out;
> -	}
> -
> -	/*
> -	 * Finally, make sure the caller has the rights to
> -	 * change /proc/pid/exe link: only local sys admin should
> -	 * be allowed to.
> -	 */
> -	if (prctl_map->exe_fd != (u32)-1) {
> -		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
> -			goto out;
> -	}
> -
>  	error = 0;
>  out:
>  	return error;
> @@ -1993,11 +1977,17 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>  	if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
>  		return -EFAULT;
>  
> -	error = validate_prctl_map(&prctl_map);
> +	error = validate_prctl_map_addr(&prctl_map);
>  	if (error)
>  		return error;
>  
>  	if (prctl_map.auxv_size) {
> +		/*
> +		 * Someone is trying to cheat the auxv vector.
> +		 */
> +		if (!prctl_map.auxv || prctl_map.auxv_size > sizeof(mm->saved_auxv))
> +			return -EINVAL;
> +
>  		memset(user_auxv, 0, sizeof(user_auxv));
>  		if (copy_from_user(user_auxv,
>  				   (const void __user *)prctl_map.auxv,
> @@ -2010,6 +2000,14 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
>  	}
>  
>  	if (prctl_map.exe_fd != (u32)-1) {
> +		/*
> +		 * Make sure the caller has the rights to
> +		 * change /proc/pid/exe link: only local sys admin should
> +		 * be allowed to.
> +		 */
> +		if (!ns_capable(current_user_ns(), CAP_SYS_ADMIN))
> +			return -EINVAL;
> +
>  		error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
>  		if (error)
>  			return error;
> @@ -2097,7 +2095,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  			unsigned long arg4, unsigned long arg5)
>  {
>  	struct mm_struct *mm = current->mm;
> -	struct prctl_mm_map prctl_map;
> +	struct prctl_mm_map prctl_map = { .auxv = NULL, .auxv_size = 0, .exe_fd = -1 };
>  	struct vm_area_struct *vma;
>  	int error;
>  
> @@ -2139,9 +2137,6 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  	prctl_map.arg_end	= mm->arg_end;
>  	prctl_map.env_start	= mm->env_start;
>  	prctl_map.env_end	= mm->env_end;
> -	prctl_map.auxv		= NULL;
> -	prctl_map.auxv_size	= 0;
> -	prctl_map.exe_fd	= -1;
>  
>  	switch (opt) {
>  	case PR_SET_MM_START_CODE:
> @@ -2181,7 +2176,7 @@ static int prctl_set_mm(int opt, unsigned long addr,
>  		goto out;
>  	}
>  
> -	error = validate_prctl_map(&prctl_map);
> +	error = validate_prctl_map_addr(&prctl_map);
>  	if (error)
>  		goto out;
>  
> 

