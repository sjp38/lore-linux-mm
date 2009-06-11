Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B2F9B6B004D
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 01:21:53 -0400 (EDT)
Date: Thu, 11 Jun 2009 13:22:28 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090611052228.GA20100@localhost>
References: <20090610050342.GA8867@localhost> <20090610074508.GA1960@cmpxchg.org> <20090610081132.GA27519@localhost> <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610102516.08f7300f@jbarnes-x200>
Sender: owner-linux-mm@kvack.org
To: "Barnes, Jesse" <jesse.barnes@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 11, 2009 at 01:25:16AM +0800, Barnes, Jesse wrote:
> On Wed, 10 Jun 2009 04:32:14 -0700
> "Wu, Fengguang" <fengguang.wu@intel.com> wrote:
> 
> > On Wed, Jun 10, 2009 at 06:05:14PM +0800, Peter Zijlstra wrote:
> > > On Wed, 2009-06-10 at 17:59 +0800, Wu Fengguang wrote:
> > > > On Wed, Jun 10, 2009 at 05:42:56PM +0800, Peter Zijlstra wrote:
> > > > > On Wed, 2009-06-10 at 16:56 +0800, Wu Fengguang wrote:
> > > > > > 
> > > > > > Yes it worked!  But then I run into page allocation failures:
> > > > > > 
> > > > > > [  340.639803] Xorg: page allocation failure. order:4,
> > > > > > mode:0x40d0 [  340.645744] Pid: 3258, comm: Xorg Not tainted
> > > > > > 2.6.30-rc8-mm1 #303 [  340.651839] Call Trace:
> > > > > > [  340.654289]  [<ffffffff810c8204>]
> > > > > > __alloc_pages_nodemask+0x344/0x6c0 [  340.660645]
> > > > > > [<ffffffff810f7489>] __slab_alloc_page+0xb9/0x3b0
> > > > > > [  340.666472]  [<ffffffff810f8608>] __kmalloc+0x198/0x250
> > > > > > [  340.671786]  [<ffffffffa014bf9f>] ?
> > > > > > i915_gem_execbuffer+0x17f/0x11e0 [i915] [  340.678746]
> > > > > > [<ffffffffa014bf9f>] i915_gem_execbuffer+0x17f/0x11e0 [i915]
> > > > > 
> > > > > Jesse Barnes had a patch to add a vmalloc fallback to those
> > > > > largish kms allocs.
> > > > > 
> > > > > But order-4 allocs failing isn't really strange, but it might
> > > > > indicate this patch fragments stuff sooner, although I've seen
> > > > > these particular failues before.
> > > > 
> > > > Thanks for the tip. Where is it? I'd like to try it out :)
> > > 
> > > commit 8e7d2b2c6ecd3c21a54b877eae3d5be48292e6b5
> > > Author: Jesse Barnes <jbarnes@virtuousgeek.org>
> > > Date:   Fri May 8 16:13:25 2009 -0700
> > > 
> > >     drm/i915: allocate large pointer arrays with vmalloc
> > 
> > Thanks! It is already in the -mm tree, but it missed on conversion :)
> > 
> > I'll retry with this patch tomorrow.
> > 
> > Thanks,
> > Fengguang
> > ---
> > 
> > diff --git a/drivers/gpu/drm/i915/i915_gem.c
> > b/drivers/gpu/drm/i915/i915_gem.c index 39f5c65..7132dbe 100644
> > --- a/drivers/gpu/drm/i915/i915_gem.c
> > +++ b/drivers/gpu/drm/i915/i915_gem.c
> > @@ -3230,8 +3230,8 @@ i915_gem_execbuffer(struct drm_device *dev,
> > void *data, }
> >  
> >  	if (args->num_cliprects != 0) {
> > -		cliprects = drm_calloc(args->num_cliprects,
> > sizeof(*cliprects),
> > -				       DRM_MEM_DRIVER);
> > +		cliprects = drm_calloc_large(args->num_cliprects,
> > +					     sizeof(*cliprects));
> >  		if (cliprects == NULL)
> >  			goto pre_mutex_err;
> >  
> > @@ -3474,8 +3474,7 @@ err:
> >  pre_mutex_err:
> >  	drm_free_large(object_list);
> >  	drm_free_large(exec_list);
> > -	drm_free(cliprects, sizeof(*cliprects) * args->num_cliprects,
> > -		 DRM_MEM_DRIVER);
> > +	drm_free_large(cliprects);
> >  
> >  	return ret;
> >  }
> 
> Kristian posted a fix to my drm_calloc_large function as well; one of
> the size checks in drm_calloc_large (the one which decides whether to
> use kmalloc or vmalloc) was just checking size instead of size * num,
> so you may be hitting that.

Yes, it is.

Unfortunately, after fixing it up the swap readahead patch still performs slow
(even worse this time):

  before       after
    0.02        0.01    N xeyes
    0.76        0.89    N firefox
    1.88        2.21    N nautilus
    3.17        3.41    N nautilus --browser
    4.89        5.20    N gthumb
    6.47        7.02    N gedit
    8.16        8.90    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
   12.55       13.36    N xterm
   14.57       15.57    N mlterm
   17.06       18.11    N gnome-terminal
   18.90       20.37    N urxvt
   23.48       25.26    N gnome-system-monitor
   26.52       27.84    N gnome-help
   29.65       31.93    N gnome-dictionary
   36.12       37.74    N /usr/games/sol
   39.27       40.61    N /usr/games/gnometris
   42.56       43.75    N /usr/games/gnect
   47.03       47.85    N /usr/games/gtali
   52.05       52.31    N /usr/games/iagno
   55.42       55.61    N /usr/games/gnotravex
   61.47       61.38    N /usr/games/mahjongg
   67.11       65.07    N /usr/games/gnome-sudoku
   75.15       70.36    N /usr/games/glines
   79.70       74.96    N /usr/games/glchess
   88.48       80.82    N /usr/games/gnomine
   96.51       88.30    N /usr/games/gnotski
  102.19       94.26    N /usr/games/gnibbles
  114.93      102.02    N /usr/games/gnobots2
  125.02      115.23    N /usr/games/blackjack
  135.11      128.41    N /usr/games/same-gnome
  154.50      153.05    N /usr/bin/gnome-window-properties
  162.09      169.53    N /usr/bin/gnome-default-applications-properties
  173.29      190.32    N /usr/bin/gnome-at-properties
  188.21      212.70    N /usr/bin/gnome-typing-monitor
  199.93      236.18    N /usr/bin/gnome-at-visual
  206.95      261.88    N /usr/bin/gnome-sound-properties
  224.49      304.66    N /usr/bin/gnome-at-mobility
  234.11      336.73    N /usr/bin/gnome-keybinding-properties
  248.59      374.03    N /usr/bin/gnome-about-me
  276.27      433.86    N /usr/bin/gnome-display-properties
  304.39      488.43    N /usr/bin/gnome-network-preferences
  342.01      686.68    N /usr/bin/gnome-mouse-properties
  388.58      769.21    N /usr/bin/gnome-appearance-properties
  508.47      933.35    N /usr/bin/gnome-control-center
  587.57     1193.27    N /usr/bin/gnome-keyboard-properties
 [...]

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
