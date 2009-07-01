Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A17C6B004F
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 00:06:42 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id l33so172664rvb.26
        for <linux-mm@kvack.org>; Tue, 30 Jun 2009 21:06:52 -0700 (PDT)
Date: Wed, 1 Jul 2009 12:06:49 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: Found the commit that causes the OOMs
Message-ID: <20090701040649.GA12832@localhost>
References: <20090701021645.GA6356@localhost> <20090701022644.GA7510@localhost> <20090701114959.85D3.A69D9226@jp.fujitsu.com> <4A4AD07E.2040508@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A4AD07E.2040508@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 10:57:02PM -0400, Rik van Riel wrote:
> KOSAKI Motohiro wrote:
>
>>> [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
>>> [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
>>> [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
>>> [ 1522.019262]  isolate:69817
>>
>> OK. thanks.
>> I plan to submit this patch after small more tests. it is useful for OOM analysis.
>
> It is also useful for throttling page reclaim.
>
> If more than half of the inactive pages in a zone are
> isolated, we are probably beyond the point where adding
> additional reclaim processes will do more harm than good.

There are probably more problems in this case. For example,
followed is the vmstat after first (successful) run of msgctl11.

The question is: Why kswapd reclaims are absent here?

Thanks,
Fengguang
---

wfg@hp ~% /cc/ltp/ltp-full-20090531/testcases/kernel/syscalls/ipc/msgctl/msgctl11
msgctl11    0  INFO  :  Using upto 16298 pids
msgctl11    1  PASS  :  msgctl11 ran successfully!

wfg@hp ~% cat /proc/vmstat
nr_free_pages 237277
nr_inactive_anon 696
nr_active_anon 152
nr_inactive_file 1378
nr_active_file 44
nr_unevictable 0
nr_mlock 0
nr_anon_pages 385
nr_mapped 362
nr_file_pages 2176
nr_dirty 0
nr_writeback 0
nr_slab_reclaimable 1319
nr_slab_unreclaimable 4457
nr_page_table_pages 334
nr_unstable 0
nr_bounce 0
nr_vmscan_write 42098
nr_writeback_temp 0
numa_hit 774529
numa_miss 0
numa_foreign 0
numa_interleave 3177
numa_local 774529
numa_other 0
pgpgin 0
pgpgout 104695
pswpin 119952
pswpout 24118
pgalloc_dma 29987
pgalloc_dma32 3061
pgalloc_normal 842682
pgalloc_movable 0
pgfree 0
pgactivate 1083151
pgdeactivate 11427
pgfault 96023
pgmajfault 1341351
pgrefill_dma 9092
pgrefill_dma32 894
pgrefill_normal 96974
pgrefill_movable 0
pgsteal_dma 0
pgsteal_dma32 104
pgsteal_normal 47883
pgsteal_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 7295
pgscan_direct_normal 143810
pgscan_direct_movable 0
zone_reclaim_failed 0
pginodesteal 0
slabs_scanned 1501
kswapd_steal 9216
kswapd_inodesteal 0
pageoutrun 0
allocstall 1
pgrotated 1965
htlb_buddy_alloc_success 6666
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 0
unevictable_pgs_scanned 0
unevictable_pgs_rescued 0
unevictable_pgs_mlocked 0
unevictable_pgs_munlocked 0
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0
isolate_pages 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
