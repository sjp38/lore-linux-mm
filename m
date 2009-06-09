Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 96AF66B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 02:18:49 -0400 (EDT)
Date: Tue, 9 Jun 2009 14:44:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class  citizen
Message-ID: <20090609064406.GA5490@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com> <20090519062503.GA9580@localhost> <87pre4nhqf.fsf@basil.nowhere.org> <20090608073944.GA12431@localhost> <ab418ea90906081018o56f036c4md200a605921337c3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ab418ea90906081018o56f036c4md200a605921337c3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Nai Xia <nai.xia@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 01:18:26AM +0800, Nai Xia wrote:
> On Mon, Jun 8, 2009 at 3:39 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> > On Wed, May 20, 2009 at 07:20:24PM +0800, Andi Kleen wrote:
> >> One scenario that might be useful to test is what happens when some very large
> >> processes, all mapped and executable exceed memory and fight each other
> >> for the working set. Do you have regressions then compared to without
> >> the patches?
> >
> > I managed to carry out some stress tests for memory tight desktops.
> > The outcome is encouraging: clock time and major faults are reduced
> > by 50%, and pswpin numbers are reduced to ~1/3.
> >
> > Here is the test scenario.
> > - nfsroot gnome desktop with 512M physical memory
> > - run some programs, and switch between the existing windows after
> > A starting each new program.
> 
> I think this is a story of VM_EXEC pages fighting against other kind of pages,
> but as Andi said, did you test real regression case of VM_EXEC pages fighting
> against each other?

No. We'd better buy more memory if it's not enough for VM_EXEC pages :-)

Thanks,
Fengguang

> "
> One scenario that might be useful to test is what happens when some very large
> processes, all mapped and executable exceed memory and fight each other
> for the working set. Do you have regressions then compared to without
> the patches?
> 
> -Andi
> "
> 
> My experices with Compcache(http://code.google.com/p/compcache/) show that
> it also has similar improvement in similar case on LTSP
> (http://code.google.com/p/compcache/wiki/Performance).
> But it does has a non-trivial performance loss even when doing kernel
> compilation.
> I am not a little surprised when Andrew said it "There must be some cost
> somewhere".
> 
> So you have found the spots where your patch doing great,
> make double sure it will not do something bad in all places,
> and that will be perfect. :-)
> 
> >
> > The progress timing (seconds) is:
> >
> > A before A  A  A  after A  A programs
> > A  A 0.02 A  A  A  A 0.02 A  A N xeyes
> > A  A 0.75 A  A  A  A 0.76 A  A N firefox
> > A  A 2.02 A  A  A  A 1.88 A  A N nautilus
> > A  A 3.36 A  A  A  A 3.17 A  A N nautilus --browser
> > A  A 5.26 A  A  A  A 4.89 A  A N gthumb
> > A  A 7.12 A  A  A  A 6.47 A  A N gedit
> > A  A 9.22 A  A  A  A 8.16 A  A N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
> > A  13.58 A  A  A  12.55 A  A N xterm
> > A  15.87 A  A  A  14.57 A  A N mlterm
> > A  18.63 A  A  A  17.06 A  A N gnome-terminal
> > A  21.16 A  A  A  18.90 A  A N urxvt
> > A  26.24 A  A  A  23.48 A  A N gnome-system-monitor
> > A  28.72 A  A  A  26.52 A  A N gnome-help
> > A  32.15 A  A  A  29.65 A  A N gnome-dictionary
> > A  39.66 A  A  A  36.12 A  A N /usr/games/sol
> > A  43.16 A  A  A  39.27 A  A N /usr/games/gnometris
> > A  48.65 A  A  A  42.56 A  A N /usr/games/gnect
> > A  53.31 A  A  A  47.03 A  A N /usr/games/gtali
> > A  58.60 A  A  A  52.05 A  A N /usr/games/iagno
> > A  65.77 A  A  A  55.42 A  A N /usr/games/gnotravex
> > A  70.76 A  A  A  61.47 A  A N /usr/games/mahjongg
> > A  76.15 A  A  A  67.11 A  A N /usr/games/gnome-sudoku
> > A  86.32 A  A  A  75.15 A  A N /usr/games/glines
> > A  92.21 A  A  A  79.70 A  A N /usr/games/glchess
> > A 103.79 A  A  A  88.48 A  A N /usr/games/gnomine
> > A 113.84 A  A  A  96.51 A  A N /usr/games/gnotski
> > A 124.40 A  A  A 102.19 A  A N /usr/games/gnibbles
> > A 137.41 A  A  A 114.93 A  A N /usr/games/gnobots2
> > A 155.53 A  A  A 125.02 A  A N /usr/games/blackjack
> > A 179.85 A  A  A 135.11 A  A N /usr/games/same-gnome
> > A 224.49 A  A  A 154.50 A  A N /usr/bin/gnome-window-properties
> > A 248.44 A  A  A 162.09 A  A N /usr/bin/gnome-default-applications-properties
> > A 282.62 A  A  A 173.29 A  A N /usr/bin/gnome-at-properties
> > A 323.72 A  A  A 188.21 A  A N /usr/bin/gnome-typing-monitor
> > A 363.99 A  A  A 199.93 A  A N /usr/bin/gnome-at-visual
> > A 394.21 A  A  A 206.95 A  A N /usr/bin/gnome-sound-properties
> > A 435.14 A  A  A 224.49 A  A N /usr/bin/gnome-at-mobility
> > A 463.05 A  A  A 234.11 A  A N /usr/bin/gnome-keybinding-properties
> > A 503.75 A  A  A 248.59 A  A N /usr/bin/gnome-about-me
> > A 554.00 A  A  A 276.27 A  A N /usr/bin/gnome-display-properties
> > A 615.48 A  A  A 304.39 A  A N /usr/bin/gnome-network-preferences
> > A 693.03 A  A  A 342.01 A  A N /usr/bin/gnome-mouse-properties
> > A 759.90 A  A  A 388.58 A  A N /usr/bin/gnome-appearance-properties
> > A 937.90 A  A  A 508.47 A  A N /usr/bin/gnome-control-center
> > A 1109.75 A  A  A 587.57 A  A N /usr/bin/gnome-keyboard-properties
> > A 1399.05 A  A  A 758.16 A  A N : oocalc
> > A 1524.64 A  A  A 830.03 A  A N : oodraw
> > A 1684.31 A  A  A 900.03 A  A N : ooimpress
> > A 1874.04 A  A  A 993.91 A  A N : oomath
> > A 2115.12 A  A  1081.89 A  A N : ooweb
> > A 2369.02 A  A  1161.99 A  A N : oowriter
> >
> > Note that the oo* commands are actually commented out.
> >
> > The vmstat numbers are (some relevant ones are marked with *):
> >
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A before A  A after
> > A nr_free_pages A  A  A  A  A  A  A 1293 A  A  A 3898
> > A nr_inactive_anon A  A  A  A  A  59956 A  A  53460
> > A nr_active_anon A  A  A  A  A  A  26815 A  A  30026
> > A nr_inactive_file A  A  A  A  A  2657 A  A  A 3218
> > A nr_active_file A  A  A  A  A  A  2019 A  A  A 2806
> > A nr_unevictable A  A  A  A  A  A  4 A  A  A  A  4
> > A nr_mlock A  A  A  A  A  A  A  A  A  4 A  A  A  A  4
> > A nr_anon_pages A  A  A  A  A  A  A 26706 A  A  27859
> > *nr_mapped A  A  A  A  A  A  A  A  A 3542 A  A  A 4469
> > A nr_file_pages A  A  A  A  A  A  A 72232 A  A  67681
> > A nr_dirty A  A  A  A  A  A  A  A  A  1 A  A  A  A  0
> > A nr_writeback A  A  A  A  A  A  A  123 A  A  A  19
> > A nr_slab_reclaimable A  A  A  A 3375 A  A  A 3534
> > A nr_slab_unreclaimable A  A  A 11405 A  A  10665
> > A nr_page_table_pages A  A  A  A 8106 A  A  A 7864
> > A nr_unstable A  A  A  A  A  A  A  A 0 A  A  A  A  0
> > A nr_bounce A  A  A  A  A  A  A  A  A 0 A  A  A  A  0
> > *nr_vmscan_write A  A  A  A  A  A 394776 A  A 230839
> > A nr_writeback_temp A  A  A  A  A 0 A  A  A  A  0
> > A numa_hit A  A  A  A  A  A  A  A  A  6843353 A  3318676
> > A numa_miss A  A  A  A  A  A  A  A  A 0 A  A  A  A  0
> > A numa_foreign A  A  A  A  A  A  A  0 A  A  A  A  0
> > A numa_interleave A  A  A  A  A  A 1719 A  A  A 1719
> > A numa_local A  A  A  A  A  A  A  A  6843353 A  3318676
> > A numa_other A  A  A  A  A  A  A  A  0 A  A  A  A  0
> > *pgpgin A  A  A  A  A  A  A  A  A  A  5954683 A  2057175
> > *pgpgout A  A  A  A  A  A  A  A  A  A 1578276 A  922744
> > *pswpin A  A  A  A  A  A  A  A  A  A  1486615 A  512238
> > *pswpout A  A  A  A  A  A  A  A  A  A 394568 A  A 230685
> > A pgalloc_dma A  A  A  A  A  A  A  A 277432 A  A 56602
> > A pgalloc_dma32 A  A  A  A  A  A  A 6769477 A  3310348
> > A pgalloc_normal A  A  A  A  A  A  0 A  A  A  A  0
> > A pgalloc_movable A  A  A  A  A  A 0 A  A  A  A  0
> > A pgfree A  A  A  A  A  A  A  A  A  A  7048396 A  3371118
> > A pgactivate A  A  A  A  A  A  A  A  2036343 A  1471492
> > A pgdeactivate A  A  A  A  A  A  A  2189691 A  1612829
> > A pgfault A  A  A  A  A  A  A  A  A  A 3702176 A  3100702
> > *pgmajfault A  A  A  A  A  A  A  A  452116 A  A 201343
> > A pgrefill_dma A  A  A  A  A  A  A  12185 A  A  7127
> > A pgrefill_dma32 A  A  A  A  A  A  334384 A  A 653703
> > A pgrefill_normal A  A  A  A  A  A 0 A  A  A  A  0
> > A pgrefill_movable A  A  A  A  A  0 A  A  A  A  0
> > A pgsteal_dma A  A  A  A  A  A  A  A 74214 A  A  22179
> > A pgsteal_dma32 A  A  A  A  A  A  A 3334164 A  1638029
> > A pgsteal_normal A  A  A  A  A  A  0 A  A  A  A  0
> > A pgsteal_movable A  A  A  A  A  A 0 A  A  A  A  0
> > A pgscan_kswapd_dma A  A  A  A  A 1081421 A  1216199
> > A pgscan_kswapd_dma32 A  A  A  A 58979118 A 46002810
> > A pgscan_kswapd_normal A  A  A  0 A  A  A  A  0
> > A pgscan_kswapd_movable A  A  A 0 A  A  A  A  0
> > A pgscan_direct_dma A  A  A  A  A 2015438 A  1086109
> > A pgscan_direct_dma32 A  A  A  A 55787823 A 36101597
> > A pgscan_direct_normal A  A  A  0 A  A  A  A  0
> > A pgscan_direct_movable A  A  A 0 A  A  A  A  0
> > A pginodesteal A  A  A  A  A  A  A  3461 A  A  A 7281
> > A slabs_scanned A  A  A  A  A  A  A 564864 A  A 527616
> > A kswapd_steal A  A  A  A  A  A  A  2889797 A  1448082
> > A kswapd_inodesteal A  A  A  A  A 14827 A  A  14835
> > A pageoutrun A  A  A  A  A  A  A  A  43459 A  A  21562
> > A allocstall A  A  A  A  A  A  A  A  9653 A  A  A 4032
> > A pgrotated A  A  A  A  A  A  A  A  A 384216 A  A 228631
> > A htlb_buddy_alloc_success A  0 A  A  A  A  0
> > A htlb_buddy_alloc_fail A  A  A 0 A  A  A  A  0
> > A unevictable_pgs_culled A  A  0 A  A  A  A  0
> > A unevictable_pgs_scanned A  A 0 A  A  A  A  0
> > A unevictable_pgs_rescued A  A 0 A  A  A  A  0
> > A unevictable_pgs_mlocked A  A 4 A  A  A  A  4
> > A unevictable_pgs_munlocked A 0 A  A  A  A  0
> > A unevictable_pgs_cleared A  A 0 A  A  A  A  0
> > A unevictable_pgs_stranded A  0 A  A  A  A  0
> > A unevictable_pgs_mlockfreed 0 A  A  A  A  0
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org. A For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
