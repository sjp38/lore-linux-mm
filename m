Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5226B0343
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 11:20:35 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 15so44640743uai.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:20:35 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id 52si1780700uai.65.2017.03.23.08.20.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 08:20:34 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id r69so38539649vke.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:20:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170323150415.301180-1-arnd@arndb.de>
References: <20170323150415.301180-1-arnd@arndb.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 23 Mar 2017 16:20:12 +0100
Message-ID: <CACT4Y+ayH70gj6sPnbBXdOFCtbeAMCXLpA7O+4k9G0zgtR4ToA@mail.gmail.com>
Subject: Re: [PATCH] kasan: avoid -Wmaybe-uninitialized warning
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Peter Zijlstra <peterz@infradead.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 23, 2017 at 4:04 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> gcc-7 produces this warning:
>
> mm/kasan/report.c: In function 'kasan_report':
> mm/kasan/report.c:351:3: error: 'info.first_bad_addr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>    print_shadow_for_address(info->first_bad_addr);
>    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> mm/kasan/report.c:360:27: note: 'info.first_bad_addr' was declared here
>
> The code seems fine as we only print info.first_bad_addr when there is a shadow,
> and we always initialize it in that case, but this is relatively hard
> for gcc to figure out after the latest rework. Adding an intialization
> in the other code path gets rid of the warning.
>
> Fixes: b235b9808664 ("kasan: unify report headers")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  mm/kasan/report.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index 718a10a48a19..63de3069dceb 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -109,6 +109,8 @@ const char *get_wild_bug_type(struct kasan_access_info *info)
>  {
>         const char *bug_type = "unknown-crash";
>
> +       info->first_bad_addr = (void *)(-1ul);
> +
>         if ((unsigned long)info->access_addr < PAGE_SIZE)
>                 bug_type = "null-ptr-deref";
>         else if ((unsigned long)info->access_addr < TASK_SIZE)
> --
> 2.9.0
>


Acked-by: Dmitry Vyukov <dvyukov@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
