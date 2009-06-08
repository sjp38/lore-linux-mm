Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B69976B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 02:50:36 -0400 (EDT)
Date: Mon, 8 Jun 2009 15:56:38 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090608075638.GA12874@localhost>
References: <87pre4nhqf.fsf@basil.nowhere.org> <20090608073944.GA12431@localhost> <20090608164611.4385.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090608164611.4385.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 08, 2009 at 03:51:53PM +0800, KOSAKI Motohiro wrote:
> > On Wed, May 20, 2009 at 07:20:24PM +0800, Andi Kleen wrote:
> > > One scenario that might be useful to test is what happens when some very large
> > > processes, all mapped and executable exceed memory and fight each other
> > > for the working set. Do you have regressions then compared to without
> > > the patches?
> > 
> > I managed to carry out some stress tests for memory tight desktops.
> > The outcome is encouraging: clock time and major faults are reduced
> > by 50%, and pswpin numbers are reduced to ~1/3.
> > 
> > Here is the test scenario.
> > - nfsroot gnome desktop with 512M physical memory
> > - run some programs, and switch between the existing windows after
> >   starting each new program.
> > 
> > The progress timing (seconds) is:
> > 
> >   before       after    programs
> >     0.02        0.02    N xeyes
> >     0.75        0.76    N firefox
> >     2.02        1.88    N nautilus
> >     3.36        3.17    N nautilus --browser
> >     5.26        4.89    N gthumb
> >     7.12        6.47    N gedit
> >     9.22        8.16    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
> >    13.58       12.55    N xterm
> >    15.87       14.57    N mlterm
> >    18.63       17.06    N gnome-terminal
> >    21.16       18.90    N urxvt
> >    26.24       23.48    N gnome-system-monitor
> >    28.72       26.52    N gnome-help
> >    32.15       29.65    N gnome-dictionary
> >    39.66       36.12    N /usr/games/sol
> >    43.16       39.27    N /usr/games/gnometris
> >    48.65       42.56    N /usr/games/gnect
> >    53.31       47.03    N /usr/games/gtali
> >    58.60       52.05    N /usr/games/iagno
> >    65.77       55.42    N /usr/games/gnotravex
> >    70.76       61.47    N /usr/games/mahjongg
> >    76.15       67.11    N /usr/games/gnome-sudoku
> >    86.32       75.15    N /usr/games/glines
> >    92.21       79.70    N /usr/games/glchess
> >   103.79       88.48    N /usr/games/gnomine
> >   113.84       96.51    N /usr/games/gnotski
> >   124.40      102.19    N /usr/games/gnibbles
> >   137.41      114.93    N /usr/games/gnobots2
> >   155.53      125.02    N /usr/games/blackjack
> >   179.85      135.11    N /usr/games/same-gnome
> >   224.49      154.50    N /usr/bin/gnome-window-properties
> >   248.44      162.09    N /usr/bin/gnome-default-applications-properties
> >   282.62      173.29    N /usr/bin/gnome-at-properties
> >   323.72      188.21    N /usr/bin/gnome-typing-monitor
> >   363.99      199.93    N /usr/bin/gnome-at-visual
> >   394.21      206.95    N /usr/bin/gnome-sound-properties
> >   435.14      224.49    N /usr/bin/gnome-at-mobility
> >   463.05      234.11    N /usr/bin/gnome-keybinding-properties
> >   503.75      248.59    N /usr/bin/gnome-about-me
> >   554.00      276.27    N /usr/bin/gnome-display-properties
> >   615.48      304.39    N /usr/bin/gnome-network-preferences
> >   693.03      342.01    N /usr/bin/gnome-mouse-properties
> >   759.90      388.58    N /usr/bin/gnome-appearance-properties
> >   937.90      508.47    N /usr/bin/gnome-control-center
> >  1109.75      587.57    N /usr/bin/gnome-keyboard-properties
> >  1399.05      758.16    N : oocalc
> >  1524.64      830.03    N : oodraw
> >  1684.31      900.03    N : ooimpress
> >  1874.04      993.91    N : oomath
> >  2115.12     1081.89    N : ooweb
> >  2369.02     1161.99    N : oowriter
> 
> Thanks this great effort!
> I definitely agree this patch sould be merge to -mm asap.
> 
> 	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thank you :)

To be complete, here are the free numbers at the end of the tests:

before patch:
                             total       used       free     shared    buffers     cached
                Mem:           474        467          7          0          0        236
                -/+ buffers/cache:        230        243
                Swap:         1023        418        605

after patch
                             total       used       free     shared    buffers     cached
                Mem:           474        457         16          0          0        236
                -/+ buffers/cache:        221        253
                Swap:         1023        404        619

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
