Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 219D66B0388
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 06:42:04 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so329725291pge.7
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 03:42:04 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q2si20812241pga.211.2017.03.21.03.42.03
        for <linux-mm@kvack.org>;
        Tue, 21 Mar 2017 03:42:03 -0700 (PDT)
Date: Tue, 21 Mar 2017 10:41:39 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170321104139.GA22188@leverpostej>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170320171718.GL31213@leverpostej>
 <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Tue, Mar 21, 2017 at 12:25:06PM +0300, Andrey Ryabinin wrote:
> On 03/20/2017 08:17 PM, Mark Rutland wrote:
> > Hi,
> > 
> > On Tue, Mar 14, 2017 at 08:24:13PM +0100, Dmitry Vyukov wrote:
> >>  /**
> >> - * atomic_read - read atomic variable
> >> + * arch_atomic_read - read atomic variable
> >>   * @v: pointer of type atomic_t
> >>   *
> >>   * Atomically reads the value of @v.
> >>   */
> >> -static __always_inline int atomic_read(const atomic_t *v)
> >> +static __always_inline int arch_atomic_read(const atomic_t *v)
> >>  {
> >> -	return READ_ONCE((v)->counter);
> >> +	/*
> >> +	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
> >> +	 * instrumentation. Double instrumentation is unnecessary.
> >> +	 */
> >> +	return READ_ONCE_NOCHECK((v)->counter);
> >>  }
> > 
> > Just to check, we do this to avoid duplicate reports, right?
> > 
> > If so, double instrumentation isn't solely "unnecessary"; it has a
> > functional difference, and we should explicitly describe that in the
> > comment.
> > 
> > ... or are duplicate reports supressed somehow?
> 
> They are not suppressed yet. But I think we should just switch kasan
> to single shot mode, i.e. report only the first error. Single bug
> quite often has multiple invalid memory accesses causing storm in
> dmesg. Also write OOB might corrupt metadata so the next report will
> print bogus alloc/free stacktraces.
> In most cases we need to look only at the first report, so reporting
> anything after the first is just counterproductive.

FWIW, that sounds sane to me.

Given that, I agree with your comment regarding READ_ONCE{,_NOCHECK}().

If anyone really wants all the reports, we could have a boot-time option
to do that.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
