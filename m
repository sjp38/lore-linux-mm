Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 434836B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 01:47:57 -0500 (EST)
Date: Tue, 6 Mar 2012 22:42:52 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [Lsf-pc] [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120307064252.GB2445@localhost>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305202330.GD11238@quack.suse.cz>
 <20120305221843.GH18546@redhat.com>
 <20120305223637.GB5479@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305223637.GB5479@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Andrea Righi <andrea@betterlinux.com>, Suresh Jayaraman <sjayaraman@suse.com>

On Mon, Mar 05, 2012 at 11:36:37PM +0100, Jan Kara wrote:
> On Mon 05-03-12 17:18:43, Vivek Goyal wrote:
> > On Mon, Mar 05, 2012 at 09:23:30PM +0100, Jan Kara wrote:
> > 
> > [..]
> > > Having the limits for dirty rate and other IO separate means I
> > > have to be rather pesimistic in setting the bounds so that combination of
> > > dirty rate + other IO limit doesn't exceed the desired bound but this is
> > > usually unnecessarily harsh...
> > 
> > We had solved this issue in my previous posting.
> > 
> > https://lkml.org/lkml/2011/6/28/243
> > 
> > I was accounting the buffered writes to associated block group in 
> > balance dirty pages and throttling it if group was exceeding upper
> > limit. This had common limit for all kind of writes (direct + buffered +
> > sync etc).
>   Ah, I didn't know that.
> 
> > But it also had its share of issues.
> > 
> > - Control was per device (not global) and was not applicable to NFS.
> > - Will not prevent IO spikes at devices (caused by flusher threads).
> > 
> > Dave Chinner preferred to throttle IO at devices much later.
> > 
> > I personally think that "dirty rate limit" does not solve all problems
> > but has some value and it will be interesting to merge any one
> > implementation and see if it solves a real world problem.
>   It rather works the other way around - you first have to show enough
> users are interested in the particular feature you want to merge and then the
> feature can get merged. Once the feature is merged we are stuck supporting
> it forever so we have to be very cautious in what we merge...

Agreed.

> > It does not block any other idea of buffered write proportional control
> > or even implementing upper limit in blkcg. We could put "dirty rate
> > limit" in memcg and develop rest of the ideas in blkcg, writeback etc.
>   Yes, it doesn't block them but OTOH we should have as few features as
> possible because otherwise it's a configuration and maintenance nightmare
> (both from admin and kernel POV). So we should think twice what set of
> features we choose to satisfy user demand.

Yeah it's a good idea to first figure out the ideal set of user
interfaces that are simple, natural, flexible and extensible. Then
look into the implementations and see how can we provide interfaces
closest to the ideal ones (if not 100% feasible).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
