Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2256B0389
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:29:08 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j18so22899211ioe.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 10:29:08 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 63si3045603itk.36.2017.02.28.10.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 10:29:07 -0800 (PST)
Date: Tue, 28 Feb 2017 19:29:02 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228182902.GN5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228131012.GI5680@worktop>
 <20170228132444.GG3817@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228132444.GG3817@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Feb 28, 2017 at 10:24:44PM +0900, Byungchul Park wrote:
> On Tue, Feb 28, 2017 at 02:10:12PM +0100, Peter Zijlstra wrote:

> > > +/* For easy access to xhlock */
> > > +#define xhlock(t, i)		((t)->xhlocks + (i))
> > > +#define xhlock_prev(t, l)	xhlock(t, idx_prev((l) - (t)->xhlocks))
> > > +#define xhlock_curr(t)		xhlock(t, idx(t))
> > 
> > So these result in an xhlock pointer
> > 
> > > +#define xhlock_incr(t)		({idx(t) = idx_next(idx(t));})
> > 
> > This does not; which is confusing seeing how they share the same
> > namespace; also incr is weird.
> 
> OK.. Could you suggest a better name? xhlock_adv()? advance_xhlock()?
> And.. replace it with a function?

How about doing: xhlocks_idx++ ? That is, keep all the indexes as
regular u32 and only reduce the space when using them as index.

Also, I would write the loop:

> +static int commit_xhlocks(struct cross_lock *xlock)
> +{
> +     struct task_struct *curr = current;
> +     struct hist_lock *xhlock_c = xhlock_curr(curr);
> +     struct hist_lock *xhlock = xhlock_c;
> +
> +     do {
> +             xhlock = xhlock_prev(curr, xhlock);
> +
> +             if (!xhlock_used(xhlock))
> +                     break;
> +
> +             if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> +                     break;
> +
> +             if (same_context_xhlock(xhlock) &&
> +                 before(xhlock->prev_gen_id, xlock->hlock.gen_id) &&
> +                 !commit_xhlock(xlock, xhlock))
> +                     return 0;
> +     } while (xhlock_c != xhlock);
> +
> +     return 1;
> +}

like:

#define xhlock(i)	current->xhlocks[i % MAX_XHLOCKS_NR]

	for (i = 0; i < MAX_XHLOCKS_NR; i++) {
		xhlock = xhlock(curr->xhlock_idx - i);

		/* ... */
	}

That avoids that horrible xhlock_prev() thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
