Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06DDFC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFE6A2147A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:44:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFE6A2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41FD78E000B; Wed, 26 Jun 2019 08:44:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D0658E0005; Wed, 26 Jun 2019 08:44:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2BF8B8E000B; Wed, 26 Jun 2019 08:44:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFD9D8E0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:44:20 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s5so3084149eda.10
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:44:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Hh3iEuxn6hEhKWsSgpsz8EJOK5lvnGFrZoMaN8JZB0E=;
        b=a1GiPnwqsJ9ndr5whqxNGhQr0+p3dpZx00qJ/iWyOkFoaAkz5DvDEz/rEH8nA5RpGg
         bOBeEt1/xm3ut5JKtZsNECHmZW+FUSY2jfG+sl8+58wRloEIkT92lN7Z5EaWODw0/rTD
         yUzKwQibjq7x3B6dfCLKb17UklWfH9RMdCiizoKsVNUrIVUFIz8oKURZFNjAAOEceBjJ
         nZ3JP6c2X6Z4oxNk2ObQ+T/p/8dwM/lPQMQt8XvVOEoMJm7ralx7DiSX64rkBrxB94D8
         AJa0AChgYveYUeC34DiW+96ay2oFjkkyCT64DJEqZn+Fr4iO+jlHUTJbKJaPBof7HZx6
         JXFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAXC4Hdy0vi3E5AukJZaEz945VX9GY83R6IaSGv/aRWCXmvjFItI
	WyFNXpcKL59kgVOZOqSEWtUdUUY+iZ3MHZt01YGHQjlf/gRIEszMbP7YT89NrHBGmMdbzaq1pjZ
	gC0faQ7bVp1IQRtDlcyFD7sM4UF1SmoQIVBgU8Ff9rrIUTs7GrofcFFy2ybnHVuUkNA==
X-Received: by 2002:a50:86ac:: with SMTP id r41mr5013619eda.271.1561553060340;
        Wed, 26 Jun 2019 05:44:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIiLa0q7Dv7bV4yueIkrlpZqPR/XFzAbG7JHfT/T+Begaiu7/NcyYvPTugjVi4KEjIb/GZ
X-Received: by 2002:a50:86ac:: with SMTP id r41mr5013563eda.271.1561553059597;
        Wed, 26 Jun 2019 05:44:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561553059; cv=none;
        d=google.com; s=arc-20160816;
        b=VOAb6LBbQnJo0fhUcQrPoSQvWtsWvB7htOGZ4w0pCxdqn0Zbrzngai+SqOtwWOfz6V
         CGGQUYNq3raXLIZi+absZN01YoHiXVmVeBZecpy1Nj0TG5BbITqCCU3iJKIoc/214J40
         1tyqPEa5tU7JI4aFC14s0QEHdG0XZ6pHts8hsLNAfdMFER9TRT5A1LFfvAY4rffGSinf
         e9a/vS+WwLhEIPuQ9Xt1MjgkQI5i0p6i/PFcBxwi21S6tA0eHoksSbGD2ClFgEDLp6Ht
         owmM7Tmumc6RDll2G8V473ZQTdQRJyT/ifkli9K4PQ6kP3A+GmuO63et5te53peTTwZO
         YXIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Hh3iEuxn6hEhKWsSgpsz8EJOK5lvnGFrZoMaN8JZB0E=;
        b=uAchSDO8BVZYrVZqzMlbFs+IhZmVIdcKppgt8XPILhARi3SLQHWkzCtMqiqnhySV5K
         Vmr5VgDyGRRfCxmvUdUIvOss83tmEc58Le+29DWXQtLYdPJ6jfhFxrzMmfbJpU+NIzlW
         +rLT39LpwO1rSmNlCcEUK7p1Uz09/x25Lk1lDVSiqd+MXYdZoNYy14bJXhE409gQEuSC
         rez6txEokdTEDUbFTkypu0p2J3IGqNl2tRV6SkjL9k2aLRbhdkc34HyqAccF4S2EHJOW
         ++TtMoRcwhCoOm5xLNwYbhSQRd816ig/pNA3tgg3ke4W4nfno8uUJNZNxESOKE+qwoEv
         wgbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c55si3250223edc.323.2019.06.26.05.44.19
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 05:44:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9535DD6E;
	Wed, 26 Jun 2019 05:44:18 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E28603F718;
	Wed, 26 Jun 2019 05:44:16 -0700 (PDT)
Date: Wed, 26 Jun 2019 13:44:14 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Marco Elver <elver@google.com>
Cc: aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com,
	andreyknvl@google.com, linux-kernel@vger.kernel.org,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/4] mm/kasan: Introduce __kasan_check_{read,write}
Message-ID: <20190626124414.GC20635@lakrids.cambridge.arm.com>
References: <20190626122018.171606-1-elver@google.com>
 <20190626122018.171606-2-elver@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626122018.171606-2-elver@google.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 02:20:16PM +0200, Marco Elver wrote:
> This introduces __kasan_check_{read,write} which return a bool if the
> access was valid or not. __kasan_check functions may be used from
> anywhere, even compilation units that disable instrumentation
> selectively. For consistency, kasan_check_{read,write} have been changed
> to also return a bool.
> 
> This change eliminates the need for the __KASAN_INTERNAL definition.

I'm very happy to see __KASAN_INTERNAL go away!

It might be worth splitting that change from the return type change,
since the two are logically unrelated.

> Signed-off-by: Marco Elver <elver@google.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> ---
>  include/linux/kasan-checks.h | 35 ++++++++++++++++++++++++++++-------
>  mm/kasan/common.c            | 14 ++++++--------
>  mm/kasan/generic.c           | 13 +++++++------
>  mm/kasan/kasan.h             | 10 +++++++++-
>  mm/kasan/tags.c              | 12 +++++++-----
>  5 files changed, 57 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> index a61dc075e2ce..b8cf8a7cad34 100644
> --- a/include/linux/kasan-checks.h
> +++ b/include/linux/kasan-checks.h
> @@ -2,14 +2,35 @@
>  #ifndef _LINUX_KASAN_CHECKS_H
>  #define _LINUX_KASAN_CHECKS_H
>  
> -#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
> -void kasan_check_read(const volatile void *p, unsigned int size);
> -void kasan_check_write(const volatile void *p, unsigned int size);
> +/*
> + * __kasan_check_*: Always available when KASAN is enabled. This may be used
> + * even in compilation units that selectively disable KASAN, but must use KASAN
> + * to validate access to an address.   Never use these in header files!
> + */
> +#ifdef CONFIG_KASAN
> +bool __kasan_check_read(const volatile void *p, unsigned int size);
> +bool __kasan_check_write(const volatile void *p, unsigned int size);
>  #else
> -static inline void kasan_check_read(const volatile void *p, unsigned int size)
> -{ }
> -static inline void kasan_check_write(const volatile void *p, unsigned int size)
> -{ }
> +static inline bool __kasan_check_read(const volatile void *p, unsigned int size)
> +{ return true; }
> +static inline bool __kasan_check_write(const volatile void *p, unsigned int size)
> +{ return true; }
> +#endif
> +
> +/*
> + * kasan_check_*: Only available when the particular compilation unit has KASAN
> + * instrumentation enabled. May be used in header files.
> + */
> +#ifdef __SANITIZE_ADDRESS__
> +static inline bool kasan_check_read(const volatile void *p, unsigned int size)
> +{ return __kasan_check_read(p, size); }
> +static inline bool kasan_check_write(const volatile void *p, unsigned int size)
> +{ return __kasan_check_read(p, size); }
> +#else
> +static inline bool kasan_check_read(const volatile void *p, unsigned int size)
> +{ return true; }
> +static inline bool kasan_check_write(const volatile void *p, unsigned int size)
> +{ return true; }

As the body doesn't fit on the same line as the prototype, please follow
the usual coding style:

#ifdef ____SANITIZE_ADDRESS__
static inline bool kasan_check_read(const volatile void *p, unsigned int size)
{
	return __kasan_check_read(p, size);
}

static inline bool kasan_check_write(const volatile void *p, unsigned int size)
{
	return __kasan_check_read(p, size);
}
#else
static inline bool kasan_check_read(const volatile void *p, unsigned int size)
{
	return true;
}

static inline bool kasan_check_write(const volatile void *p, unsigned int size)
{
	return true;
}
#endif

... or use __is_defined() to do the check within the body, .e.g

static inline bool kasan_check_read(const volatile void *p, unsigned int size)
{
	if (__is_defined(__SANITIZE_ADDRESS__))
		return __kasan_check_read(p, size);
	else
		return true;
}

Thanks,
Mark.

>  #endif
>  
>  #endif
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 242fdc01aaa9..2277b82902d8 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -14,8 +14,6 @@
>   *
>   */
>  
> -#define __KASAN_INTERNAL
> -
>  #include <linux/export.h>
>  #include <linux/interrupt.h>
>  #include <linux/init.h>
> @@ -89,17 +87,17 @@ void kasan_disable_current(void)
>  	current->kasan_depth--;
>  }
>  
> -void kasan_check_read(const volatile void *p, unsigned int size)
> +bool __kasan_check_read(const volatile void *p, unsigned int size)
>  {
> -	check_memory_region((unsigned long)p, size, false, _RET_IP_);
> +	return check_memory_region((unsigned long)p, size, false, _RET_IP_);
>  }
> -EXPORT_SYMBOL(kasan_check_read);
> +EXPORT_SYMBOL(__kasan_check_read);
>  
> -void kasan_check_write(const volatile void *p, unsigned int size)
> +bool __kasan_check_write(const volatile void *p, unsigned int size)
>  {
> -	check_memory_region((unsigned long)p, size, true, _RET_IP_);
> +	return check_memory_region((unsigned long)p, size, true, _RET_IP_);
>  }
> -EXPORT_SYMBOL(kasan_check_write);
> +EXPORT_SYMBOL(__kasan_check_write);
>  
>  #undef memset
>  void *memset(void *addr, int c, size_t len)
> diff --git a/mm/kasan/generic.c b/mm/kasan/generic.c
> index 504c79363a34..616f9dd82d12 100644
> --- a/mm/kasan/generic.c
> +++ b/mm/kasan/generic.c
> @@ -166,29 +166,30 @@ static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
>  	return memory_is_poisoned_n(addr, size);
>  }
>  
> -static __always_inline void check_memory_region_inline(unsigned long addr,
> +static __always_inline bool check_memory_region_inline(unsigned long addr,
>  						size_t size, bool write,
>  						unsigned long ret_ip)
>  {
>  	if (unlikely(size == 0))
> -		return;
> +		return true;
>  
>  	if (unlikely((void *)addr <
>  		kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
>  		kasan_report(addr, size, write, ret_ip);
> -		return;
> +		return false;
>  	}
>  
>  	if (likely(!memory_is_poisoned(addr, size)))
> -		return;
> +		return true;
>  
>  	kasan_report(addr, size, write, ret_ip);
> +	return false;
>  }
>  
> -void check_memory_region(unsigned long addr, size_t size, bool write,
> +bool check_memory_region(unsigned long addr, size_t size, bool write,
>  				unsigned long ret_ip)
>  {
> -	check_memory_region_inline(addr, size, write, ret_ip);
> +	return check_memory_region_inline(addr, size, write, ret_ip);
>  }
>  
>  void kasan_cache_shrink(struct kmem_cache *cache)
> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
> index 3ce956efa0cb..e62ea45d02e3 100644
> --- a/mm/kasan/kasan.h
> +++ b/mm/kasan/kasan.h
> @@ -123,7 +123,15 @@ static inline bool addr_has_shadow(const void *addr)
>  
>  void kasan_poison_shadow(const void *address, size_t size, u8 value);
>  
> -void check_memory_region(unsigned long addr, size_t size, bool write,
> +/**
> + * check_memory_region - Check memory region, and report if invalid access.
> + * @addr: the accessed address
> + * @size: the accessed size
> + * @write: true if access is a write access
> + * @ret_ip: return address
> + * @return: true if access was valid, false if invalid
> + */
> +bool check_memory_region(unsigned long addr, size_t size, bool write,
>  				unsigned long ret_ip);
>  
>  void *find_first_bad_addr(void *addr, size_t size);
> diff --git a/mm/kasan/tags.c b/mm/kasan/tags.c
> index 63fca3172659..0e987c9ca052 100644
> --- a/mm/kasan/tags.c
> +++ b/mm/kasan/tags.c
> @@ -76,7 +76,7 @@ void *kasan_reset_tag(const void *addr)
>  	return reset_tag(addr);
>  }
>  
> -void check_memory_region(unsigned long addr, size_t size, bool write,
> +bool check_memory_region(unsigned long addr, size_t size, bool write,
>  				unsigned long ret_ip)
>  {
>  	u8 tag;
> @@ -84,7 +84,7 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
>  	void *untagged_addr;
>  
>  	if (unlikely(size == 0))
> -		return;
> +		return true;
>  
>  	tag = get_tag((const void *)addr);
>  
> @@ -106,22 +106,24 @@ void check_memory_region(unsigned long addr, size_t size, bool write,
>  	 * set to KASAN_TAG_KERNEL (0xFF)).
>  	 */
>  	if (tag == KASAN_TAG_KERNEL)
> -		return;
> +		return true;
>  
>  	untagged_addr = reset_tag((const void *)addr);
>  	if (unlikely(untagged_addr <
>  			kasan_shadow_to_mem((void *)KASAN_SHADOW_START))) {
>  		kasan_report(addr, size, write, ret_ip);
> -		return;
> +		return false;
>  	}
>  	shadow_first = kasan_mem_to_shadow(untagged_addr);
>  	shadow_last = kasan_mem_to_shadow(untagged_addr + size - 1);
>  	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
>  		if (*shadow != tag) {
>  			kasan_report(addr, size, write, ret_ip);
> -			return;
> +			return false;
>  		}
>  	}
> +
> +	return true;
>  }
>  
>  #define DEFINE_HWASAN_LOAD_STORE(size)					\
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

