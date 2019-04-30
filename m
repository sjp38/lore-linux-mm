Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3022C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9D7020652
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:10:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9D7020652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D2716B0007; Tue, 30 Apr 2019 05:10:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55C446B0008; Tue, 30 Apr 2019 05:10:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D9086B000A; Tue, 30 Apr 2019 05:10:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC3646B0007
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:10:06 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id q2so1679799lff.15
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FIsfZvgOHluTZXTIryj3lfd3dDN6/7zHtU2jtxJbAOk=;
        b=KEQ7bu4uDF/kQMTlkPi1+7+L5D/TWhGEN25S7zoA0CDFsHzHNrLAgmEVxjd1m7slqb
         u9GNp3bLBds9B2syIfFfVaQw9jryHlXawoJiN01utCbVflY1HRTUwgvxiwJwkKY1S4sk
         drCGWHCkjiI4fGwIPlzS/Pe9gfj8xY3BKL+026IKl+HXd8MVaclfzz6BbHRfF6ArGPNa
         EtDtduUuZN1VxDdoKFUw4FP7C0yp6wnJaqZMgvSEhHDvkZbU3iyVbUT/tc4qIyzQwY3t
         29gE4WE5Mrp+8clHxRLZ4enqcC6TepsRSHdFzHcA2L77A92GkE0nmhiaVmCWi6VrcUXu
         beUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAWxOebOUp0wHwrmCnRiRfiDq2piTDO12C92LbIcZgom5kAwKdSs
	j16LxN9+C7/7vn2IF5idRHEhWsbQrrelBKRPEPhfe5Ws52tj9NHLaaGkpjoKiZ6GNbB1Q0q0GLG
	nwk8Zd/6Y77Z4loknlybcjORyUbA2cqntSmzkQUkupRzY+e+TsOVa5EKwZ6jAh0+MZQ==
X-Received: by 2002:a19:ee17:: with SMTP id g23mr36021669lfb.43.1556615406254;
        Tue, 30 Apr 2019 02:10:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdOTKRL7GwLswChwEBVNJyGCpDzQYCYkFVOuYh1cfno0dCzSvbszkfMO4PbYidKi7D1y9A
X-Received: by 2002:a19:ee17:: with SMTP id g23mr36021626lfb.43.1556615405372;
        Tue, 30 Apr 2019 02:10:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556615405; cv=none;
        d=google.com; s=arc-20160816;
        b=fetmP/LiK9T2eMSdhx4MHMHj6JDFU+XCTJ0ZX4cNx1OG5Mr54Np5pjcz1dLwVEKx98
         2ishVMlfOBy4oWDhGxcJJmFeRUCGBwBnNGkH7Fh7G28duWIR7UZbZ9mXNugKT550Oiel
         iB3XDchFQW9dFyp2bqHjdHIJN8b67KzvPj82/6d9g6HkYrF2+oObZOmVRMyUiZ4+VIVZ
         HvBFzVEL/r2xYbaqv5pd8qteabVEEyN/ILJDyMogSBuKJ3RTDmXOWO6HrZghPqK16LLZ
         qy14kEmYGTDx/GTADkzEduwrttA1By6DBtiwiLOqEhW+T0xPVhrTZmybJfuYV2yEqHcv
         iJVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FIsfZvgOHluTZXTIryj3lfd3dDN6/7zHtU2jtxJbAOk=;
        b=FR+/WRwd8S3fU7WCwhmM23T0k++07GfpnkeNwHtrSnwnFv3gW8G2TPZ+q4qGlKRALT
         48LKWKs9y8srTU60qGSi/HYDc0R1u6Bgs8jJsSMnGBqSRaK/kKilzMNwLyEDYmpjm1gn
         kGE1RP+ph+agEyj8BrBxiN17jpRmwkFMKfg2SEI6evBIKWmq8/X/+WLo1HPh/Jlm/uef
         5USDlhfU+pdZ+mWfqLw3nuYMME25knPVm0sTe4joO8LA9ASJF8sjIL7dNknHSKavQJzw
         rgU+JC1qbUyP2l8/nOmOYbky0F6q9veXljTlT36fLGAics7y2f8JTJTC6c9W6Z/MdI0Z
         WVIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id k4si2653182ljc.66.2019.04.30.02.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 02:10:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hLOlz-0007UE-CV; Tue, 30 Apr 2019 12:09:59 +0300
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>, gorcunov@gmail.com
Cc: akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
 geert+renesas@glider.be, ldufour@linux.ibm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
 mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
Date: Tue, 30 Apr 2019 12:09:57 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190430081844.22597-2-mkoutny@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 30.04.2019 11:18, Michal Koutný wrote:
> The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
> semaphore taken.") added synchronization of reading argument/environment
> boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
> arg_lock to protect arg_start|end and env_start|end in mm_struct")
> avoided the coarse use of mmap_sem in similar situations.
> 
> get_cmdline can also use arg_lock instead of mmap_sem when it reads the
> boundaries.
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Mateusz Guzik <mguzik@redhat.com>
> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  mm/util.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
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

This looks OK for me.

But speaking about existing code it's a secret for me, why we ignore arg_lock
in binfmt code, e.g. in load_elf_binary().

