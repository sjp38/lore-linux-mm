Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0BC946B00C5
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 22:42:07 -0400 (EDT)
Received: from vs3017.wh2.ocn.ne.jp (125.206.180.250)
	by mail30s.wh2.ocn.ne.jp (RS ver 1.0.95vs) with SMTP id 3-0970072523
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 11:42:05 +0900 (JST)
From: Bruno Randolf <br1@einfach.org>
Subject: Re: [PATCH v2] Add generic exponentially weighted moving average function
Date: Wed, 20 Oct 2010 11:42:00 +0900
References: <20101019083635.32294.67087.stgit@localhost6.localdomain6> <20101019153756.a89ed362.akpm@linux-foundation.org> <20101019155406.0a728971.akpm@linux-foundation.org>
In-Reply-To: <20101019155406.0a728971.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201010201142.00110.br1@einfach.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: randy.dunlap@oracle.com, kevin.granade@gmail.com, blp@cs.stanford.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed October 20 2010 07:54:06 Andrew Morton wrote:
> I looked at the code..

Thank you for your review!

> > > +#define AVG_FACTOR	1000
> 
> Can you please document the magic number?  What does it do?  I'd have
> though it likely that one day this will become variable, initialised in
> moving_average_init().

OK. I thought I'd get away without it ;) but you convinced me it's better to 
have a moving_average_init().

> > > +struct avg_val {
> > > +	int value;
> > > +	int internal;
> > > +};
> 
> So it's using integer types.
> 
> I guess that makes sense, maybe.  Does your application use negative
> quantities?  They're pretty rare beasts in the kernel.  I expect most
> callers will want an unsigned type?

I want to use it with negative numbers (signal strength in dBm), but it's easy 
enough to convert them to positive numbers, so I'll change the variables to 
unsigned. I guess averaging between positive and negative numbers is really 
rare...

> > > +static inline void
> > > +moving_average(struct avg_val *avg, const int val, const int weight)
> > > +{
> > > +	if (WARN_ON_ONCE(weight <= 1))
> > > +		return;
> > > +	avg->internal = avg->internal  ?
> > > +		(((avg->internal * (weight - 1)) +
> > > +			(val * AVG_FACTOR)) / weight) :
> > > +		(val * AVG_FACTOR);
> > > +	avg->value = DIV_ROUND_CLOSEST(avg->internal, AVG_FACTOR);
> > > +}
> 
> This function is really already too large to be inlined, and I'd
> suggest that lib/moving_average.c would be a better home for it.

OK. Maybe we could call it lib/average.c so other averaging implementations - 
should there be any in the future - could go there as well?

> Is it expected that `weight' will have the same value for all calls of
> moving_average() against a particular avg_val?  If so then perhaps we
> should do away with this argument and place `weight' into the avg_val
> struct, and set that up in moving_average_init().

Yes. So I'll make a moving_average_init(scaling_factor, weight).

> And I do think that we need a moving_average_init(), because at present
> you require that callers initialise the avg_val() by hand.  This means
> that if we later add more fields to that struct, all callers will need
> to be updated.  Any which are out-of-tree will have been made buggy.

Well, the initialization we currently require is just to make sure is is 
zeroed out... But I agree to the other benefits using an init function.

> Also, perhaps moving_average() should end with a
> 
> 	return avg->value;
> 
> for convenience on the callers side.  Or maybe not - I haven't looked
> at any calling code...

Ok. No problem.
 
> Finally, it's a little ugly to have callers poking around inside the
> avg_val to get the current average.  The main problem with this is that
> it restricts future implementations: they must maintain their average
> in avg_val.value.  If they instead were to call
> 
> 	moving_average_read(struct avg_val *)
> 
> then we get more freedom regarding future implementations.  The current
> moving_average_read() could be inlined.  That would require that avg_val be
> defined in the header file rather than in .c.  This is a bit sad, but
> acceptable.

I see.
 
> And finally+1: moving_average() needs locking to protect internal
> state.  Right now, the caller must provide that locking.  And that's a
> fine design IMO - we have no business here assuming that we can use
> mutex_lock() or spin_lock() or spin_lock_irq() or spin_lock_irqsave() -
> let the caller decide that.
> 
> But the need for this caller-provided locking should be described in
> the API documentation, please.

Will do that and resend an improved version shortly.

Thanks,
Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
