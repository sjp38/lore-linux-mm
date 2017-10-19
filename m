Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 998876B0268
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:57:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n4so3440599wrb.8
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 22:57:34 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b5sor5852930wrf.66.2017.10.18.22.57.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 22:57:33 -0700 (PDT)
Date: Thu, 19 Oct 2017 07:57:30 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/2] lockdep: Introduce CROSSRELEASE_STACK_TRACE and make
 it not unwind as default
Message-ID: <20171019055730.mlpoz333ekflacs2@gmail.com>
References: <1508318006-2090-1-git-send-email-byungchul.park@lge.com>
 <20171018100944.g2mc6yorhtm5piom@gmail.com>
 <20171019043240.GA3310@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019043240.GA3310@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com, Linus Torvalds <torvalds@linux-foundation.org>


* Byungchul Park <byungchul.park@lge.com> wrote:

> On Wed, Oct 18, 2017 at 12:09:44PM +0200, Ingo Molnar wrote:
> > BTW., have you attempted limiting the depth of the stack traces? I suspect more 
> > than 2-4 are rarely required to disambiguate the calling context.
> 
> I did it for you. Let me show you the result.
> 
> 1. No lockdep:				2.756558155 seconds time elapsed                ( +-  0.09% )
> 2. Lockdep:					2.968710420 seconds time elapsed		( +-  0.12% )
> 3. Lockdep + Crossrelease 5 entries:		3.153839636 seconds time elapsed                ( +-  0.31% )
> 4. Lockdep + Crossrelease 3 entries:		3.137205534 seconds time elapsed                ( +-  0.87% )
> 5. Lockdep + Crossrelease + This patch:	2.963669551 seconds time elapsed		( +-  0.11% )

I think the lockdep + crossrelease + full-stack numbers are missing?

But yeah, looks like single-entry-stacktrace crossrelease only has a +0.2% 
performance cost (with 0.1% noise), while lockdep itself has a +7.7% cost.

That's very reasonable and we can keep the single-entry cross-release feature 
enabled by default as part of CONFIG_PROVE_LOCKING=y - assuming all the crashes 
and false positives are fixed by the next merge window.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
