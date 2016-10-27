Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1906B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:07:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 2so6389466wmj.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:07:46 -0700 (PDT)
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id qr3si7286016wjc.91.2016.10.27.02.07.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:07:45 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id C04661C131C
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 10:07:44 +0100 (IST)
Date: Thu, 27 Oct 2016 10:07:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027090742.GG2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net>
 <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
 <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
 <20161026230726.GF2699@techsingularity.net>
 <20161027080852.GC3568@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161027080852.GC3568@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 10:08:52AM +0200, Peter Zijlstra wrote:
> On Thu, Oct 27, 2016 at 12:07:26AM +0100, Mel Gorman wrote:
> > > but I consider PeterZ's
> > > patch the fix to that, so I wouldn't worry about it.
> > > 
> > 
> > Agreed. Peter, do you plan to finish that patch?
> 
> I was waiting for you guys to hash out the 32bit issue. But if we're now
> OK with having this for 64bit only, I can certainly look at doing a new
> version.
> 

I've no problem with it being 64-bit only.

> I'll have to look at fixing Alpha's bitops for that first though,
> because as is that patch relies on atomics to the same word not needing
> ordering, but placing the contended/waiters bit in the high word for
> 64bit only sorta breaks that.
> 

I see the problem assuming you're referring to the requirement that locked
and waiter bits are on the same word. Without it, you need a per-arch helper
that forces ordering or takes a spinlock. I doubt it's worth the trouble.

> Hurm, we could of course play games with the layout, the 64bit only
> flags don't _have_ to be at the end.
> 
> Something like so could work I suppose, but then there's a slight
> regression in the page_unlock() path, where we now do an unconditional
> spinlock; iow. we loose the unlocked waitqueue_active() test.
> 

I can't convince myself it's worthwhile. At least, I can't see a penalty
of potentially moving one of the two bits to the high word. It's the
same cache line and the same op when it matters.

> We could re-instate this with an #ifndef CONFIG_NUMA I suppose.. not
> pretty though.
> 
> Also did the s/contended/waiters/ rename per popular request.
> 
> ---
>  include/linux/page-flags.h     |   19 ++++++++
>  include/linux/pagemap.h        |   25 ++++++++--
>  include/trace/events/mmflags.h |    7 +++
>  mm/filemap.c                   |   94 +++++++++++++++++++++++++++++++++++++----
>  4 files changed, 130 insertions(+), 15 deletions(-)
> 
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -73,6 +73,14 @@
>   */
>  enum pageflags {
>  	PG_locked,		/* Page is locked. Don't touch. */
> +#ifdef CONFIG_NUMA
> +	/*
> +	 * This bit must end up in the same word as PG_locked (or any other bit
> +	 * we're waiting on), as per all architectures their bitop
> +	 * implementations.
> +	 */
> +	PG_waiters,		/* The hashed waitqueue has waiters */
> +#endif
>  	PG_error,
>  	PG_referenced,
>  	PG_uptodate,

I don't see why it should be NUMA-specific even though with Linus'
patch, NUMA is a concern. Even then, you still need a 64BIT check
because 32BIT && NUMA is allowed on a number of architectures.

Otherwise, nothing jumped out at me but glancing through it looked very
similar to the previous patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
