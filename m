Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E971D6B005A
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 13:18:30 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so2176923qwk.44
        for <linux-mm@kvack.org>; Mon, 08 Jun 2009 10:18:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090608073944.GA12431@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com>
	 <20090519032759.GA7608@localhost>
	 <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
	 <20090519062503.GA9580@localhost> <87pre4nhqf.fsf@basil.nowhere.org>
	 <20090608073944.GA12431@localhost>
Date: Tue, 9 Jun 2009 01:18:26 +0800
Message-ID: <ab418ea90906081018o56f036c4md200a605921337c3@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 8, 2009 at 3:39 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> On Wed, May 20, 2009 at 07:20:24PM +0800, Andi Kleen wrote:
>> One scenario that might be useful to test is what happens when some very=
 large
>> processes, all mapped and executable exceed memory and fight each other
>> for the working set. Do you have regressions then compared to without
>> the patches?
>
> I managed to carry out some stress tests for memory tight desktops.
> The outcome is encouraging: clock time and major faults are reduced
> by 50%, and pswpin numbers are reduced to ~1/3.
>
> Here is the test scenario.
> - nfsroot gnome desktop with 512M physical memory
> - run some programs, and switch between the existing windows after
> =A0starting each new program.

I think this is a story of VM_EXEC pages fighting against other kind of pag=
es,
but as Andi said, did you test real regression case of VM_EXEC pages fighti=
ng
against each other?

"
One scenario that might be useful to test is what happens when some very la=
rge
processes, all mapped and executable exceed memory and fight each other
for the working set. Do you have regressions then compared to without
the patches?

-Andi
"

My experices with Compcache(http://code.google.com/p/compcache/) show that
it also has similar improvement in similar case on LTSP
(http://code.google.com/p/compcache/wiki/Performance).
But it does has a non-trivial performance loss even when doing kernel
compilation.
I am not a little surprised when Andrew said it "There must be some cost
somewhere".

So you have found the spots where your patch doing great,
make double sure it will not do something bad in all places,
and that will be perfect. :-)

>
> The progress timing (seconds) is:
>
> =A0before =A0 =A0 =A0 after =A0 =A0programs
> =A0 =A00.02 =A0 =A0 =A0 =A00.02 =A0 =A0N xeyes
> =A0 =A00.75 =A0 =A0 =A0 =A00.76 =A0 =A0N firefox
> =A0 =A02.02 =A0 =A0 =A0 =A01.88 =A0 =A0N nautilus
> =A0 =A03.36 =A0 =A0 =A0 =A03.17 =A0 =A0N nautilus --browser
> =A0 =A05.26 =A0 =A0 =A0 =A04.89 =A0 =A0N gthumb
> =A0 =A07.12 =A0 =A0 =A0 =A06.47 =A0 =A0N gedit
> =A0 =A09.22 =A0 =A0 =A0 =A08.16 =A0 =A0N xpdf /usr/share/doc/shared-mime-=
info/shared-mime-info-spec.pdf
> =A0 13.58 =A0 =A0 =A0 12.55 =A0 =A0N xterm
> =A0 15.87 =A0 =A0 =A0 14.57 =A0 =A0N mlterm
> =A0 18.63 =A0 =A0 =A0 17.06 =A0 =A0N gnome-terminal
> =A0 21.16 =A0 =A0 =A0 18.90 =A0 =A0N urxvt
> =A0 26.24 =A0 =A0 =A0 23.48 =A0 =A0N gnome-system-monitor
> =A0 28.72 =A0 =A0 =A0 26.52 =A0 =A0N gnome-help
> =A0 32.15 =A0 =A0 =A0 29.65 =A0 =A0N gnome-dictionary
> =A0 39.66 =A0 =A0 =A0 36.12 =A0 =A0N /usr/games/sol
> =A0 43.16 =A0 =A0 =A0 39.27 =A0 =A0N /usr/games/gnometris
> =A0 48.65 =A0 =A0 =A0 42.56 =A0 =A0N /usr/games/gnect
> =A0 53.31 =A0 =A0 =A0 47.03 =A0 =A0N /usr/games/gtali
> =A0 58.60 =A0 =A0 =A0 52.05 =A0 =A0N /usr/games/iagno
> =A0 65.77 =A0 =A0 =A0 55.42 =A0 =A0N /usr/games/gnotravex
> =A0 70.76 =A0 =A0 =A0 61.47 =A0 =A0N /usr/games/mahjongg
> =A0 76.15 =A0 =A0 =A0 67.11 =A0 =A0N /usr/games/gnome-sudoku
> =A0 86.32 =A0 =A0 =A0 75.15 =A0 =A0N /usr/games/glines
> =A0 92.21 =A0 =A0 =A0 79.70 =A0 =A0N /usr/games/glchess
> =A0103.79 =A0 =A0 =A0 88.48 =A0 =A0N /usr/games/gnomine
> =A0113.84 =A0 =A0 =A0 96.51 =A0 =A0N /usr/games/gnotski
> =A0124.40 =A0 =A0 =A0102.19 =A0 =A0N /usr/games/gnibbles
> =A0137.41 =A0 =A0 =A0114.93 =A0 =A0N /usr/games/gnobots2
> =A0155.53 =A0 =A0 =A0125.02 =A0 =A0N /usr/games/blackjack
> =A0179.85 =A0 =A0 =A0135.11 =A0 =A0N /usr/games/same-gnome
> =A0224.49 =A0 =A0 =A0154.50 =A0 =A0N /usr/bin/gnome-window-properties
> =A0248.44 =A0 =A0 =A0162.09 =A0 =A0N /usr/bin/gnome-default-applications-=
properties
> =A0282.62 =A0 =A0 =A0173.29 =A0 =A0N /usr/bin/gnome-at-properties
> =A0323.72 =A0 =A0 =A0188.21 =A0 =A0N /usr/bin/gnome-typing-monitor
> =A0363.99 =A0 =A0 =A0199.93 =A0 =A0N /usr/bin/gnome-at-visual
> =A0394.21 =A0 =A0 =A0206.95 =A0 =A0N /usr/bin/gnome-sound-properties
> =A0435.14 =A0 =A0 =A0224.49 =A0 =A0N /usr/bin/gnome-at-mobility
> =A0463.05 =A0 =A0 =A0234.11 =A0 =A0N /usr/bin/gnome-keybinding-properties
> =A0503.75 =A0 =A0 =A0248.59 =A0 =A0N /usr/bin/gnome-about-me
> =A0554.00 =A0 =A0 =A0276.27 =A0 =A0N /usr/bin/gnome-display-properties
> =A0615.48 =A0 =A0 =A0304.39 =A0 =A0N /usr/bin/gnome-network-preferences
> =A0693.03 =A0 =A0 =A0342.01 =A0 =A0N /usr/bin/gnome-mouse-properties
> =A0759.90 =A0 =A0 =A0388.58 =A0 =A0N /usr/bin/gnome-appearance-properties
> =A0937.90 =A0 =A0 =A0508.47 =A0 =A0N /usr/bin/gnome-control-center
> =A01109.75 =A0 =A0 =A0587.57 =A0 =A0N /usr/bin/gnome-keyboard-properties
> =A01399.05 =A0 =A0 =A0758.16 =A0 =A0N : oocalc
> =A01524.64 =A0 =A0 =A0830.03 =A0 =A0N : oodraw
> =A01684.31 =A0 =A0 =A0900.03 =A0 =A0N : ooimpress
> =A01874.04 =A0 =A0 =A0993.91 =A0 =A0N : oomath
> =A02115.12 =A0 =A0 1081.89 =A0 =A0N : ooweb
> =A02369.02 =A0 =A0 1161.99 =A0 =A0N : oowriter
>
> Note that the oo* commands are actually commented out.
>
> The vmstat numbers are (some relevant ones are marked with *):
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0before =A0 =A0afte=
r
> =A0nr_free_pages =A0 =A0 =A0 =A0 =A0 =A0 =A01293 =A0 =A0 =A03898
> =A0nr_inactive_anon =A0 =A0 =A0 =A0 =A0 59956 =A0 =A0 53460
> =A0nr_active_anon =A0 =A0 =A0 =A0 =A0 =A0 26815 =A0 =A0 30026
> =A0nr_inactive_file =A0 =A0 =A0 =A0 =A0 2657 =A0 =A0 =A03218
> =A0nr_active_file =A0 =A0 =A0 =A0 =A0 =A0 2019 =A0 =A0 =A02806
> =A0nr_unevictable =A0 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 4
> =A0nr_mlock =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 4
> =A0nr_anon_pages =A0 =A0 =A0 =A0 =A0 =A0 =A026706 =A0 =A0 27859
> *nr_mapped =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03542 =A0 =A0 =A04469
> =A0nr_file_pages =A0 =A0 =A0 =A0 =A0 =A0 =A072232 =A0 =A0 67681
> =A0nr_dirty =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 0
> =A0nr_writeback =A0 =A0 =A0 =A0 =A0 =A0 =A0 123 =A0 =A0 =A0 19
> =A0nr_slab_reclaimable =A0 =A0 =A0 =A03375 =A0 =A0 =A03534
> =A0nr_slab_unreclaimable =A0 =A0 =A011405 =A0 =A0 10665
> =A0nr_page_table_pages =A0 =A0 =A0 =A08106 =A0 =A0 =A07864
> =A0nr_unstable =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0nr_bounce =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> *nr_vmscan_write =A0 =A0 =A0 =A0 =A0 =A0394776 =A0 =A0230839
> =A0nr_writeback_temp =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0numa_hit =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6843353 =A0 3318676
> =A0numa_miss =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0numa_foreign =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0numa_interleave =A0 =A0 =A0 =A0 =A0 =A01719 =A0 =A0 =A01719
> =A0numa_local =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6843353 =A0 3318676
> =A0numa_other =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> *pgpgin =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 5954683 =A0 2057175
> *pgpgout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01578276 =A0 922744
> *pswpin =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1486615 =A0 512238
> *pswpout =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0394568 =A0 =A0230685
> =A0pgalloc_dma =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0277432 =A0 =A056602
> =A0pgalloc_dma32 =A0 =A0 =A0 =A0 =A0 =A0 =A06769477 =A0 3310348
> =A0pgalloc_normal =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0pgalloc_movable =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0pgfree =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 7048396 =A0 3371118
> =A0pgactivate =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2036343 =A0 1471492
> =A0pgdeactivate =A0 =A0 =A0 =A0 =A0 =A0 =A0 2189691 =A0 1612829
> =A0pgfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A03702176 =A0 3100702
> *pgmajfault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 452116 =A0 =A0201343
> =A0pgrefill_dma =A0 =A0 =A0 =A0 =A0 =A0 =A0 12185 =A0 =A0 7127
> =A0pgrefill_dma32 =A0 =A0 =A0 =A0 =A0 =A0 334384 =A0 =A0653703
> =A0pgrefill_normal =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0pgrefill_movable =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0pgsteal_dma =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A074214 =A0 =A0 22179
> =A0pgsteal_dma32 =A0 =A0 =A0 =A0 =A0 =A0 =A03334164 =A0 1638029
> =A0pgsteal_normal =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0pgsteal_movable =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0pgscan_kswapd_dma =A0 =A0 =A0 =A0 =A01081421 =A0 1216199
> =A0pgscan_kswapd_dma32 =A0 =A0 =A0 =A058979118 =A046002810
> =A0pgscan_kswapd_normal =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0pgscan_kswapd_movable =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0pgscan_direct_dma =A0 =A0 =A0 =A0 =A02015438 =A0 1086109
> =A0pgscan_direct_dma32 =A0 =A0 =A0 =A055787823 =A036101597
> =A0pgscan_direct_normal =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0pgscan_direct_movable =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0pginodesteal =A0 =A0 =A0 =A0 =A0 =A0 =A0 3461 =A0 =A0 =A07281
> =A0slabs_scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0564864 =A0 =A0527616
> =A0kswapd_steal =A0 =A0 =A0 =A0 =A0 =A0 =A0 2889797 =A0 1448082
> =A0kswapd_inodesteal =A0 =A0 =A0 =A0 =A014827 =A0 =A0 14835
> =A0pageoutrun =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 43459 =A0 =A0 21562
> =A0allocstall =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9653 =A0 =A0 =A04032
> =A0pgrotated =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0384216 =A0 =A0228631
> =A0htlb_buddy_alloc_success =A0 0 =A0 =A0 =A0 =A0 0
> =A0htlb_buddy_alloc_fail =A0 =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_culled =A0 =A0 0 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_scanned =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_rescued =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_mlocked =A0 =A04 =A0 =A0 =A0 =A0 4
> =A0unevictable_pgs_munlocked =A00 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_cleared =A0 =A00 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_stranded =A0 0 =A0 =A0 =A0 =A0 0
> =A0unevictable_pgs_mlockfreed 0 =A0 =A0 =A0 =A0 0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
