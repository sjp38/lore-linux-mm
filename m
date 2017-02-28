Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB936B03AC
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 08:25:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so16412653pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:25:03 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id l1si1791983pln.71.2017.02.28.05.25.01
        for <linux-mm@kvack.org>;
        Tue, 28 Feb 2017 05:25:02 -0800 (PST)
Date: Tue, 28 Feb 2017 22:24:44 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228132444.GG3817@X58A-UD3R>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228131012.GI5680@worktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228131012.GI5680@worktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Feb 28, 2017 at 02:10:12PM +0100, Peter Zijlstra wrote:
> > +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> > +
> > +#define idx(t)			((t)->xhlock_idx)
> > +#define idx_prev(i)		((i) ? (i) - 1 : MAX_XHLOCKS_NR - 1)
> > +#define idx_next(i)		(((i) + 1) % MAX_XHLOCKS_NR)
> 
> Note that:
> 
> #define idx_prev(i)		(((i) - 1) % MAX_XHLOCKS_NR)
> #define idx_next(i)		(((i) + 1) % MAX_XHLOCKS_NR)
> 
> is more symmetric and easier to understand.

OK. I will do it after forcing MAX_XHLOCKS_NR to be power of 2. Current
value of it is already power of 2 but I need to add comment explaning it.

> > +
> > +/* For easy access to xhlock */
> > +#define xhlock(t, i)		((t)->xhlocks + (i))
> > +#define xhlock_prev(t, l)	xhlock(t, idx_prev((l) - (t)->xhlocks))
> > +#define xhlock_curr(t)		xhlock(t, idx(t))
> 
> So these result in an xhlock pointer
> 
> > +#define xhlock_incr(t)		({idx(t) = idx_next(idx(t));})
> 
> This does not; which is confusing seeing how they share the same
> namespace; also incr is weird.

OK.. Could you suggest a better name? xhlock_adv()? advance_xhlock()?
And.. replace it with a function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
