Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 811596B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 15:44:30 -0400 (EDT)
Date: Fri, 28 Jun 2013 15:44:02 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628154402.4035f2fa@redhat.com>
In-Reply-To: <20130628185547.GA14520@teo>
References: <20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
	<20130628144507.37d28ed9@redhat.com>
	<20130628185547.GA14520@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, 28 Jun 2013 11:55:47 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Fri, Jun 28, 2013 at 02:45:07PM -0400, Luiz Capitulino wrote:
> > On Fri, 28 Jun 2013 10:09:17 -0700
> > Anton Vorontsov <anton@enomsg.org> wrote:
> > 
> > > So, I would now argue that the current scheme is perfectly OK and can do
> > > everything you can do with the "strict" one,
> > 
> > I forgot commenting this bit. This is not true, because I don't want a
> > low fd to be notified on critical level. The current interface just
> > can't do that.
> 
> Why can't you use poll() and demultiplex the events? Check if there is an
> event in the crit fd, and if there is, then just ignore all the rest.

This may be a valid workaround for current kernels, but application
behavior will be different among kernels with a different number of
events.

Say, we events on top of critical. Then crit fd will now be
notified for cases where it didn't use to on older kernels.

> > However, it *is* possible to make non-strict work on strict if we make
> > strict default _and_ make reads on memory.pressure_level return
> > available events. Just do this on app initialization:
> > 
> > for each event in memory.pressure_level; do
> > 	/* register eventfd to be notified on "event" */
> > done
> 
> This scheme registers "all" events.

Yes, because I thought that's the user-case that matters for activity
manager :)

> Here is more complicated case:
> 
> Old kernels, pressure_level reads:
> 
>   low, med, crit
> 
> The app just wants to listen for med level.
> 
> New kernels, pressure_level reads:
> 
>   low, FOO, med, BAR, crit
> 
> How would application decide which of FOO and BAR are ex-med levels?

What you meant by ex-med?

Let's not over-design. I agree that allowing the API to be extended
is a good thing, but we shouldn't give complex meaning to events,
otherwise we're better with a numeric scale instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
