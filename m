Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2C951830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:39:11 -0500 (EST)
Received: by mail-oi0-f50.google.com with SMTP id m82so2736887oif.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:39:11 -0800 (PST)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id f10si3003651obt.98.2016.02.18.17.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 17:39:10 -0800 (PST)
Received: by mail-oi0-x234.google.com with SMTP id x21so2739867oix.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:39:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160219003421.GA587@swordfish>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160218092926.083ca007@gandalf.local.home>
	<20160219003421.GA587@swordfish>
Date: Fri, 19 Feb 2016 10:39:10 +0900
Message-ID: <CAAmzW4Ni2uZ_J1dcfHPNPYDc0EDDDOL+_oKD-+OZ=Cmg=8sgGA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-19 9:34 GMT+09:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (02/18/16 09:29), Steven Rostedt wrote:
>> > diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
>> > index 534249c..fd6d9a5 100644
>> > --- a/include/linux/page_ref.h
>> > +++ b/include/linux/page_ref.h
>> > @@ -1,6 +1,54 @@
>> >  #include <linux/atomic.h>
>> >  #include <linux/mm_types.h>
>> >  #include <linux/page-flags.h>
>> > +#include <linux/tracepoint-defs.h>
>> > +
>> > +extern struct tracepoint __tracepoint_page_ref_set;
>> > +extern struct tracepoint __tracepoint_page_ref_mod;
>> > +extern struct tracepoint __tracepoint_page_ref_mod_and_test;
>> > +extern struct tracepoint __tracepoint_page_ref_mod_and_return;
>> > +extern struct tracepoint __tracepoint_page_ref_mod_unless;
>> > +extern struct tracepoint __tracepoint_page_ref_freeze;
>> > +extern struct tracepoint __tracepoint_page_ref_unfreeze;
>> > +
>> > +#ifdef CONFIG_DEBUG_PAGE_REF
>>
>> Please add a comment here. Something to the effect of:
>>
>> /*
>>  * Ideally we would want to use the trace_<tracepoint>_enabled() helper
>>  * functions. But due to include header file issues, that is not
>>  * feasible. Instead we have to open code the static key functions.
>>  *
>>  * See trace_##name##_enabled(void) in include/linux/tracepoint.h
>>  */
>>
>
> not sure if it's worth mentioning in the comment, but the other
> concern here is the performance impact of an extra function call,
> I believe. otherwise, Joonsoo would just do:

It's very natural thing so I'm not sure it is worth mentioning.

> in include/linux/page_ref.h
>
> static inline void set_page_count(struct page *page, int v)
> {
>         atomic_set(&page->_count, v);
>         __page_ref_set(page, v);
> }
> ...
>
>
>
> and in mm/debug_page_ref.c
>
> void __page_ref_set(struct page *page, int v)
> {
>         if (trace_page_ref_set_enabled())
>                 trace_page_ref_set(page, v);
> }
> EXPORT_SYMBOL(__page_ref_set);
> EXPORT_TRACEPOINT_SYMBOL(page_ref_set);

It is what I did in v1.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
