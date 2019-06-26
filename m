Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3758C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85FD82084B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:17:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85FD82084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26E388E001A; Wed, 26 Jun 2019 12:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21DE28E0002; Wed, 26 Jun 2019 12:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10E5B8E001A; Wed, 26 Jun 2019 12:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B4F658E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:17:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so3893195edb.1
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QcBn4cqu94i8F4ufUBZvWRMGOwZ2fc5S8X3LYrAGys8=;
        b=WyvhsDhironwWvmHJI0PKnawE7UIsQhjr7XUFUBzwphwOlyOwATuy5DIm5xv+gu79X
         oWJ8fOhbsiiKGqTVJwhC1Qlv0JWzh8rt00KWfTQIBiqTAz97Jxmkt7mD5Z3GtN1r/KN1
         BQaGahxAf/pFgRK1KsISzYPNrdgoMD7XgpYPAE5FE0PUh7ru3Oo5EFDLDlqXX3KD04AL
         knOnQmb+KCIAK1HgckJ0K4dNiQX4rfEU6UO3YllJOOdAfDjZ2Q1WnUhRDVF2KQ+FsbLK
         0C1ibgMUl1/w5cr8go63DSTSAY27xF4THCQ/cJQMSeHqTlr2OoIPEYwDcyY1imc0X67s
         0d5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAWbPm+C3esEr6M+VTkP5/benbfK5pRoL3IdmADJTzLgvVhq/fgD
	VMAiR7nWhvzZmwTNryN5mZz9lYembqMCjHdFswWvlJy8mrJ1C7MUV0i2871yWA6ZFsLOX5xftdi
	MLn6csJF+6PhBhBl8XvkshrBYOmbHwRq1iMxCznEi6Yo6nvreM50RCtj7UradjdWPYQ==
X-Received: by 2002:a17:906:4e8f:: with SMTP id v15mr4827186eju.47.1561565874267;
        Wed, 26 Jun 2019 09:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpjZyuY4MpNPNVrFjBfgWcG/5Mn5nV8LJ6hJkQ4PStiv3X/bLRc8Bcq66uexDdExBl+703
X-Received: by 2002:a17:906:4e8f:: with SMTP id v15mr4827105eju.47.1561565873249;
        Wed, 26 Jun 2019 09:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561565873; cv=none;
        d=google.com; s=arc-20160816;
        b=aiE+R3RjuUe58vVd6mtBF61aHyZtUDoLVL6CJgtXbyxV0sNYTGPTXP+tNxjgqxfbJo
         kJyA+m+JHtKVOdVnYTSeLB/YJOojqTcAvXWPJqVYhe1bPcB9uwI7DoIbiJZI3kSwYdnK
         AUFtMJ3uohOqzyA5wF4LHiFQH8fGsuXdfiF4qM7Qj0jPcbdiRFFD4D/r9y8y9yWplyFj
         BauZkMwlDBuq0U6LGJhc3dYj1IOOzH5qekZIC3XJTWlfvmWO4mwSRy69YvTqf4i5uJOO
         RAvrNu/xBhjGop5kfkvUWBLVOeHBzsjJ3x/E8ue3AUxOTqK65bRXHohH9B+pcCCBjpXs
         UCIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QcBn4cqu94i8F4ufUBZvWRMGOwZ2fc5S8X3LYrAGys8=;
        b=CcgsLIM8nwjXbbUsveKgAVif5CNIB7A64MYq6iyNf3YsLo3i/eo5d/V54VkTjOaZMa
         ASkpp9P+DYv8Q6ajIXyARvD/W7bXncthmyazpS2J99MI8HbVUn4uyj5XcyGsFVNMpChc
         rgGetQ3CqHbLj9JQmxuuA8KPThrDnJRIiCJcCiCfEve+fJsyWyT3pGCViyFM+aUXFdxq
         DSPZwxkSFiWw1INjyUPJV86PQsETWtOJ6pEQNNmFmulO5Gd3kxBs8vUYFzneNDPl1s+p
         h6P6+KT6Pe0SiAWw5tk6Xc2ILfwKSeknHgUzMOhl4qruaAe5yTk6yA2xFHHEvdLqvaep
         SxIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f36si3934286edd.292.2019.06.26.09.17.52
        for <linux-mm@kvack.org>;
        Wed, 26 Jun 2019 09:17:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 458BE2B;
	Wed, 26 Jun 2019 09:17:52 -0700 (PDT)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 93CED3F706;
	Wed, 26 Jun 2019 09:17:50 -0700 (PDT)
Date: Wed, 26 Jun 2019 17:17:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Marco Elver <elver@google.com>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/5] mm/kasan: Introduce __kasan_check_{read,write}
Message-ID: <20190626161748.GH20635@lakrids.cambridge.arm.com>
References: <20190626142014.141844-1-elver@google.com>
 <20190626142014.141844-2-elver@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626142014.141844-2-elver@google.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 04:20:10PM +0200, Marco Elver wrote:
> This introduces __kasan_check_{read,write}. __kasan_check functions may
> be used from anywhere, even compilation units that disable
> instrumentation selectively.
> 
> This change eliminates the need for the __KASAN_INTERNAL definition.
> 
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
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: kasan-dev@googlegroups.com
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Logically this makes sense to me, so FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

> ---
> v3:
> * Fix Formatting and split introduction of __kasan_check_* and returning
>   bool into 2 patches.
> ---
>  include/linux/kasan-checks.h | 31 ++++++++++++++++++++++++++++---
>  mm/kasan/common.c            | 10 ++++------
>  2 files changed, 32 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> index a61dc075e2ce..19a0175d2452 100644
> --- a/include/linux/kasan-checks.h
> +++ b/include/linux/kasan-checks.h
> @@ -2,9 +2,34 @@
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
> +void __kasan_check_read(const volatile void *p, unsigned int size);
> +void __kasan_check_write(const volatile void *p, unsigned int size);
> +#else
> +static inline void __kasan_check_read(const volatile void *p, unsigned int size)
> +{ }
> +static inline void __kasan_check_write(const volatile void *p, unsigned int size)
> +{ }
> +#endif
> +
> +/*
> + * kasan_check_*: Only available when the particular compilation unit has KASAN
> + * instrumentation enabled. May be used in header files.
> + */
> +#ifdef __SANITIZE_ADDRESS__
> +static inline void kasan_check_read(const volatile void *p, unsigned int size)
> +{
> +	__kasan_check_read(p, size);
> +}
> +static inline void kasan_check_write(const volatile void *p, unsigned int size)
> +{
> +	__kasan_check_read(p, size);
> +}
>  #else
>  static inline void kasan_check_read(const volatile void *p, unsigned int size)
>  { }
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 242fdc01aaa9..6bada42cc152 100644
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
> +void __kasan_check_read(const volatile void *p, unsigned int size)
>  {
>  	check_memory_region((unsigned long)p, size, false, _RET_IP_);
>  }
> -EXPORT_SYMBOL(kasan_check_read);
> +EXPORT_SYMBOL(__kasan_check_read);
>  
> -void kasan_check_write(const volatile void *p, unsigned int size)
> +void __kasan_check_write(const volatile void *p, unsigned int size)
>  {
>  	check_memory_region((unsigned long)p, size, true, _RET_IP_);
>  }
> -EXPORT_SYMBOL(kasan_check_write);
> +EXPORT_SYMBOL(__kasan_check_write);
>  
>  #undef memset
>  void *memset(void *addr, int c, size_t len)
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

