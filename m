Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5F79C6B0008
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:55:50 -0500 (EST)
Date: Wed, 30 Jan 2013 10:55:29 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/8] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
Message-ID: <20130130155520.GA1272@konrad-lan.dumpdata.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
 <1352919432-9699-3-git-send-email-konrad.wilk@oracle.com>
 <20121116151619.aa60acff.akpm@linux-foundation.org>
 <CAA_GA1crg1ngNx2MAv-fJbgKYqSKmkapZHq=8F4QcNgFja1A-w@mail.gmail.com>
 <20121119142516.b2936a7c.akpm@linux-foundation.org>
 <20121127212617.GA13890@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121127212617.GA13890@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, mgorman@suse.de, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com

On Tue, Nov 27, 2012 at 04:26:17PM -0500, Konrad Rzeszutek Wilk wrote:
> On Mon, Nov 19, 2012 at 02:25:16PM -0800, Andrew Morton wrote:
> > On Mon, 19 Nov 2012 08:53:46 +0800
> > Bob Liu <lliubbo@gmail.com> wrote:
> > 
> > > On Sat, Nov 17, 2012 at 7:16 AM, Andrew Morton
> > > <akpm@linux-foundation.org> wrote:
> > > > On Wed, 14 Nov 2012 13:57:06 -0500
> > > > Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
> > > >
> > > >> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > > >>
> > > >> With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> > > >> built/loaded as modules rather than built-in and enabled by a boot parameter,
> > > >> this patch provides "lazy initialization", allowing backends to register to
> > > >> frontswap even after swapon was run. Before a backend registers all calls
> > > >> to init are recorded and the creation of tmem_pools delayed until a backend
> > > >> registers or until a frontswap put is attempted.
> > > >>
> > > >>
> > > >> ...
> > > >>
> > > >> --- a/mm/frontswap.c
> > > >> +++ b/mm/frontswap.c
> > > >> @@ -80,6 +80,18 @@ static inline void inc_frontswap_succ_stores(void) { }
> > > >>  static inline void inc_frontswap_failed_stores(void) { }
> > > >>  static inline void inc_frontswap_invalidates(void) { }
> > > >>  #endif
> > > >> +
> > > >> +/*
> > > >> + * When no backend is registered all calls to init are registered and
> > > >
> > > > What is "init"?  Spell it out fully, please.
> > > >
> > > 
> > > I think it's frontswap_init().
> > > swapon will call frontswap_init() and in it we need to call init
> > > function of backends with some parameters
> > > like swap_type.
> > 
> > Well, let's improve that comment please.
> > 
> > > >> + * remembered but fail to create tmem_pools. When a backend registers with
> > > >> + * frontswap the previous calls to init are executed to create tmem_pools
> > > >> + * and set the respective poolids.
> > > >
> > > > Again, seems really hacky.  Why can't we just change callers so they
> > > > call things in the correct order?
> > > >
> > > 
> > > I don't think so, because it asynchronous.
> > > 
> > > The original idea was to make backends like zcache/tmem modularization.
> > > So that it's more convenient and flexible to use and testing.
> > > 
> > > But currently callers like swapon only invoke frontswap_init() once,
> > > it fail if backend not registered.
> > > We have no way to notify swap to call frontswap_init() again when
> > > backend registered in some random time
> > >  in future.
> > 
> > We could add such a way?
> 
> Hey Andrew,
> 
> Sorry for the late email. Right at as you posted your questions I went on vacation :-)
> Let me respond to your email and rebase the patch per your comments/ideas this week.

"This week" turned rather into a large couple of months :-(

Please see inline patch that tries to address the comments you made.

In regards to making swap and frontswap be synchronous and support
module loading - that is a tricky thing. If we wanted the swap system to
call the 'frontswap_init' outside of 'swapon' call, one way to do this would
be to have a notifier chain - which the swap API would subscribe too. The
frontswap API upon being called frontswap_register_ops (so a backend module
has loaded) could kick of the notifier and the swap API would immediately call
frontswap_init.

Something like this:

	swap API starts, makes a call to:
		register_frontswap_notifier(&swap_fnc), wherein

		.notifier_call = swap_notifier just does:

		swap_notifier(void) {

		struct swap_info_struct *p = NULL;
		spin_lock(&swap_lock);                                                  
        	for (type = swap_list.head; type >= 0; type = swap_info[type]->next) { 
                	p = swap_info[type]; 
			frontswap_init(p->type);
		};
		spin_unlock(&swap_lock);
		}

	swapon /dev/XX , makes a call to frontswap_init. Frontswap_init
		ignores it since there are no backend.

	I/Os on the swap device, the calls to frontswap_store/load are
		all returning as there are no backend.

	modprobe zcache -> calls frontswap_register_ops().
		frontswap_register_ops-> kicks the notifier.


As opposed to what this patchset does it by not exposing a notifier but
just queing up which p->type's to call (by having a atomic bitmap) when a
backend has registered.
In this patchset we end up with:

	swap API inits..

	swapon /dev/XX, makes a call to frontswap_init. Frontswap_init
		ignores it since there are no backend, but saves away
		the proper parameters

	I/Os on the swap device, the calls to frontswap_store/load are
		all returning fast as there are no backend.

	modprobe zcache -> calls frontswap_register_ops().
		processes the frontswap_init on the queued up swap_file.
		enables backend_registered, and all I/Os now flow to the
		backend.

The difference here is that we would not queue anymore. My thinking is
go with the queue system, then also implement proper unloading mechanism
(by perhaps have a dummy frontswap_ops or an atomic or static_key
gates to inhibit further frontswap API calls), drain all the swap pages
from the backend to the "regular" swap disk (by using Seth's patchset)
and then allowing the backend to unload.

And then if we decide that bitmap queue is not appropiate (b/c the
swap system can now have more than 32 entries), then revisit this?
