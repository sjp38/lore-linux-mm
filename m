Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id E9631828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:29:29 -0500 (EST)
Received: by mail-ig0-f170.google.com with SMTP id y8so13626998igp.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 06:29:29 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0133.hostedemail.com. [216.40.44.133])
        by mx.google.com with ESMTPS id b8si5660151igx.61.2016.02.18.06.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 06:29:29 -0800 (PST)
Date: Thu, 18 Feb 2016 09:29:26 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160218092926.083ca007@gandalf.local.home>
In-Reply-To: <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 15 Feb 2016 12:04:50 +0900
js1304@gmail.com wrote:


> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> index 534249c..fd6d9a5 100644
> --- a/include/linux/page_ref.h
> +++ b/include/linux/page_ref.h
> @@ -1,6 +1,54 @@
>  #include <linux/atomic.h>
>  #include <linux/mm_types.h>
>  #include <linux/page-flags.h>
> +#include <linux/tracepoint-defs.h>
> +
> +extern struct tracepoint __tracepoint_page_ref_set;
> +extern struct tracepoint __tracepoint_page_ref_mod;
> +extern struct tracepoint __tracepoint_page_ref_mod_and_test;
> +extern struct tracepoint __tracepoint_page_ref_mod_and_return;
> +extern struct tracepoint __tracepoint_page_ref_mod_unless;
> +extern struct tracepoint __tracepoint_page_ref_freeze;
> +extern struct tracepoint __tracepoint_page_ref_unfreeze;
> +
> +#ifdef CONFIG_DEBUG_PAGE_REF

Please add a comment here. Something to the effect of:

/*
 * Ideally we would want to use the trace_<tracepoint>_enabled() helper
 * functions. But due to include header file issues, that is not
 * feasible. Instead we have to open code the static key functions.
 *
 * See trace_##name##_enabled(void) in include/linux/tracepoint.h
 */

I may have to work on something that lets these helpers be defined in
headers. I have some ideas on how to do that. But for now, this
solution is fine.

-- Steve


> +#define page_ref_tracepoint_active(t) static_key_false(&(t).key)
> +
> +extern void __page_ref_set(struct page *page, int v);
> +extern void __page_ref_mod(struct page *page, int v);
> +extern void __page_ref_mod_and_test(struct page *page, int v, int ret);
> +extern void __page_ref_mod_and_return(struct page *page, int v, int ret);
> +extern void __page_ref_mod_unless(struct page *page, int v, int u);
> +extern void __page_ref_freeze(struct page *page, int v, int ret);
> +extern void __page_ref_unfreeze(struct page *page, int v);
> +
> +#else
> +
> +#define page_ref_tracepoint_active(t) false
> +
> +static inline void __page_ref_set(struct page *page, int v)
> +{
> +}
> +static inline void __page_ref_mod(struct page *page, int v)
> +{
> +}
> +static inline void __page_ref_mod_and_test(struct page *page, int v, int ret)
> +{
> +}
> +static inline void __page_ref_mod_and_return(struct page *page, int v, int ret)
> +{
> +}
> +static inline void __page_ref_mod_unless(struct page *page, int v, int u)
> +{
> +}
> +static inline void __page_ref_freeze(struct page *page, int v, int ret)
> +{
> +}
> +static inline void __page_ref_unfreeze(struct page *page, int v)
> +{
> +}
> +
> +#endif
>  
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
