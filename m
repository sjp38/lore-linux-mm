Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 994F76B0009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 19:46:47 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id e127so95045964pfe.3
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 16:46:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id h11si46894450pfd.42.2016.02.15.16.46.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 15 Feb 2016 16:46:46 -0800 (PST)
Date: Tue, 16 Feb 2016 09:47:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20160216004720.GA1782@js1304-P5Q-DELUXE>
References: <1455505490-12376-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1455505490-12376-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20160215110741.7c0c5039@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160215110741.7c0c5039@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, Feb 15, 2016 at 11:07:41AM -0500, Steven Rostedt wrote:
> On Mon, 15 Feb 2016 12:04:50 +0900
> js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > CMA allocation should be guaranteed to succeed by definition, but,
> > unfortunately, it would be failed sometimes. It is hard to track down
> > the problem, because it is related to page reference manipulation and
> > we don't have any facility to analyze it.
> > 
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
> > 
> > Enabling this feature bloat kernel text 30 KB in my configuration.
> > 
> >    text    data     bss     dec     hex filename
> > 12127327        2243616 1507328 15878271         f2487f vmlinux_disabled
> > 12157208        2258880 1507328 15923416         f2f8d8 vmlinux_enabled
> > 
> > v2:
> > o Use static key of each tracepoints to avoid function call overhead
> > when tracepoints are disabled.
> > o Print human-readable page flag through show_page_flags()
> > o Add more description to Kconfig.debug.
> > 
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  include/linux/page_ref.h        |  90 +++++++++++++++++++++++++--
> >  include/trace/events/page_ref.h | 133 ++++++++++++++++++++++++++++++++++++++++
> >  mm/Kconfig.debug                |  13 ++++
> >  mm/Makefile                     |   1 +
> >  mm/debug_page_ref.c             |  53 ++++++++++++++++
> >  5 files changed, 285 insertions(+), 5 deletions(-)
> >  create mode 100644 include/trace/events/page_ref.h
> >  create mode 100644 mm/debug_page_ref.c
> > 
> > diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> > index 534249c..fd6d9a5 100644
> > --- a/include/linux/page_ref.h
> > +++ b/include/linux/page_ref.h
> > @@ -1,6 +1,54 @@
> >  #include <linux/atomic.h>
> >  #include <linux/mm_types.h>
> >  #include <linux/page-flags.h>
> > +#include <linux/tracepoint-defs.h>
> > +
> > +extern struct tracepoint __tracepoint_page_ref_set;
> > +extern struct tracepoint __tracepoint_page_ref_mod;
> > +extern struct tracepoint __tracepoint_page_ref_mod_and_test;
> > +extern struct tracepoint __tracepoint_page_ref_mod_and_return;
> > +extern struct tracepoint __tracepoint_page_ref_mod_unless;
> > +extern struct tracepoint __tracepoint_page_ref_freeze;
> > +extern struct tracepoint __tracepoint_page_ref_unfreeze;
> > +
> > +#ifdef CONFIG_DEBUG_PAGE_REF
> > +#define page_ref_tracepoint_active(t) static_key_false(&(t).key)
> 
> Please don't open code this. Use the following instead:
> 
>   trace_page_ref_set_enabled()
>   trace_page_ref_mod_enabled()
>   trace_page_ref_mod_and_test_enabled()
>   trace_page_ref_mod_and_return_enabled()
>   trace_page_ref_mod_unless_enabled()
>   trace_page_ref_freeze_enabled()
>   trace_page_ref_unfreeze_enabled()
> 
> They return true when CONFIG_TRACEPOINTS is configured in and the
> tracepoint is enabled, and false otherwise.

This implementation is what you proposed before. Please refer below
link and source.

https://lkml.org/lkml/2015/12/9/699
arch/x86/include/asm/msr.h

There is header file dependency problem between mm.h and tracepoint.h.
page_ref.h should be included in mm.h and tracepoint.h cannot
be included in this case.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
