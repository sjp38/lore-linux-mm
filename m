Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDE366B026B
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:41:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u3so5263675pfl.5
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 08:41:44 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0130.outbound.protection.outlook.com. [104.47.2.130])
        by mx.google.com with ESMTPS id x22si3279462pgc.53.2017.11.30.08.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 08:41:43 -0800 (PST)
Subject: Re: [PATCH v2 5/5] kasan: add compiler support for clang
References: <20171129215050.158653-1-paullawrence@google.com>
 <20171129215050.158653-6-paullawrence@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <8b1a30b7-9c16-ac0a-3cc1-6fb70247add0@virtuozzo.com>
Date: Thu, 30 Nov 2017 19:45:10 +0300
MIME-Version: 1.0
In-Reply-To: <20171129215050.158653-6-paullawrence@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Lawrence <paullawrence@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>



On 11/30/2017 12:50 AM, Paul Lawrence wrote:
> For now we can hard-code ASAN ABI level 5, since historical clang builds
> can't build the kernel anyway.  We also need to emulate gcc's
> __SANITIZE_ADDRESS__ flag, or memset() calls won't be instrumented.
> 
> Signed-off-by: Greg Hackmann <ghackmann@google.com>
> Signed-off-by: Paul Lawrence <paullawrence@google.com>
> 
> ---
>  include/linux/compiler-clang.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> index 3b609edffa8f..d02a4df3f473 100644
> --- a/include/linux/compiler-clang.h
> +++ b/include/linux/compiler-clang.h
> @@ -19,3 +19,11 @@
>  
>  #define randomized_struct_fields_start	struct {
>  #define randomized_struct_fields_end	};
> +
> +/* all clang versions usable with the kernel support KASAN ABI version 5 */
> +#define KASAN_ABI_VERSION 5
> +

This patch should be earlier in this series. Patch 4/5 breaks clang-built kernel, because
we start using globals instrumentation with wrong KASAN_ABI_VERSION.

> +/* emulate gcc's __SANITIZE_ADDRESS__ flag */
> +#if __has_feature(address_sanitizer)
> +#define __SANITIZE_ADDRESS__
> +#endif
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
