Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 039996B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 01:50:10 -0500 (EST)
Received: by padhx2 with SMTP id hx2so71361798pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 22:50:09 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id dy5si10088134pbb.217.2015.11.18.22.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Nov 2015 22:50:09 -0800 (PST)
Date: Thu, 19 Nov 2015 15:50:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151119065015.GB15540@bbox>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
 <564C9A86.1090906@suse.cz>
MIME-Version: 1.0
In-Reply-To: <564C9A86.1090906@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Nov 18, 2015 at 04:34:30PM +0100, Vlastimil Babka wrote:
> On 11/09/2015 08:23 AM, Joonsoo Kim wrote:
> > CMA allocation should be guaranteed to succeed by definition, but,
> > unfortunately, it would be failed sometimes. It is hard to track down
> > the problem, because it is related to page reference manipulation and
> > we don't have any facility to analyze it.
> 
> Reminds me of the PeterZ's VM_PINNED patchset. What happened to it?
> https://lwn.net/Articles/600502/
> 
> > This patch adds tracepoints to track down page reference manipulation.
> > With it, we can find exact reason of failure and can fix the problem.
> > Following is an example of tracepoint output.
> > 
> > <...>-9018  [004]    92.678375: page_ref_set:         pfn=0x17ac9 flags=0x0 count=1 mapcount=0 mapping=(nil) mt=4 val=1
> > <...>-9018  [004]    92.678378: kernel_stack:
> >  => get_page_from_freelist (ffffffff81176659)
> >  => __alloc_pages_nodemask (ffffffff81176d22)
> >  => alloc_pages_vma (ffffffff811bf675)
> >  => handle_mm_fault (ffffffff8119e693)
> >  => __do_page_fault (ffffffff810631ea)
> >  => trace_do_page_fault (ffffffff81063543)
> >  => do_async_page_fault (ffffffff8105c40a)
> >  => async_page_fault (ffffffff817581d8)
> > [snip]
> > <...>-9018  [004]    92.678379: page_ref_mod:         pfn=0x17ac9 flags=0x40048 count=2 mapcount=1 mapping=0xffff880015a78dc1 mt=4 val=1
> > [snip]
> > ...
> > ...
> > <...>-9131  [001]    93.174468: test_pages_isolated:  start_pfn=0x17800 end_pfn=0x17c00 fin_pfn=0x17ac9 ret=fail
> > [snip]
> > <...>-9018  [004]    93.174843: page_ref_mod_and_test: pfn=0x17ac9 flags=0x40068 count=0 mapcount=0 mapping=0xffff880015a78dc1 mt=4 val=-1 ret=1
> >  => release_pages (ffffffff8117c9e4)
> >  => free_pages_and_swap_cache (ffffffff811b0697)
> >  => tlb_flush_mmu_free (ffffffff81199616)
> >  => tlb_finish_mmu (ffffffff8119a62c)
> >  => exit_mmap (ffffffff811a53f7)
> >  => mmput (ffffffff81073f47)
> >  => do_exit (ffffffff810794e9)
> >  => do_group_exit (ffffffff81079def)
> >  => SyS_exit_group (ffffffff81079e74)
> >  => entry_SYSCALL_64_fastpath (ffffffff817560b6)
> > 
> > This output shows that problem comes from exit path. In exit path,
> > to improve performance, pages are not freed immediately. They are gathered
> > and processed by batch. During this process, migration cannot be possible
> > and CMA allocation is failed. This problem is hard to find without this
> > page reference tracepoint facility.
> 
> Yeah but when you realized it was this problem, what was the fix? Probably not
> remove batching from exit path? Shouldn't CMA in this case just try waiting for
> the pins to go away, which would eventually happen? And for long-term pins,
> VM_PINNED would make sure the pages are migrated away from CMA pageblocks first?
> 
> So I'm worried that this is quite nontrivial change for a very specific usecase.

This patch is not to solve the problem but just to expose what is culprit.

For using VM_PINNED, firstly, we should know where are long-term pins.
There are obviously clear places which will be first target if we use
VM_PINNED but somewhere are vague. For vague places, this patch will
help finding there. Even we don't use VM_PINNED, this patch will expose
current obstacle which can help to understand current problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
