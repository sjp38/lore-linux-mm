Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DEF76B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 11:10:21 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id hc3so69065601pac.4
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 08:10:21 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50090.outbound.protection.outlook.com. [40.107.5.90])
        by mx.google.com with ESMTPS id gg10si184033pac.148.2016.11.09.08.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 08:10:20 -0800 (PST)
Subject: Re: [PATCH 1/2] stacktrace: fix print_stack_trace printing timestamp
 twice
References: <cover.1478632698.git.andreyknvl@google.com>
 <9df5bd889e1b980d84aa41e7010e622005fd0665.1478632698.git.andreyknvl@google.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <2a6c133d-a42e-34ca-108c-b1399b939d65@virtuozzo.com>
Date: Wed, 9 Nov 2016 19:10:34 +0300
MIME-Version: 1.0
In-Reply-To: <9df5bd889e1b980d84aa41e7010e622005fd0665.1478632698.git.andreyknvl@google.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@redhat.com
Cc: kcc@google.com

On 11/08/2016 10:37 PM, Andrey Konovalov wrote:
> Right now print_stack_trace prints timestamp twice, the first time
> it's done by printk when printing spaces, the second - by print_ip_sym.
> As a result, stack traces in KASAN reports have double timestamps:
> [   18.822232] Allocated by task 3838:
> [   18.822232]  [   18.822232] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
> [   18.822232]  [   18.822232] [<ffffffff81509bd6>] save_stack+0x46/0xd0
> [   18.822232]  [   18.822232] [<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0
> ....
> 
> Fix by calling printk only once.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>


Right, since commit 4bcc595ccd80 ("printk: reinstate KERN_CONT for printing continuation lines")
printk requires KERN_CONT to continue log messages, and print_ip_sym() doesn't have it.

After a small nit bellow fixed:
	Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>

> ---
>  kernel/stacktrace.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
> index b6e4c16..56f510f 100644
> --- a/kernel/stacktrace.c
> +++ b/kernel/stacktrace.c
> @@ -14,13 +14,15 @@
>  void print_stack_trace(struct stack_trace *trace, int spaces)
>  {
>  	int i;
> +	unsigned long ip;

This can be inside for loop.
>  
>  	if (WARN_ON(!trace->entries))
>  		return;
>  
>  	for (i = 0; i < trace->nr_entries; i++) {
> -		printk("%*c", 1 + spaces, ' ');
> -		print_ip_sym(trace->entries[i]);
> +		ip = trace->entries[i];
> +		printk("%*c[<%p>] %pS\n", 1 + spaces, ' ',
> +				(void *) ip, (void *) ip);
>  	}
>  }
>  EXPORT_SYMBOL_GPL(print_stack_trace);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
