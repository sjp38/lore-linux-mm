Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6094482F6C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:34:34 -0500 (EST)
Received: by wmvv187 with SMTP id v187so284283609wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:34:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si5567838wmh.33.2015.11.18.07.34.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 07:34:32 -0800 (PST)
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564C9A86.1090906@suse.cz>
Date: Wed, 18 Nov 2015 16:34:30 +0100
MIME-Version: 1.0
In-Reply-To: <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 11/09/2015 08:23 AM, Joonsoo Kim wrote:
> CMA allocation should be guaranteed to succeed by definition, but,
> unfortunately, it would be failed sometimes. It is hard to track down
> the problem, because it is related to page reference manipulation and
> we don't have any facility to analyze it.

Reminds me of the PeterZ's VM_PINNED patchset. What happened to it?
https://lwn.net/Articles/600502/

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

Yeah but when you realized it was this problem, what was the fix? Probably not
remove batching from exit path? Shouldn't CMA in this case just try waiting for
the pins to go away, which would eventually happen? And for long-term pins,
VM_PINNED would make sure the pages are migrated away from CMA pageblocks first?

So I'm worried that this is quite nontrivial change for a very specific usecase.

> Enabling this feature bloat kernel text 20 KB in my configuration.

It's not just that, see below.

[...]


>  static inline int page_ref_freeze(struct page *page, int count)
>  {
> -	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
> +	int ret = likely(atomic_cmpxchg(&page->_count, count, 0) == count);

The "likely" mean makes no sense anymore, doe it?

> diff --git a/mm/Kconfig.debug b/mm/Kconfig.debug
> index 957d3da..71d2399 100644
> --- a/mm/Kconfig.debug
> +++ b/mm/Kconfig.debug
> @@ -28,3 +28,7 @@ config DEBUG_PAGEALLOC
>  
>  config PAGE_POISONING
>  	bool
> +
> +config DEBUG_PAGE_REF
> +	bool "Enable tracepoint to track down page reference manipulation"

So you should probably state the costs. Which is the extra memory, and also that
all the page ref manipulations are now turned to function calls, even if the
tracepoints are disabled. Patch 1 didn't change that many callsites, so maybe it
would be feasible to have the tracepoints inline, where being disabled has
near-zero overhead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
