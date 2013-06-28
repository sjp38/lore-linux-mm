Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id EC4F26B0033
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 14:26:29 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:25:58 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628142558.5da3d030@redhat.com>
In-Reply-To: <20130628170917.GA12610@teo>
References: <20130626231712.4a7392a7@redhat.com>
	<20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
	<20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
	<20130628050712.GA10097@teo>
	<20130628100027.31504abe@redhat.com>
	<20130628165722.GA12271@teo>
	<20130628170917.GA12610@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Fri, 28 Jun 2013 10:09:17 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Fri, Jun 28, 2013 at 09:57:22AM -0700, Anton Vorontsov wrote:
> > On Fri, Jun 28, 2013 at 10:00:27AM -0400, Luiz Capitulino wrote:
> > > On Thu, 27 Jun 2013 22:07:12 -0700
> > > Anton Vorontsov <anton@enomsg.org> wrote:
> > > 
> > > > On Thu, Jun 27, 2013 at 09:34:11PM -0700, Anton Vorontsov wrote:
> > > > > ... we can add the strict mode and deprecate the
> > > > > "filtering" -- basically we'll implement the idea of requiring that
> > > > > userspace registers a separate fd for each level.
> > > > 
> > > > Btw, assuming that more levels can be added, there will be a problem:
> > > > imagine that an app hooked up onto low, med, crit levels in "strict"
> > > > mode... then once we add a new level, the app will start missing the new
> > > > level events.
> > > 
> > > That's how it's expected to work, because on strict mode you're notified
> > > for the level you registered for. So apps registering for critical, will
> > > still be notified on critical just like before.
> > 
> > Suppose you introduce a new level, and the system hits this level. Before,
> > the app would receive at least some notification for the given memory load
> > (i.e. one of the old levels), with the new level introduced in the kernel,
> > the app will receive no events at all.

That's not true. If an app registered for critical it will still get
critical notification when the system is at the critical level. Just as it
always did. No new events will change this.

With today's semantics though, new events will change when current events
are triggered. So each new extension will cause applications to have
different behaviors, in different kernel versions. This looks quite
undesirable to me.

> > This makes a serious behavioural
> > change in the app (read: it'll break it).

How? Strict mode semantics is simple: you get what you registered for.
No matter the kernel version, no matter how many events we add on top
of existing ones. How can this brake applications?

> Btw, why exactly you need the strict mode?

I'm implementing automatic guest-resize for KVM guests. What I'd like to
do is to inflate the balloon by different values depending on the
host pressure. Say, 1MB on low; 16MB on medium and 128MB on critical.

The actual values are meaningless btw, as this is going to be set by
the user. So, saying that 1MB on low is too little to be concerned about
is not an valid argument, as the user can set this to 1GB.

> Why 'medium' won't work for the
> load-balancing?

I need precision. If the system is at 'medium' level, then I'll do
medium stuff. If it gets into critical, then I'll do critical stuff.

I don't want to do critical stuff on all levels, or critical on
medium. This is really messy. Just give me what I asked for, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
