Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8A36D6B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:38:10 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z8so39189550ige.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:38:10 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0136.hostedemail.com. [216.40.44.136])
        by mx.google.com with ESMTPS id vv5si5442743igb.80.2016.02.26.08.38.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 08:38:09 -0800 (PST)
Date: Fri, 26 Feb 2016 11:38:06 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160226113806.27002b82@gandalf.local.home>
In-Reply-To: <1456448282-897-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456448282-897-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1456448282-897-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 26 Feb 2016 09:58:02 +0900
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
> Following is an example of tracepoint output. (note: this example is
> stale version that printing flags as the number. Recent version will
> print it as human readable string.)
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
> Note that, due to header file dependency problem between mm.h and
> tracepoint.h, this feature has to open code the static key functions
> for tracepoints. Proposed by Steven Rostedt in following link.
> 
> https://lkml.org/lkml/2015/12/9/699
> 
> v3:
> o Add commit description and code comment why this patch open code
> the static key functions for tracepoints.
> o Notify that example is stale version.
> o Add "depends on TRACEPOINTS".
> 
> v2:
> o Use static key of each tracepoints to avoid function call overhead
> when tracepoints are disabled.
> o Print human-readable page flag thanks to newly introduced %pgp option.
> o Add more description to Kconfig.debug.
> 
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Steven Rostedt <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
