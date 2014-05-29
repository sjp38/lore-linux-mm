Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
	by kanga.kvack.org (Postfix) with ESMTP id 51E566B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 00:13:16 -0400 (EDT)
Received: by mail-ve0-f172.google.com with SMTP id oz11so13646230veb.17
        for <linux-mm@kvack.org>; Wed, 28 May 2014 21:13:16 -0700 (PDT)
Received: from mail-vc0-x22b.google.com (mail-vc0-x22b.google.com [2607:f8b0:400c:c03::22b])
        by mx.google.com with ESMTPS id y5si12358504vdv.103.2014.05.28.21.13.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 21:13:15 -0700 (PDT)
Received: by mail-vc0-f171.google.com with SMTP id lc6so13541121vcb.30
        for <linux-mm@kvack.org>; Wed, 28 May 2014 21:13:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140529034625.GB10092@bbox>
References: <1401260039-18189-1-git-send-email-minchan@kernel.org>
	<1401260039-18189-2-git-send-email-minchan@kernel.org>
	<CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
	<20140529034625.GB10092@bbox>
Date: Wed, 28 May 2014 21:13:15 -0700
Message-ID: <CA+55aFyoT1xuM-HsZ4GKt=FfDYs76oD7U-RBkZn-2PErj6ZZVw@mail.gmail.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Wed, May 28, 2014 at 8:46 PM, Minchan Kim <minchan@kernel.org> wrote:
>
> Yes. For example, with mark __alloc_pages_slowpath noinline_for_stack,
> we can reduce 176byte.

Well, but it will then call that __alloc_pages_slowpath() function,
which has a 176-byte stack frame.. Plus the call frame.

Now, that only triggers for when the initial "__GFP_HARDWALL" case
fails, but that's exactly what happens when we do need to do direct
reclaim.

That said, I *have* seen cases where the gcc spill code got really
confused, and simplifying the function (by not inlining excessively)
actually causes a truly smaller stack overall, despite the actual call
frames etc.  But I think the gcc people fixed the kinds of things that
caused *that* kind of stack slot explosion.

And avoiding inlining can end up resulting in less stack, if the
really deep parts don't happen to go through that function that got
inlined (ie any call chain that wouldn't have gone through that
"slowpath" function at all).

But in this case, __alloc_pages_slowpath() is where we end up doing
the actual direct reclaim anyway, so just uninlining doesn't actually
help. Although it would probably make the asm code more readable ;)

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
