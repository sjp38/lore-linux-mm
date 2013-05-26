Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 85D896B00CB
	for <linux-mm@kvack.org>; Sun, 26 May 2013 10:55:53 -0400 (EDT)
Received: by mail-ob0-f176.google.com with SMTP id wp18so7140400obc.35
        for <linux-mm@kvack.org>; Sun, 26 May 2013 07:55:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130526135237.GA2333@x61.redhat.com>
References: <cover.1369529143.git.aquini@redhat.com> <537407790857e8a5d4db5fb294a909a61be29687.1369529143.git.aquini@redhat.com>
 <CAHGf_=qU5nBeya=God5AyG2szvtJJCDd4VOt0TJZBgiEX27Njw@mail.gmail.com> <20130526135237.GA2333@x61.redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 26 May 2013 10:55:32 -0400
Message-ID: <CAHGf_=rpO=5HmZzTYsdPwCkA_rUaBEFG1dtThPMTQSmR1=7-fg@mail.gmail.com>
Subject: Re: [PATCH 01/02] swap: discard while swapping only if SWAP_FLAG_DISCARD_PAGES
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, shli@kernel.org, Karel Zak <kzak@redhat.com>, Jeff Moyer <jmoyer@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Mel Gorman <mgorman@suse.de>

On Sun, May 26, 2013 at 9:52 AM, Rafael Aquini <aquini@redhat.com> wrote:
> On Sun, May 26, 2013 at 07:44:56AM -0400, KOSAKI Motohiro wrote:
>> > +                       /*
>> > +                        * By flagging sys_swapon, a sysadmin can tell us to
>> > +                        * either do sinle-time area discards only, or to just
>> > +                        * perform discards for released swap page-clusters.
>> > +                        * Now it's time to adjust the p->flags accordingly.
>> > +                        */
>> > +                       if (swap_flags & SWAP_FLAG_DISCARD_ONCE)
>> > +                               p->flags &= ~SWP_PAGE_DISCARD;
>> > +                       else if (swap_flags & SWAP_FLAG_DISCARD_PAGES)
>> > +                               p->flags &= ~SWP_AREA_DISCARD;
>>
>> When using old swapon(8), this code turn off both flags, right
>
 > As the flag that enables swap discards SWAP_FLAG_DISCARD remains meaning the
> same it meant before, when using old swapon(8) (SWP_PAGE_DISCARD|SWP_AREA_DISCARD)

But old swapon(8) don't use neigher SWAP_FLAG_DISCARD_ONCE nor
SWAP_FLAG_DISCARD_PAGES.  It uses only SWAP_FLAG_DISCARD. So, this
condition disables both SWP_PAGE_DISCARD and SWP_AREA_DISCARD.

And you changed that SWP_DISCARDABLE is not checked in IO path  at all.

>-               if (si->flags & SWP_DISCARDABLE) {
>+               if (si->flags & SWP_PAGE_DISCARD) {

I suggest new swapon(8) don't pass SWP_DISCARDABLE and kernel handle
SWP_DISCARDABLE as (SWAP_FLAG_DISCARD_ONCE | SWAP_FLAG_DISCARD_PAGES).

Optionally, warn SWP_DISCARDABLE is a good idea.


> will remain flagged when discard is enabled, so we keep doing discards the same way
> we did before (at swapon, and for every released page-cluster).
> The flags are removed orthogonally only when the new swapon(8) selects one of the
> particular discard policy available by using either SWAP_FLAG_DISCARD_ONCE,
> or SWAP_FLAG_DISCARD_PAGES flags.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
