Date: Wed, 10 May 2000 08:31:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: A possible winner in pre7-8
In-Reply-To: <yttvh0nozf7.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.10.10005100817530.1989-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 10 May 2000, Juan J. Quintela wrote:
> 
> It begin to kill processes after the 10th iteration.  After that, the
> machine freezes.

Do you have a SMP machine? If so, I think I found this one.

And it's been there for ages.

The bug is that GFP_ATOMIC _really_ must not try to page stuff out,
eventhe stuff that doesn't need IO to be dropped.

Why? Because GFP_ATOMIC can be (and mostly is) called from interrupts, and
even when we don't do IO we _do_ access a number of spinlocks in order to
see whether we can even just drop it.

For example, in order to scan the page tables we take the page_table_lock
("vmlist_access_lock") which is not irq-safe.

So the lockup will occur if you take an interrupt that does an allocation
(usually networking-related) while you hold the page_table_lock (which can
be due to a swapout, for example).

The reason it has been there for long is that usually SMP machines have
enough memory that this condition is really hard to trigger in normal use.
And on UP machines you'd never see the problem (except, possibly, as page
table double-freeing, but the window for that looks extremely small
indeed, much smaller than the double-spinlock window).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
