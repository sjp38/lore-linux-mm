Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 12D406B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 00:23:03 -0500 (EST)
Date: Sun, 16 Dec 2012 05:23:02 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216052302.GA6680@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121215223448.08272fd5@pyramind.ukuu.org.uk>
 <20121216002549.GA19402@dcvr.yhbt.net>
 <20121216030302.GI9806@dastard>
 <20121216033549.GA30446@dcvr.yhbt.net>
 <20121216041549.GK9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216041549.GK9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner <david@fromorbit.com> wrote:
> On Sun, Dec 16, 2012 at 03:35:49AM +0000, Eric Wong wrote:
> > Dave Chinner <david@fromorbit.com> wrote:
> > > On Sun, Dec 16, 2012 at 12:25:49AM +0000, Eric Wong wrote:
> > > > Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > > > > On Sat, 15 Dec 2012 00:54:48 +0000
> > > > > Eric Wong <normalperson@yhbt.net> wrote:
> > > > > 
> > > > > > Applications streaming large files may want to reduce disk spinups and
> > > > > > I/O latency by performing large amounts of readahead up front
> 
> > This could also be a use case for an audio/video player.
> 
> Sure, but this can all be handled by a userspace application. If you
> want to avoid/batch IO to enable longer spindown times, then you
> have to load the file into RAM somewhere, and you don't need special
> kernel support for that.

>From userspace, I don't know when/if I'm caching too much and possibly
getting the userspace cache itself swapped out.

> > So no, there's no difference that matters between the approaches.
> > But I think doing this in the kernel is easier for userspace users.
> 
> The kernel provides mechanisms for applications to use. You have not
> mentioned anything new that requires a new kernel mechanism to
> acheive - you just need to have the knowledge to put the pieces
> together properly.  People have been solving this same problem for
> the last 20 years without needing to tweak fadvise(). Or even having
> an fadvise() syscall...

fadvise() is fairly new, and AFAIK few apps use it.  Perhaps if it
were improved, more people would use it and not have to reinvent
the wheel.

> Nothing about low latency IO or streaming IO is simple or easy, and
> changing how readahead works doesn't change that fact. All it does
> is change the behaviour of every other application that uses
> fadvise() to minimise IO latency....

I don't want to introduce regressions, either.

Perhaps if part of the FADV_WILLNEED read-ahead were handled
synchronously (maybe 2M?) and humongous large readaheads (like mine)
went to the background, that would be a good trade off?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
