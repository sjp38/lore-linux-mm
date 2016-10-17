Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E46B06B0260
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 04:58:33 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id t73so358033672oie.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 01:58:33 -0700 (PDT)
Received: from EUR03-DB5-obe.outbound.protection.outlook.com (mail-eopbgr40118.outbound.protection.outlook.com. [40.107.4.118])
        by mx.google.com with ESMTPS id s129si7443034oib.138.2016.10.17.01.58.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 01:58:33 -0700 (PDT)
Subject: Re: [PATCH] kasan: support panic_on_warn
References: <1476694624-28366-1-git-send-email-dvyukov@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <9dd34617-da15-fedf-cdab-03b67aefc8ec@virtuozzo.com>
Date: Mon, 17 Oct 2016 11:58:40 +0300
MIME-Version: 1.0
In-Reply-To: <1476694624-28366-1-git-send-email-dvyukov@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, glider@google.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/17/2016 11:57 AM, Dmitry Vyukov wrote:
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
