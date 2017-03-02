Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E8B46B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 21:52:44 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 1so77385779pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 18:52:44 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z17si6194721pgi.387.2017.03.01.18.52.42
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 18:52:43 -0800 (PST)
Date: Thu, 2 Mar 2017 11:52:25 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302025225.GL11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228154900.GL5680@worktop>
 <20170301051706.GD11663@X58A-UD3R>
MIME-Version: 1.0
In-Reply-To: <20170301051706.GD11663@X58A-UD3R>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Mar 01, 2017 at 02:17:07PM +0900, Byungchul Park wrote:
> > > +void lock_commit_crosslock(struct lockdep_map *lock)
> > > +{
> > > +	struct cross_lock *xlock;
> > > +	unsigned long flags;
> > > +
> > > +	if (!current->xhlocks)
> > > +		return;
> > > +
> > > +	if (unlikely(current->lockdep_recursion))
> > > +		return;
> > > +
> > > +	raw_local_irq_save(flags);
> > > +	check_flags(flags);
> > > +	current->lockdep_recursion = 1;
> > > +
> > > +	if (unlikely(!debug_locks))
> > > +		return;
> > > +
> > > +	if (!graph_lock())
> > > +		return;
> > > +
> > > +	xlock = &((struct lockdep_map_cross *)lock)->xlock;
> > > +	if (atomic_read(&xlock->ref) > 0 && !commit_xhlocks(xlock))
> > 
> > You terminate with graph_lock() held.
> 
> Oops. What did I do? I'll fix it.

I remembered it. It's no problem because it would terminate there, only
if _both_ 'xlock->ref > 0' and 'commit_xhlocks returns 0' are true.
Otherwise, it will unlock the lock safely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
