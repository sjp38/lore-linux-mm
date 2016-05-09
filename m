Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BCBD36B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 02:29:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so78168241lfq.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 23:29:26 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id v195si24250548wmv.63.2016.05.08.23.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 23:29:25 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id w143so19007658wmw.3
        for <linux-mm@kvack.org>; Sun, 08 May 2016 23:29:25 -0700 (PDT)
Date: Mon, 9 May 2016 08:29:21 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/4] x86/kasan: Instrument user memory access API
Message-ID: <20160509062921.GA2522@gmail.com>
References: <1462538722-1574-1-git-send-email-aryabinin@virtuozzo.com>
 <1462538722-1574-4-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462538722-1574-4-git-send-email-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, x86@kernel.org


* Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> Exchange between user and kernel memory is coded in assembly language.
> Which means that such accesses won't be spotted by KASAN as a compiler
> instruments only C code.
> Add explicit KASAN checks to user memory access API to ensure that
> userspace writes to (or reads from) a valid kernel memory.
> 
> Note: Unlike others strncpy_from_user() is written mostly in C and KASAN
> sees memory accesses in it. However, it makes sense to add explicit check
> for all @count bytes that *potentially* could be written to the kernel.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: x86@kernel.org
> ---
>  arch/x86/include/asm/uaccess.h    | 5 +++++
>  arch/x86/include/asm/uaccess_64.h | 7 +++++++
>  lib/strncpy_from_user.c           | 2 ++
>  3 files changed, 14 insertions(+)

[...]

> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 3384032..e3472b0 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -1,5 +1,6 @@
>  #include <linux/compiler.h>
>  #include <linux/export.h>
> +#include <linux/kasan-checks.h>
>  #include <linux/uaccess.h>
>  #include <linux/kernel.h>
>  #include <linux/errno.h>
> @@ -103,6 +104,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
>  	if (unlikely(count <= 0))
>  		return 0;
>  
> +	kasan_check_write(dst, count);
>  	max_addr = user_addr_max();
>  	src_addr = (unsigned long)src;
>  	if (likely(src_addr < max_addr)) {

Please do the check inside the condition, before the user_access_begin(), because 
where you've put the check we might still fail and not do a user copy and -EFAULT 
out.

With that fixed:

Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
