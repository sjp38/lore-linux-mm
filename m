Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8C8C6B0008
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:25:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z11-v6so5681662pgu.1
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:25:44 -0700 (PDT)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10114.outbound.protection.outlook.com. [40.107.1.114])
        by mx.google.com with ESMTPS id u69-v6si13207725pgd.467.2018.05.22.09.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:25:43 -0700 (PDT)
Subject: Re: [PATCH v2 2/2] kasan: fix memory hotplug during boot
References: <20180522100756.18478-1-david@redhat.com>
 <20180522100756.18478-3-david@redhat.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <f4378c56-acc2-a5cf-724c-76cffee28235@virtuozzo.com>
Date: Tue, 22 May 2018 19:26:53 +0300
MIME-Version: 1.0
In-Reply-To: <20180522100756.18478-3-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, "open list:KASAN" <kasan-dev@googlegroups.com>



On 05/22/2018 01:07 PM, David Hildenbrand wrote:
> Using module_init() is wrong. E.g. ACPI adds and onlines memory before
> our memory notifier gets registered.
> 
> This makes sure that ACPI memory detected during boot up will not
> result in a kernel crash.
> 
> Easily reproducable with QEMU, just specify a DIMM when starting up.

         reproducible
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---

Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: <stable@vger.kernel.org>

>  mm/kasan/kasan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 53564229674b..a8b85706e2d6 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -892,5 +892,5 @@ static int __init kasan_memhotplug_init(void)
>  	return 0;
>  }
>  
> -module_init(kasan_memhotplug_init);
> +core_initcall(kasan_memhotplug_init);
>  #endif
> 
