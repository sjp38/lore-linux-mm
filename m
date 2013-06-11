Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 42EED6B0031
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 02:21:28 -0400 (EDT)
Date: Tue, 11 Jun 2013 08:21:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: event control at vmpressure.
Message-ID: <20130611062124.GA24031@dhcp22.suse.cz>
References: <021701ce65cb$a3b9c3b0$eb2d4b10$%kim@samsung.com>
 <20130610151258.GA14295@dhcp22.suse.cz>
 <20130611001747.GA16971@teo>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130611001747.GA16971@teo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Mon 10-06-13 17:17:47, Anton Vorontsov wrote:
> On Mon, Jun 10, 2013 at 05:12:58PM +0200, Michal Hocko wrote:
> > > +		if (level >= ev->level && level != vmpr->current_level) {
> > >  			eventfd_signal(ev->efd, 1);
> > >  			signalled = true;
> > > +			vmpr->current_level = level;
> > 
> > This would mean that you send a signal for, say, VMPRESSURE_LOW, then
> > the reclaim finishes and two days later when you hit the reclaim again
> > you would simply miss the event, right?
> > 
> > So, unless I am missing something, then this is plain wrong.
> 
> Yup, in it current version, it is not acceptable. For example, sometimes
> we do want to see all the _LOW events, since _LOW level shows not just the
> level itself, but the activity (i.e. reclaiming process).
> 
> There are a few ways to make both parties happy, though.
> 
> If the app wants to implement the time-based throttling, then just close
> the fd and sleep for needed amount of time (or do not read from the
> eventfd -- kernel then will just increment the eventfd counter, so there
> won't be context switches at the least).

That makes sense to me.

> Doing the time-based throttling in the kernel won't buy us much, I
> believe.

Yes.
 
> Or, if you still want the "one-shot"/"edge-triggered" events (which might
> make perfect sense for medium and critical levels), then I'd propose to
> add some additional flag when you register the event, so that the old
> behaviour would be still available for those who need it. This approach I
> think is the best one.

Hmm, how would one-shot even differ from a single open, register, read
and close?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
