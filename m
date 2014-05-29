Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DCFB86B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 23:45:55 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id bj1so12154424pad.13
        for <linux-mm@kvack.org>; Wed, 28 May 2014 20:45:55 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gm1si26089244pbd.252.2014.05.28.20.45.53
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 20:45:54 -0700 (PDT)
Date: Thu, 29 May 2014 12:46:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140529034625.GB10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
 <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 09:09:23AM -0700, Linus Torvalds wrote:
> On Tue, May 27, 2014 at 11:53 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > So, my stupid idea is just let's expand stack size and keep an eye
> > toward stack consumption on each kernel functions via stacktrace of ftrace.
> 
> We probably have to do this at some point, but that point is not -rc7.
> 
> And quite frankly, from the backtrace, I can only say: there is some
> bad shit there. The current VM stands out as a bloated pig:
> 
> > [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   0)     7696      16   lookup_address+0x28/0x30
> > [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   1)     7680      16   _lookup_address_cpa.isra.3+0x3b/0x40
> > [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   2)     7664      24   __change_page_attr_set_clr+0xe0/0xb50
> > [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   3)     7640     392   kernel_map_pages+0x6c/0x120
> > [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   4)     7248     256   get_page_from_freelist+0x489/0x920
> > [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   5)     6992     352   __alloc_pages_nodemask+0x5e1/0xb20
> 
> > [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  23)     4672     160   __swap_writepage+0x150/0x230
> > [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  24)     4512      32   swap_writepage+0x42/0x90
> > [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  25)     4480     320   shrink_page_list+0x676/0xa80
> > [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  26)     4160     208   shrink_inactive_list+0x262/0x4e0
> > [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  27)     3952     304   shrink_lruvec+0x3e1/0x6a0
> > [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  28)     3648      80   shrink_zone+0x3f/0x110
> > [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  29)     3568     128   do_try_to_free_pages+0x156/0x4c0
> > [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  30)     3440     208   try_to_free_pages+0xf7/0x1e0
> > [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  31)     3232     352   __alloc_pages_nodemask+0x783/0xb20
> > [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  32)     2880       8   alloc_pages_current+0x10f/0x1f0
> > [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  33)     2872     200   __page_cache_alloc+0x13f/0x160
> 
> That __alloc_pages_nodemask() thing in particular looks bad. It
> actually seems not to be the usual "let's just allocate some
> structures on the stack" disease, it looks more like "lots of
> inlining, horrible calling conventions, and lots of random stupid
> variables".

Yes. For example, with mark __alloc_pages_slowpath noinline_for_stack,
we can reduce 176byte. And there are more places we could reduce stack
consumption but I thought it was bandaid although reducing stack itself
is desireable.

    before
    
    ffffffff81150600 <__alloc_pages_nodemask>:
    ffffffff81150600:	e8 fb f6 59 00       	callq  ffffffff816efd00 <__entry_text_start>
    ffffffff81150605:	55                   	push   %rbp
    ffffffff81150606:	b8 e8 e8 00 00       	mov    $0xe8e8,%eax
    ffffffff8115060b:	48 89 e5             	mov    %rsp,%rbp
    ffffffff8115060e:	41 57                	push   %r15
    ffffffff81150610:	41 56                	push   %r14
    ffffffff81150612:	41 be 22 01 32 01    	mov    $0x1320122,%r14d
    ffffffff81150618:	41 55                	push   %r13
    ffffffff8115061a:	41 54                	push   %r12
    ffffffff8115061c:	41 89 fc             	mov    %edi,%r12d
    ffffffff8115061f:	53                   	push   %rbx
    ffffffff81150620:	48 81 ec 28 01 00 00 	sub    $0x128,%rsp
    ffffffff81150627:	48 89 55 88          	mov    %rdx,-0x78(%rbp)
    ffffffff8115062b:	89 fa                	mov    %edi,%edx
    ffffffff8115062d:	83 e2 0f             	and    $0xf,%edx
    ffffffff81150630:	48 89 4d 90          	mov    %rcx,-0x70(%rbp)
    
    after:
    
    ffffffff81150600 <__alloc_pages_nodemask>:
    ffffffff81150600:	e8 7b f6 59 00       	callq  ffffffff816efc80 <__entry_text_start>
    ffffffff81150605:	55                   	push   %rbp
    ffffffff81150606:	b8 e8 e8 00 00       	mov    $0xe8e8,%eax
    ffffffff8115060b:	48 89 e5             	mov    %rsp,%rbp
    ffffffff8115060e:	41 57                	push   %r15
    ffffffff81150610:	41 bf 22 01 32 01    	mov    $0x1320122,%r15d
    ffffffff81150616:	41 56                	push   %r14
    ffffffff81150618:	41 55                	push   %r13
    ffffffff8115061a:	41 54                	push   %r12
    ffffffff8115061c:	41 89 fc             	mov    %edi,%r12d
    ffffffff8115061f:	53                   	push   %rbx
    ffffffff81150620:	48 83 ec 78          	sub    $0x78,%rsp
    ffffffff81150624:	48 89 55 a8          	mov    %rdx,-0x58(%rbp)
    ffffffff81150628:	89 fa                	mov    %edi,%edx
    ffffffff8115062a:	83 e2 0f             	and    $0xf,%edx
    ffffffff8115062d:	48 89 4d b0          	mov    %rcx,-0x50(%rbp)
    
> 
> >From a quick glance at the frame usage, some of it seems to be gcc
> being rather bad at stack allocation, but lots of it is just nasty
> spilling around the disgusting call-sites with tons or arguments. A
> _lot_ of the stack slots are marked as "%sfp" (which is gcc'ese for
> "spill frame pointer", afaik).
> 
> Avoiding some inlining, and using a single flag value rather than the
> collection of "bool"s would probably help. But nothing really
> trivially obvious stands out.
> 
> But what *does* stand out (once again) is that we probably shouldn't
> do swap-out in direct reclaim. This came up the last time we had stack
> issues (XFS) too. I really do suspect that direct reclaim should only
> do the kind of reclaim that does not need any IO at all.
> 
> I think we _do_ generally avoid IO in direct reclaim, but swap is
> special. And not for a good reason, afaik. DaveC, remind me, I think
> you said something about the swap case the last time this came up..
> 
>                   Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
