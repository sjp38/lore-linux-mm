Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD04B6B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:54:00 -0500 (EST)
Message-ID: <4CF56463.3040109@goop.org>
Date: Tue, 30 Nov 2010 12:53:55 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [thisops uV3 15/18] Xen: Use this_cpu_ops
References: <20101130190707.457099608@linux.com> <20101130190850.002148257@linux.com>
In-Reply-To: <20101130190850.002148257@linux.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/30/2010 11:07 AM, Christoph Lameter wrote:
>  static irqreturn_t xen_timer_interrupt(int irq, void *dev_id)
>  {
> -	struct clock_event_device *evt = &__get_cpu_var(xen_clock_events);
>  	irqreturn_t ret;
>  
>  	ret = IRQ_NONE;
> -	if (evt->event_handler) {
> -		evt->event_handler(evt);
> +	if (__this_cpu_read(xen_clock_events.event_handler)) {
> +		__this_cpu_read(xen_clock_events.event_handler)(evt);

Really?  What code does this generate?  If this is generating two
segment-prefixed reads rather than getting the address and doing normal
reads on it, then I don't think it is an improvement.

The rest looks OK, I guess.  How does it change the generated code?

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
