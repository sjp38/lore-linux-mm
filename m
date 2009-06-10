Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AF8976B005C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 05:58:24 -0400 (EDT)
Date: Wed, 10 Jun 2009 17:59:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090610095950.GA514@localhost>
References: <20090609190128.GA1785@cmpxchg.org> <20090609193702.GA2017@cmpxchg.org> <20090610050342.GA8867@localhost> <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1244626976.13761.11593.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 05:42:56PM +0800, Peter Zijlstra wrote:
> On Wed, 2009-06-10 at 16:56 +0800, Wu Fengguang wrote:
> > 
> > Yes it worked!  But then I run into page allocation failures:
> > 
> > [  340.639803] Xorg: page allocation failure. order:4, mode:0x40d0
> > [  340.645744] Pid: 3258, comm: Xorg Not tainted 2.6.30-rc8-mm1 #303
> > [  340.651839] Call Trace:
> > [  340.654289]  [<ffffffff810c8204>] __alloc_pages_nodemask+0x344/0x6c0
> > [  340.660645]  [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
> > [  340.666472]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
> > [  340.671786]  [<ffffffffa014bf9f>] ? i915_gem_execbuffer+0x17f/0x11e0 [i915]
> > [  340.678746]  [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
> 
> Jesse Barnes had a patch to add a vmalloc fallback to those largish kms
> allocs.
> 
> But order-4 allocs failing isn't really strange, but it might indicate
> this patch fragments stuff sooner, although I've seen these particular
> failues before.

Thanks for the tip. Where is it? I'd like to try it out :)

Despite of the xorg failures, the test was able to complete with the
listed timing. The numbers are the time each program is able to start:

  before       after
    0.02        0.01    N xeyes
    0.76        0.68    N firefox
    1.88        1.89    N nautilus
    3.17        3.25    N nautilus --browser
    4.89        4.98    N gthumb
    6.47        6.79    N gedit
    8.16        8.56    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
   12.55       12.61    N xterm
   14.57       14.99    N mlterm
   17.06       17.16    N gnome-terminal
   18.90       19.60    N urxvt
   23.48       24.26    N gnome-system-monitor
   26.52       27.13    N gnome-help
   29.65       30.29    N gnome-dictionary
   36.12       36.93    N /usr/games/sol
   39.27       39.21    N /usr/games/gnometris
   42.56       43.61    N /usr/games/gnect
   47.03       47.40    N /usr/games/gtali
   52.05       51.41    N /usr/games/iagno
   55.42       56.21    N /usr/games/gnotravex
   61.47       60.58    N /usr/games/mahjongg
   67.11       64.68    N /usr/games/gnome-sudoku
   75.15       72.42    N /usr/games/glines
   79.70       78.61    N /usr/games/glchess
   88.48       87.01    N /usr/games/gnomine
   96.51       95.03    N /usr/games/gnotski
  102.19      100.50    N /usr/games/gnibbles
  114.93      108.97    N /usr/games/gnobots2
  125.02      120.09    N /usr/games/blackjack
  135.11      134.39    N /usr/games/same-gnome
  154.50      159.99    N /usr/bin/gnome-window-properties
  162.09      176.04    N /usr/bin/gnome-default-applications-properties
  173.29      197.12    N /usr/bin/gnome-at-properties
  188.21      221.15    N /usr/bin/gnome-typing-monitor
  199.93      249.38    N /usr/bin/gnome-at-visual
  206.95      272.87    N /usr/bin/gnome-sound-properties
  224.49      302.03    N /usr/bin/gnome-at-mobility
  234.11      325.73    N /usr/bin/gnome-keybinding-properties
  248.59      358.64    N /usr/bin/gnome-about-me
  276.27      402.30    N /usr/bin/gnome-display-properties
  304.39      439.35    N /usr/bin/gnome-network-preferences
  342.01      482.78    N /usr/bin/gnome-mouse-properties
  388.58      528.54    N /usr/bin/gnome-appearance-properties
  508.47      653.12    N /usr/bin/gnome-control-center
  587.57      769.65    N /usr/bin/gnome-keyboard-properties
  758.16     1021.65    N : oocalc
  830.03     1124.14    N : oodraw
  900.03     1246.52    N : ooimpress
  993.91     1370.35    N : oomath
 1081.89     1478.34    N : ooweb
 1161.99     1595.85    N : oowriter

It's slower with the patch. Maybe we shall give it another run with
the vmalloc patch.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
