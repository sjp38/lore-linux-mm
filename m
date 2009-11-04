Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F21936B0062
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:01:54 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH 3/3] vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
Date: Wed, 4 Nov 2009 01:01:46 +0100
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <200911032301.59662.elendil@planet.nl> <20091103220808.GF22046@csn.ul.ie>
In-Reply-To: <20091103220808.GF22046@csn.ul.ie>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_uRM8KDGKb3AC14I"
Message-Id: <200911040101.50194.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_uRM8KDGKb3AC14I
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 03 November 2009, you wrote:
> > With a representative test I get 0 for kswapd_slept_prematurely.
> > Tested with .32-rc6 + patches 1-3 + this patch.
>
> Assuming the problem actually reproduced, can you still retest with the

Yes, it does.

> patch I posted as a follow-up and see if fast or slow premature sleeps
> are happening and if the problem still occurs please? It's still
> possible with the patch as-is could be timing related. After I posted
> this patch, I continued testing and found I could get counts fairly
> reliably if kswapd was calling printk() before making the premature
> check so the window appears to be very small.

Tested with .32-rc6 and .31.1. With that follow-up patch I still get=20
freezes and SKB allocation errors. And I don't get anywhere near the fast,=
=20
smooth and reliable behavior I get when I do the congestion_wait()=20
reverts.

The new case does trigger as you can see below, but I'm afraid I don't see=
=20
it making any significant difference for my test. Hope the data is still=20
useful for you.

=46rom vmstat for .32-rc6:
kswapd_highorder_rewakeup 8
kswapd_slept_prematurely_fast 329
kswapd_slept_prematurely_slow 55

=46rom vmstat for .31.1:
kswapd_highorder_rewakeup 20
kswapd_slept_prematurely_fast 307
kswapd_slept_prematurely_slow 105

If you'd like me to test with the congestion_wait() revert on top of this=20
for comparison, please let me know.

Cheers,
=46JP

P.S. Your follow-up patch did not apply cleanly on top of the debug one as=
=20
you seem to have made some changes between posting them (dropped kswapd_=20
from the sleeping_prematurely() function name and added a comment).


--Boundary-00=_uRM8KDGKb3AC14I
Content-Type: text/plain;
  charset="iso-8859-15";
  name="vmstat.32"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="vmstat.32"

nr_free_pages 4798
nr_inactive_anon 102550
nr_active_anon 305242
nr_inactive_file 17876
nr_active_file 13213
nr_unevictable 400
nr_mlock 400
nr_anon_pages 376898
nr_mapped 2769
nr_file_pages 63678
nr_dirty 18
nr_writeback 0
nr_slab_reclaimable 2236
nr_slab_unreclaimable 3984
nr_page_table_pages 3996
nr_kernel_stack 173
nr_unstable 0
nr_bounce 0
nr_vmscan_write 215582
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 17
pgpgin 607186
pgpgout 872956
pswpin 9397
pswpout 215580
pgalloc_dma 2128
pgalloc_dma32 1922180
pgalloc_normal 0
pgalloc_movable 0
pgfree 1929319
pgactivate 122493
pgdeactivate 383992
pgfault 2210388
pgmajfault 6625
pgrefill_dma 1792
pgrefill_dma32 386511
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 41
pgsteal_dma32 295511
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 64
pgscan_kswapd_dma32 379687
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 36768
pgscan_direct_dma32 5233523
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 2416
slabs_scanned 42240
kswapd_steal 241253
kswapd_inodesteal 6252
kswapd_highorder_rewakeup 20
kswapd_slept_prematurely_fast 307
kswapd_slept_prematurely_slow 105
pageoutrun 3394
allocstall 964
pgrotated 215342
unevictable_pgs_culled 4247
unevictable_pgs_scanned 0
unevictable_pgs_rescued 33344
unevictable_pgs_mlocked 43192
unevictable_pgs_munlocked 42780
unevictable_pgs_cleared 2
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--Boundary-00=_uRM8KDGKb3AC14I
Content-Type: text/plain;
  charset="iso-8859-15";
  name="vmstat.31"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="vmstat.31"

nr_free_pages 5730
nr_inactive_anon 101680
nr_active_anon 304236
nr_inactive_file 18296
nr_active_file 14717
nr_unevictable 408
nr_mlock 408
nr_anon_pages 347177
nr_mapped 2751
nr_file_pages 93394
nr_dirty 8
nr_writeback 0
nr_slab_reclaimable 2218
nr_slab_unreclaimable 3670
nr_page_table_pages 3976
nr_unstable 0
nr_bounce 0
nr_vmscan_write 238631
nr_writeback_temp 0
pgpgin 594630
pgpgout 964231
pswpin 8629
pswpout 238627
pgalloc_dma 2169
pgalloc_dma32 1869092
pgalloc_normal 0
pgalloc_movable 0
pgfree 1877147
pgactivate 116309
pgdeactivate 372861
pgfault 2152528
pgmajfault 6806
pgrefill_dma 1410
pgrefill_dma32 375616
pgrefill_normal 0
pgrefill_movable 0
pgsteal_dma 54
pgsteal_dma32 285950
pgsteal_normal 0
pgsteal_movable 0
pgscan_kswapd_dma 96
pgscan_kswapd_dma32 564994
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 448
pgscan_direct_dma32 268795
pgscan_direct_normal 0
pgscan_direct_movable 0
pginodesteal 2411
slabs_scanned 41600
kswapd_steal 247394
kswapd_inodesteal 6479
kswapd_highorder_rewakeup 8
kswapd_slept_prematurely_fast 329
kswapd_slept_prematurely_slow 55
pageoutrun 3525
allocstall 686
pgrotated 238322
unevictable_pgs_culled 4254
unevictable_pgs_scanned 0
unevictable_pgs_rescued 33336
unevictable_pgs_mlocked 43192
unevictable_pgs_munlocked 42772
unevictable_pgs_cleared 2
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0

--Boundary-00=_uRM8KDGKb3AC14I--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
