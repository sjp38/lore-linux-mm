Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7F84F6B0087
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:32:16 -0500 (EST)
Subject: Re: [PATCH 06/13] writeback: bdi write bandwidth estimation
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20101124142142.GA14123@localhost>
References: <20101117042720.033773013@intel.com>
	 <20101117042850.002299964@intel.com> <1290596732.2072.450.camel@laptop>
	 <20101124121046.GA8333@localhost> <1290603047.2072.465.camel@laptop>
	 <20101124131437.GE10413@localhost> <20101124132012.GA12117@localhost>
	 <1290606129.2072.467.camel@laptop> <20101124134641.GA12987@localhost>
	 <1290607953.2072.472.camel@laptop>  <20101124142142.GA14123@localhost>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 24 Nov 2010 15:31:57 +0100
Message-ID: <1290609117.2072.474.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-24 at 22:21 +0800, Wu Fengguang wrote:
>=20
> Hmm, but why not avoid locking at all?  With per-cpu bandwidth vars,
> each CPU will see slightly different bandwidth, but that should be
> close enough and not a big problem.

I don't think so, on a large enough machine some cpus might hardly ever
use a particular BDI and hence get very stale data.

Also, it increases the memory footprint of the whole solution.

> > +void bdi_update_write_bandwidth(struct backing_dev_info *bdi)
> > +{
> > +     unsigned long time_now, write_now;
> > +     long time_delta, write_delta;
> > +     long bw;
> > +
> > +     if (!spin_try_lock(&bdi->bw_lock))
> > +             return;
>=20
> spin_try_lock is good, however is still global state and risks
> cacheline bouncing..=20

If there are many concurrent writers to the BDI I don't think this is
going to be the top sore spot, once it is we can think of something
else.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
