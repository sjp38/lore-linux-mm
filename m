Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70D86C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:28:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D08D2064B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:28:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D08D2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 972346B02BC; Tue, 16 Apr 2019 11:28:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F8736B02BE; Tue, 16 Apr 2019 11:28:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79B966B02BF; Tue, 16 Apr 2019 11:28:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 21E6D6B02BC
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:28:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e6so11136561edi.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:28:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=T8IoNJ8HpW2rQvsT2Nm2hixuPlh3C7s9juXoxt2P7kM=;
        b=J+LNpQzoVCDS7gCHSCcnyhDkuryiZO22LxVb2u4l4kDWXLB3Z9Sz08L+jD2Rb/q+7H
         Ql4hiMFjmS7sfTR8h7gKddIvbE8YoT+hrJGClnjnErFuewOBXgGEwR293spU8TfD2Cve
         CIPY/804VaUjf1Et4dPltuEMeuZ9eYQLkdl4My8lXe2dFUbhBsY9SEt6J56/p6/y5IVz
         k1a87kacIw0cHZMR32WYN6DuWv2frzkiB0hIirzXbZcKs2B99nph+8I4NOBam+b/zXxS
         uvIDl1dm1uxJpQpdk2TUrh0XLU0cdNw8GPGsOnhjPjTK4+ocxhzS2xCSBtk/+67NgHQD
         OHZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUC0ZkZivbkD8VtVbRTIgpG0C1CKaIYo3eIgP5mvNhJdKEHXOW2
	y7+4/OANQGkkpXVXUOLtZgKcbCeQkYkD9P9OiLvRaqtswGjo+3UXQTUsMtXayR5vKyWWnBpaEcu
	IrQuC1w3mI5HrpvtL2kxYa9PEsGC+pxYheIPssCoym33dXnLNgs0hDoMcxumpk+dnXg==
X-Received: by 2002:a17:906:29c1:: with SMTP id y1mr42700912eje.251.1555428504511;
        Tue, 16 Apr 2019 08:28:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1YGphbjQ7KwU+V1XSXMMEjyPzeS4MeTpH2kQ651DvORj5hDiqHyly5ZqewmqHzLk1ybUZ
X-Received: by 2002:a17:906:29c1:: with SMTP id y1mr42700829eje.251.1555428502857;
        Tue, 16 Apr 2019 08:28:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555428502; cv=none;
        d=google.com; s=arc-20160816;
        b=znxulnmFQDwgznmfR9iFnpCANuBUGA10j5K7J1vDEVNS6WT+b+bCZ8wyGE6g9FmNRF
         6fe1cmALJJNhBMha1vRAJKlUfZz0kyqD/xi8azoZaJHCl6HT5fyJddJrQvaqN4uyAe37
         PCdtrlETkFysYbMPp97PY99H8iXgDjOvGp4cfKU6EFXtUkIxe45WpB32p+iNPrzHXJFG
         5sudQwH90bhfZkKtMqI5OKMMVSJAb3eGJkgYL03Rt0DwihV3svWw1EOmzJPHiASqkak5
         U+SrgqRvTNDrPn9XUjy1/WlHKQGbz870ukJ3n/QoTtUx0mS3hjlDKqFv5xyQ0eOcdHW4
         oWQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=T8IoNJ8HpW2rQvsT2Nm2hixuPlh3C7s9juXoxt2P7kM=;
        b=x7F6aiphOyxlup3ai/4DhsnX7d/4Jb3bjKp7Ct/v2jrT1cU6QvHRrrb4Ae/syXJ9Bu
         TcSTgHLAHRLIp58AiM535yGp9jMoTUGZpS9hh0XtYZL1TR5XbjVIrOXs7aE7m3P6jGtV
         t0654mvjAbgZw0DexaKw6ZTh1EQMDxn8uTIaZEH81lh0wMicKeD7Mqon+IqQ8QiOXSmP
         D60vXkrBy3Qa3yXZL0n2HxA/VEJxexj6m9/G8ZOKp8u5bUP0SqJqS3nLeMhOeL7NMKk9
         tbdoh2oRzqog40cg07kVdfkwLC/o4A0kUIBTAW61B9gN9vbeqi33Ey7RQuFIftu35SLK
         msTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si2961114edh.122.2019.04.16.08.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:28:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1BAA3AE3D;
	Tue, 16 Apr 2019 15:28:22 +0000 (UTC)
Subject: Re: [PATCH] slab: remove store_stackinfo()
To: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org
Cc: luto@kernel.org, jpoimboe@redhat.com, sean.j.christopherson@intel.com,
 penberg@kernel.org, rientjes@google.com, tglx@linutronix.de,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190416142258.18694-1-cai@lca.pw>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <902fed9c-9655-a241-677d-5fa11b6c95a1@suse.cz>
Date: Tue, 16 Apr 2019 17:25:03 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190416142258.18694-1-cai@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/16/19 4:22 PM, Qian Cai wrote:
> store_stackinfo() does not seem used in actual SLAB debugging.
> Potentially, it could be added to check_poison_obj() to provide more
> information, but this seems like an overkill due to the declining
> popularity of the SLAB, so just remove it instead.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

I've acked Thomas' version already which was narrower, but no objection
to remove more stuff on top of that. Linus (and I later in another
thread) already pointed out /proc/slab_allocators. It only takes a look
at add_caller() there to not regret removing that one.

> ---
>  mm/slab.c | 48 ++++++------------------------------------------
>  1 file changed, 6 insertions(+), 42 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 3e1b7ff0360c..20f318f4f56e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1467,53 +1467,17 @@ static bool is_debug_pagealloc_cache(struct kmem_cache *cachep)
>  }
>  
>  #ifdef CONFIG_DEBUG_PAGEALLOC
> -static void store_stackinfo(struct kmem_cache *cachep, unsigned long *addr,
> -			    unsigned long caller)
> -{
> -	int size = cachep->object_size;
> -
> -	addr = (unsigned long *)&((char *)addr)[obj_offset(cachep)];
> -
> -	if (size < 5 * sizeof(unsigned long))
> -		return;
> -
> -	*addr++ = 0x12345678;
> -	*addr++ = caller;
> -	*addr++ = smp_processor_id();
> -	size -= 3 * sizeof(unsigned long);
> -	{
> -		unsigned long *sptr = &caller;
> -		unsigned long svalue;
> -
> -		while (!kstack_end(sptr)) {
> -			svalue = *sptr++;
> -			if (kernel_text_address(svalue)) {
> -				*addr++ = svalue;
> -				size -= sizeof(unsigned long);
> -				if (size <= sizeof(unsigned long))
> -					break;
> -			}
> -		}
> -
> -	}
> -	*addr++ = 0x87654321;
> -}
> -
> -static void slab_kernel_map(struct kmem_cache *cachep, void *objp,
> -				int map, unsigned long caller)
> +static void slab_kernel_map(struct kmem_cache *cachep, void *objp, int map)
>  {
>  	if (!is_debug_pagealloc_cache(cachep))
>  		return;
>  
> -	if (caller)
> -		store_stackinfo(cachep, objp, caller);
> -
>  	kernel_map_pages(virt_to_page(objp), cachep->size / PAGE_SIZE, map);
>  }
>  
>  #else
>  static inline void slab_kernel_map(struct kmem_cache *cachep, void *objp,
> -				int map, unsigned long caller) {}
> +				int map) {}
>  
>  #endif
>  
> @@ -1661,7 +1625,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
>  
>  		if (cachep->flags & SLAB_POISON) {
>  			check_poison_obj(cachep, objp);
> -			slab_kernel_map(cachep, objp, 1, 0);
> +			slab_kernel_map(cachep, objp, 1);
>  		}
>  		if (cachep->flags & SLAB_RED_ZONE) {
>  			if (*dbg_redzone1(cachep, objp) != RED_INACTIVE)
> @@ -2433,7 +2397,7 @@ static void cache_init_objs_debug(struct kmem_cache *cachep, struct page *page)
>  		/* need to poison the objs? */
>  		if (cachep->flags & SLAB_POISON) {
>  			poison_obj(cachep, objp, POISON_FREE);
> -			slab_kernel_map(cachep, objp, 0, 0);
> +			slab_kernel_map(cachep, objp, 0);
>  		}
>  	}
>  #endif
> @@ -2812,7 +2776,7 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
>  
>  	if (cachep->flags & SLAB_POISON) {
>  		poison_obj(cachep, objp, POISON_FREE);
> -		slab_kernel_map(cachep, objp, 0, caller);
> +		slab_kernel_map(cachep, objp, 0);
>  	}
>  	return objp;
>  }
> @@ -3076,7 +3040,7 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
>  		return objp;
>  	if (cachep->flags & SLAB_POISON) {
>  		check_poison_obj(cachep, objp);
> -		slab_kernel_map(cachep, objp, 1, 0);
> +		slab_kernel_map(cachep, objp, 1);
>  		poison_obj(cachep, objp, POISON_INUSE);
>  	}
>  	if (cachep->flags & SLAB_STORE_USER)
> 

