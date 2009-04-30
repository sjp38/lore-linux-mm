Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2DCB06B0047
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 21:00:45 -0400 (EDT)
Date: Thu, 30 Apr 2009 09:00:20 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090430010019.GA5708@localhost>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <1240940961.938.451.camel@calx> <20090429080553.GA14838@localhost> <1241032436.938.1519.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1241032436.938.1519.camel@calx>
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 30, 2009 at 03:13:56AM +0800, Matt Mackall wrote:
> On Wed, 2009-04-29 at 16:05 +0800, Wu Fengguang wrote:
> > On Wed, Apr 29, 2009 at 01:49:21AM +0800, Matt Mackall wrote:
> > > On Tue, 2009-04-28 at 09:09 +0800, Wu Fengguang wrote:
> > > > plain text document attachment (kpageflags-extending.patch)
> > > > Export 9 page flags in /proc/kpageflags, and 8 more for kernel developers.
> > > 
> > > My only concern with this patch is it knows a bit too much about SLUB
> > > internals (and perhaps not enough about SLOB, which also overloads
> > > flags). 
> > 
> > Yup. PG_private=PG_slob_free is not masked because SLOB actually does
> > not set PG_slab at all. I wonder if it's safe to do this change:
> > 
> >         /* SLOB */
> > -       PG_slob_page = PG_active,
> > +       PG_slob_page = PG_slab,
> >         PG_slob_free = PG_private,
> 
> Yep.

OK. I'll do it - for consistency.

> > In the page-types output:
> > 
> >          flags  page-count       MB  symbolic-flags                     long-symbolic-flags
> > 0x000800000040        7113       27  ______A_________________P____      active,private
> > 0x000000000040          66        0  ______A______________________      active
> > 
> > The above two lines are obviously for SLOB pages.  It indicates lots of
> > free SLOB pages. So my question is:
> 
> Free here just means partially allocated.

Yes, I realized this when lying in bed ;-)

> > - Do you have other means to get the nr_free_slobs info? (I found none in the code)
> > or
> > - Will exporting the SL*B overloaded flags going to help?
> 
> Yes, it's useful.

Thank you. SLUB/SLOB overload different page flags, so it's possible
for user space tools to restore their real meanings - ugly but useful.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
