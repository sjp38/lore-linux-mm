Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 465046B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 12:09:24 -0400 (EDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so12833403veb.10
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:09:24 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id ej4si6290345vdb.27.2014.05.28.09.09.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 09:09:23 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id hq11so6921864vcb.33
        for <linux-mm@kvack.org>; Wed, 28 May 2014 09:09:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1401260039-18189-2-git-send-email-minchan@kernel.org>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
Date: Wed, 28 May 2014 09:09:23 -0700
Message-ID: <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Tue, May 27, 2014 at 11:53 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> So, my stupid idea is just let's expand stack size and keep an eye
> toward stack consumption on each kernel functions via stacktrace of ftrace.

We probably have to do this at some point, but that point is not -rc7.

And quite frankly, from the backtrace, I can only say: there is some
bad shit there. The current VM stands out as a bloated pig:

> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   0)     7696      16   lookup_address+0x28/0x30
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   1)     7680      16   _lookup_address_cpa.isra.3+0x3b/0x40
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   2)     7664      24   __change_page_attr_set_clr+0xe0/0xb50
> [ 1065.604404] kworker/-5766    0d..2 1071625991us : stack_trace_call:   3)     7640     392   kernel_map_pages+0x6c/0x120
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   4)     7248     256   get_page_from_freelist+0x489/0x920
> [ 1065.604404] kworker/-5766    0d..2 1071625992us : stack_trace_call:   5)     6992     352   __alloc_pages_nodemask+0x5e1/0xb20

> [ 1065.604404] kworker/-5766    0d..2 1071625995us : stack_trace_call:  23)     4672     160   __swap_writepage+0x150/0x230
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  24)     4512      32   swap_writepage+0x42/0x90
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  25)     4480     320   shrink_page_list+0x676/0xa80
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  26)     4160     208   shrink_inactive_list+0x262/0x4e0
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  27)     3952     304   shrink_lruvec+0x3e1/0x6a0
> [ 1065.604404] kworker/-5766    0d..2 1071625996us : stack_trace_call:  28)     3648      80   shrink_zone+0x3f/0x110
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  29)     3568     128   do_try_to_free_pages+0x156/0x4c0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  30)     3440     208   try_to_free_pages+0xf7/0x1e0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  31)     3232     352   __alloc_pages_nodemask+0x783/0xb20
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  32)     2880       8   alloc_pages_current+0x10f/0x1f0
> [ 1065.604404] kworker/-5766    0d..2 1071625997us : stack_trace_call:  33)     2872     200   __page_cache_alloc+0x13f/0x160

That __alloc_pages_nodemask() thing in particular looks bad. It
actually seems not to be the usual "let's just allocate some
structures on the stack" disease, it looks more like "lots of
inlining, horrible calling conventions, and lots of random stupid
variables".

>From a quick glance at the frame usage, some of it seems to be gcc
being rather bad at stack allocation, but lots of it is just nasty
spilling around the disgusting call-sites with tons or arguments. A
_lot_ of the stack slots are marked as "%sfp" (which is gcc'ese for
"spill frame pointer", afaik).

Avoiding some inlining, and using a single flag value rather than the
collection of "bool"s would probably help. But nothing really
trivially obvious stands out.

But what *does* stand out (once again) is that we probably shouldn't
do swap-out in direct reclaim. This came up the last time we had stack
issues (XFS) too. I really do suspect that direct reclaim should only
do the kind of reclaim that does not need any IO at all.

I think we _do_ generally avoid IO in direct reclaim, but swap is
special. And not for a good reason, afaik. DaveC, remind me, I think
you said something about the swap case the last time this came up..

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
