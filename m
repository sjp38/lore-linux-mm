Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 81CC76B007E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 02:43:50 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id m82so9803321oif.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:43:50 -0800 (PST)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id gb5si7601270obb.87.2016.03.02.23.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 23:43:49 -0800 (PST)
Received: by mail-oi0-x22d.google.com with SMTP id d205so9838389oia.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 23:43:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56D71BB2.5060503@suse.cz>
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1456448282-897-2-git-send-email-iamjoonsoo.kim@lge.com>
	<56D71BB2.5060503@suse.cz>
Date: Thu, 3 Mar 2016 16:43:49 +0900
Message-ID: <CAAmzW4NwhSKw432qw0Ry+gi=yGpRU-MtC-zQGL27o+XEawLKrg@mail.gmail.com>
Subject: Re: [PATCH v4 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-03-03 1:58 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 02/26/2016 01:58 AM, js1304@gmail.com wrote:
>>
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> CMA allocation should be guaranteed to succeed by definition, but,
>> unfortunately, it would be failed sometimes. It is hard to track down
>> the problem, because it is related to page reference manipulation and
>> we don't have any facility to analyze it.
>>
>> This patch adds tracepoints to track down page reference manipulation.
>> With it, we can find exact reason of failure and can fix the problem.
>> Following is an example of tracepoint output. (note: this example is
>> stale version that printing flags as the number. Recent version will
>> print it as human readable string.)
>>
>> Enabling this feature bloat kernel text 30 KB in my configuration.
>>
>>     text    data     bss     dec     hex filename
>> 12127327        2243616 1507328 15878271         f2487f vmlinux_disabled
>> 12157208        2258880 1507328 15923416         f2f8d8 vmlinux_enabled
>>
>
> That's not bad, and it's even configurable. Thanks for taking the extra care
> about overhead since v1.
>
>> Note that, due to header file dependency problem between mm.h and
>> tracepoint.h, this feature has to open code the static key functions
>> for tracepoints. Proposed by Steven Rostedt in following link.
>>
>> https://lkml.org/lkml/2015/12/9/699
>>
>> v3:
>> o Add commit description and code comment why this patch open code
>> the static key functions for tracepoints.
>> o Notify that example is stale version.
>> o Add "depends on TRACEPOINTS".
>>
>> v2:
>> o Use static key of each tracepoints to avoid function call overhead
>> when tracepoints are disabled.
>> o Print human-readable page flag thanks to newly introduced %pgp option.
>> o Add more description to Kconfig.debug.
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
>> +config DEBUG_PAGE_REF
>> +       bool "Enable tracepoint to track down page reference manipulation"
>> +       depends on DEBUG_KERNEL
>> +       depends on TRACEPOINTS
>> +       ---help---
>> +         This is the feature to add tracepoint for tracking down page
>> reference
>> +         manipulation. This tracking is useful to diagnosis functional
>> failure
>> +         due to migration failure caused by page reference mismatch. Be
>
>
> OK.
>
>> +         careful to turn on this feature because it could bloat some
>> kernel
>> +         text. In my configuration, it bloats 30 KB. Although kernel text
>> will
>> +         be bloated, there would be no runtime performance overhead if
>> +         tracepoint isn't enabled thanks to jump label.
>
>
> I would just write something like:
>
> Enabling this feature adds about 30 KB to the kernel code, but runtime
> performance overhead is virtually none until the tracepoints are actually
> enabled.

Okay, better!
Andrew, do you want fixup patch from me or could you simply handle it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
