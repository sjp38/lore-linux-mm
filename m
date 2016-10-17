Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 543B76B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 05:14:15 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e200so359762430oig.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 02:14:15 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0126.outbound.protection.outlook.com. [104.47.1.126])
        by mx.google.com with ESMTPS id w126si11587580oif.264.2016.10.17.02.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 02:14:14 -0700 (PDT)
Subject: Re: [PATCH v2] kasan: support panic_on_warn
References: <1476694764-31986-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <53400e91-cf51-1bff-c5e4-0a02cd9c2290@virtuozzo.com>
Date: Mon, 17 Oct 2016 12:14:19 +0300
MIME-Version: 1.0
In-Reply-To: <1476694764-31986-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, glider@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/17/2016 11:59 AM, Dmitry Vyukov wrote:
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
> 
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
> 
> Changes from v1:
>  - don't reset panic_on_warn before calling panic()
> ---
>  mm/kasan/report.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 24c1211..0ee8211 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -133,6 +133,8 @@ static void kasan_end_report(unsigned long *flags)
>  	pr_err("==================================================================\n");
>  	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
>  	spin_unlock_irqrestore(&report_lock, *flags);
> +	if (panic_on_warn)
> +		panic("panic_on_warn set ...\n");
>  	kasan_enable_current();
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
