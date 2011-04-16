Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7F805900086
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 04:38:55 -0400 (EDT)
Subject: Re: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up
 time
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110415221314.GE5432@quack.suse.cz>
References: <20110413085937.981293444@intel.com>
	 <20110413090415.763161169@intel.com> <20110413220444.GF4648@quack.suse.cz>
	 <20110413233122.GA6097@localhost> <20110413235211.GN31057@dastard>
	 <20110414002301.GA9826@localhost> <20110414151424.GA367@localhost>
	 <20110414181609.GH5054@quack.suse.cz> <20110415034300.GA23430@localhost>
	 <20110415143711.GA17181@localhost>  <20110415221314.GE5432@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Sat, 16 Apr 2011 10:33:29 +0200
Message-ID: <1302942809.2388.254.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Richard Kennedy <richard@rsk.demon.co.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Sat, 2011-04-16 at 00:13 +0200, Jan Kara wrote:
>=20
> So what is a takeaway from this for me is that scaling the period
> with the dirty limit is not the right thing. If you'd have 4-times more
> memory, your choice of "dirty limit" as the period would be as bad as
> current 4*"dirty limit". What would seem like a better choice of period
> to me would be to have the period in an order of a few seconds worth of
> writeback. That would allow the bdi limit to scale up reasonably fast whe=
n
> new bdi starts to be used and still not make it fluctuate that much
> (hopefully).

No best would be to scale the period with the writeout bandwidth, but
lacking that the dirty limit had to do. Since we're counting pages, and
bandwidth is pages/second we'll end up with a time measure, exactly the
thing you wanted.

> Looking at math in lib/proportions.c, nothing really fundamental requires
> that each period has the same length. So it shouldn't be hard to actually
> create proportions calculator that would have timer triggered periods -
> simply whenever the timer fires, we would declare a new period. The only
> things which would be broken by this are (t represents global counter of
> events):
> a) counting of periods as t/period_len - we would have to maintain global
> period counter but that's trivial
> b) trick that we don't do t=3Dt/2 for each new period but rather use
> period_len/2+(t % (period_len/2)) when calculating fractions - again we
> would have to bite the bullet and divide the global counter when we decla=
re
> new period but again it's not a big deal in our case.
>=20
> Peter what do you think about this? Do you (or anyone else) think it make=
s
> sense?=20

But if you don't have a fixed sized period, then how do you catch up on
fractions that haven't been updated for several periods? You cannot go
remember all the individual period lengths.

The whole trick to the proportion stuff is that its all O(1) regardless
of the number of contestants. There isn't a single loop that iterates
over all BDIs or tasks to update their cycle, that wouldn't have scaled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
