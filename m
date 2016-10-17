Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id BDF616B025E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:13:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t73so356661191oie.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:13:35 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40123.outbound.protection.outlook.com. [40.107.4.123])
        by mx.google.com with ESMTPS id g68si10808242otb.98.2016.10.17.01.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 01:13:34 -0700 (PDT)
Subject: Re: [PATCH] kasan: support panic_on_warn
References: <1476465002-2728-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <2b39f90e-2c67-fafb-dc48-f642c62bead6@virtuozzo.com>
Date: Mon, 17 Oct 2016 11:13:42 +0300
MIME-Version: 1.0
In-Reply-To: <1476465002-2728-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, akpm@linux-foundation.org, glider@google.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/14/2016 08:10 PM, Dmitry Vyukov wrote:
> If user sets panic_on_warn, he wants kernel to panic if there is
> anything barely wrong with the kernel. KASAN-detected errors
> are definitely not less benign than an arbitrary kernel WARNING.
> 
> Panic after KASAN errors if panic_on_warn is set.
> 
> We use this for continuous fuzzing where we want kernel to stop
> and reboot on any error.
> 
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: kasan-dev@googlegroups.com
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Alexander Potapenko <glider@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/kasan/report.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 24c1211..ca0bd48 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -133,6 +133,10 @@ static void kasan_end_report(unsigned long *flags)
>  	pr_err("==================================================================\n");
>  	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>  	spin_unlock_irqrestore(&report_lock, *flags);
> +	if (panic_on_warn) {
> +		panic_on_warn = 0;

Why we need to reset panic_on_warn?
I assume this was copied from __warn(). AFAIU in __warn() this protects from recursion:
 __warn() -> painc() ->__warn() -> panic() -> ...
which is possible if WARN_ON() triggered in panic().
But KASAN is protected from such recursion via kasan_disable_current().

> +		panic("panic_on_warn set ...\n");
> +	}
>  	kasan_enable_current();
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
