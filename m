Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C2FB16B0038
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:33:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b6so5717161pff.18
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 13:33:18 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f11si6200223plj.190.2017.10.19.13.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 13:33:17 -0700 (PDT)
Date: Thu, 19 Oct 2017 13:33:13 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 2/3] lockdep: Remove BROKEN flag of
 LOCKDEP_CROSSRELEASE
Message-ID: <20171019203313.GA10538@bombadil.infradead.org>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
 <1508392531-11284-3-git-send-email-byungchul.park@lge.com>
 <1508425527.2429.11.camel@wdc.com>
 <alpine.DEB.2.20.1710191718260.1971@nanos>
 <1508428021.2429.22.camel@wdc.com>
 <alpine.DEB.2.20.1710192021480.2054@nanos>
 <alpine.DEB.2.20.1710192107000.2054@nanos>
 <1508444515.2429.55.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508444515.2429.55.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "byungchul.park@lge.com" <byungchul.park@lge.com>, "kernel-team@lge.com" <kernel-team@lge.com>

On Thu, Oct 19, 2017 at 08:21:56PM +0000, Bart Van Assche wrote:
> In case it wouldn't be clear, your work and the work of others on lockdep
> and preempt-rt is highly appreciated. Sorry that I missed the discussion
> about the cross-release functionality when it went upstream. I have several
> questions about that functionality:
> * How many lock inversion problems have been found so far thanks to the
>   cross-release checking? How many false positives have the cross-release
>   checks triggered so far? Does the number of real issues that has been
>   found outweigh the effort spent on suppressing false positives?
> * What alternatives have been considered other than enabling cross-release
>   checking for all locking objects that support releasing from the context
>   of another task than the context from which the lock was obtained? Has it
>   e.g. been considered to introduce two versions of the lock objects that
>   support cross-releases - one version for which lock inversion checking is
>   always enabled and another version for which lock inversion checking is
>   always disabled?
> * How much review has the Documentation/locking/crossrelease.txt received
>   before it went upstream? At least to me that document seems much harder
>   to read than other kernel documentation due to weird use of the English
>   grammar.

While interesting, I think this list of questions misses an important one:

 * How many bugs is this going to catch in the future?

For example, the page lock is not annotatable with lockdep -- we return
to userspace with it held, for heaven's sake!  So it is quite easy for
someone not familiar with the MM locking hierarchy to inadvertently
introduce an ABBA deadlock against the page lock.  (ie me.  I did that.)
Right now, that has to be caught by a human reviewer; if cross-release
checking can catch that, then it's worth having.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
