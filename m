Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85A16C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D1ED2184E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:20:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D1ED2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBA376B000A; Thu, 11 Apr 2019 04:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C41E96B000C; Thu, 11 Apr 2019 04:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABE1F6B000D; Thu, 11 Apr 2019 04:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52AB16B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:20:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so2638441edl.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:20:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=CBn9Qb6oVmC3+Ny9V3nQOq2+ZdwY/crTgcTRBRLyhAY=;
        b=rGmFzQ3nkPt9+6pwNEpsxHHmpoINRfEc5r/rgu2QekAOZHq8+s9+jeUrvtaj7w+cXC
         HulWDDnp7hWUnjawVrsv6+Wn+UGKWTz0z8H/JXjsOckgjfETGzAaGL6qtOuXnImRSKwp
         3QYlMGTWuN3U7FAe8BGXqCQ4g31BtsNd0FU9rFqpvC4SQGdncD5P40aP2MLDXqSi2Uzx
         63AdeCIaxJpqlil5Iqqwt+QuDwWILg6GoNNcValKXKW+OlDwGynags4t6QTcv5JX9r7a
         LJO80UmLx9UqutR1Q5ZHW2O3BssNdjMeTiPnJ0CEHugCyy+/vu1J77sNx/BcTT3143VG
         uDlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUXy/v3nuVdCWYiM1tzqWk57GGDRNOoe6h5mOakmI4/qy02EMHp
	RPJXMFYTErf00mfxV8bAH9I/2JaG0MAKRT9tK2A/QccfO5yrEMPkNWhbvG9Z+Cww2WLD0M4JV3m
	R56vtjxeU/WiZABJdE+kYgGrmrfPiVxbYFh1L3PW6QdAgUAREi3I/V/aO6C62mxjVWw==
X-Received: by 2002:a50:ee02:: with SMTP id g2mr18404962eds.124.1554970816855;
        Thu, 11 Apr 2019 01:20:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGwkcjboT+rizd6mSTa8hPAU28PyGHSZiFlVAVC6JgqqUUajTTT8cPUEZgtfhSKJnUlTIA
X-Received: by 2002:a50:ee02:: with SMTP id g2mr18404921eds.124.1554970816035;
        Thu, 11 Apr 2019 01:20:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554970816; cv=none;
        d=google.com; s=arc-20160816;
        b=X7VuNBMd8YiDK8H0hDEZzZIm8Wd9ikJIdEzPbMK+5mzHT8dTyUPEsTWoEDnBSrHqEP
         71/v3fkXENoJdz5fgCGCOTc8/Oyo3UYp6iKa2KmcH9QP+UETzhnUnaQDlfIX9lFVm0bM
         PTQ1qsCR3p4a/FnbDtSXFnon/8ttZ7RuRSs+sVbP72iuBzRHBiHts7N9ENYGRiitv4Dg
         CpAfLDSAWxc6AmP6aIRF4QDfacLYm6LtvVAZ8avLcJv8XPZSsqLkxAT/oyZTsWTZQ/2L
         mC2RG/Ffr+mKPF+u8OUxxGUMhvj/czP/D7DoUqAj/+6TXYAC1dGaFY1Qn34LyQZybSpu
         fKXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=CBn9Qb6oVmC3+Ny9V3nQOq2+ZdwY/crTgcTRBRLyhAY=;
        b=zIVsumFoRpRodqf0TmEEIGYQXFxn5lRLU76NFPd43stx3Za6rwDlqXJ15YH6rUBWKh
         lkpMJZMxgpqIv73CGE//ee3Nnfr7B2srAyIcPmhApOnKxIdnnUs3OkIKCwcOBVgmcR+g
         xy1mftIk2a/2H4YefcN/lTkEt7YyiRH4qdWdtAdd1EWnqy9M20HS1KffJrkmgJIRgvGv
         xYDBFOdrPobqnGR/Euqwwn9ToHuMJWq9Q0Q5662h1tZtzYvZNwXuF9dJ3cIFlEk8DJ78
         pnTEW7qaQF0/iAoa/jZ1p5+6HnmeChYac4Oz3pug7kF7v1UlRfDX6OZk/ZDM0TeqbTJb
         2s9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9si1219200edy.321.2019.04.11.01.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 01:20:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5D48BAE8A;
	Thu, 11 Apr 2019 08:20:15 +0000 (UTC)
Subject: Re: [PATCH] slab: fix an infinite loop in leaks_show()
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 "Tobin C. Harding" <tobin@kernel.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Michal Hocko <mhocko@kernel.org>
References: <20190411032635.10325-1-cai@lca.pw>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <43517646-a808-bccd-a05e-1b583fc411c7@suse.cz>
Date: Thu, 11 Apr 2019 10:20:14 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411032635.10325-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/11/19 5:26 AM, Qian Cai wrote:
> "cat /proc/slab_allocators" could hang forever on SMP machines with
> kmemleak or object debugging enabled due to other CPUs running do_drain()
> will keep making kmemleak_object or debug_objects_cache dirty and unable
> to escape the first loop in leaks_show(),

So what if we don't remove SLAB (yet?) but start removing the debugging
functionality that has been broken for years and nobody noticed. I think
Linus already mentioned that we remove at least the
/proc/slab_allocators file...

> do {
> 	set_store_user_clean(cachep);
> 	drain_cpu_caches(cachep);
> 	...
> 
> } while (!is_store_user_clean(cachep));
> 
> For example,
> 
> do_drain
>   slabs_destroy
>     slab_destroy
>       kmem_cache_free
>         __cache_free
>           ___cache_free
>             kmemleak_free_recursive
>               delete_object_full
>                 __delete_object
>                   put_object
>                     free_object_rcu
>                       kmem_cache_free
>                         cache_free_debugcheck --> dirty kmemleak_object
> 
> One approach is to check cachep->name and skip both kmemleak_object and
> debug_objects_cache in leaks_show(). The other is to set
> store_user_clean after drain_cpu_caches() which leaves a small window
> between drain_cpu_caches() and set_store_user_clean() where per-CPU
> caches could be dirty again lead to slightly wrong information has been
> stored but could also speed up things significantly which sounds like a
> good compromise. For example,
> 
>  # cat /proc/slab_allocators
>  0m42.778s # 1st approach
>  0m0.737s  # 2nd approach
> 
> Fixes: d31676dfde25 ("mm/slab: alternative implementation for DEBUG_SLAB_LEAK")
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/slab.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 9142ee992493..3e1b7ff0360c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4328,8 +4328,12 @@ static int leaks_show(struct seq_file *m, void *p)
>  	 * whole processing.
>  	 */
>  	do {
> -		set_store_user_clean(cachep);
>  		drain_cpu_caches(cachep);
> +		/*
> +		 * drain_cpu_caches() could always make kmemleak_object and
> +		 * debug_objects_cache dirty, so reset afterwards.
> +		 */
> +		set_store_user_clean(cachep);
>  
>  		x[1] = 0;
>  
> 

