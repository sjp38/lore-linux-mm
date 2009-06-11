Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 292106B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:19:46 -0400 (EDT)
Date: Thu, 11 Jun 2009 12:17:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090611101741.GA1974@cmpxchg.org>
References: <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611052228.GA20100@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 01:22:28PM +0800, Wu Fengguang wrote:
> Unfortunately, after fixing it up the swap readahead patch still performs slow
> (even worse this time):

Thanks for doing the tests.  Do you know if the time difference comes
from IO or CPU time?

Because one reason I could think of is that the original code walks
the readaround window in two directions, starting from the target each
time but immediately stops when it encounters a hole where the new
code just skips holes but doesn't abort readaround and thus might
indeed read more slots.

I have an old patch flying around that changed the physical ra code to
use a bitmap that is able to represent holes.  If the increased time
is waiting for IO, I would be interested if that patch has the same
negative impact.

	Hannes

>   before       after
>     0.02        0.01    N xeyes
>     0.76        0.89    N firefox
>     1.88        2.21    N nautilus
>     3.17        3.41    N nautilus --browser
>     4.89        5.20    N gthumb
>     6.47        7.02    N gedit
>     8.16        8.90    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
>    12.55       13.36    N xterm
>    14.57       15.57    N mlterm
>    17.06       18.11    N gnome-terminal
>    18.90       20.37    N urxvt
>    23.48       25.26    N gnome-system-monitor
>    26.52       27.84    N gnome-help
>    29.65       31.93    N gnome-dictionary
>    36.12       37.74    N /usr/games/sol
>    39.27       40.61    N /usr/games/gnometris
>    42.56       43.75    N /usr/games/gnect
>    47.03       47.85    N /usr/games/gtali
>    52.05       52.31    N /usr/games/iagno
>    55.42       55.61    N /usr/games/gnotravex
>    61.47       61.38    N /usr/games/mahjongg
>    67.11       65.07    N /usr/games/gnome-sudoku
>    75.15       70.36    N /usr/games/glines
>    79.70       74.96    N /usr/games/glchess
>    88.48       80.82    N /usr/games/gnomine
>    96.51       88.30    N /usr/games/gnotski
>   102.19       94.26    N /usr/games/gnibbles
>   114.93      102.02    N /usr/games/gnobots2
>   125.02      115.23    N /usr/games/blackjack
>   135.11      128.41    N /usr/games/same-gnome
>   154.50      153.05    N /usr/bin/gnome-window-properties
>   162.09      169.53    N /usr/bin/gnome-default-applications-properties
>   173.29      190.32    N /usr/bin/gnome-at-properties
>   188.21      212.70    N /usr/bin/gnome-typing-monitor
>   199.93      236.18    N /usr/bin/gnome-at-visual
>   206.95      261.88    N /usr/bin/gnome-sound-properties
>   224.49      304.66    N /usr/bin/gnome-at-mobility
>   234.11      336.73    N /usr/bin/gnome-keybinding-properties
>   248.59      374.03    N /usr/bin/gnome-about-me
>   276.27      433.86    N /usr/bin/gnome-display-properties
>   304.39      488.43    N /usr/bin/gnome-network-preferences
>   342.01      686.68    N /usr/bin/gnome-mouse-properties
>   388.58      769.21    N /usr/bin/gnome-appearance-properties
>   508.47      933.35    N /usr/bin/gnome-control-center
>   587.57     1193.27    N /usr/bin/gnome-keyboard-properties

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
