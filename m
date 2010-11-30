Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 07FB86B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:03:24 -0500 (EST)
Date: Tue, 30 Nov 2010 15:03:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [thisops uV3 15/18] Xen: Use this_cpu_ops
In-Reply-To: <4CF56463.3040109@goop.org>
Message-ID: <alpine.DEB.2.00.1011301501320.4039@router.home>
References: <20101130190707.457099608@linux.com> <20101130190850.002148257@linux.com> <4CF56463.3040109@goop.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, Jeremy Fitzhardinge wrote:

> On 11/30/2010 11:07 AM, Christoph Lameter wrote:
> >  static irqreturn_t xen_timer_interrupt(int irq, void *dev_id)
> >  {
> > -	struct clock_event_device *evt = &__get_cpu_var(xen_clock_events);
> >  	irqreturn_t ret;
> >
> >  	ret = IRQ_NONE;
> > -	if (evt->event_handler) {
> > -		evt->event_handler(evt);
> > +	if (__this_cpu_read(xen_clock_events.event_handler)) {
> > +		__this_cpu_read(xen_clock_events.event_handler)(evt);
>
> Really?  What code does this generate?  If this is generating two
> segment-prefixed reads rather than getting the address and doing normal
> reads on it, then I don't think it is an improvement.

Lets drop that hunk. No point to do optimizations at that location then.

evt is also not defined then. Without the evt address determination via
__get_cpu_var we have at least 2 prefixed load and one address
calculation to figure out the parameter to pass. No win.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
