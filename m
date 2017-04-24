Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC0616B02C4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 05:30:55 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d203so220318369iof.20
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 02:30:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e124si18213854pfc.59.2017.04.24.02.30.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 02:30:54 -0700 (PDT)
Date: Mon, 24 Apr 2017 11:30:51 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424093051.imizyhpifqf4t6bc@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419171954.tqp5tkxlsg4jp2xz@hirez.programming.kicks-ass.net>
 <20170424030412.GG21430@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424030412.GG21430@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Apr 24, 2017 at 12:04:12PM +0900, Byungchul Park wrote:
> On Wed, Apr 19, 2017 at 07:19:54PM +0200, Peter Zijlstra wrote:
> > > +/*
> > > + * For crosslock.
> > > + */
> > > +static int add_xlock(struct held_lock *hlock)
> > > +{
> > > +	struct cross_lock *xlock;
> > > +	unsigned int gen_id;
> > > +
> > > +	if (!graph_lock())
> > > +		return 0;
> > > +
> > > +	xlock = &((struct lockdep_map_cross *)hlock->instance)->xlock;
> > > +
> > > +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> > > +	xlock->hlock = *hlock;
> > > +	xlock->hlock.gen_id = gen_id;
> > > +	graph_unlock();
> > 
> > What does graph_lock protect here?
> 
> Modifying xlock(not xhlock) instance should be protected with graph_lock.
> Don't you think so?

Ah, right you are. I think I got confused between our xhlock (local)
array and the xlock instance thing. The latter needs protection to
serialize concurrent acquires.

> > > +static int commit_xhlocks(struct cross_lock *xlock)
> > > +{
> > > +	unsigned int cur = current->xhlock_idx;
> > > +	unsigned int i;
> > > +
> > > +	if (!graph_lock())
> > > +		return 0;
> > > +
> > > +	for (i = cur - 1; !xhlock_same(i, cur); i--) {
> > > +		struct hist_lock *xhlock = &xhlock(i);
> > 
> > *blink*, you mean this?
> > 
> > 	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
> > 		struct hist_lock *xhlock = &xhlock(cur - i);
> 
> I will change the loop to this form.
> 
> > Except you seem to skip over the most recent element (@cur), why?
> 
> Currently 'cur' points to the next *free* slot.

Well, there's no such thing has a 'free' slot, its a _ring_ buffer.

But:

+static void add_xhlock(struct held_lock *hlock)
+{
+       unsigned int idx = current->xhlock_idx++;
+       struct hist_lock *xhlock = &xhlock(idx);

Yes, I misread that. Then '0' has the oldest entry, which is slightly
weird. Should we change that?


> > > +
> > > +		if (!xhlock_used(xhlock))
> > > +			break;
> > > +
> > > +		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> > > +			break;
> > > +
> > > +		if (same_context_xhlock(xhlock) &&
> > > +		    !commit_xhlock(xlock, xhlock))
> > 
> > return with graph_lock held?
> 
> No. When commit_xhlock() returns 0, the lock was already unlocked.

Please add a comment, because I completely missed that. That's at least
2 functions deeper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
