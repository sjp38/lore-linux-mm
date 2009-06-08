Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F8F06B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 02:46:02 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n587pwUa009658
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Jun 2009 16:51:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B65845DE53
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 16:51:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BF7845DE51
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 16:51:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 282F01DB803F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 16:51:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A1C371DB805D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 16:51:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class citizen
In-Reply-To: <20090608073944.GA12431@localhost>
References: <87pre4nhqf.fsf@basil.nowhere.org> <20090608073944.GA12431@localhost>
Message-Id: <20090608164611.4385.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Jun 2009 16:51:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Wed, May 20, 2009 at 07:20:24PM +0800, Andi Kleen wrote:
> > One scenario that might be useful to test is what happens when some very large
> > processes, all mapped and executable exceed memory and fight each other
> > for the working set. Do you have regressions then compared to without
> > the patches?
> 
> I managed to carry out some stress tests for memory tight desktops.
> The outcome is encouraging: clock time and major faults are reduced
> by 50%, and pswpin numbers are reduced to ~1/3.
> 
> Here is the test scenario.
> - nfsroot gnome desktop with 512M physical memory
> - run some programs, and switch between the existing windows after
>   starting each new program.
> 
> The progress timing (seconds) is:
> 
>   before       after    programs
>     0.02        0.02    N xeyes
>     0.75        0.76    N firefox
>     2.02        1.88    N nautilus
>     3.36        3.17    N nautilus --browser
>     5.26        4.89    N gthumb
>     7.12        6.47    N gedit
>     9.22        8.16    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
>    13.58       12.55    N xterm
>    15.87       14.57    N mlterm
>    18.63       17.06    N gnome-terminal
>    21.16       18.90    N urxvt
>    26.24       23.48    N gnome-system-monitor
>    28.72       26.52    N gnome-help
>    32.15       29.65    N gnome-dictionary
>    39.66       36.12    N /usr/games/sol
>    43.16       39.27    N /usr/games/gnometris
>    48.65       42.56    N /usr/games/gnect
>    53.31       47.03    N /usr/games/gtali
>    58.60       52.05    N /usr/games/iagno
>    65.77       55.42    N /usr/games/gnotravex
>    70.76       61.47    N /usr/games/mahjongg
>    76.15       67.11    N /usr/games/gnome-sudoku
>    86.32       75.15    N /usr/games/glines
>    92.21       79.70    N /usr/games/glchess
>   103.79       88.48    N /usr/games/gnomine
>   113.84       96.51    N /usr/games/gnotski
>   124.40      102.19    N /usr/games/gnibbles
>   137.41      114.93    N /usr/games/gnobots2
>   155.53      125.02    N /usr/games/blackjack
>   179.85      135.11    N /usr/games/same-gnome
>   224.49      154.50    N /usr/bin/gnome-window-properties
>   248.44      162.09    N /usr/bin/gnome-default-applications-properties
>   282.62      173.29    N /usr/bin/gnome-at-properties
>   323.72      188.21    N /usr/bin/gnome-typing-monitor
>   363.99      199.93    N /usr/bin/gnome-at-visual
>   394.21      206.95    N /usr/bin/gnome-sound-properties
>   435.14      224.49    N /usr/bin/gnome-at-mobility
>   463.05      234.11    N /usr/bin/gnome-keybinding-properties
>   503.75      248.59    N /usr/bin/gnome-about-me
>   554.00      276.27    N /usr/bin/gnome-display-properties
>   615.48      304.39    N /usr/bin/gnome-network-preferences
>   693.03      342.01    N /usr/bin/gnome-mouse-properties
>   759.90      388.58    N /usr/bin/gnome-appearance-properties
>   937.90      508.47    N /usr/bin/gnome-control-center
>  1109.75      587.57    N /usr/bin/gnome-keyboard-properties
>  1399.05      758.16    N : oocalc
>  1524.64      830.03    N : oodraw
>  1684.31      900.03    N : ooimpress
>  1874.04      993.91    N : oomath
>  2115.12     1081.89    N : ooweb
>  2369.02     1161.99    N : oowriter

Thanks this great effort!
I definitely agree this patch sould be merge to -mm asap.

	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
