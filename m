Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 627DB6B00CE
	for <linux-mm@kvack.org>; Sun, 26 May 2013 11:30:32 -0400 (EDT)
Date: Sun, 26 May 2013 12:30:17 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 01/02] swap: discard while swapping only if
 SWAP_FLAG_DISCARD_PAGES
Message-ID: <20130526153016.GB2333@x61.redhat.com>
References: <cover.1369529143.git.aquini@redhat.com>
 <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
 <CAHGf_=qU5nBeya=God5AyG2szvtJJCDd4VOt0TJZBgiEX27Njw@mail.gmail.com>
 <20130526135237.GA2333@x61.redhat.com>
 <CAHGf_=rpO=5HmZzTYsdPwCkA_rUaBEFG1dtThPMTQSmR1=7-fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHGf_=rpO=5HmZzTYsdPwCkA_rUaBEFG1dtThPMTQSmR1=7-fg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, shli@kernel.org, Karel Zak <kzak@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Mel Gorman <mgorman@suse.de>

On Sun, May 26, 2013 at 10:55:32AM -0400, KOSAKI Motohiro wrote:
> On Sun, May 26, 2013 at 9:52 AM, Rafael Aquini <aquini@redhat.com> wrote:
> > On Sun, May 26, 2013 at 07:44:56AM -0400, KOSAKI Motohiro wrote:
> >> > +                       /*
> >> > +                        * By flagging sys_swapon, a sysadmin can tell us to
> >> > +                        * either do sinle-time area discards only, or to just
> >> > +                        * perform discards for released swap page-clusters.
> >> > +                        * Now it's time to adjust the p->flags accordingly.
> >> > +                        */
> >> > +                       if (swap_flags & SWAP_FLAG_DISCARD_ONCE)
> >> > +                               p->flags &= ~SWP_PAGE_DISCARD;
> >> > +                       else if (swap_flags & SWAP_FLAG_DISCARD_PAGES)
> >> > +                               p->flags &= ~SWP_AREA_DISCARD;
> >>
> >> When using old swapon(8), this code turn off both flags, right
> >
>  > As the flag that enables swap discards SWAP_FLAG_DISCARD remains meaning the
> > same it meant before, when using old swapon(8) (SWP_PAGE_DISCARD|SWP_AREA_DISCARD)
> 
> But old swapon(8) don't use neigher SWAP_FLAG_DISCARD_ONCE nor
> SWAP_FLAG_DISCARD_PAGES.  It uses only SWAP_FLAG_DISCARD. So, this
> condition disables both SWP_PAGE_DISCARD and SWP_AREA_DISCARD.
>

This condition _only_ disables one of the new flags orthogonally if swapon(8)
flags a policy to sys_swapon. As old swapon(8) can only flag SWAP_FLAG_DISCARD,
the original behavior is kept. Nothing will change when one is using an old
swapon(8) with this changeset. 

 
> And you changed that SWP_DISCARDABLE is not checked in IO path  at all.
> 
> >-               if (si->flags & SWP_DISCARDABLE) {
> >+               if (si->flags & SWP_PAGE_DISCARD) {
> 

And this is exactly what this change is about -- only enabling that particular
I/O path if we've been told to discard swap page-clusters. Notice that having
SWP_PAGE_DISCARD flagged already implies SWP_DISCARDABLE.


> I suggest new swapon(8) don't pass SWP_DISCARDABLE and kernel handle
> SWP_DISCARDABLE as (SWAP_FLAG_DISCARD_ONCE | SWAP_FLAG_DISCARD_PAGES).

As the old swapon(8) case can only pass SWAP_FLAG_DISCARD along, this change
would nullify the backwards compatibility, wouldn't it?



> 
> Optionally, warn SWP_DISCARDABLE is a good idea.
> 
> 
> > will remain flagged when discard is enabled, so we keep doing discards the same way
> > we did before (at swapon, and for every released page-cluster).
> > The flags are removed orthogonally only when the new swapon(8) selects one of the
> > particular discard policy available by using either SWAP_FLAG_DISCARD_ONCE,
> > or SWAP_FLAG_DISCARD_PAGES flags.
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
