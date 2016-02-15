Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 40DF3828E2
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 09:18:43 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id jq7so28871091obb.0
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:18:43 -0800 (PST)
Received: from mail-ob0-x241.google.com (mail-ob0-x241.google.com. [2607:f8b0:4003:c01::241])
        by mx.google.com with ESMTPS id np10si12484696oeb.30.2016.02.15.06.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 06:18:42 -0800 (PST)
Received: by mail-ob0-x241.google.com with SMTP id il1so16382090obb.2
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 06:18:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160215052855.GA2010@swordfish>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
	<20160215050858.GA556@swordfish>
	<20160215052855.GA2010@swordfish>
Date: Mon, 15 Feb 2016 23:18:42 +0900
Message-ID: <CAAmzW4Nwe45dn5iPKmK_t1F6=+d1K4xqHAn+CfTxL6uvsxQhqw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steven Rostedt <rostedt@goodmis.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-02-15 14:28 GMT+09:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (02/15/16 14:08), Sergey Senozhatsky wrote:
>>
>> will this compile with !CONFIG_TRACEPOINTS config?
>>

Yes, even if !CONFIG_TRACEPOINTS, it is compiled well.

> uh.. sorry, was composed in email client. seems the correct way to do it is
>
> +#if defined CONFIG_DEBUG_PAGE_REF && defined CONFIG_TRACEPOINTS
>
>  #include <linux/tracepoint-defs.h>
>
>  #define page_ref_tracepoint_active(t) static_key_false(&(t).key)
>
>  extern struct tracepoint __tracepoint_page_ref_set;
>  ...
>
>  extern void __page_ref_set(struct page *page, int v);
>  ...
>
> #else
>
>  #define page_ref_tracepoint_active(t) false
>
>  static inline void __page_ref_set(struct page *page, int v)
>  {
>  }
>  ...
>
> #endif
>
>
>
> or add a dependency of PAGE_REF on CONFIG_TRACEPOINTS in Kconfig.

Thanks for catching it.
I will add "depends on CONFIG_TRACEPOINTS" to Kconfig because
this feature has no meaning if !CONFIG_TRACEPOINTS.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
