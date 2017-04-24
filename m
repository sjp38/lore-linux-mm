Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6101D6B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:17:57 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id g66so66021852ite.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 03:17:57 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k8si10880843itf.35.2017.04.24.03.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 03:17:56 -0700 (PDT)
Date: Mon, 24 Apr 2017 12:17:47 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424101747.iirvjjoq66x25w7n@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
 <20170424051102.GJ21430@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424051102.GJ21430@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Apr 24, 2017 at 02:11:02PM +0900, Byungchul Park wrote:
> On Wed, Apr 19, 2017 at 04:25:03PM +0200, Peter Zijlstra wrote:

> > I still don't like work_id; it doesn't have anything to do with
> > workqueues per se, other than the fact that they end up using it.
> > 
> > It's a history generation id; touching it completely invalidates our
> > history. Workqueues need this because they run independent work from the
> > same context.
> > 
> > But the same is true for other sites. Last time I suggested
> > lockdep_assert_empty() to denote all suck places (and note we already
> > have lockdep_sys_exit() that hooks into the return to user path).
> 
> I'm sorry but I don't understand what you intend. It would be appriciated
> if you explain more.
> 
> You might know why I introduced the 'work_id'.. Is there any alternative?

My complaint is mostly about naming.. and "hist_gen_id" might be a
better name.

But let me explain.


The reason workqueues need this is because the lock history for each
'work' are independent. The locks of Work-B do not depend on the locks
of the preceding Work-A, because the completion of Work-B is not
dependent on those locks.

But this is true for many things; pretty much all kthreads fall in this
pattern, where they have an 'idle' state and future completions do not
depend on past completions. Its just that since they all have the 'same'
form -- the kthread does the same over and over -- it doesn't matter
much.

The same is true for system-calls, once a system call is complete (we've
returned to userspace) the next system call does not depend on the lock
history of the previous one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
