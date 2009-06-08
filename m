Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9FB1C6B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 02:34:29 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:39:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090608073944.GA12431@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com> <20090519062503.GA9580@localhost> <87pre4nhqf.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pre4nhqf.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 20, 2009 at 07:20:24PM +0800, Andi Kleen wrote:
> One scenario that might be useful to test is what happens when some very large
> processes, all mapped and executable exceed memory and fight each other
> for the working set. Do you have regressions then compared to without
> the patches?

I managed to carry out some stress tests for memory tight desktops.
The outcome is encouraging: clock time and major faults are reduced
by 50%, and pswpin numbers are reduced to ~1/3.

Here is the test scenario.
- nfsroot gnome desktop with 512M physical memory
- run some programs, and switch between the existing windows after
  starting each new program.

The progress timing (seconds) is:

  before       after    programs
    0.02        0.02    N xeyes
    0.75        0.76    N firefox
    2.02        1.88    N nautilus
    3.36        3.17    N nautilus --browser
    5.26        4.89    N gthumb
    7.12        6.47    N gedit
    9.22        8.16    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
   13.58       12.55    N xterm
   15.87       14.57    N mlterm
   18.63       17.06    N gnome-terminal
   21.16       18.90    N urxvt
   26.24       23.48    N gnome-system-monitor
   28.72       26.52    N gnome-help
   32.15       29.65    N gnome-dictionary
   39.66       36.12    N /usr/games/sol
   43.16       39.27    N /usr/games/gnometris
   48.65       42.56    N /usr/games/gnect
   53.31       47.03    N /usr/games/gtali
   58.60       52.05    N /usr/games/iagno
   65.77       55.42    N /usr/games/gnotravex
   70.76       61.47    N /usr/games/mahjongg
   76.15       67.11    N /usr/games/gnome-sudoku
   86.32       75.15    N /usr/games/glines
   92.21       79.70    N /usr/games/glchess
  103.79       88.48    N /usr/games/gnomine
  113.84       96.51    N /usr/games/gnotski
  124.40      102.19    N /usr/games/gnibbles
  137.41      114.93    N /usr/games/gnobots2
  155.53      125.02    N /usr/games/blackjack
  179.85      135.11    N /usr/games/same-gnome
  224.49      154.50    N /usr/bin/gnome-window-properties
  248.44      162.09    N /usr/bin/gnome-default-applications-properties
  282.62      173.29    N /usr/bin/gnome-at-properties
  323.72      188.21    N /usr/bin/gnome-typing-monitor
  363.99      199.93    N /usr/bin/gnome-at-visual
  394.21      206.95    N /usr/bin/gnome-sound-properties
  435.14      224.49    N /usr/bin/gnome-at-mobility
  463.05      234.11    N /usr/bin/gnome-keybinding-properties
  503.75      248.59    N /usr/bin/gnome-about-me
  554.00      276.27    N /usr/bin/gnome-display-properties
  615.48      304.39    N /usr/bin/gnome-network-preferences
  693.03      342.01    N /usr/bin/gnome-mouse-properties
  759.90      388.58    N /usr/bin/gnome-appearance-properties
  937.90      508.47    N /usr/bin/gnome-control-center
 1109.75      587.57    N /usr/bin/gnome-keyboard-properties
 1399.05      758.16    N : oocalc
 1524.64      830.03    N : oodraw
 1684.31      900.03    N : ooimpress
 1874.04      993.91    N : oomath
 2115.12     1081.89    N : ooweb
 2369.02     1161.99    N : oowriter

Note that the oo* commands are actually commented out.

The vmstat numbers are (some relevant ones are marked with *):

                            before    after
 nr_free_pages              1293      3898
 nr_inactive_anon           59956     53460
 nr_active_anon             26815     30026
 nr_inactive_file           2657      3218
 nr_active_file             2019      2806
 nr_unevictable             4         4
 nr_mlock                   4         4
 nr_anon_pages              26706     27859
*nr_mapped                  3542      4469
 nr_file_pages              72232     67681
 nr_dirty                   1         0
 nr_writeback               123       19
 nr_slab_reclaimable        3375      3534
 nr_slab_unreclaimable      11405     10665
 nr_page_table_pages        8106      7864
 nr_unstable                0         0
 nr_bounce                  0         0
*nr_vmscan_write            394776    230839
 nr_writeback_temp          0         0
 numa_hit                   6843353   3318676
 numa_miss                  0         0
 numa_foreign               0         0
 numa_interleave            1719      1719
 numa_local                 6843353   3318676
 numa_other                 0         0
*pgpgin                     5954683   2057175
*pgpgout                    1578276   922744
*pswpin                     1486615   512238
*pswpout                    394568    230685
 pgalloc_dma                277432    56602
 pgalloc_dma32              6769477   3310348
 pgalloc_normal             0         0
 pgalloc_movable            0         0
 pgfree                     7048396   3371118
 pgactivate                 2036343   1471492
 pgdeactivate               2189691   1612829
 pgfault                    3702176   3100702
*pgmajfault                 452116    201343
 pgrefill_dma               12185     7127
 pgrefill_dma32             334384    653703
 pgrefill_normal            0         0
 pgrefill_movable           0         0
 pgsteal_dma                74214     22179
 pgsteal_dma32              3334164   1638029
 pgsteal_normal             0         0
 pgsteal_movable            0         0
 pgscan_kswapd_dma          1081421   1216199
 pgscan_kswapd_dma32        58979118  46002810
 pgscan_kswapd_normal       0         0
 pgscan_kswapd_movable      0         0
 pgscan_direct_dma          2015438   1086109
 pgscan_direct_dma32        55787823  36101597
 pgscan_direct_normal       0         0
 pgscan_direct_movable      0         0
 pginodesteal               3461      7281
 slabs_scanned              564864    527616
 kswapd_steal               2889797   1448082
 kswapd_inodesteal          14827     14835
 pageoutrun                 43459     21562
 allocstall                 9653      4032
 pgrotated                  384216    228631
 htlb_buddy_alloc_success   0         0
 htlb_buddy_alloc_fail      0         0
 unevictable_pgs_culled     0         0
 unevictable_pgs_scanned    0         0
 unevictable_pgs_rescued    0         0
 unevictable_pgs_mlocked    4         4
 unevictable_pgs_munlocked  0         0
 unevictable_pgs_cleared    0         0
 unevictable_pgs_stranded   0         0
 unevictable_pgs_mlockfreed 0         0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
