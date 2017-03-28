Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B78236B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 19:29:45 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 79so129591281pgf.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:29:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e3si5377865plj.114.2017.03.28.16.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:29:44 -0700 (PDT)
Date: Tue, 28 Mar 2017 16:29:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: avoid -Wmaybe-uninitialized warning
Message-Id: <20170328162942.eb08b50af725428a4be25f2b@linux-foundation.org>
In-Reply-To: <20170323150415.301180-1-arnd@arndb.de>
References: <20170323150415.301180-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, Peter Zijlstra <peterz@infradead.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 23 Mar 2017 16:04:09 +0100 Arnd Bergmann <arnd@arndb.de> wrote:

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
> ...
>
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -109,6 +109,8 @@ const char *get_wild_bug_type(struct kasan_access_info *info)
>  {
>  	const char *bug_type = "unknown-crash";
>  
> +	info->first_bad_addr = (void *)(-1ul);
> +
>  	if ((unsigned long)info->access_addr < PAGE_SIZE)
>  		bug_type = "null-ptr-deref";
>  	else if ((unsigned long)info->access_addr < TASK_SIZE)

A weird, ugly and seemingly-unneeded statement should have a comment
explaining its existence, no?

Fortunately it is no longer needed.  We now have:

static void print_error_description(struct kasan_access_info *info)
{
	const char *bug_type = "unknown-crash";
	u8 *shadow_addr;

	info->first_bad_addr = find_first_bad_addr(info->access_addr,
						info->access_size);

	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);

	...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
