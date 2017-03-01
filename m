Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75DD06B0038
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 23:40:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so41536607pgi.4
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 20:40:49 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 64si3554093ply.256.2017.02.28.20.40.47
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 20:40:48 -0800 (PST)
Date: Wed, 1 Mar 2017 13:40:33 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170301044033.GC11663@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228131012.GI5680@worktop>
 <20170228132444.GG3817@X58A-UD3R>
 <20170228182902.GN5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228182902.GN5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Feb 28, 2017 at 07:29:02PM +0100, Peter Zijlstra wrote:
> On Tue, Feb 28, 2017 at 10:24:44PM +0900, Byungchul Park wrote:
> > On Tue, Feb 28, 2017 at 02:10:12PM +0100, Peter Zijlstra wrote:
> 
> > > > +/* For easy access to xhlock */
> > > > +#define xhlock(t, i)		((t)->xhlocks + (i))
> > > > +#define xhlock_prev(t, l)	xhlock(t, idx_prev((l) - (t)->xhlocks))
> > > > +#define xhlock_curr(t)		xhlock(t, idx(t))
> > > 
> > > So these result in an xhlock pointer
> > > 
> > > > +#define xhlock_incr(t)		({idx(t) = idx_next(idx(t));})
> > > 
> > > This does not; which is confusing seeing how they share the same
> > > namespace; also incr is weird.
> > 
> > OK.. Could you suggest a better name? xhlock_adv()? advance_xhlock()?
> > And.. replace it with a function?
> 
> How about doing: xhlocks_idx++ ? That is, keep all the indexes as
> regular u32 and only reduce the space when using them as index.

OK.

> 
> Also, I would write the loop:
> 
> > +static int commit_xhlocks(struct cross_lock *xlock)
> > +{
> > +     struct task_struct *curr = current;
> > +     struct hist_lock *xhlock_c = xhlock_curr(curr);
> > +     struct hist_lock *xhlock = xhlock_c;
> > +
> > +     do {
> > +             xhlock = xhlock_prev(curr, xhlock);
> > +
> > +             if (!xhlock_used(xhlock))
> > +                     break;
> > +
> > +             if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> > +                     break;
> > +
> > +             if (same_context_xhlock(xhlock) &&
> > +                 before(xhlock->prev_gen_id, xlock->hlock.gen_id) &&
> > +                 !commit_xhlock(xlock, xhlock))
> > +                     return 0;
> > +     } while (xhlock_c != xhlock);
> > +
> > +     return 1;
> > +}
> 
> like:
> 
> #define xhlock(i)	current->xhlocks[i % MAX_XHLOCKS_NR]
> 
> 	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
> 		xhlock = xhlock(curr->xhlock_idx - i);
> 
> 		/* ... */
> 	}
> 
> That avoids that horrible xhlock_prev() thing.

Right. I decided to force MAX_XHLOCKS_NR to be power of 2 and everything
became easy. Thank you very much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
