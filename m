Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C360C6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 22:37:48 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id A59F13EE0B5
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:37:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D10A45DE93
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:37:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6983145DE78
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:37:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5DB65E08001
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:37:45 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 121F51DB8037
	for <linux-mm@kvack.org>; Thu, 19 May 2011 11:37:45 +0900 (JST)
Date: Thu, 19 May 2011 11:30:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking
 vmlinux)
Message-Id: <20110519113059.06d0e0d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com>
	<20110517060001.GC24069@localhost>
	<BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com>
	<BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
	<BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Wed, 18 May 2011 22:15:53 -0400
Andrew Lutomirski <luto@mit.edu> wrote:

> On Wed, May 18, 2011 at 1:17 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Wed, May 18, 2011 at 4:22 AM, Andrew Lutomirski <luto@mit.edu> wrote:

> > Andrew, Could you test this patch with !pgdat_balanced patch?
> > I think we shouldn't see OOM message if we have lots of free swap space.
> >
> > == CUT_HERE ==
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index f73b865..cc23f04 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1341,10 +1341,6 @@ static inline bool
> > should_reclaim_stall(unsigned long nr_taken,
> > A  A  A  A if (current_is_kswapd())
> > A  A  A  A  A  A  A  A return false;
> >
> > - A  A  A  /* Only stall on lumpy reclaim */
> > - A  A  A  if (sc->reclaim_mode & RECLAIM_MODE_SINGLE)
> > - A  A  A  A  A  A  A  return false;
> > -
> > A  A  A  A /* If we have relaimed everything on the isolated list, no stall */
> > A  A  A  A if (nr_freed == nr_taken)
> > A  A  A  A  A  A  A  A return false;
> >
> >
> >
> > Then, if you don't see any unnecessary OOM but still see the hangup,
> > could you apply this patch based on previous?
> 
> With this patch, I started GNOME and Firefox, turned on swap, and ran
> test_mempressure.sh 1500 1400 1.  Instant panic (or OOPS and hang or
> something -- didn't get the top part).  Picture attached -- it looks
> like memcg might be involved.  I'm running F15, so it might even be
> doing something.
> 

Hmm, what kernel version do you use ?
I think memcg is not guilty because RIP is shrink_page_list().
But ok, I'll dig this. Could you give us your .config ?

Thanks,
-Kame


> I won't be able to get netconsole dumps until next week because I'm
> out of town and only have this one computer here.
> 
> I haven't tried the other patch.
> 
> Also, the !pgdat_balanced fix plus the if (need_resched()) return
> false patch just hung once on 2.6.37-rc9.  I don't know what triggered
> it.  Maybe yum.
> 
> --Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
