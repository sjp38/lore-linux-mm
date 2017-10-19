Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E3E656B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:49:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so4026213wmu.10
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:49:36 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id k17si1771179wmh.67.2017.10.19.13.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 13:49:35 -0700 (PDT)
Date: Thu, 19 Oct 2017 22:49:27 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
In-Reply-To: <1508444515.2429.55.camel@wdc.com>
Message-ID: <alpine.DEB.2.20.1710192233130.2054@nanos>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>   <1508392531-11284-3-git-send-email-byungchul.park@lge.com>   <1508425527.2429.11.camel@wdc.com>   <alpine.DEB.2.20.1710191718260.1971@nanos>  <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>  <alpine.DEB.2.20.1710192107000.2054@nanos> <1508444515.2429.55.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, 19 Oct 2017, Bart Van Assche wrote:
> * How many lock inversion problems have been found so far thanks to the
>   cross-release checking? How many false positives have the cross-release
>   checks triggered so far? Does the number of real issues that has been
>   found outweigh the effort spent on suppressing false positives?

That's bean counting which is completely irrelevant. Real issues and false
positives are both problems which need to be looked at carefully.

- The deadlock needs to be fixed, which is obvious.

- The false positive needs to be annotated, which is a good thing in
  several aspects:

  It proofs that this was done intentional and is correct and the
  annotation documents it at the same time in the code.

  I'm pretty sure that except for a few obvious ones the effort to prove
  that a false positive is a false positive is substantial, but not proving
  it would either be arrogant or outright stupid.

So it's not a N > M question. Even if the number of false positives is
higher than the number of real deadlocks, then everyone out in the field
who had to stare at his server once a year not making progress and not
telling why will appreciate that these obscure issues are gone.

> * What alternatives have been considered other than enabling cross-release
>   checking for all locking objects that support releasing from the context
>   of another task than the context from which the lock was obtained? Has it
>   e.g. been considered to introduce two versions of the lock objects that
>   support cross-releases - one version for which lock inversion checking is
>   always enabled and another version for which lock inversion checking is
>   always disabled?

That would just make the door open for evading lockdep. This has been
discussed when lockdep was introduced and with a lot of other 'annoying'
debug features we've seen the same discussion happening.

When they get introduced the number of real issues and false positives is
high, but once the dust settles it's just business as usual and the overall
code quality improves and the number of hard to decode problems shrinks.

> * How much review has the Documentation/locking/crossrelease.txt received
>   before it went upstream? At least to me that document seems much harder
>   to read than other kernel documentation due to weird use of the English
>   grammar.

It was reviewed, and yes it could do with some polishing, but it's a good
start.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
