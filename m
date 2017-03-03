Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF3F6B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 03:14:17 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id w189so71720973pfb.4
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 00:14:17 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x15si9851973pgc.190.2017.03.03.00.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 00:14:16 -0800 (PST)
Date: Fri, 3 Mar 2017 09:14:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170303081416.GT6515@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228134018.GK5680@worktop>
 <20170301054323.GE11663@X58A-UD3R>
 <20170301122843.GF6515@twins.programming.kicks-ass.net>
 <20170302134031.GG6536@twins.programming.kicks-ass.net>
 <20170303001737.GF28562@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170303001737.GF28562@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com, Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>

On Fri, Mar 03, 2017 at 09:17:37AM +0900, Byungchul Park wrote:
> On Thu, Mar 02, 2017 at 02:40:31PM +0100, Peter Zijlstra wrote:

> > diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> > index a95e5d1..7baea89 100644
> > --- a/kernel/locking/lockdep.c
> > +++ b/kernel/locking/lockdep.c
> > @@ -1860,6 +1860,17 @@ check_prev_add(struct task_struct *curr, struct held_lock *prev,
> >  		}
> >  	}
> >  
> > +	/*
> > +	 * Is the <prev> -> <next> redundant?
> > +	 */
> > +	this.class = hlock_class(prev);
> > +	this.parent = NULL;
> > +	ret = check_noncircular(&this, hlock_class(next), &target_entry);
> > +	if (!ret) /* exists, redundant */
> > +		return 2;
> > +	if (ret < 0)
> > +		return print_bfs_bug(ret);
> > +
> >  	if (!*stack_saved) {
> >  		if (!save_trace(&trace))
> >  			return 0;
> 
> This whoud be very nice if you allow to add this code. However, prev_gen_id
> thingy is still useful, the code above can achieve it though. Agree?

So my goal was to avoid prev_gen_id, and yes I think the above does
that.

Now the problem with the above condition is that it makes reports
harder to decipher, because by avoiding adding redundant links to our
graph we loose a possible shorter path.

So while for correctness sake it doesn't matter, it is irrelevant how
long the cycle is after all, all that matters is that there is a cycle.
But the humans on the receiving end tend to like shorter cycles.

And I think the same is true for crossrelease, avoiding redundant links
increases cycle length.

(And remember, BFS will otherwise find the shortest cycle.)

That said; I'd be fairly interested in numbers on how many links this
avoids, I'll go make a check_redundant() version of the above and put a
proper counter in so I can see what it does for a regular boot etc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
