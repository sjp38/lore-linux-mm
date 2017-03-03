Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 664B56B0393
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:14:04 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 203so15136082ith.3
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:14:04 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0132.outbound.protection.outlook.com. [104.47.2.132])
        by mx.google.com with ESMTPS id w202si4371716iof.186.2017.03.03.05.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Mar 2017 05:14:03 -0800 (PST)
Subject: Re: [PATCH v2 1/9] kasan: introduce helper functions for determining
 bug type
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-2-andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <12f7d7bc-23f1-a5b1-5f26-cfe8158e48d5@virtuozzo.com>
Date: Fri, 3 Mar 2017 16:15:10 +0300
MIME-Version: 1.0
In-Reply-To: <20170302134851.101218-2-andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
> Introduce get_shadow_bug_type() function, which determines bug type
> based on the shadow value for a particular kernel address.
> Introduce get_wild_bug_type() function, which determines bug type
> for addresses which don't have a corresponding shadow value.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  mm/kasan/report.c | 40 ++++++++++++++++++++++++++++++----------
>  1 file changed, 30 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index f479365530b6..2790b4cadfa3 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -49,7 +49,13 @@ static const void *find_first_bad_addr(const void *addr, size_t size)
>  	return first_bad_addr;
>  }
>  
> -static void print_error_description(struct kasan_access_info *info)
> +static bool addr_has_shadow(struct kasan_access_info *info)
> +{
> +	return (info->access_addr >=
> +		kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
> +}
> +
> +static const char *get_shadow_bug_type(struct kasan_access_info *info)
>  {
>  	const char *bug_type = "unknown-crash";
>  	u8 *shadow_addr;
> @@ -96,6 +102,27 @@ static void print_error_description(struct kasan_access_info *info)
>  		break;
>  	}
>  
> +	return bug_type;
> +}
> +
> +const char *get_wild_bug_type(struct kasan_access_info *info)

static 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
