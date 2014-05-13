Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0094E6B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 08:50:13 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so383503eek.15
        for <linux-mm@kvack.org>; Tue, 13 May 2014 05:50:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h41si344867eeo.28.2014.05.13.05.50.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 05:50:12 -0700 (PDT)
Date: Tue, 13 May 2014 13:50:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 17/19] fs: buffer: Do not use unnecessary atomic
 operations when discarding buffers
Message-ID: <20140513125007.GQ23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-18-git-send-email-mgorman@suse.de>
 <20140513110951.GB30445@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140513110951.GB30445@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 01:09:51PM +0200, Peter Zijlstra wrote:
> On Tue, May 13, 2014 at 10:45:48AM +0100, Mel Gorman wrote:
> > Discarding buffers uses a bunch of atomic operations when discarding buffers
> > because ...... I can't think of a reason. Use a cmpxchg loop to clear all the
> > necessary flags. In most (all?) cases this will be a single atomic operations.
> > 
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  fs/buffer.c                 | 14 +++++++++-----
> >  include/linux/buffer_head.h |  5 +++++
> >  2 files changed, 14 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 9ddb9fc..e80012d 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -1485,14 +1485,18 @@ EXPORT_SYMBOL(set_bh_page);
> >   */
> >  static void discard_buffer(struct buffer_head * bh)
> >  {
> > +	unsigned long b_state, b_state_old;
> > +
> >  	lock_buffer(bh);
> >  	clear_buffer_dirty(bh);
> >  	bh->b_bdev = NULL;
> > -	clear_buffer_mapped(bh);
> > -	clear_buffer_req(bh);
> > -	clear_buffer_new(bh);
> > -	clear_buffer_delay(bh);
> > -	clear_buffer_unwritten(bh);
> > +	b_state = bh->b_state;
> > +	for (;;) {
> > +		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
> > +		if (b_state_old == b_state)
> > +			break;
> > +		b_state = b_state_old;
> > +	}
> >  	unlock_buffer(bh);
> >  }
> 
> So.. I'm soon going to introduce atomic_{or,and}() and
> atomic64_{or,and}() across the board, but of course this isn't an
> atomic_long_t but a regular unsigned long.
> 
> Its a bit unfortunate we have this discrepancy with types vs atomic ops,
> there's:
> 
>   cmpxchg, xchg -- mostly available for all 1,2,3,4 (and 8 where
>   appropriate) byte values.
> 
>   bitops -- operate on unsigned long *
> 
>   atomic* -- operate on atomic_*t

I hit the same problem when dealing with pageblock bitmap. I would have
preferred it to do an atomic_read() but the actual conversion to use
atomic_t for the map became a mess with little or no upside.

> 
> operation which is available on a lot of architectures, we'll be stuck
> with a cmpxchg loop instead :/
> 
> *sigh*
> 
> Anyway, nothing wrong with this patch, however, you could, if you really
> wanted to push things, also include BH_Lock in that clear :-)

That's a bold strategy Cotton.

Untested patch on top

---8<---
diff --git a/fs/buffer.c b/fs/buffer.c
index e80012d..42fcb6d 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1490,6 +1490,8 @@ static void discard_buffer(struct buffer_head * bh)
 	lock_buffer(bh);
 	clear_buffer_dirty(bh);
 	bh->b_bdev = NULL;
+
+	smp_mb__before_clear_bit();
 	b_state = bh->b_state;
 	for (;;) {
 		b_state_old = cmpxchg(&bh->b_state, b_state, (b_state & ~BUFFER_FLAGS_DISCARD));
@@ -1497,7 +1499,13 @@ static void discard_buffer(struct buffer_head * bh)
 			break;
 		b_state = b_state_old;
 	}
-	unlock_buffer(bh);
+
+	/*
+	 * BUFFER_FLAGS_DISCARD include BH_lock so it has been cleared so the
+	 * wake_up_bit is the last part of a unlock_buffer
+	 */
+	smp_mb__after_clear_bit();
+	wake_up_bit(&bh->b_state, BH_Lock);
 }
 
 /**
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 95f565a..523db58 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -80,7 +80,7 @@ struct buffer_head {
 /* Bits that are cleared during an invalidate */
 #define BUFFER_FLAGS_DISCARD \
 	(1 << BH_Mapped | 1 << BH_New | 1 << BH_Req | \
-	 1 << BH_Delay | 1 << BH_Unwritten)
+	 1 << BH_Delay | 1 << BH_Unwritten | 1 << BH_Lock)
 
 /*
  * macro tricks to expand the set_buffer_foo(), clear_buffer_foo()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
