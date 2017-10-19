Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38D076B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 15:04:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z96so4523031wrb.21
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 12:04:27 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 3si1561806wmc.54.2017.10.19.12.04.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 12:04:26 -0700 (PDT)
Date: Thu, 19 Oct 2017 21:04:09 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
In-Reply-To: <1508428021.2429.22.camel@wdc.com>
Message-ID: <alpine.DEB.2.20.1710192021480.2054@nanos>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>  <1508392531-11284-3-git-send-email-byungchul.park@lge.com>  <1508425527.2429.11.camel@wdc.com>  <alpine.DEB.2.20.1710191718260.1971@nanos> <1508428021.2429.22.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

Bart,

On Thu, 19 Oct 2017, Bart Van Assche wrote:

> It seems like you are missing my point.

That might be a perception problem. 

> Cross-release checking is really *broken* as a concept. It is impossible
> to improve it to the same reliability level as the kernel v4.13 lockdep
> code. Hence my request to make it possible to disable cross-release
> checking if PROVE_LOCKING is enabled.

I did not read it as a request. If you'd had said:

  I have doubts about the concept and I think that it's impossible to
  handle the false positives up to the point where the existing lockdep
  infrastructure can do. Therefore I request that the feature gets an extra
  Kconfig entry (default y) or a command line parameter which allows to
  disable it in case of hard to fix false positive warnings, so the issue
  can be reported and normal lockdep testing can be resumed until the issue
  is fixed.

Then I would have said: That makes sense, as long as its default on and
people actually report the problems so the responsible developers can
tackle them.

What tripped me over was your statement:

  Many kernel developers, including myself, are not interested in spending
  time on analyzing false positive deadlock reports.

Which sends a completely different message.

> Consider the following example from the cross-release documentation:
> 
>    TASK X			   TASK Y
>    ------			   ------
> 				   acquire AX
>    acquire B /* A dependency 'AX -> B' exists */
>    release B
>    release AX held by Y
> 
> My understanding is that the cross-release code will add (AX, B) to the lock
> order graph after having encountered the above code. I think that's wrong
> because if the following sequence (Y: acquire AX, X: acquire B, X: release B)
> is encountered again that there is no guarantee that AX can only be released
> by X. Any task other than X could release that synchronization object too.

Emphasis on could.

That's not a lockdep problem and neither can the pure locking dependency
tracking know that a particular deadlock is not possible by design. It can
merily record the dependency chains and detect circular dependencies.

There is enough code which is obviously correct in terms of locking which
has lockdep annotations in one form or the other (nesting, different
lock_class_keys etc.). These annotations are there to teach lockdep about
false positives. It's pretty much the same with the cross release feature
and we won't get these annotations into the code when people disable it 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
