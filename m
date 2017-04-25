Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B83C6B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 03:02:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p81so23435671pfd.12
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 00:02:34 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j61si14346841plb.85.2017.04.25.00.02.32
        for <linux-mm@kvack.org>;
        Tue, 25 Apr 2017 00:02:32 -0700 (PDT)
Date: Tue, 25 Apr 2017 15:59:43 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170425065943.GL21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419171954.tqp5tkxlsg4jp2xz@hirez.programming.kicks-ass.net>
 <20170424030412.GG21430@X58A-UD3R>
 <20170424093051.imizyhpifqf4t6bc@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170424093051.imizyhpifqf4t6bc@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Apr 24, 2017 at 11:30:51AM +0200, Peter Zijlstra wrote:
> +static void add_xhlock(struct held_lock *hlock)
> +{
> +       unsigned int idx = current->xhlock_idx++;
> +       struct hist_lock *xhlock = &xhlock(idx);
> 
> Yes, I misread that. Then '0' has the oldest entry, which is slightly
> weird. Should we change that?

I will just follow your decision. Do you think I should change it so
that 'xhlock_idx' points to newest one, or ok to keep it unchanged?

> 
> 
> > > > +
> > > > +		if (!xhlock_used(xhlock))
> > > > +			break;
> > > > +
> > > > +		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> > > > +			break;
> > > > +
> > > > +		if (same_context_xhlock(xhlock) &&
> > > > +		    !commit_xhlock(xlock, xhlock))
> > > 
> > > return with graph_lock held?
> > 
> > No. When commit_xhlock() returns 0, the lock was already unlocked.
> 
> Please add a comment, because I completely missed that. That's at least
> 2 functions deeper.

Yes, I will add a comment.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
