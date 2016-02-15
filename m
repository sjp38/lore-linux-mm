Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 608946B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 11:07:45 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id y8so57820626igp.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 08:07:45 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0126.hostedemail.com. [216.40.44.126])
        by mx.google.com with ESMTPS id d7si27760617igg.8.2016.02.15.08.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 08:07:44 -0800 (PST)
Date: Mon, 15 Feb 2016 11:07:41 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160215110741.7c0c5039@gandalf.local.home>
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

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> CMA allocation should be guaranteed to succeed by definition, but,
> unfortunately, it would be failed sometimes. It is hard to track down
> the problem, because it is related to page reference manipulation and
> we don't have any facility to analyze it.
> 
> This patch adds tracepoints to track down page reference manipulation.
> With it, we can find exact reason of failure and can fix the problem.
> Following is an example of tracepoint output.
> 
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
> ...
> ...
> <...>-9131  [001]    93.174468: test_pages_isolated:  start_pfn=0x17800 end_pfn=0x17c00 fin_pfn=0x17ac9 ret=fail
> [snip]
> <...>-9018  [004]    93.174843: page_ref_mod_and_test: pfn=0x17ac9 flags=0x40068 count=0 mapcount=0 mapping=0xffff880015a78dc1 mt=4 val=-1 ret=1
>  => release_pages (ffffffff8117c9e4)
>  => free_pages_and_swap_cache (ffffffff811b0697)
>  => tlb_flush_mmu_free (ffffffff81199616)
>  => tlb_finish_mmu (ffffffff8119a62c)
>  => exit_mmap (ffffffff811a53f7)
>  => mmput (ffffffff81073f47)
>  => do_exit (ffffffff810794e9)
>  => do_group_exit (ffffffff81079def)
>  => SyS_exit_group (ffffffff81079e74)
>  => entry_SYSCALL_64_fastpath (ffffffff817560b6)  
> 
> This output shows that problem comes from exit path. In exit path,
> to improve performance, pages are not freed immediately. They are gathered
> and processed by batch. During this process, migration cannot be possible
> and CMA allocation is failed. This problem is hard to find without this
> page reference tracepoint facility.
> 
> Enabling this feature bloat kernel text 30 KB in my configuration.
> 
>    text    data     bss     dec     hex filename
> 12127327        2243616 1507328 15878271         f2487f vmlinux_disabled
> 12157208        2258880 1507328 15923416         f2f8d8 vmlinux_enabled
> 
> v2:
> o Use static key of each tracepoints to avoid function call overhead
> when tracepoints are disabled.
> o Print human-readable page flag through show_page_flags()
> o Add more description to Kconfig.debug.
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  include/linux/page_ref.h        |  90 +++++++++++++++++++++++++--
>  include/trace/events/page_ref.h | 133 ++++++++++++++++++++++++++++++++++++++++
>  mm/Kconfig.debug                |  13 ++++
>  mm/Makefile                     |   1 +
>  mm/debug_page_ref.c             |  53 ++++++++++++++++
>  5 files changed, 285 insertions(+), 5 deletions(-)
>  create mode 100644 include/trace/events/page_ref.h
>  create mode 100644 mm/debug_page_ref.c
> 
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
> +#define page_ref_tracepoint_active(t) static_key_false(&(t).key)

Please don't open code this. Use the following instead:

  trace_page_ref_set_enabled()
  trace_page_ref_mod_enabled()
  trace_page_ref_mod_and_test_enabled()
  trace_page_ref_mod_and_return_enabled()
  trace_page_ref_mod_unless_enabled()
  trace_page_ref_freeze_enabled()
  trace_page_ref_unfreeze_enabled()

They return true when CONFIG_TRACEPOINTS is configured in and the
tracepoint is enabled, and false otherwise.

-- Steve


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
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
