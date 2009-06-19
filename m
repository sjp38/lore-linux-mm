Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 29CBA6B004D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 23:16:55 -0400 (EDT)
Date: Fri, 19 Jun 2009 11:17:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090619031721.GA7894@localhost>
References: <20090609190128.GA1785@cmpxchg.org> <20090611143122.108468f1.kamezawa.hiroyu@jp.fujitsu.com> <20090617224149.GA16104@cmpxchg.org> <20090618092947.GA846@localhost> <20090618130934.GA3070@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline
In-Reply-To: <20090618130934.GA3070@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.org.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 18, 2009 at 09:09:34PM +0800, Johannes Weiner wrote:
> On Thu, Jun 18, 2009 at 05:29:47PM +0800, Wu Fengguang wrote:
> > Johannes,
> > 
> > On Thu, Jun 18, 2009 at 06:41:49AM +0800, Johannes Weiner wrote:
> > > On Thu, Jun 11, 2009 at 02:31:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > > > On Tue, 9 Jun 2009 21:01:28 +0200
> > > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > > [resend with lists cc'd, sorry]
> > > > > 
> > > > > +static int swap_readahead_ptes(struct mm_struct *mm,
> > 
> > I suspect the previous unfavorable results are due to comparing things
> > with/without the drm vmalloc patch. So I spent one day redo the whole
> > comparisons. The swap readahead patch shows neither big improvements
> > nor big degradations this time.
> 
> Thanks again!  Nice.  So according to this, vswapra doesn't increase
> other IO latency (much) but boosts ongoing swap loads (quite some) (as
> qsbench showed).  Is that a result or what! :)
> 
> I will see how the tests described in the other mail work out.

And here are the /proc/vmstat contents after each test run :)

The pswpin number goes down radically in case (c) which seems
illogical.

     pgpgin 8898235              pgpgin 4828771              pgpgin 1807731                           
     pgpgout 1806868             pgpgout 1463644             pgpgout 1382244                          
==>  pswpin 2222503              pswpin 1205137              pswpin 449877                            
     pswpout 451716              pswpout 365910              pswpout 345560                           
     pgalloc_dma 39883           pgalloc_dma 24343           pgalloc_dma 3547                         
     pgalloc_dma32 11918819      pgalloc_dma32 6810775       pgalloc_dma32 6387602                    
     pgalloc_normal 0            pgalloc_normal 0            pgalloc_normal 0
     pgalloc_movable 0           pgalloc_movable 0           pgalloc_movable 0
     pgfree 11961651             pgfree 6837658              pgfree 6396229                           
     pgactivate 5771012          pgactivate 2999101          pgactivate 2341219                       
     pgdeactivate 5909300        pgdeactivate 3140474        pgdeactivate 2481319                     
     pgfault 4536082             pgfault 3468555             pgfault 3589046                          
==>  pgmajfault 926383           pgmajfault 506265           pgmajfault 520010                        

Thanks,
Fengguang

> > Base kernel is 2.6.30-rc8-mm1 with drm vmalloc patch.
> > 
> > a) base kernel
> > b) base kernel + VM_EXEC protection
> > c) base kernel + VM_EXEC protection + swap readahead
> > 
> >      (a)         (b)         (c)
> >     0.02        0.02        0.01    N xeyes
> >     0.78        0.92        0.77    N firefox
> >     2.03        2.20        1.97    N nautilus
> >     3.27        3.35        3.39    N nautilus --browser
> >     5.10        5.28        4.99    N gthumb
> >     6.74        7.06        6.64    N gedit
> >     8.70        8.82        8.47    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
> >    11.05       10.95       10.94    N
> >    13.03       12.72       12.79    N xterm
> >    15.46       15.09       15.10    N mlterm
> >    18.05       17.31       17.51    N gnome-terminal
> >    20.59       19.90       19.98    N urxvt
> >    23.45       22.82       22.67    N
> >    25.74       25.16       24.96    N gnome-system-monitor
> >    28.87       27.53       27.89    N gnome-help
> >    32.37       31.17       31.89    N gnome-dictionary
> >    36.60       35.18       35.16    N
> >    39.76       38.04       37.64    N /usr/games/sol
> >    43.05       42.17       40.33    N /usr/games/gnometris
> >    47.70       47.08       43.48    N /usr/games/gnect
> >    51.64       50.46       47.24    N /usr/games/gtali
> >    56.26       54.58       50.83    N /usr/games/iagno
> >    60.36       58.01       55.15    N /usr/games/gnotravex
> >    65.79       62.92       59.28    N /usr/games/mahjongg
> >    71.59       67.36       65.95    N /usr/games/gnome-sudoku
> >    78.57       72.32       72.60    N /usr/games/glines
> >    84.25       80.03       77.42    N /usr/games/glchess
> >    90.65       88.11       83.66    N /usr/games/gnomine
> >    97.75       95.13       89.38    N /usr/games/gnotski
> >   102.99      101.59       95.05    N /usr/games/gnibbles
> >   110.68      112.05      109.40    N /usr/games/gnobots2
> >   117.23      121.58      120.05    N /usr/games/blackjack
> >   125.15      133.59      130.91    N /usr/games/same-gnome
> >   134.05      151.99      148.91    N
> >   142.57      162.67      165.00    N /usr/bin/gnome-window-properties
> >   156.29      174.54      183.84    N /usr/bin/gnome-default-applications-properties
> >   168.37      190.38      200.99    N /usr/bin/gnome-at-properties
> >   184.80      209.41      230.82    N /usr/bin/gnome-typing-monitor
> >   202.05      226.52      250.02    N /usr/bin/gnome-at-visual
> >   217.60      243.76      272.91    N /usr/bin/gnome-sound-properties
> >   239.78      266.47      308.74    N /usr/bin/gnome-at-mobility
> >   255.23      285.42      338.51    N /usr/bin/gnome-keybinding-properties
> >   276.85      314.84      374.64    N /usr/bin/gnome-about-me
> >   308.51      355.95      419.78    N /usr/bin/gnome-display-properties
> >   341.27      401.22      463.55    N /usr/bin/gnome-network-preferences
> >   393.42      451.27      517.24    N /usr/bin/gnome-mouse-properties
> >   438.48      510.54      574.64    N /usr/bin/gnome-appearance-properties
> >   616.09      671.44      760.49    N /usr/bin/gnome-control-center
> >   879.69      879.45      918.87    N /usr/bin/gnome-keyboard-properties
> >  1159.47     1076.29     1071.65    N
> >  1701.82     1240.47     1280.77    N : oocalc
> >  1921.14     1446.95     1451.82    N : oodraw
> >  2262.40     1572.95     1698.37    N : ooimpress
> >  2703.88     1714.53     1841.89    N : oomath
> >  3464.54     1864.99     1983.96    N : ooweb
> >  4040.91     2079.96     2185.53    N : oowriter
> >  4668.16     2330.24     2365.17    N
> > 
> >  Thanks,
> >  Fengguang
> > 

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmstat.0"

nr_free_pages 2774
nr_inactive_anon 49669
nr_active_anon 37887
nr_inactive_file 1943
nr_active_file 1432
nr_unevictable 4
nr_mlock 4
nr_anon_pages 33433
nr_mapped 3748
nr_file_pages 63113
nr_dirty 0
nr_writeback 14
nr_slab_reclaimable 3067
nr_slab_unreclaimable 11016
nr_page_table_pages 7733
nr_unstable 0
nr_bounce 0
nr_vmscan_write 452422
nr_writeback_temp 0
numa_hit 11905133
numa_miss 0
numa_foreign 0
numa_interleave 1719
numa_local 11905133
numa_other 0
pgpgin 8898235
pgpgout 1806868
pswpin 2222503
pswpout 451716
pgalloc_dma 39883
pgalloc_dma32 11918819
pgalloc_normal 0
pgalloc_movable 0
pgfree 11961651
pgactivate 5771012
pgdeactivate 5909300
pgfault 4536082
pgmajfault 926383
pgrefill_dma 3358
pgrefill_dma32 327639
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 4163
pgsteal_dma32 9004008
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 14283579
pgscan_kswapd_dma32 440003821
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 2518976
pgscan_direct_dma32 85187744
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 4578
slabs_scanned 567936
kswapd_steal 8653718
kswapd_inodesteal 11378
pageoutrun 154601
allocstall 7487
pgrotated 438820
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 4
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmstat.1"

nr_free_pages 2441
nr_inactive_anon 48016
nr_active_anon 38622
nr_inactive_file 3402
nr_active_file 1641
nr_unevictable 4
nr_mlock 4
nr_anon_pages 34731
nr_mapped 3599
nr_file_pages 62566
nr_dirty 0
nr_writeback 2
nr_slab_reclaimable 3091
nr_slab_unreclaimable 10664
nr_page_table_pages 7769
nr_unstable 0
nr_bounce 0
nr_vmscan_write 366662
nr_writeback_temp 0
numa_hit 6789271
numa_miss 0
numa_foreign 0
numa_interleave 1719
numa_local 6789271
numa_other 0
pgpgin 4828771
pgpgout 1463644
pswpin 1205137
pswpout 365910
pgalloc_dma 24343
pgalloc_dma32 6810775
pgalloc_normal 0
pgalloc_movable 0
pgfree 6837658
pgactivate 2999101
pgdeactivate 3140474
pgfault 3468555
pgmajfault 506265
pgrefill_dma 2336
pgrefill_dma32 729107
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 1913
pgsteal_dma32 4357494
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 6712845
pgscan_kswapd_dma32 286604714
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 1341301
pgscan_direct_dma32 59422832
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 4612
slabs_scanned 575616
kswapd_steal 4132786
kswapd_inodesteal 13238
pageoutrun 68758
allocstall 4576
pgrotated 359071
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 4
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmstat.2"

nr_free_pages 5027
nr_inactive_anon 45647
nr_active_anon 39133
nr_inactive_file 2213
nr_active_file 2204
nr_unevictable 4
nr_mlock 4
nr_anon_pages 34044
nr_mapped 4110
nr_file_pages 60736
nr_dirty 0
nr_writeback 2
nr_slab_reclaimable 3024
nr_slab_unreclaimable 10694
nr_page_table_pages 7737
nr_unstable 0
nr_bounce 0
nr_vmscan_write 346130
nr_writeback_temp 0
numa_hit 6348796
numa_miss 0
numa_foreign 0
numa_interleave 1719
numa_local 6348796
numa_other 0
pgpgin 1807731
pgpgout 1382244
pswpin 449877
pswpout 345560
pgalloc_dma 3547
pgalloc_dma32 6387602
pgalloc_normal 0
pgalloc_movable 0
pgfree 6396229
pgactivate 2341219
pgdeactivate 2481319
pgfault 3589046
pgmajfault 520010
pgrefill_dma 1760
pgrefill_dma32 704673
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 0
pgsteal_dma32 3801681
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 9155325
pgscan_kswapd_dma32 225882967
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 89949
pgscan_direct_dma32 2499274
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 3410
slabs_scanned 544000
kswapd_steal 3618518
kswapd_inodesteal 11438
pageoutrun 59774
allocstall 4014
pgrotated 326236
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 4
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--cWoXeonUoKmBZSoM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
