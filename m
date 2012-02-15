Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 4C06A6B004A
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:35:28 -0500 (EST)
Date: Wed, 15 Feb 2012 02:35:24 +0100
From: Andrea Righi <andrea@betterlinux.com>
Subject: Re: [RFC] [PATCH v5 0/3] fadvise: support POSIX_FADV_NOREUSE
Message-ID: <20120215012957.GA1728@thinkpad>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com>
 <20120214133337.9de7835b.akpm@linux-foundation.org>
 <20120214225922.GA12394@thinkpad>
 <20120214152220.4f621975.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120214152220.4f621975.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?iso-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, Greg Thelen <gthelen@google.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 14, 2012 at 03:22:20PM -0800, Andrew Morton wrote:
> On Tue, 14 Feb 2012 23:59:22 +0100
> Andrea Righi <andrea@betterlinux.com> wrote:
> 
> > On Tue, Feb 14, 2012 at 01:33:37PM -0800, Andrew Morton wrote:
> > > On Sun, 12 Feb 2012 01:21:35 +0100
> > > Andrea Righi <andrea@betterlinux.com> wrote:
> > > 
> > > > The new proposal is to implement POSIX_FADV_NOREUSE as a way to perform a real
> > > > drop-behind policy where applications can mark certain intervals of a file as
> > > > FADV_NOREUSE before accessing the data.
> > > 
> > > I think you and John need to talk to each other, please.  The amount of
> > > duplication here is extraordinary.
> > 
> > Yes, definitely. I'm currently reviewing and testing the John's patch
> > set. I was even considering to apply my patch set on top of the John's
> > patch, or at least propose my tree-based approach to manage the list of
> > the POSIX_FADV_VOLATILE ranges.
> 
> Cool.
> 
> > > 
> > > Both patchsets add fields to the address_space (and hence inode), which
> > > is significant - we should convince ourselves that we're getting really
> > > good returns from a feature which does this.
> > > 
> > > 
> > > 
> > > Regarding the use of fadvise(): I suppose it's a reasonable thing to do
> > > in the long term - if the feature works well, popular data streaming
> > > applications will eventually switch over.  But I do think we should
> > > explore interfaces which don't require modification of userspace source
> > > code.  Because there will always be unconverted applications, and the
> > > feature becomes available immediately.
> > > 
> > > One such interface would be to toss the offending application into a
> > > container which has a modified drop-behind policy.  And here we need to
> > > drag out the crystal ball: what *is* the best way of tuning application
> > > pagecache behaviour?  Will we gravitate towards containerization, or
> > > will we gravitate towards finer-tuned fadvise/sync_page_range/etc
> > > behaviour?  Thus far it has been the latter, and I don't think that has
> > > been a great success.
> > > 
> > > Finally, are the problems which prompted these patchsets already
> > > solved?  What happens if you take the offending streaming application
> > > and toss it into a 16MB memcg?  That *should* avoid perturbing other
> > > things running on that machine.
> > 
> > Moving the streaming application into a 16MB memcg can be dangerous in
> > some cases... the application might start to do "bad" things, like
> > swapping (if the memcg can swap) or just fail due to OOMs.
> 
> Well OK, maybe there are problems with the current implementation.  But
> are they unfixable problems?  Is the right approach to give up on ever
> making containers useful for this application and to instead go off and
> implement a new and separate feature?
> 
> > > And yes, a container-based approach is pretty crude, and one can
> > > envision applications which only want modified reclaim policy for one
> > > particualr file.  But I suspect an application-wide reclaim policy
> > > solves 90% of the problems.
> > 
> > I really like the container-based approach. But for this we need a
> > better file cache control in the memory cgroup; now we have the
> > accounting of file pages, but there's no way to limit them.
> 
> Again, if/whem memcg becomes sufficiently useful for this application
> we're left maintaining the obsolete POSIX_FADVISE_NOREUSE for ever.

Yes, totally agree. For the future a memcg-based solution is probably
the best way to go.

This reminds me to the old per-memcg dirty memory discussion
(http://thread.gmane.org/gmane.linux.kernel.mm/67114), cc'ing Greg.

Maybe the generic feature to provide that could solve both problems is
a better file cache isolation in memcg.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
