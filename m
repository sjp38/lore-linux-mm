Date: Mon, 25 Sep 2000 20:25:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925202549.V2615@redhat.com>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925123456.A16612@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 12:34:56PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 12:34:56PM -0600, yodaiken@fsmlabs.com wrote:

> > > Process 1,2 and 3 all start allocating 20 pages
> > >     now 57 pages are locked up in non-swapable kernel space and the system deadlocks OOM.
> > 
> > Or go the beancounter route: process 1 asks "can I pin 20 pages", gets
> > told "yes", and goes allocating them, blocking as necessary until it
> 
> So you have a "pre-allocation allocator"?  Leads to interesting and hard to detect
> bugs with old code that does not pre-allocate or with code that incorrectly pre-allocates
> or that blocks on something unrelated

Right, but if the alternative is spurious ENOMEM when we can satisfy
all of the pending requests just as long as they are serialised, is
this a problem?

If you want, wrap it in a "get_free_pagev" call which returns a vector
of pointers to free pages, doing whatever accounting is needed.  You
don't have to push all of it to the callers.

However, you just can't escape from the fact that on low memory
machinnes, we *need* beancounter-style accounting of pinned pages or
we'll be in Deep Trouble (TM).  We already have nasty DoS situations
which are embarassingly easy to reproduce.  If we need such
beancounter protection, AND such protection can prevent the situation
you describe, then do we need to go looking for another way of
achieving the same protection?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
