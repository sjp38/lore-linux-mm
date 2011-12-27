Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 763BA6B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 01:07:14 -0500 (EST)
Message-ID: <1324966011.8894.1.camel@rybalov.eng.ttk.net>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: nowhere <nowhere@hakkenden.ath.cx>
Date: Tue, 27 Dec 2011 10:06:51 +0400
In-Reply-To: <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
	 <1324630880.562.6.camel@rybalov.eng.ttk.net>
	 <20111223102027.GB12731@dastard>
	 <1324638242.562.15.camel@rybalov.eng.ttk.net>
	 <20111223204503.GC12731@dastard>
	 <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
	 <1324954208.4634.2.camel@hakkenden.homenet>
	 <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=92=D1=82., 27/12/2011 =D0=B2 13:44 +0900, KAMEZAWA Hiroyuki =D0=
=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, 27 Dec 2011 06:50:08 +0400
> "Nikolay S." <nowhere@hakkenden.ath.cx> wrote:
>=20
> > =D0=92 =D0=92=D1=82., 27/12/2011 =D0=B2 11:15 +0900, KAMEZAWA Hiroyuki =
=D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > On Sat, 24 Dec 2011 07:45:03 +1100
> > > Dave Chinner <david@fromorbit.com> wrote:
> > >=20
> > > > On Fri, Dec 23, 2011 at 03:04:02PM +0400, nowhere wrote:
> > > > > =D0=92 =D0=9F=D1=82., 23/12/2011 =D0=B2 21:20 +1100, Dave Chinner=
 =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > > > On Fri, Dec 23, 2011 at 01:01:20PM +0400, nowhere wrote:
> > > > > > > =D0=92 =D0=A7=D1=82., 22/12/2011 =D0=B2 09:55 +1100, Dave Chi=
nner =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > > > > > On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrot=
e:
> > >=20
> > > > > Here is the report of trace-cmd while dd'ing
> > > > > https://80.237.6.56/report-dd.xz
> > > >=20
> > > > Ok, it's not a shrink_slab() problem - it's just being called ~100u=
S
> > > > by kswapd. The pattern is:
> > > >=20
> > > > 	- reclaim 94 (batches of 32,32,30) pages from iinactive list
> > > > 	  of zone 1, node 0, prio 12
> > > > 	- call shrink_slab
> > > > 		- scan all caches
> > > > 		- all shrinkers return 0 saying nothing to shrink
> > > > 	- 40us gap
> > > > 	- reclaim 10-30 pages from inactive list of zone 2, node 0, prio 1=
2
> > > > 	- call shrink_slab
> > > > 		- scan all caches
> > > > 		- all shrinkers return 0 saying nothing to shrink
> > > > 	- 40us gap
> > > > 	- isolate 9 pages from LRU zone ?, node ?, none isolated, none fre=
ed
> > > > 	- isolate 22 pages from LRU zone ?, node ?, none isolated, none fr=
eed
> > > > 	- call shrink_slab
> > > > 		- scan all caches
> > > > 		- all shrinkers return 0 saying nothing to shrink
> > > > 	40us gap
> > > >=20
> > > > And it just repeats over and over again. After a while, nid=3D0,zon=
e=3D1
> > > > drops out of the traces, so reclaim only comes in batches of 10-30
> > > > pages from zone 2 between each shrink_slab() call.
> > > >=20
> > > > The trace starts at 111209.881s, with 944776 pages on the LRUs. It
> > > > finishes at 111216.1 with kswapd going to sleep on node 0 with
> > > > 930067 pages on the LRU. So 7 seconds to free 15,000 pages (call it
> > > > 2,000 pages/s) which is awfully slow....
> > > >=20
> > > > vmscan gurus - time for you to step in now...
> > > >
> > > =20
> > > Can you show /proc/zoneinfo ? I want to know each zone's size.
> >=20
>=20
> Thanks,=20
> Qeustion:
>  1. does this system has no swap ?

It has. 4G

>  2. What version of kernel which you didn't see the kswapd issue ?

Hmm... 3.1 and below, I presume

>  3. Is this real host ? or virtualized ?

100% real

>=20
> > $ cat /proc/zoneinfo=20
> ...
> Node 0, zone    DMA32
>   pages free     19620
>         min      14715
>         low      18393
>         high     22072
>         scanned  0
>         spanned  1044480
>         present  896960
>     nr_free_pages 19620
>     nr_inactive_anon 43203
>     nr_active_anon 206577
>     nr_inactive_file 412249
>     nr_active_file 126151
>=20
> Then, DMA32(zone=3D1) files are enough large (> 32 << 12)
> Hmm. assuming all frees are used for file(of dd)
>=20
>=20
> (412249 + 126151 + 19620) >> 12 =3D 136
>=20
> So, 32, 32, 30 scan seems to work as desgined.
>=20
> > Node 0, zone   Normal
> >   pages free     2854
> >         min      2116
> >         low      2645
> >         high     3174
> >         scanned  0
> >         spanned  131072
> >         present  129024
> >     nr_free_pages 2854
> >     nr_inactive_anon 20682
> >     nr_active_anon 10262
> >     nr_inactive_file 47083
> >     nr_active_file 11292
>=20
> Hmm, NORMAL is much smaller than DMA32. (only 500MB.)
>=20
> Then, at priority=3D12,
>=20
>   13 << 12 =3D 53248
>=20
> 13 pages per a scan seems to work as designed.
> To me,  it seems kswapd does usual work...reclaim small memory until free
> gets enough. And it seems 'dd' allocates its memory from ZONE_DMA32 becau=
se
> of gfp_t fallbacks.
>=20
>=20
> Memo.
>=20
> 1. why shrink_slab() should be called per zone, which is not zone aware.
>    Isn't it enough to call it per priority ?
>=20
> 2. what spinlock contention that perf showed ?
>    And if shrink_slab() doesn't consume cpu as trace shows, why perf=20
>    says shrink_slab() is heavy..
>=20
> 3. because 8/9 of memory is in DMA32, calling shrink_slab() frequently
>    at scanning NORMAL seems to be time wasting.
> =20
>=20
> Thanks,
> -Kame
>=20
>=20
>=20
>=20
>=20


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
