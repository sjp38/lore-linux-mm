Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C50EF8D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 13:00:03 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6b37b0d0-5ea1-4c4e-8b93-1362cb5c77d2@default>
Date: Wed, 30 Mar 2011 09:59:32 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Lsf] [LSF][MM] page allocation & direct reclaim latency
References: <1301373398.2590.20.camel@mulgrave.site>
 <4D91FC2D.4090602@redhat.com> <20110329190520.GJ12265@random.random>
 <BANLkTikDwfQaSGtrKOSvgA9oaRC1Lbx3cw@mail.gmail.com
 20110330161716.GA3876@csn.ul.ie>
In-Reply-To: <20110330161716.GA3876@csn.ul.ie>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>

> 1. LRU ordering - are we aging pages properly or recycling through the
>    list too aggressively? The high_wmark*8 change made recently was
>    partially about list rotations and the associated cost so it might
>    be worth listing out whatever issues people are currently aware of.

Here's one: zcache (and tmem RAMster and SSmem) is essentially a level2
cache for clean page cache pages that have been reclaimed.  (Or
more precisely, the pageFRAME has been reclaimed, but the contents
has been squirreled away in zcache.)

Just like the active/inactive lists, ideally, you'd like to ensure
zcache gets filled with pages that have some probability of being used
in the future, not pages you KNOW won't be used in the future but
have left on the inactive list to rot until they are reclaimed.

There's also a sizing issue... under memory pressure, pages in
active/inactive have different advantages/disadvantages vs
pages in zcache/etc... What tuning knobs exist already?

I hacked a (non-upstreamable) patch to only "put" clean pages
that had been previously in active, to play with this a bit but
didn't pursue it.

Anyway, would like to include this in the above discussion.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
