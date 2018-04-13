Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8B16B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 11:30:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id k3so3061222pff.23
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 08:30:58 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0119.outbound.protection.outlook.com. [104.47.0.119])
        by mx.google.com with ESMTPS id g15si4237583pgu.112.2018.04.13.08.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 08:30:57 -0700 (PDT)
Subject: Re: [PATCH] kasan: add no_sanitize attribute for clang builds
References: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <b849e2ff-3693-9546-5850-1ddcea23ee29@virtuozzo.com>
Date: Fri, 13 Apr 2018 18:31:46 +0300
MIME-Version: 1.0
In-Reply-To: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paul Lawrence <paullawrence@google.com>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Cc: Kostya Serebryany <kcc@google.com>



On 04/12/2018 08:29 PM, Andrey Konovalov wrote:
> KASAN uses the __no_sanitize_address macro to disable instrumentation
> of particular functions. Right now it's defined only for GCC build,
> which causes false positives when clang is used.
> 
> This patch adds a definition for clang.
> 
> Note, that clang's revision 329612 or higher is required.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  include/linux/compiler-clang.h | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> index ceb96ecab96e..5a1d8580febe 100644
> --- a/include/linux/compiler-clang.h
> +++ b/include/linux/compiler-clang.h
> @@ -25,6 +25,11 @@
>  #define __SANITIZE_ADDRESS__
>  #endif
>  
> +#ifdef CONFIG_KASAN

If, for whatever reason, developer decides to add __no_sanitize_address to some
generic function, guess what will happen next when he/she will try to build CONFIG_KASAN=n kernel?

> +#undef __no_sanitize_address
> +#define __no_sanitize_address __attribute__((no_sanitize("address")))
> +#endif
> +
>  /* Clang doesn't have a way to turn it off per-function, yet. */
>  #ifdef __noretpoline
>  #undef __noretpoline
> 
