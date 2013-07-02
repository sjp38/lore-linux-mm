Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 2AF616B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 10:59:47 -0400 (EDT)
Date: Tue, 2 Jul 2013 10:59:11 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130702105911.2830181d@redhat.com>
In-Reply-To: <20130629005637.GA16068@teo>
References: <20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
	<20130628144507.37d28ed9@redhat.com>
	<20130628185547.GA14520@teo>
	<20130628154402.4035f2fa@redhat.com>
	<20130629005637.GA16068@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, 28 Jun 2013 17:56:37 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Fri, Jun 28, 2013 at 03:44:02PM -0400, Luiz Capitulino wrote:
> > > Why can't you use poll() and demultiplex the events? Check if there is an
> > > event in the crit fd, and if there is, then just ignore all the rest.
> > 
> > This may be a valid workaround for current kernels, but application
> > behavior will be different among kernels with a different number of
> > events.
> 
> This is not a workaround, this is how poll works, and this is kinda
> expected...

I think this is a workaround because it's tailored to my specific
use-case and to a specific kernel version, as:

 1. Applications registering for lower levels (eg. low) are still
    unable to tell which level actually caused them to be notified,
    as lower levels are triggered along with higher levels

 2. Considering the interface can be extended, how can new applications
    work on backwards mode? Say, we add ultra-critical on 3.12 and
    I update my application to work on it, how will my application
    work on 3.11?

    Hint: Try and error is an horribly bad approach.

 3. I also don't believe we have good forward compatibility with
    the current API, as adding new events will cause existing ones
    to be triggered more often, so I'd expect app behavior to vary
    among kernels with a different number of events.

Honestly, what Andrew suggested is the best design for me: apps
are notified on all events but the event name is sent to the application.

This is pretty simple and solves all the problems we've discussed
so far.

Why can't we just do it?

> But not that I had this plan in mind when I was designing the
> current scheme... :)

Hehe :)

> > Say, we events on top of critical. Then crit fd will now be
> > notified for cases where it didn't use to on older kernels.
> 
> I'm not sure I am following here... but thinking about it more, I guess
> the extra read() will be needed anyway (to reset the counter).

I hope I have explained this more clearly above.

> > > > However, it *is* possible to make non-strict work on strict if we make
> > > > strict default _and_ make reads on memory.pressure_level return
> > > > available events. Just do this on app initialization:
> > > > 
> > > > for each event in memory.pressure_level; do
> > > > 	/* register eventfd to be notified on "event" */
> > > > done
> > > 
> > > This scheme registers "all" events.
> > 
> > Yes, because I thought that's the user-case that matters for activity
> > manager :)
> 
> Some activity managers use only low levels (Android), some might use only
> medium levels (simple load-balancing).
> 
> Being able to register only "all" does not make sense to me.

Well, you can skip events if you want.

> > > Here is more complicated case:
> > > 
> > > Old kernels, pressure_level reads:
> > > 
> > >   low, med, crit
> > > 
> > > The app just wants to listen for med level.
> > > 
> > > New kernels, pressure_level reads:
> > > 
> > >   low, FOO, med, BAR, crit
> > > 
> > > How would application decide which of FOO and BAR are ex-med levels?
> > 
> > What you meant by ex-med?
> 
> The scale is continuous and non-overlapping. If you add some other level,
> you effectively "shrinking" other levels, so the ex-med in the list above
> might correspond to "FOO, med" or "med, BAR" or "FOO, med, BAR", and that
> is exactly the problem.

Just return the events in order?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
