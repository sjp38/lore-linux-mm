Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 091B2C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 07:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B86CE21019
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 07:21:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B86CE21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 564786B0003; Thu,  9 May 2019 03:21:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53A6D6B0006; Thu,  9 May 2019 03:21:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42B0C6B0007; Thu,  9 May 2019 03:21:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id EBDBD6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 03:21:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x9so1171178wrw.20
        for <linux-mm@kvack.org>; Thu, 09 May 2019 00:21:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=A+wsiT3vu0EmiAAwgNFrbpx1FBKhfF4sMlpe8qyJugA=;
        b=IVMKiqxxu7h07NiCj21sxkemSv8ufImkfaWGE8gWB7s3p+9V9ZQPk1M+DvhSSvCV0T
         L2gNUrnrdToLxnd0yJgynkdbNrj8wkOCo1nKRP8QKPQJozfZoydfh948Q87KCwfAwRIC
         TPr9kUJpoQk08Qb0i5JRFavUDNIgT9MBWjyBsYxxchMA0Q45W2oD8y+QzcEbk25R6VIT
         wRAcyR+JIeD/lUTOvG2mEUvIxkfyhSePrH+dMD5Z2wSdbFtxX9RemBTuJPk8RgcaFxbM
         dD9Ge0Pvqd7/gA6YBmzXKoQ4rbXlMlyZU7vq9+WLsS+indS//1p4lmm4zAMZZqJ4h6Gy
         oCqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Gm-Message-State: APjAAAW8Sfau/rvgrZbVZDZQ0Jj/M1HxzJu2BQD/rRiAFBxXJFMaAiDg
	atwL2GchiOZ368uWnUXbM5brd3XlTSGjVMgdcaFixGviOUNsyjGcplxdsCUMiXlJ4+5y+f9FJ9o
	Q5FfxJi8k0uoY69xt2EI4hwdfdJKxwroHZAvUViEh57cYcTJ3ZdRNWSi9wxkWkxw=
X-Received: by 2002:adf:df88:: with SMTP id z8mr1588467wrl.209.1557386506471;
        Thu, 09 May 2019 00:21:46 -0700 (PDT)
X-Received: by 2002:adf:df88:: with SMTP id z8mr1588413wrl.209.1557386505734;
        Thu, 09 May 2019 00:21:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557386505; cv=none;
        d=google.com; s=arc-20160816;
        b=qTV+41wz9cGW/WnxdXLIr9Hn9z4GEsPWj9WMXfVFJh43HNPMpaRJDDQ7Ml3dYpflRI
         FWHK++7B+xvaWXS1pORfm4GfL0OXbma2VVoOOdj69PjEqeJGLkcbv5Mp8mJwsXPHN5oG
         roAJTFOT12H7Z51jmVhjpWDUUzLUpnLrK9X56rFHGqTlho79tla/Acg9P4hOwGwojgHp
         NWh2ANWCztMKYmTehLQL729BCLG+6FEbA1e3NSsY8qTDHoBtpoCO9fxmES0hxYK8HEez
         VWOEUSVgM+nIbU7X+0XE4VJJYQDmMOrxB2v6XGqXB3zTMH2sfuv19JGeexNMqmRBEE6J
         h12g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=A+wsiT3vu0EmiAAwgNFrbpx1FBKhfF4sMlpe8qyJugA=;
        b=VcGpq3Ceep6bH+29IWBCqe9HMypu2Y7cATxR4dtTfceOUS6QAGQC0QxccEbb6lXfH1
         ORbBGWDE2tPYPfcWxKJxukXeD/j2hI+kX5GxRuDa5wGHPZGRoO1gODJqzJLOFNwhg3v5
         oZ8sK1ceI4Nt1pk5PD0i2k+xO8ygTHo/62lIQkNQg3bKJFwGW9USgYGyVP+/Smi1XMMp
         Kfcv0cyom3XMls9BKQ1WEg2LQvIbAgdVv9BFuVkDb1/HInFCZUHwqaxlm3EhULE8RRC2
         5wMjxOYmqkH76pQdb6khqAUM01pUCgXJ02ILMmrxSRhDEFC1FnKy9x32Bja8eylG+ddu
         al9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14sor826385wre.10.2019.05.09.00.21.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 00:21:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jirislaby@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jirislaby@gmail.com
X-Google-Smtp-Source: APXvYqyl7y9daiOVIO3C57v4YdWzwlKpuBpQ/7t3Cj08OJGRUka8Fb8mCovTsZpHaQXZwRp2bETSZA==
X-Received: by 2002:a5d:6249:: with SMTP id m9mr1590418wrv.255.1557386505152;
        Thu, 09 May 2019 00:21:45 -0700 (PDT)
Received: from ?IPv6:2a0b:e7c0:0:107::49? ([2a0b:e7c0:0:107::49])
        by smtp.gmail.com with ESMTPSA id 130sm1502350wmd.15.2019.05.09.00.21.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 00:21:43 -0700 (PDT)
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>,
 Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>,
 cgroups@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
From: Jiri Slaby <jslaby@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=jslaby@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <414a361f-90c5-36ef-e290-c3551595e854@suse.cz>
Date: Thu, 9 May 2019 09:21:41 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190429105939.11962-1-jslaby@suse.cz>
Content-Type: text/plain; charset=iso-8859-2
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Vladimir,

as you are perhaps the one most familiar with the code, could you take a
look on this?

On 29. 04. 19, 12:59, Jiri Slaby wrote:
> We have a single node system with node 0 disabled:
>   Scanning NUMA topology in Northbridge 24
>   Number of physical nodes 2
>   Skipping disabled node 0
>   Node 1 MemBase 0000000000000000 Limit 00000000fbff0000
>   NODE_DATA(1) allocated [mem 0xfbfda000-0xfbfeffff]
> 
> This causes crashes in memcg when system boots:
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
>   #PF error: [normal kernel read fault]
> ...
>   RIP: 0010:list_lru_add+0x94/0x170
> ...
>   Call Trace:
>    d_lru_add+0x44/0x50
>    dput.part.34+0xfc/0x110
>    __fput+0x108/0x230
>    task_work_run+0x9f/0xc0
>    exit_to_usermode_loop+0xf5/0x100
> 
> It is reproducible as far as 4.12. I did not try older kernels. You have
> to have a new enough systemd, e.g. 241 (the reason is unknown -- was not
> investigated). Cannot be reproduced with systemd 234.
> 
> The system crashes because the size of lru array is never updated in
> memcg_update_all_list_lrus and the reads are past the zero-sized array,
> causing dereferences of random memory.
> 
> The root cause are list_lru_memcg_aware checks in the list_lru code.
> The test in list_lru_memcg_aware is broken: it assumes node 0 is always
> present, but it is not true on some systems as can be seen above.
> 
> So fix this by checking the first online node instead of node 0.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: <cgroups@vger.kernel.org>
> Cc: <linux-mm@kvack.org>
> Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
> ---
>  mm/list_lru.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/list_lru.c b/mm/list_lru.c
> index 0730bf8ff39f..7689910f1a91 100644
> --- a/mm/list_lru.c
> +++ b/mm/list_lru.c
> @@ -37,11 +37,7 @@ static int lru_shrinker_id(struct list_lru *lru)
>  
>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
>  {
> -	/*
> -	 * This needs node 0 to be always present, even
> -	 * in the systems supporting sparse numa ids.
> -	 */
> -	return !!lru->node[0].memcg_lrus;
> +	return !!lru->node[first_online_node].memcg_lrus;
>  }
>  
>  static inline struct list_lru_one *
> 


-- 
js
suse labs

