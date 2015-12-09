Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1805C6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 15:48:47 -0500 (EST)
Received: by wmww144 with SMTP id w144so239222814wmw.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 12:48:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lh8si13799404wjb.110.2015.12.09.12.48.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 12:48:45 -0800 (PST)
Subject: Re: [PATCH v2 1/3] mm, printk: introduce new format string for flags
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
 <9558837.lN284KClUg@wuerfel>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <566893A9.7050704@suse.cz>
Date: Wed, 9 Dec 2015 21:48:41 +0100
MIME-Version: 1.0
In-Reply-To: <9558837.lN284KClUg@wuerfel>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Andi Kleen <andi@firstfloor.org>

On 12/09/2015 12:29 PM, Arnd Bergmann wrote:
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

Thanks and sorry. Andrew can you please include it in mmotm as -fix for now?
I plan to respin the whole of this later with some patch splitting and
reordering to reduce churn and follow Rasmus' advice.

Also I've just learned that there's a new lightweight tracepoint-defs.h in -tip
thanks to Andi, which would be a better place for struct trace_print_flags than
tracepoint.h is, so I'll look into using it for the respin, which should make
this temporary -fix redundant.

> Fixes: 8c0d593d0f8f ("mm, printk: introduce new format string for flags")

Note that the linux-next commit id is volatile here (regenerated from quilt series).

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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
