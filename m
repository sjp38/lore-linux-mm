Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DD2116B0028
	for <linux-mm@kvack.org>; Tue, 17 May 2011 01:52:07 -0400 (EDT)
Date: Tue, 17 May 2011 13:52:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-ID: <20110517055204.GB24069@localhost>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
 <20110512054631.GI6008@one.firstfloor.org>
 <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
 <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
 <20110514165346.GV6008@one.firstfloor.org>
 <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
 <20110514174333.GW6008@one.firstfloor.org>
 <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
 <20110515152747.GA25905@localhost>
 <BANLkTinv=_38E3Eyu88Ra4-x5vPEq7CDkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTinv=_38E3Eyu88Ra4-x5vPEq7CDkw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Lutomirski <luto@mit.edu>, LKML <linux-kernel@vger.kernel.org>

On Mon, May 16, 2011 at 07:40:42AM +0900, Minchan Kim wrote:
> On Mon, May 16, 2011 at 12:27 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > On Sun, May 15, 2011 at 09:37:58AM +0800, Minchan Kim wrote:
> >> On Sun, May 15, 2011 at 2:43 AM, Andi Kleen <andi@firstfloor.org> wrote:
> >> > Copying back linux-mm.
> >> >
> >> >> Recently, we added following patch.
> >> >> https://lkml.org/lkml/2011/4/26/129
> >> >> If it's a culprit, the patch should solve the problem.
> >> >
> >> > It would be probably better to not do the allocations at all under
> >> > memory pressure. A Even if the RA allocation doesn't go into reclaim
> >>
> >> Fair enough.
> >> I think we can do it easily now.
> >> If page_cache_alloc_readahead(ie, GFP_NORETRY) is fail, we can adjust
> >> RA window size or turn off a while. The point is that we can use the
> >> fail of __do_page_cache_readahead as sign of memory pressure.
> >> Wu, What do you think?
> >
> > No, disabling readahead can hardly help.
> 
> I don't mean we have to disable RA.
> As I said, the point is that we can use __GFP_NORETRY alloc fail as
> _sign_ of memory pressure.

I see.

> >
> > The sequential readahead memory consumption can be estimated by
> >
> > A  A  A  A  A  A  A  A 2 * (number of concurrent read streams) * (readahead window size)
> >
> > And you can double that when there are two level of readaheads.
> >
> > Since there are hardly any concurrent read streams in Andy's case,
> > the readahead memory consumption will be ignorable.
> >
> > Typically readahead thrashing will happen long before excessive
> > GFP_NORETRY failures, so the reasonable solutions are to
> 
> If it is, RA thrashing could be better sign than failure of __GFP_NORETRY.
> If we can do it easily, I don't object it. :)

Yeah, the RA thrashing is much better sign because it not only happens
long before normal __GFP_NORETRY failures, but also offers hint on how
tight memory pressure it is. We can then shrink the readahead window
adaptively to the available page cache memory :)

> >
> > - shrink readahead window on readahead thrashing
> > A (current readahead heuristic can somehow do this, and I have patches
> > A to further improve it)
> 
> Good to hear. :)
> I don't want RA steals high order page in memory pressure.

More often than not it won't be RA's fault :)  When you see RA page
allocations stealing high order pages, it may actually be reflecting
some more general order-0 steal order-N problem..

> My patch and shrinking RA window helps this case.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
