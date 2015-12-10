Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 86F7D6B0038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 07:26:56 -0500 (EST)
Received: by vkbs1 with SMTP id s1so79424609vkb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:26:56 -0800 (PST)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id d141si10155227vka.151.2015.12.10.04.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Dec 2015 04:26:55 -0800 (PST)
Received: by vkbs1 with SMTP id s1so79423754vkb.1
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 04:26:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9558837.lN284KClUg@wuerfel>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
	<1449242195-16374-1-git-send-email-vbabka@suse.cz>
	<9558837.lN284KClUg@wuerfel>
Date: Thu, 10 Dec 2015 12:26:53 +0000
Message-ID: <CAAG0J98vnEBq-vXtJcS6p9dvcsnyJpgR25zom238b8a20BKTEg@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
From: James Hogan <james.hogan@imgtec.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, metag <linux-metag@vger.kernel.org>

On 9 December 2015 at 11:29, Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday 04 December 2015 16:16:33 Vlastimil Babka wrote:
>> --- a/include/linux/mmdebug.h
>> +++ b/include/linux/mmdebug.h
>> @@ -2,15 +2,20 @@
>>  #define LINUX_MM_DEBUG_H 1
>>
>>  #include <linux/stringify.h>
>> +#include <linux/types.h>
>> +#include <linux/tracepoint.h>
>
> 8<-----
> Subject: mm: fix generated/bounds.h
>
> The inclusion of linux/tracepoint.h is causing build errors for me in ARM
> randconfig:
>
> In file included from /git/arm-soc/include/linux/ktime.h:25:0,
>                  from /git/arm-soc/include/linux/rcupdate.h:47,
>                  from /git/arm-soc/include/linux/tracepoint.h:19,
>                  from /git/arm-soc/include/linux/mmdebug.h:6,
>                  from /git/arm-soc/include/linux/page-flags.h:10,
>                  from /git/arm-soc/kernel/bounds.c:9:
> /git/arm-soc/include/linux/jiffies.h:10:33: fatal error: generated/timeconst.h: No such file or directory
> compilation terminated.
>
> To work around this, we can stop including linux/mmdebug.h from linux/page_flags.h
> while generating bounds.h, as we do for mm_types.h already.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 8c0d593d0f8f ("mm, printk: introduce new format string for flags")
>
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 19724e6ebd26..4efad0578a28 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -7,8 +7,8 @@
>
>  #include <linux/types.h>
>  #include <linux/bug.h>
> -#include <linux/mmdebug.h>
>  #ifndef __GENERATING_BOUNDS_H
> +#include <linux/mmdebug.h>
>  #include <linux/mm_types.h>
>  #include <generated/bounds.h>
>  #endif /* !__GENERATING_BOUNDS_H */

Same build issue observed for metag too.
Tested-by: James Hogan <james.hogan@imgtec.com>

Cheers
James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
