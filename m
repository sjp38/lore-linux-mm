Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id D36746B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:26:31 -0500 (EST)
Date: Tue, 27 Nov 2012 16:26:17 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/8] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
Message-ID: <20121127212617.GA13890@phenom.dumpdata.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
 <1352919432-9699-3-git-send-email-konrad.wilk@oracle.com>
 <20121116151619.aa60acff.akpm@linux-foundation.org>
 <CAA_GA1crg1ngNx2MAv-fJbgKYqSKmkapZHq=8F4QcNgFja1A-w@mail.gmail.com>
 <20121119142516.b2936a7c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121119142516.b2936a7c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, mgorman@suse.de, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com

On Mon, Nov 19, 2012 at 02:25:16PM -0800, Andrew Morton wrote:
> On Mon, 19 Nov 2012 08:53:46 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
> 
> > On Sat, Nov 17, 2012 at 7:16 AM, Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > > On Wed, 14 Nov 2012 13:57:06 -0500
> > > Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
> > >
> > >> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > >>
> > >> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> > >> built/loaded as modules rather than built-in and enabled by a boot parameter,
> > >> this patch provides "lazy initialization", allowing backends to register to
> > >> frontswap even after swapon was run. Before a backend registers all calls
> > >> to init are recorded and the creation of tmem_pools delayed until a backend
> > >> registers or until a frontswap put is attempted.
> > >>
> > >>
> > >> ...
> > >>
> > >> --- a/mm/frontswap.c
> > >> +++ b/mm/frontswap.c
> > >> @@ -80,6 +80,18 @@ static inline void inc_frontswap_succ_stores(void) { }
> > >>  static inline void inc_frontswap_failed_stores(void) { }
> > >>  static inline void inc_frontswap_invalidates(void) { }
> > >>  #endif
> > >> +
> > >> +/*
> > >> + * When no backend is registered all calls to init are registered and
> > >
> > > What is "init"?  Spell it out fully, please.
> > >
> > 
> > I think it's frontswap_init().
> > swapon will call frontswap_init() and in it we need to call init
> > function of backends with some parameters
> > like swap_type.
> 
> Well, let's improve that comment please.
> 
> > >> + * remembered but fail to create tmem_pools. When a backend registers with
> > >> + * frontswap the previous calls to init are executed to create tmem_pools
> > >> + * and set the respective poolids.
> > >
> > > Again, seems really hacky.  Why can't we just change callers so they
> > > call things in the correct order?
> > >
> > 
> > I don't think so, because it asynchronous.
> > 
> > The original idea was to make backends like zcache/tmem modularization.
> > So that it's more convenient and flexible to use and testing.
> > 
> > But currently callers like swapon only invoke frontswap_init() once,
> > it fail if backend not registered.
> > We have no way to notify swap to call frontswap_init() again when
> > backend registered in some random time
> >  in future.
> 
> We could add such a way?

Hey Andrew,

Sorry for the late email. Right at as you posted your questions I went on vacation :-)
Let me respond to your email and rebase the patch per your comments/ideas this week.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
