Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB366B026B
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 02:22:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k15so3552197wrc.1
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:22:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i13sor160675wmc.3.2017.10.18.23.22.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 23:22:16 -0700 (PDT)
Date: Thu, 19 Oct 2017 08:22:12 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019062212.n55vzg4khtds3mqk@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
 <20171019055730.mlpoz333ekflacs2@gmail.com>
 <20171019061112.GB3310@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019061112.GB3310@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Linus Torvalds <torvalds@linux-foundation.org>


* Byungchul Park <byungchul.park@lge.com> wrote:

> On Thu, Oct 19, 2017 at 07:57:30AM +0200, Ingo Molnar wrote:
> > 
> > * Byungchul Park <byungchul.park@lge.com> wrote:
> > 
> > > On Wed, Oct 18, 2017 at 12:09:44PM +0200, Ingo Molnar wrote:
> > > > BTW., have you attempted limiting the depth of the stack traces? I suspect more 
> > > > than 2-4 are rarely required to disambiguate the calling context.
> > > 
> > > I did it for you. Let me show you the result.
> > > 
> > > 1. No lockdep:				2.756558155 seconds time elapsed                ( +-  0.09% )
> > > 2. Lockdep:					2.968710420 seconds time elapsed		( +-  0.12% )
> > > 3. Lockdep + Crossrelease 5 entries:		3.153839636 seconds time elapsed                ( +-  0.31% )
> > > 4. Lockdep + Crossrelease 3 entries:		3.137205534 seconds time elapsed                ( +-  0.87% )
> > > 5. Lockdep + Crossrelease + This patch:	2.963669551 seconds time elapsed		( +-  0.11% )
> > 
> > I think the lockdep + crossrelease + full-stack numbers are missing?
> 
> Ah, the last version of crossrelease merged into vanilla, records 5
> entries, since I thought it overloads too much if full stack is used,
> and 5 entries are enough. Don't you think so?

Ok, fair enough, I missed that limitation!

> > That's very reasonable and we can keep the single-entry cross-release feature 
> > enabled by default as part of CONFIG_PROVE_LOCKING=y - assuming all the crashes 
> 
> BTW, is there any crash by cross-release I don't know? Of course, I know
> cases of false positives, but I don't about crash.

There's no current crash regression that I know of - I'm just outlining the 
conditions of getting all this re-enabled in the next merge window.

Instead of sending two series, could you please send a series that includes both 
these fixing + re-enabling patches, plus the false positive fixes?

In particular I think the cross-release re-enabling should be done as the last 
patch, so that any future bisections of new false positives won't be made more 
difficult by re-introducing the old false positives near the end of the bisection.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
