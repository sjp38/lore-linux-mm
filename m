Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 886A56B00D3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 18:38:18 -0500 (EST)
Received: by mail-oi0-f51.google.com with SMTP id g201so11278726oib.10
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:38:18 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id y205si30988034oif.105.2014.11.13.15.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 15:38:17 -0800 (PST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so12796241obb.13
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 15:38:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141113152247.GB1408@swordfish>
References: <1415885857-5283-1-git-send-email-opensource.ganesh@gmail.com>
	<20141113152247.GB1408@swordfish>
Date: Fri, 14 Nov 2014 07:38:16 +0800
Message-ID: <CADAEsF80gaDH=uctJeU7_uRBXvL4D_vX_y6Jiw71-u+uErB7ZQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/zsmalloc: avoid unregister a NOT-registered
 zsmalloc zpool driver
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello

2014-11-13 23:22 GMT+08:00 Sergey Senozhatsky <sergey.senozhatsky@gmail.com>:
> On (11/13/14 21:37), Mahendran Ganesh wrote:
>> Now zsmalloc can be registered as a zpool driver into zpool when
>> CONFIG_ZPOOL is enabled. During the init of zsmalloc, when error happens,
>> we need to do cleanup. But in current code, it will unregister a not yet
>> registered zsmalloc zpool driver(*zs_zpool_driver*).
>>
>> This patch puts the cleanup in zs_init() instead of calling zs_exit()
>> where it will unregister a not-registered zpool driver.
>>
>> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
>> ---
>>  mm/zsmalloc.c |   12 ++++++++----
>>  1 file changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> index 839a48c..3d2bb36 100644
>> --- a/mm/zsmalloc.c
>> +++ b/mm/zsmalloc.c
>> @@ -907,10 +907,8 @@ static int zs_init(void)
>>       __register_cpu_notifier(&zs_cpu_nb);
>>       for_each_online_cpu(cpu) {
>>               ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
>> -             if (notifier_to_errno(ret)) {
>> -                     cpu_notifier_register_done();
>> +             if (notifier_to_errno(ret))
>>                       goto fail;
>> -             }
>>       }
>>
>>       cpu_notifier_register_done();
>> @@ -920,8 +918,14 @@ static int zs_init(void)
>>  #endif
>>
>>       return 0;
>> +
>>  fail:
>> -     zs_exit();
>> +     for_each_online_cpu(cpu)
>> +             zs_cpu_notifier(NULL, CPU_UP_CANCELED, (void *)(long)cpu);
>> +     __unregister_cpu_notifier(&zs_cpu_nb);
>> +
>> +     cpu_notifier_register_done();
>> +
>>       return notifier_to_errno(ret);
>
> so we duplicate same code, and there is a bit confusing part
> now: zs_cpu_notifier(CPU_UP_CANCELED) and zs_cpu_notifier(CPU_DEAD)
> calls.

Thanks for your review.

CPU_UP_CANCELED and CPU_DEAD have different scenario.
CPU_UP_CANCELED is better for fail to complete initialization. While
CPU_DEAD is better for exit(such as removing module)

Thanks.

>
> how about something like this?
>
> Factor out zsmalloc cpu notifier unregistration code and call
> it from both zs_exit() and zs_init() error path.
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>
> ---
>
>  mm/zsmalloc.c | 20 +++++++++++---------
>  1 file changed, 11 insertions(+), 9 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index b3b57ef..c4d2d60 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -881,14 +881,10 @@ static struct notifier_block zs_cpu_nb = {
>         .notifier_call = zs_cpu_notifier
>  };
>
> -static void zs_exit(void)
> +static inline void zs_unregister_cpu_notifier()
>  {
>         int cpu;
>
> -#ifdef CONFIG_ZPOOL
> -       zpool_unregister_driver(&zs_zpool_driver);
> -#endif
> -
>         cpu_notifier_register_begin();
>
>         for_each_online_cpu(cpu)
> @@ -898,6 +894,14 @@ static void zs_exit(void)
>         cpu_notifier_register_done();
>  }
>
> +static void zs_exit(void)
> +{
> +#ifdef CONFIG_ZPOOL
> +       zpool_unregister_driver(&zs_zpool_driver);
> +#endif
> +       zs_unregister_cpu_notifier();
> +}
> +
>  static int zs_init(void)
>  {
>         int cpu, ret;
> @@ -907,10 +911,8 @@ static int zs_init(void)
>         __register_cpu_notifier(&zs_cpu_nb);
>         for_each_online_cpu(cpu) {
>                 ret = zs_cpu_notifier(NULL, CPU_UP_PREPARE, (void *)(long)cpu);
> -               if (notifier_to_errno(ret)) {
> -                       cpu_notifier_register_done();
> +               if (notifier_to_errno(ret))
>                         goto fail;
> -               }
>         }
>
>         cpu_notifier_register_done();
> @@ -921,7 +923,7 @@ static int zs_init(void)
>
>         return 0;
>  fail:
> -       zs_exit();
> +       zs_unregister_cpu_notifier();
>         return notifier_to_errno(ret);
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
