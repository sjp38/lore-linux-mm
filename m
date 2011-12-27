Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 7BC6B6B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 21:50:26 -0500 (EST)
Message-ID: <1324954208.4634.2.camel@hakkenden.homenet>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
From: "Nikolay S." <nowhere@hakkenden.ath.cx>
Date: Tue, 27 Dec 2011 06:50:08 +0400
In-Reply-To: <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	 <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard>
	 <1324630880.562.6.camel@rybalov.eng.ttk.net>
	 <20111223102027.GB12731@dastard>
	 <1324638242.562.15.camel@rybalov.eng.ttk.net>
	 <20111223204503.GC12731@dastard>
	 <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

=D0=92 =D0=92=D1=82., 27/12/2011 =D0=B2 11:15 +0900, KAMEZAWA Hiroyuki =D0=
=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Sat, 24 Dec 2011 07:45:03 +1100
> Dave Chinner <david@fromorbit.com> wrote:
>=20
> > On Fri, Dec 23, 2011 at 03:04:02PM +0400, nowhere wrote:
> > > =D0=92 =D0=9F=D1=82., 23/12/2011 =D0=B2 21:20 +1100, Dave Chinner =D0=
=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > On Fri, Dec 23, 2011 at 01:01:20PM +0400, nowhere wrote:
> > > > > =D0=92 =D0=A7=D1=82., 22/12/2011 =D0=B2 09:55 +1100, Dave Chinner=
 =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > > > > > On Wed, Dec 21, 2011 at 10:52:49AM +0100, Michal Hocko wrote:
>=20
> > > Here is the report of trace-cmd while dd'ing
> > > https://80.237.6.56/report-dd.xz
> >=20
> > Ok, it's not a shrink_slab() problem - it's just being called ~100uS
> > by kswapd. The pattern is:
> >=20
> > 	- reclaim 94 (batches of 32,32,30) pages from iinactive list
> > 	  of zone 1, node 0, prio 12
> > 	- call shrink_slab
> > 		- scan all caches
> > 		- all shrinkers return 0 saying nothing to shrink
> > 	- 40us gap
> > 	- reclaim 10-30 pages from inactive list of zone 2, node 0, prio 12
> > 	- call shrink_slab
> > 		- scan all caches
> > 		- all shrinkers return 0 saying nothing to shrink
> > 	- 40us gap
> > 	- isolate 9 pages from LRU zone ?, node ?, none isolated, none freed
> > 	- isolate 22 pages from LRU zone ?, node ?, none isolated, none freed
> > 	- call shrink_slab
> > 		- scan all caches
> > 		- all shrinkers return 0 saying nothing to shrink
> > 	40us gap
> >=20
> > And it just repeats over and over again. After a while, nid=3D0,zone=3D=
1
> > drops out of the traces, so reclaim only comes in batches of 10-30
> > pages from zone 2 between each shrink_slab() call.
> >=20
> > The trace starts at 111209.881s, with 944776 pages on the LRUs. It
> > finishes at 111216.1 with kswapd going to sleep on node 0 with
> > 930067 pages on the LRU. So 7 seconds to free 15,000 pages (call it
> > 2,000 pages/s) which is awfully slow....
> >=20
> > vmscan gurus - time for you to step in now...
> >
> =20
> Can you show /proc/zoneinfo ? I want to know each zone's size.

$ cat /proc/zoneinfo=20
Node 0, zone      DMA
  pages free     3980
        min      64
        low      80
        high     96
        scanned  0
        spanned  4080
        present  3916
    nr_free_pages 3980
    nr_inactive_anon 0
    nr_active_anon 0
    nr_inactive_file 0
    nr_active_file 0
    nr_unevictable 0
    nr_mlock     0
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_kernel_stack 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
    nr_vmscan_immediate_reclaim 0
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     0
    nr_dirtied   0
    nr_written   0
    nr_anon_transparent_hugepages 0
        protection: (0, 3503, 4007, 4007)
  pagesets
    cpu: 0
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
    cpu: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 4
  all_unreclaimable: 1
  start_pfn:         16
  inactive_ratio:    1
Node 0, zone    DMA32
  pages free     19620
        min      14715
        low      18393
        high     22072
        scanned  0
        spanned  1044480
        present  896960
    nr_free_pages 19620
    nr_inactive_anon 43203
    nr_active_anon 206577
    nr_inactive_file 412249
    nr_active_file 126151
    nr_unevictable 7
    nr_mlock     7
    nr_anon_pages 108557
    nr_mapped    6683
    nr_file_pages 540415
    nr_dirty     5
    nr_writeback 0
    nr_slab_reclaimable 58887
    nr_slab_unreclaimable 12145
    nr_page_table_pages 1389
    nr_kernel_stack 100
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 1021
    nr_vmscan_immediate_reclaim 69337
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     1861
    nr_dirtied   1586363
    nr_written   1245872
    nr_anon_transparent_hugepages 272
        protection: (0, 0, 504, 504)
  pagesets
    cpu: 0
              count: 4
              high:  186
              batch: 31
  vm stats threshold: 24
    cpu: 1
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 24
  all_unreclaimable: 0
  start_pfn:         4096
  inactive_ratio:    5
Node 0, zone   Normal
  pages free     2854
        min      2116
        low      2645
        high     3174
        scanned  0
        spanned  131072
        present  129024
    nr_free_pages 2854
    nr_inactive_anon 20682
    nr_active_anon 10262
    nr_inactive_file 47083
    nr_active_file 11292
    nr_unevictable 518
    nr_mlock     518
    nr_anon_pages 22801
    nr_mapped    1798
    nr_file_pages 58853
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 4347
    nr_slab_unreclaimable 5955
    nr_page_table_pages 769
    nr_kernel_stack 128
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 5285
    nr_vmscan_immediate_reclaim 51475
    nr_writeback_temp 0
    nr_isolated_anon 0
    nr_isolated_file 0
    nr_shmem     28
    nr_dirtied   251597
    nr_written   191561
    nr_anon_transparent_hugepages 16
        protection: (0, 0, 0, 0)
  pagesets
    cpu: 0
              count: 30
              high:  186
              batch: 31
  vm stats threshold: 12
    cpu: 1
              count: 0
              high:  186
              batch: 31
  vm stats threshold: 12
  all_unreclaimable: 0
  start_pfn:         1048576
  inactive_ratio:

>=20
> Below is my memo.
>=20
> In trace log, priority =3D 11 or 12. Then, I think kswapd can reclaim mem=
ory
> to satisfy "sc.nr_reclaimed >=3D SWAP_CLUSTER_MAX" condition and loops ag=
ain.
>=20
> Seeing balance_pgdat() and trace log, I guess it does
>=20
> 	wake up
>=20
> 	shrink_zone(zone=3D0(DMA?))     =3D> nothing to reclaim.
> 		shrink_slab()
> 	shrink_zone(zone=3D1(DMA32?))   =3D> reclaim 32,32,31 pages=20
> 		shrink_slab()
> 	shrink_zone(zone=3D2(NORMAL?))  =3D> reclaim 13 pages.=20
> 		srhink_slab()
>=20
> 	sleep or retry.
>=20
> Why shrink_slab() need to be called frequently like this ?
>=20
> BTW. I'm sorry if I miss something ...Why only kswapd reclaims memory
> while 'dd' operation ? (no direct relcaim by dd.)
> Is this log record cpu hog after 'dd' ?

report-dd.xz is while_ dd.
report-normal.xz - some time after

> Thanks,
> -Kame
>=20
>=20
>=20
>=20
>=20
>=20
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
