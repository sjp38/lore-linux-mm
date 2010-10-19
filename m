Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BE17E6B00B2
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 18:54:26 -0400 (EDT)
Date: Tue, 19 Oct 2010 15:54:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] Add generic exponentially weighted moving average
 function
Message-Id: <20101019155406.0a728971.akpm@linux-foundation.org>
In-Reply-To: <20101019153756.a89ed362.akpm@linux-foundation.org>
References: <20101019083635.32294.67087.stgit@localhost6.localdomain6>
	<20101019153756.a89ed362.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bruno Randolf <br1@einfach.org>, randy.dunlap@oracle.com, kevin.granade@gmail.com, blp@cs.stanford.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 15:37:56 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 19 Oct 2010 17:36:35 +0900
> Bruno Randolf <br1@einfach.org> wrote:
> 
> > This adds a generic exponentially weighted moving average function. This
> > implementation makes use of a structure which keeps a scaled up internal
> > representation to reduce rounding errors.
> > 
> > The idea for this implementation comes from the rt2x00 driver (rt2x00link.c)
> > and I would like to use it in several places in the mac80211 and ath5k code.
> > 
> > Signed-off-by: Bruno Randolf <br1@einfach.org>
> > 
> 
> hm, interesting.  I suspect there are a few places in MM/VFS/writeback
> which could/should be using something like this.  Of course, if we do
> this then your nice little function will end up 250 lines long, utterly
> incomprehensible and full of subtle bugs.  We like things to be that way.
> 
> Thanks for proposing it as generic code, btw.  Let's merge it and see
> what happens.

I looked at the code..

> > diff --git a/include/linux/average.h b/include/linux/average.h
> > new file mode 100644
> > index 0000000..55e4317
> > --- /dev/null
> > +++ b/include/linux/average.h
> > @@ -0,0 +1,37 @@
> > +#ifndef _LINUX_AVERAGE_H
> > +#define _LINUX_AVERAGE_H
> > +
> > +#define AVG_FACTOR	1000

Can you please document the magic number?  What does it do?  I'd have
though it likely that one day this will become variable, initialised in
moving_average_init().

> > +struct avg_val {
> > +	int value;
> > +	int internal;
> > +};

So it's using integer types.

I guess that makes sense, maybe.  Does your application use negative
quantities?  They're pretty rare beasts in the kernel.  I expect most
callers will want an unsigned type?

> > +/**
> > + * moving_average() -  Exponentially weighted moving average (EWMA)
> > + * @avg: Average structure
> > + * @val: Current value
> > + * @weight: This defines how fast the influence of older values decreases.
> > + *	Has to be higher than 1. Use the same number every time you call this
> > + *	function for a single struct avg_val!
> > + *
> > + * This implementation make use of a struct avg_val which keeps a scaled up
> > + * internal representation to prevent rounding errors. Due to this, the maximum
> > + * range of values is MAX_INT/(AVG_FACTOR*weight).
> > + *
> > + * The current average value can be accessed by using avg_val.value.
> > + */
> > +static inline void
> > +moving_average(struct avg_val *avg, const int val, const int weight)
> > +{
> > +	if (WARN_ON_ONCE(weight <= 1))
> > +		return;
> > +	avg->internal = avg->internal  ?
> > +		(((avg->internal * (weight - 1)) +
> > +			(val * AVG_FACTOR)) / weight) :
> > +		(val * AVG_FACTOR);
> > +	avg->value = DIV_ROUND_CLOSEST(avg->internal, AVG_FACTOR);
> > +}

This function is really already too large to be inlined, and I'd
suggest that lib/moving_average.c would be a better home for it.

Is it expected that `weight' will have the same value for all calls of
moving_average() against a particular avg_val?  If so then perhaps we
should do away with this argument and place `weight' into the avg_val
struct, and set that up in moving_average_init().

And I do think that we need a moving_average_init(), because at present
you require that callers initialise the avg_val() by hand.  This means
that if we later add more fields to that struct, all callers will need
to be updated.  Any which are out-of-tree will have been made buggy.

Also, perhaps moving_average() should end with a

	return avg->value;

for convenience on the callers side.  Or maybe not - I haven't looked
at any calling code...

Finally, it's a little ugly to have callers poking around inside the
avg_val to get the current average.  The main problem with this is that
it restricts future implementations: they must maintain their average
in avg_val.value.  If they instead were to call

	moving_average_read(struct avg_val *)

then we get more freedom regarding future implementations.  The current
moving_average_read() could be inlined.  That would require that avg_val be
defined in the header file rather than in .c.  This is a bit sad, but
acceptable.



And finally+1: moving_average() needs locking to protect internal
state.  Right now, the caller must provide that locking.  And that's a
fine design IMO - we have no business here assuming that we can use
mutex_lock() or spin_lock() or spin_lock_irq() or spin_lock_irqsave() - 
let the caller decide that.

But the need for this caller-provided locking should be described in
the API documentation, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
