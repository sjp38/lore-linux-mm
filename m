Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 059E16B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 02:49:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z128so280525044pfb.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:49:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 33si24122275plg.204.2017.01.16.23.49.42
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 23:49:43 -0800 (PST)
Date: Tue, 17 Jan 2017 16:49:35 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170117074935.GJ3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <20170116151001.GD3144@twins.programming.kicks-ass.net>
 <20170117020541.GF3326@X58A-UD3R>
 <20170117071220.GJ25813@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117071220.GJ25813@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Tue, Jan 17, 2017 at 08:12:20AM +0100, Peter Zijlstra wrote:
> On Tue, Jan 17, 2017 at 11:05:42AM +0900, Byungchul Park wrote:
> > On Mon, Jan 16, 2017 at 04:10:01PM +0100, Peter Zijlstra wrote:
> > > On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:
> 
> > > > +
> > > > +	/*
> > > > +	 * Whenever irq happens, these are updated so that we can
> > > > +	 * distinguish each irq context uniquely.
> > > > +	 */
> > > > +	unsigned int		hardirq_id;
> > > > +	unsigned int		softirq_id;
> > > 
> > > An alternative approach would be to 'unwind' or discard all historical
> > > events from a nested context once we exit it.
> > 
> > That's one of what I considered. However, it would make code complex to
> > detect if pend_lock ring buffer was wrapped.
> 
> I'm not sure I see the need for detecting that...
> 
> > > 
> > > After all, all we care about is the history of the release context, once
> > > the context is gone, we don't care.
> > 
> > We must care it and decide if the next plock in the ring buffer might be
> > valid one or not.
> 
> So I was thinking this was an overwriting ring buffer; something like
> so:

OK. I am making code just overwrite ring buffer when overflowing it,
instead of warning the situation.

Thank you very much.

> 
> struct pend_lock plocks[64];
> unsigned int plocks_idx;
> 
> static void plocks_add(..)
> {
> 	unsigned int idx = (plocks_idx++) % 64;
> 
> 	plocks[idx] = ...;
> }
> 
> static void plocks_close_context(int ctx)
> {
> 	for (i = 0; i < 64; i++) {
> 		int idx = (plocks_idx - 1) % 64;
> 		if (plocks[idx].ctx != ctx)
> 			break;
> 
> 		plocks_idx--;
> 	}
> }
> 
> Similarly for the release, it need only look at 64 entries and terminate
> early if the generation number is too old.
> 
> static void plocks_release(unsigned int gen)
> {
> 	for (i = 0; i < 64; i++) {
> 		int idx = (plocks_idx - 1 - i) % 64;
> 		if ((int)(plocks[idx].gen_id - gen) < 0)
> 			break;
> 
> 		/* do release muck */
> 	}
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
