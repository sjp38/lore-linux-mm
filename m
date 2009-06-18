Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C86066B0055
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:12:49 -0400 (EDT)
Date: Thu, 18 Jun 2009 15:09:34 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090618130934.GA3070@cmpxchg.org>
References: <20090609190128.GA1785@cmpxchg.org> <20090611143122.108468f1.kamezawa.hiroyu@jp.fujitsu.com> <20090617224149.GA16104@cmpxchg.org> <20090618092947.GA846@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090618092947.GA846@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.org.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 18, 2009 at 05:29:47PM +0800, Wu Fengguang wrote:
> Johannes,
> 
> On Thu, Jun 18, 2009 at 06:41:49AM +0800, Johannes Weiner wrote:
> > On Thu, Jun 11, 2009 at 02:31:22PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 9 Jun 2009 21:01:28 +0200
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > [resend with lists cc'd, sorry]
> > > > 
> > > > +static int swap_readahead_ptes(struct mm_struct *mm,
> 
> I suspect the previous unfavorable results are due to comparing things
> with/without the drm vmalloc patch. So I spent one day redo the whole
> comparisons. The swap readahead patch shows neither big improvements
> nor big degradations this time.

Thanks again!  Nice.  So according to this, vswapra doesn't increase
other IO latency (much) but boosts ongoing swap loads (quite some) (as
qsbench showed).  Is that a result or what! :)

I will see how the tests described in the other mail work out.

> Base kernel is 2.6.30-rc8-mm1 with drm vmalloc patch.
> 
> a) base kernel
> b) base kernel + VM_EXEC protection
> c) base kernel + VM_EXEC protection + swap readahead
> 
>      (a)         (b)         (c)
>     0.02        0.02        0.01    N xeyes
>     0.78        0.92        0.77    N firefox
>     2.03        2.20        1.97    N nautilus
>     3.27        3.35        3.39    N nautilus --browser
>     5.10        5.28        4.99    N gthumb
>     6.74        7.06        6.64    N gedit
>     8.70        8.82        8.47    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
>    11.05       10.95       10.94    N
>    13.03       12.72       12.79    N xterm
>    15.46       15.09       15.10    N mlterm
>    18.05       17.31       17.51    N gnome-terminal
>    20.59       19.90       19.98    N urxvt
>    23.45       22.82       22.67    N
>    25.74       25.16       24.96    N gnome-system-monitor
>    28.87       27.53       27.89    N gnome-help
>    32.37       31.17       31.89    N gnome-dictionary
>    36.60       35.18       35.16    N
>    39.76       38.04       37.64    N /usr/games/sol
>    43.05       42.17       40.33    N /usr/games/gnometris
>    47.70       47.08       43.48    N /usr/games/gnect
>    51.64       50.46       47.24    N /usr/games/gtali
>    56.26       54.58       50.83    N /usr/games/iagno
>    60.36       58.01       55.15    N /usr/games/gnotravex
>    65.79       62.92       59.28    N /usr/games/mahjongg
>    71.59       67.36       65.95    N /usr/games/gnome-sudoku
>    78.57       72.32       72.60    N /usr/games/glines
>    84.25       80.03       77.42    N /usr/games/glchess
>    90.65       88.11       83.66    N /usr/games/gnomine
>    97.75       95.13       89.38    N /usr/games/gnotski
>   102.99      101.59       95.05    N /usr/games/gnibbles
>   110.68      112.05      109.40    N /usr/games/gnobots2
>   117.23      121.58      120.05    N /usr/games/blackjack
>   125.15      133.59      130.91    N /usr/games/same-gnome
>   134.05      151.99      148.91    N
>   142.57      162.67      165.00    N /usr/bin/gnome-window-properties
>   156.29      174.54      183.84    N /usr/bin/gnome-default-applications-properties
>   168.37      190.38      200.99    N /usr/bin/gnome-at-properties
>   184.80      209.41      230.82    N /usr/bin/gnome-typing-monitor
>   202.05      226.52      250.02    N /usr/bin/gnome-at-visual
>   217.60      243.76      272.91    N /usr/bin/gnome-sound-properties
>   239.78      266.47      308.74    N /usr/bin/gnome-at-mobility
>   255.23      285.42      338.51    N /usr/bin/gnome-keybinding-properties
>   276.85      314.84      374.64    N /usr/bin/gnome-about-me
>   308.51      355.95      419.78    N /usr/bin/gnome-display-properties
>   341.27      401.22      463.55    N /usr/bin/gnome-network-preferences
>   393.42      451.27      517.24    N /usr/bin/gnome-mouse-properties
>   438.48      510.54      574.64    N /usr/bin/gnome-appearance-properties
>   616.09      671.44      760.49    N /usr/bin/gnome-control-center
>   879.69      879.45      918.87    N /usr/bin/gnome-keyboard-properties
>  1159.47     1076.29     1071.65    N
>  1701.82     1240.47     1280.77    N : oocalc
>  1921.14     1446.95     1451.82    N : oodraw
>  2262.40     1572.95     1698.37    N : ooimpress
>  2703.88     1714.53     1841.89    N : oomath
>  3464.54     1864.99     1983.96    N : ooweb
>  4040.91     2079.96     2185.53    N : oowriter
>  4668.16     2330.24     2365.17    N
> 
>  Thanks,
>  Fengguang
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
