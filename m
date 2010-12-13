Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B0C196B009B
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:31:19 -0500 (EST)
Received: by pwj8 with SMTP id 8so621442pwj.14
        for <linux-mm@kvack.org>; Mon, 13 Dec 2010 07:31:16 -0800 (PST)
Date: Tue, 14 Dec 2010 00:31:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v4 4/7] Reclaim invalidated page ASAP
Message-ID: <20101213153105.GA2344@barrios-desktop>
References: <cover.1291568905.git.minchan.kim@gmail.com>
 <0724024711222476a0c8deadb5b366265b8e5824.1291568905.git.minchan.kim@gmail.com>
 <20101208170504.1750.A69D9226@jp.fujitsu.com>
 <AANLkTikG1EAMm8yPvBVUXjFz1Bu9m+vfwH3TRPDzS9mq@mail.gmail.com>
 <87oc8wa063.fsf@gmail.com>
 <AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTin642NFLMubtCQhSVUNLzfdk5ajz-RWe2zT+Lw6@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 08:10:17AM +0900, Minchan Kim wrote:
> On Wed, Dec 8, 2010 at 10:01 PM, Ben Gamari <bgamari.foss@gmail.com> wrote:
> >> Make sense to me. If Ben is busy, I will measure it and send the result.
> >
> > I've done measurements on the patched kernel. All that remains is to do
> > measurements on the baseline unpached case. To summarize the results
> > thusfar,
> >
> > Times:
> > =======
> > ? ? ? ? ? ? ? ? ? ? ? user ? ?sys ? ? %cpu ? ?inputs ? ? ? ? ? outputs
> > Patched, drop ? ? ? ? ?142 ? ? 64 ? ? ?46 ? ? ?13557744 ? ? ? ? 14052744
> > Patched, nodrop ? ? ? ?55 ? ? ?57 ? ? ?33 ? ? ?13557936 ? ? ? ? 13556680
> >
> > vmstat:
> > ========
> > ? ? ? ? ? ? ? ? ? ? ? ?free_pages ? ? ?inact_anon ? ? ?act_anon ? ? ? ?inact_file ? ? ?act_file ? ? ? ?dirtied ? ? ?written ?reclaim
> > Patched, drop, pre ? ? ?306043 ? ? ? ? ?37541 ? ? ? ? ? 185463 ? ? ? ? ?276266 ? ? ? ? ?153955 ? ? ? ? ?3689674 ? ? ?3604959 ?1550641
> > Patched, drop, post ? ? 13233 ? ? ? ? ? 38462 ? ? ? ? ? 175252 ? ? ? ? ?536346 ? ? ? ? ?178792 ? ? ? ? ?5527564 ? ? ?5371563 ?3169155
> >
> > Patched, nodrop, pre ? ?475211 ? ? ? ? ?38602 ? ? ? ? ? 175242 ? ? ? ? ?81979 ? ? ? ? ? 178820 ? ? ? ? ?5527592 ? ? ?5371554 ?3169155
> > Patched, nodrop, post ? 7697 ? ? ? ? ? ?38959 ? ? ? ? ? 176986 ? ? ? ? ?547984 ? ? ? ? ?180855 ? ? ? ? ?7324836 ? ? ?7132158 ?3169155
> >
> > Altogether, it seems that something is horribly wrong, most likely with
> > my test (or rsync patch). I'll do the baseline benchmarks today.
> >
> > Thoughts?
> 
> 
> How do you test it?
> I think patch's effect would be good in big memory pressure environment.
> 
> Quickly I did it on my desktop environment.(2G DRAM)
> So it's not completed result. I will test more when out of office.
> 
> Used kernel : mmotm-12-02 + my patch series
> Used rsync :
> 1. rsync_normal : v3.0.7 vanilla
> 2. rsync_patch : v3.0.7 + Ben's patch(fadvise)
> 
> Test scenario :
> * kernel full compile
> * git clone linux-kernel
> * rsync local host directory to local host dst directory
> 
> 
> 1) rsync_normal : 89.08user 127.48system 33:22.24elapsed
> 2) rsync_patch : 88.42user 135.26system 31:30.56elapsed
> 
> 1) rsync_normal vmstat :
> pgfault : 45538203
> pgmajfault : 4181
> 
> pgactivate 377416
> pgdeactivate 34183
> pginvalidate 0
> pgreclaim 0
> 
> pgsteal_dma 0
> pgsteal_normal 2144469
> pgsteal_high 2884412
> pgsteal_movable 0
> pgscan_kswapd_dma 0
> pgscan_kswapd_normal 2149739
> pgscan_kswapd_high 2909140
> pgscan_kswapd_movable 0
> pgscan_direct_dma 0
> pgscan_direct_normal 647
> pgscan_direct_high 716
> pgscan_direct_movable 0
> pginodesteal 0
> slabs_scanned 1737344
> kswapd_steal 5028353
> kswapd_inodesteal 438910
> pageoutrun 81208
> allocstall 9
> pgrotated 1642
> 
> 2) rsync_patch vmstat:
> 
> pgfault : 47570231
> pgmajfault : 2669
> 
> pgactivate 391806
> pgdeactivate 36861
> pginvalidate 1685065
> pgreclaim 1685065
> 
> pgrefill_dma 0
> pgrefill_normal 32025
> pgrefill_high 9619
> pgrefill_movable 0
> pgsteal_dma 0
> pgsteal_normal 744904
> pgsteal_high 1079709
> pgsteal_movable 0
> pgscan_kswapd_dma 0
> pgscan_kswapd_normal 745017
> pgscan_kswapd_high 1096660
> pgscan_kswapd_movable 0
> pgscan_direct_dma 0
> pgscan_direct_normal 0
> pgscan_direct_high 0
> pgscan_direct_movable 0
> pginodesteal 0
> slabs_scanned 1896960
> kswapd_steal 1824613
> kswapd_inodesteal 703499
> pageoutrun 26828
> allocstall 0
> pgrotated 1681570
> 
> In summary,
> Unfortunately, the number of fault is increased (47570231 - 45538203)
> but pgmajfault is reduced (4181 - 2669).
> 
> The number of scanning is much reduced. 2149739 -> 745017, 2909140 ->
> 1096660 and even no direct reclaim in patched rsync.
> 
> The number of steal is much reduced. 2144469 -> 744904, 2884412 ->
> 1079709, 5028353 -> 1824613.
> 
> The elapsed time is reduced 2 minutes.
> 
> I think result is good. Reduced the steal number could imply prevent
> eviction of working set pages.
> 
> It has a good result with small effort(small scanning).
> 
> I will resend with more exact measurement after repeated test.
> 
> > Thanks,
> >
> > - Ben
> >
> >

Test Environment :
DRAM : 2G, CPU : Intel(R) Core(TM)2 CPU
Rsync backup directory size : 16G

rsync version is 3.0.7.
rsync patch is Ben's fadivse.
stress scenario do following jobs with parallel.

1. make all -j4 linux, git clone linux-kernel
2. git clone linux-kernel
3. rsync src dst

nrns : no-patched rsync + no stress
prns : patched rsync + no stress
nrs  : no-patched rsync + stress
prs  : patched rsync + stress

pginvalidate : the number of dirty/writeback pages which is invalidated by fadvise
pgreclaim : pages moved PG_reclaim trick in inactive's tail

In summary, my patch enhances a littie bit about elapsed time in
memory pressure environment and enhance reclaim effectivness(reclaim/reclaim)
with x2. It means reclaim latency is short and doesn't evict working set
pages due to invalidated pages.

Look at reclaim effectivness. Patched rsync enhances x2 about reclaim
effectiveness and compared to mmotm-12-03, mmotm-12-03-fadvise enhances
3 minute about elapsed time in stress environment. 
I think it's due to reduce scanning, reclaim overhead.

In no-stress enviroment, fadivse makes program little bit slow.
I think because there are many pgfault. I don't know why it happens.
Could you guess why it happens?

Before futher work, I hope listen opinions.
Any comment is welcome.

Thanks.

== CUT_HERE ==

mmotm-12-03-fadvise

nrns 				prns 				nrs 				prs

27:29.49			28:29.31			41:19.64			40:31.80
pginvalidate 0			pginvalidate 1941654		pginvalidate 0			pginvalidate 1773948
pgreclaim 0			pgreclaim 1941654		pgreclaim 0			pgreclaim 1773947
pgfault 254691			pgfault 462927			pgfault 61865725		pgfault 61015497
pgmajfault 206			pgmajfault 234			pgmajfault 3552			pgmajfault 2240
pgsteal_normal 3047828		pgsteal_normal 1581276		pgsteal_normal 3142791		pgsteal_normal 1845419
pgsteal_high 4757751		pgsteal_high 2419625		pgsteal_high 5351655		pgsteal_high 2731594
pgscan_kswapd_dma 0		pgscan_kswapd_dma 0		pgscan_kswapd_dma 0		pgscan_kswapd_dma 0
pgscan_kswapd_normal 3047960	pgscan_kswapd_normal 1581780	pgscan_kswapd_normal 3146659	pgscan_kswapd_normal 1846071
pgscan_kswapd_high 4758492	pgscan_kswapd_high 2428427	pgscan_kswapd_high 5359960	pgscan_kswapd_high 2732502
pgscan_kswapd_movable 0		pgscan_kswapd_movable 0		pgscan_kswapd_movable 0		pgscan_kswapd_movable 0
pgscan_direct_normal 0		pgscan_direct_normal 0		pgscan_direct_normal 0		pgscan_direct_normal 0
pgscan_direct_high 0		pgscan_direct_high 0		pgscan_direct_high 0		pgscan_direct_high 0
slabs_scanned 1408512		slabs_scanned 1672704		slabs_scanned 1839360		slabs_scanned 2049792
kswapd_steal 7805579		kswapd_steal 4000901		kswapd_steal 8494446		kswapd_steal 4577013
kswapd_inodesteal 146398	kswapd_inodesteal 502321	kswapd_inodesteal 280462	kswapd_inodesteal 493576
pageoutrun 96384		pageoutrun 49907		pageoutrun 139530		pageoutrun 62029
allocstall 0			allocstall 0			allocstall 0			allocstall 0
pgrotated 0			pgrotated 1935875		pgrotated 2511			pgrotated 1768188

mmotm-12-03
nrns 				prns 				nrs 				prs

27:38.84			29:50.22			41:12.10			43:46.63
pgfault 256793			pgfault 415539			pgfault 61205117		pgfault 66495840
pgmajfault 216			pgmajfault 276			pgmajfault 3577			pgmajfault 3383
pgsteal_normal 2963119		pgsteal_normal 1743418		pgsteal_normal 3247443		pgsteal_normal 1904633
pgsteal_high 4832522		pgsteal_high 2718769		pgsteal_high 5202506		pgsteal_high 3124215
pgscan_kswapd_normal 2963164	pgscan_kswapd_normal 1743717	pgscan_kswapd_normal 3252646	pgscan_kswapd_normal 1908354
pgscan_kswapd_high 4832815	pgscan_kswapd_high 2727233	pgscan_kswapd_high 5213874	pgscan_kswapd_high 3132365
pgscan_direct_normal 0		pgscan_direct_normal 0		pgscan_direct_normal 70		pgscan_direct_normal 0
pgscan_direct_high 0		pgscan_direct_high 0		pgscan_direct_high 98		pgscan_direct_high 0
slabs_scanned 1409408		slabs_scanned 1360512		slabs_scanned 1837440		slabs_scanned 1897856
kswapd_steal 7795641		kswapd_steal 4462187		kswapd_steal 8449781		kswapd_steal 5028848
kswapd_inodesteal 142039	kswapd_inodesteal 178		kswapd_inodesteal 311758	kswapd_inodesteal 255974
pageoutrun 97538		pageoutrun 55949		pageoutrun 130136		pageoutrun 84663
allocstall 0			allocstall 0			allocstall 2			allocstall 0
pgrotated 0			pgrotated 0			pgrotated 0			pgrotated 0

> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
