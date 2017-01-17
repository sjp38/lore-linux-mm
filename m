Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A18BF6B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 21:33:49 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so108534942pgf.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 18:33:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d198si23301199pga.322.2017.01.16.18.33.48
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 18:33:48 -0800 (PST)
Date: Tue, 17 Jan 2017 11:33:41 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170117023341.GG3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <20170116151319.GE3144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170116151319.GE3144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Mon, Jan 16, 2017 at 04:13:19PM +0100, Peter Zijlstra wrote:
> On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:
> > +	/*
> > +	 * We assign class_idx here redundantly even though following
> > +	 * memcpy will cover it, in order to ensure a rcu reader can
> > +	 * access the class_idx atomically without lock.
> > +	 *
> > +	 * Here we assume setting a word-sized variable is atomic.
> 
> which one, where?

I meant xlock_class(xlock) in check_add_plock().

I was not sure about the following two.

1. Is it ordered between following a and b?
   a. memcpy -> list_add_tail_rcu
   b. list_for_each_entry_rcu -> load class_idx (xlock_class)
   I assumed that it's not ordered.
2. Does memcpy guarantee atomic store for each word?
   I assumed that it doesn't.

But I think I was wrong.. The first might be ordered. I will remove
the following redundant statement. It'd be orderd, right?

> 
> > +	 */
> > +	xlock->hlock.class_idx = hlock->class_idx;
> > +	gen_id = (unsigned int)atomic_inc_return(&cross_gen_id);
> > +	WRITE_ONCE(xlock->gen_id, gen_id);
> > +	memcpy(&xlock->hlock, hlock, sizeof(struct held_lock));
> > +	INIT_LIST_HEAD(&xlock->xlock_entry);
> > +	list_add_tail_rcu(&xlock->xlock_entry, &xlocks_head);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
