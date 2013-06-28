Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 8B9766B0033
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:58:58 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:58:29 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628145829.14dde5a2@redhat.com>
In-Reply-To: <20130628184547.GA14287@teo>
References: <20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
	<20130628142558.5da3d030@redhat.com>
	<20130628184547.GA14287@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, 28 Jun 2013 11:45:47 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Fri, Jun 28, 2013 at 02:25:58PM -0400, Luiz Capitulino wrote:
> > > > > That's how it's expected to work, because on strict mode you're notified
> > > > > for the level you registered for. So apps registering for critical, will
> > > > > still be notified on critical just like before.
> > > > 
> > > > Suppose you introduce a new level, and the system hits this level. Before,
> > > > the app would receive at least some notification for the given memory load
> > > > (i.e. one of the old levels), with the new level introduced in the kernel,
> > > > the app will receive no events at all.
> > 
> > That's not true. If an app registered for critical it will still get
> > critical notification when the system is at the critical level. Just as it
> > always did. No new events will change this.
> > 
> > With today's semantics though, new events will change when current events
> > are triggered. So each new extension will cause applications to have
> > different behaviors, in different kernel versions. This looks quite
> > undesirable to me.
> 
> I'll try to explain it again.
> 
> Old behaviour:
> 
> low -> event
>   x <- but the system is at this unnamed level, between low and med
> med
> crit
> 
> 
> We add a level:
> 
> low
> low-med <- system at this state, we send an event, but the old app does
>            not know about it, so it won't receive *any* notifications. (In
> 	   older kernels it would receive low level notification
> med
> crit
> 
> You really don't see a problem here?

I do get what you're saying. We disagree it's a problem. In my mind the
best API is to get what you registered for. Nothing more, nothing less.

Now, there might be ways around it (being it a problem or not). I was
also considering this:

> 3. Never change the levels (how can we know?)

If we fail at determining levels (I honestly think current levels are
all we need), we can add a new interface later.

Also, what I said in the last email should work, which is to make
memory.pressure_level return supported levels, so an application can
register for all available levels. This way it will never miss a level.

I also think this matches having the mechanism in the kernel and
policy in user-space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
