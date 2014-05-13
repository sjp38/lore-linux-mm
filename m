Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4846B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:46:49 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so500620eek.40
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:46:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si13331455eel.256.2014.05.13.07.46.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 07:46:48 -0700 (PDT)
Date: Tue, 13 May 2014 15:46:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140513144642.GV23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
 <20140513110951.GB30445@twins.programming.kicks-ass.net>
 <20140513125007.GQ23991@suse.de>
 <20140513140127.GC2485@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513140127.GC2485@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 04:01:27PM +0200, Peter Zijlstra wrote:
> On Tue, May 13, 2014 at 01:50:07PM +0100, Mel Gorman wrote:
> > > Anyway, nothing wrong with this patch, however, you could, if you really
> > > wanted to push things, also include BH_Lock in that clear :-)
> > 
> > That's a bold strategy Cotton.
> 
> :-)
> 
> > Untested patch on top
> > 
> > ---8<---
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index e80012d..42fcb6d 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -1490,6 +1490,8 @@ static void discard_buffer(struct buffer_head * bh)
> >  	lock_buffer(bh);
> >  	clear_buffer_dirty(bh);
> >  	bh->b_bdev = NULL;
> > +
> > +	smp_mb__before_clear_bit();
> 
> Not needed.
> 
> >  	b_state = bh->b_state;
> >  	for (;;) {
> >  		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
> > @@ -1497,7 +1499,13 @@ static void discard_buffer(struct buffer_head * bh)
> >  			break;
> >  		b_state = b_state_old;
> >  	}
> > -	unlock_buffer(bh);
> > +
> > +	/*
> > +	 * BUFFER_FLAGS_DISCARD include BH_lock so it has been cleared so the
> > +	 * wake_up_bit is the last part of a unlock_buffer
> > +	 */
> > +	smp_mb__after_clear_bit();
> 
> Similarly superfluous.
> 
> > +	wake_up_bit(&bh->b_state, BH_Lock);
> >  }
> 
> The thing is that cmpxchg() guarantees full barrier semantics before and
> after the op, and since the loop guarantees at least one cmpxchg() call
> its all good.
> 

Of course, thanks for pointing that out. I was only thinking of it in
terms of it being a clear_bit operation which was dumb.

> Now just to confuse everyone, you could have written the loop like:
> 
> 	b_state = bh->b_state;
> 	for (;;) {
> 		b_state_new = b_state & ~BUFFER_FLAGS_DISCARD;
> 		if (b_state == b_state_new)
> 			break;
> 		b_state = cmpxchg(&bh->b_state, b_state, b_state_new);
> 	}
> 
> Which is 'similar' but doesn't guarantee that cmpxchg() gets called.
> If you expect the initial value to match the new state, the above form
> is slightly faster, but the lack of barrier guarantees can still spoil
> the fun.

I do not really expect the initial value to match the new state. At the
very least I would expect BH_mapped to be routinely cleared during this
operation so I doubt it's worth the effort trying to deal with
conditional buffers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
