Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57FAB6B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 07:30:49 -0400 (EDT)
Subject: Re: [PATCH 05/18] writeback: per task dirty rate limit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 07 Sep 2011 09:27:50 +0200
In-Reply-To: <20110906232738.GC31945@quack.suse.cz>
References: <20110904015305.367445271@intel.com>
	 <20110904020915.240747479@intel.com> <1315324030.14232.14.camel@twins>
	 <20110906232738.GC31945@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1315380470.11101.1.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 2011-09-07 at 01:27 +0200, Jan Kara wrote:
> On Tue 06-09-11 17:47:10, Peter Zijlstra wrote:
> > On Sun, 2011-09-04 at 09:53 +0800, Wu Fengguang wrote:
> > >  /*
> > > + * After a task dirtied this many pages, balance_dirty_pages_ratelim=
ited_nr()
> > > + * will look to see if it needs to start dirty throttling.
> > > + *
> > > + * If dirty_poll_interval is too low, big NUMA machines will call th=
e expensive
> > > + * global_page_state() too often. So scale it near-sqrt to the safet=
y margin
> > > + * (the number of pages we may dirty without exceeding the dirty lim=
its).
> > > + */
> > > +static unsigned long dirty_poll_interval(unsigned long dirty,
> > > +                                        unsigned long thresh)
> > > +{
> > > +       if (thresh > dirty)
> > > +               return 1UL << (ilog2(thresh - dirty) >> 1);
> > > +
> > > +       return 1;
> > > +}
> >=20
> > Where does that sqrt come from?=20
>   He does 2^{log_2(x)/2} which, if done in real numbers arithmetics, woul=
d
> result in x^{1/2}. Given the integer arithmetics, it might be twice as
> small but still it's some approximation...

Right, and I guess with a cpu that can do the fls its slightly faster
than our int_sqrt().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
