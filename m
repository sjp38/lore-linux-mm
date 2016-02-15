Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 45A5F6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 00:07:43 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e127so81151238pfe.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:07:43 -0800 (PST)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id rk9si40722775pab.31.2016.02.14.21.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Feb 2016 21:07:42 -0800 (PST)
Received: by mail-pa0-x242.google.com with SMTP id y7so227483paa.3
        for <linux-mm@kvack.org>; Sun, 14 Feb 2016 21:07:42 -0800 (PST)
Date: Mon, 15 Feb 2016 14:08:58 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160215050858.GA556@swordfish>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello Joonsoo,

On (02/15/16 12:04), js1304@gmail.com wrote:
[..]
> <...>-9018  [004]    92.678375: page_ref_set:         pfn=0x17ac9 flags=0x0 count=1 mapcount=0 mapping=(nil) mt=4 val=1
> <...>-9018  [004]    92.678378: kernel_stack:
>  => get_page_from_freelist (ffffffff81176659)
>  => __alloc_pages_nodemask (ffffffff81176d22)
>  => alloc_pages_vma (ffffffff811bf675)
>  => handle_mm_fault (ffffffff8119e693)
>  => __do_page_fault (ffffffff810631ea)
>  => trace_do_page_fault (ffffffff81063543)
>  => do_async_page_fault (ffffffff8105c40a)
>  => async_page_fault (ffffffff817581d8)
> [snip]
> <...>-9018  [004]    92.678379: page_ref_mod:         pfn=0x17ac9 flags=0x40048 count=2 mapcount=1 mapping=0xffff880015a78dc1 mt=4 val=1
> [snip]
[..]
> o Print human-readable page flag through show_page_flags()

not even a nitpick, just for note, the examples don't use show_page_flags().


[..]
> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> index 534249c..fd6d9a5 100644
> --- a/include/linux/page_ref.h
> +++ b/include/linux/page_ref.h
> @@ -1,6 +1,54 @@
>  #include <linux/atomic.h>
>  #include <linux/mm_types.h>
>  #include <linux/page-flags.h>

will this compile with !CONFIG_TRACEPOINTS config?

+#ifdef CONFIG_TRACEPOINTS
 #include <linux/tracepoint-defs.h>

 extern struct tracepoint __tracepoint_page_ref_set;
 extern struct tracepoint __tracepoint_page_ref_mod;
 extern struct tracepoint __tracepoint_page_ref_mod_and_test;
 extern struct tracepoint __tracepoint_page_ref_mod_and_return;
 extern struct tracepoint __tracepoint_page_ref_mod_unless;
 extern struct tracepoint __tracepoint_page_ref_freeze;
 extern struct tracepoint __tracepoint_page_ref_unfreeze;

 #ifdef CONFIG_DEBUG_PAGE_REF
 #define page_ref_tracepoint_active(t) static_key_false(&(t).key)

 extern void __page_ref_set(struct page *page, int v);
 extern void __page_ref_mod(struct page *page, int v);
 extern void __page_ref_mod_and_test(struct page *page, int v, int ret);
 extern void __page_ref_mod_and_return(struct page *page, int v, int ret);
 extern void __page_ref_mod_unless(struct page *page, int v, int u);
 extern void __page_ref_freeze(struct page *page, int v, int ret);
 extern void __page_ref_unfreeze(struct page *page, int v);

 #else

 #define page_ref_tracepoint_active(t) false

 static inline void __page_ref_set(struct page *page, int v)
 {
 }
 static inline void __page_ref_mod(struct page *page, int v)
 {
 }
 static inline void __page_ref_mod_and_test(struct page *page, int v, int ret)
 {
 }
 static inline void __page_ref_mod_and_return(struct page *page, int v, int ret)
 {
 }
 static inline void __page_ref_mod_unless(struct page *page, int v, int u)
 {
 }
 static inline void __page_ref_freeze(struct page *page, int v, int ret)
 {
 }
 static inline void __page_ref_unfreeze(struct page *page, int v)
 {
 }

 #endif /* CONFIG_DEBUG_PAGE_REF */

+#endif /* CONFIG_TRACEPOINTS */

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
