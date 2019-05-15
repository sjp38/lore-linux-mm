Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E14FFC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:38:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACC702082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 08:38:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACC702082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E80736B000A; Wed, 15 May 2019 04:38:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBA7B6B000C; Wed, 15 May 2019 04:38:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB25D6B000D; Wed, 15 May 2019 04:38:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 692BA6B000A
	for <linux-mm@kvack.org>; Wed, 15 May 2019 04:38:31 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 17so430176lfr.14
        for <linux-mm@kvack.org>; Wed, 15 May 2019 01:38:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BAqHI2ypPGaioUF0B32f2/XIYx142pgDOlaWD+A8+sw=;
        b=PfE+Wa1oC78pg5AsGGLSn7cKECxg8VhrPK3snV2h6qPzjexh+haFNA/anL7SsfZ3sZ
         tUzziu83zoyDguA2GAUfBQQerdx76uL/j1297gHOfr6A0nr77O8F5W0Py9XByWZ1LRGK
         uJmYZj09N0weQutP2Cvmb9jLjfoUDbMq94Updc4Xp23k1hHED4z+OiIipsk60YVjl7nj
         k1XLZWPM1ApDFceY6Td/nm10oE6CnHhdvA/c1zsWSxS6/Hb2GFekP8JDLl6mF7tV5Y3x
         g3b3P0JsYx8gExPi76YOV4NKXUmGLHJhqzw/kYTTxx+oWYQKlesqWku3HFQeBlmNOIkU
         gmAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAW6GaN2h12yquGIurf1r0VEyMwV28hInwXPLEIwSXahIcq+gx7l
	Wb6idsjpBMb0qHnp5yLcZ8ixLG7IF8xFWNP2atqI1ZY2GvVTc1amr2jUx82TlwOV4PUUHZxvOyu
	NZ+sWFSt1lOcZMt0qksgqr2S6ND5kxZ51MGp3LAbD+4XYP9trE+WLfIhY2X8y6Y0QZQ==
X-Received: by 2002:a19:6f4d:: with SMTP id n13mr19490817lfk.57.1557909510853;
        Wed, 15 May 2019 01:38:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZpQlO1IFxrZ6s/IHzfQobgS4x6PVRqnFeVidmpt8+RL6d7PH1q6L0LfLE/neYwu8GStw5
X-Received: by 2002:a19:6f4d:: with SMTP id n13mr19490786lfk.57.1557909510095;
        Wed, 15 May 2019 01:38:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557909510; cv=none;
        d=google.com; s=arc-20160816;
        b=pZlBn1nXnpFafyCCeM0san88r0DuNWCUh6h7gCKlc4FymsbWLOIboN4TRzJvvxSzzG
         CekxOOsHawfodRR3Tf/cdLPLg/JrMv08KVgp7IxTeE5JJX475+dgY5FwyjUaxyczQWhb
         3kKCdSV2TP9odeB9zRYQ0AJMsMAaZgUe3+18piGqqNY0SaDQGIb2d0ymTfL27BKARIc+
         YZsnx8GzUDYzubm8ZOJEbi1KxU8Qor0RtrWlRgCn2OEoYSAVe0l6JdKj/QQpMMQXhRr6
         rF4pOehcvXOG4xYVyag8T43T9+Gnn8l7wfPq+FIu6gSkMEC/oTgSWKLBqLyUD9TVfqWV
         vDGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BAqHI2ypPGaioUF0B32f2/XIYx142pgDOlaWD+A8+sw=;
        b=p+xkHJ9/WO8WMwaoyCTKk3nH4vAqj2oxXWnOh+mmPeeaSWmuUtRk84+Ct/oiiWa/Mf
         OLsZ0LylVc+9bhpBwEwR+O22np0f5rBgGSFeEjHuCz4BSDiVI16KA81/JyeakTDur36M
         ula45bh6ng1lPWonncqAC2jFC0mBtcB4yJuFZt5hWQA3/Mtca+ZyP+YDEBiIJorISz/1
         PNSkejiO8lmwWZEzZv6p+pLY4TIDs3vDbceA/FCDfRbi9M12g0dMBI+5NiBQDkGbTFev
         +fRIEOI7K7k7NgrO4dTe7FWW1fXiRRmgCovelrdc2ry71hcZqsUE6iZGP6CK9vBvGZGC
         WwRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id h5si1031072ljk.81.2019.05.15.01.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 01:38:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQpQZ-0006hD-8M; Wed, 15 May 2019 11:38:19 +0300
Subject: Re: [PATCH] mm: fix protection of mm_struct fields in get_cmdline()
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org,
 mkoutny@suse.com, Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.com>, Yang Shi <yang.shi@linux.alibaba.com>
References: <155790813764.2995.13706842444028749629.stgit@buzz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <f0978f70-716c-0272-d8f0-87dc163d0784@virtuozzo.com>
Date: Wed, 15 May 2019 11:38:18 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155790813764.2995.13706842444028749629.stgit@buzz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Konstantin,

On 15.05.2019 11:15, Konstantin Khlebnikov wrote:
> Since commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|
> end and env_start|end in mm_struct") related mm fields are protected with
> separate spinlock and mmap_sem held for read is not enough for protection.
> 
> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

is this already fixed in Michal's series: https://lkml.org/lkml/2019/5/2/422 ?

Thanks,
Kirill

> ---
>  mm/util.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index e2e4f8c3fa12..540e7c157cf2 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -717,12 +717,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
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

