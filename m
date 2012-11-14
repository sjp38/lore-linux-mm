Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id AC0756B002B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 11:26:00 -0500 (EST)
Date: Wed, 14 Nov 2012 11:25:40 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
Message-ID: <20121114162540.GA28650@localhost.localdomain>
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com>
 <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com>
 <50915A5C.8000303@linux.vnet.ibm.com>
 <20121102182749.GB30100@konrad-lan.dumpdata.com>
 <CAA_GA1e3ACs8v5955S8xfSVomT3niq0_PfLO23QpBMR6OoB5UQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1e3ACs8v5955S8xfSVomT3niq0_PfLO23QpBMR6OoB5UQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

> On Sat, Nov 3, 2012 at 2:27 AM, Konrad Rzeszutek Wilk
> <konrad.wilk@oracle.com> wrote:
> > On Wed, Oct 31, 2012 at 12:05:32PM -0500, Seth Jennings wrote:
> >> On 10/31/2012 10:07 AM, Dan Magenheimer wrote:
> >> > With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> >> > built/loaded as modules rather than built-in and enabled by a boot parameter,
> >> > this patch provides "lazy initialization", allowing backends to register to
> >> > frontswap even after swapon was run. Before a backend registers all calls
> >> > to init are recorded and the creation of tmem_pools delayed until a backend
> >> > registers or until a frontswap put is attempted.
> >> >
> >> > Signed-off-by: Stefan Hengelein <ilendir@googlemail.com>
> >> > Signed-off-by: Florian Schmaus <fschmaus@gmail.com>
> >> > Signed-off-by: Andor Daam <andor.daam@googlemail.com>
> >> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> >> > ---
> >> >  include/linux/frontswap.h |    1 +
> >> >  mm/frontswap.c            |   70 +++++++++++++++++++++++++++++++++++++++-----
> >> >  2 files changed, 63 insertions(+), 8 deletions(-)
> >> >
> >> > diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
> >> > index 3044254..ef6ada6 100644
> >> > --- a/include/linux/frontswap.h
> >> > +++ b/include/linux/frontswap.h
> >> > @@ -23,6 +23,7 @@ extern void frontswap_writethrough(bool);
> >> >  extern void frontswap_tmem_exclusive_gets(bool);
> >> >
> >> >  extern void __frontswap_init(unsigned type);
> >> > +#define FRONTSWAP_HAS_LAZY_INIT
> >> >  extern int __frontswap_store(struct page *page);
> >> >  extern int __frontswap_load(struct page *page);
> >> >  extern void __frontswap_invalidate_page(unsigned, pgoff_t);
> >> > diff --git a/mm/frontswap.c b/mm/frontswap.c
> >> > index 2890e67..523a19b 100644
> >> > --- a/mm/frontswap.c
> >> > +++ b/mm/frontswap.c
> >> > @@ -80,6 +80,19 @@ static inline void inc_frontswap_succ_stores(void) { }
> >> >  static inline void inc_frontswap_failed_stores(void) { }
> >> >  static inline void inc_frontswap_invalidates(void) { }
> >> >  #endif
> >> > +
> >> > +/*
> >> > + * When no backend is registered all calls to init are registered and
> >> > + * remembered but fail to create tmem_pools. When a backend registers with
> >> > + * frontswap the previous calls to init are executed to create tmem_pools
> >> > + * and set the respective poolids.
> >> > + * While no backend is registered all "puts", "gets" and "flushes" are
> >> > + * ignored or fail.
> >> > + */
> >> > +#define MAX_INITIALIZABLE_SD 32
> >>
> >> MAX_INITIALIZABLE_SD should just be MAX_SWAPFILES
> >>
> >> > +static int sds[MAX_INITIALIZABLE_SD];
> >>
> >> Rather than store and array of enabled types indexed by type, why not
> >> an array of booleans indexed by type.  Or a bitfield if you really
> >> want to save space.
> >>
> >> > +static int backend_registered;
> >>
> >> (backend_registered) is equivalent to checking (frontswap_ops != NULL)
> >> right?

Kind of. frontswap_ops is not a pointer though so it would be more of
a frontswap_ops != dummy. Lets make another patch that makes this a
pointer and then rip out the backend_registered.
.. snip..
> >         if (sis->frontswap_map == NULL)
> >                 return;
> > -       frontswap_ops.init(type);
> > +       if (backend_registered) {
> > +               (*frontswap_ops.init)(type);
> > +               set_bit(type, sds);
> > +       }
> >  }
> 
> What about set bit if backend not registered and clear bit when invalidate.
> I think that looks more directly.
> Like:
> +       if (backend_registered) {
> +               BUG_ON(sis == NULL);
> +               if (sis->frontswap_map == NULL)
> +                       return;
> +               frontswap_ops.init(type);
> +       }
> +       else {
> +               BUG_ON(type > MAX_SWAPFILES);
> +                set_bit(type, sds);
> +       }

Good idea.
> 
> 
> >  EXPORT_SYMBOL(__frontswap_init);
> >
> > @@ -147,10 +169,20 @@ int __frontswap_store(struct page *page)
> >         struct swap_info_struct *sis = swap_info[type];
> >         pgoff_t offset = swp_offset(entry);
> >
> > +       if (!backend_registered) {
> > +               inc_frontswap_failed_stores();
> > +               return ret;
> > +       }
> > +
> >         BUG_ON(!PageLocked(page));
> >         BUG_ON(sis == NULL);
> >         if (frontswap_test(sis, offset))
> >                 dup = 1;
> > +       if (type < MAX_SWAPFILES && !test_bit(type, sds)) {
> > +               /* lazy init call to handle post-boot insmod backends*/
> > +               (*frontswap_ops.init)(type);
> > +               set_bit(type, sds);
> > +       }
> 
> Then rm this.

Right, b/c the frontswap_init takes care of initializing the backend.
And this does not get called _until_ backend_registered is set.

So we have to be extra careful to set backend_registered _after_
all the frontswap.init have been called.
> 
> >         ret = frontswap_ops.store(type, offset, page);
> >         if (ret == 0) {
> >                 frontswap_set(sis, offset);
> > @@ -186,6 +218,9 @@ int __frontswap_load(struct page *page)
> >         struct swap_info_struct *sis = swap_info[type];
> >         pgoff_t offset = swp_offset(entry);
> >
> > +       if (!backend_registered)
> > +               return ret;
> > +
> >         BUG_ON(!PageLocked(page));
> >         BUG_ON(sis == NULL);
> >         if (frontswap_test(sis, offset))
> > @@ -209,6 +244,9 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
> >  {
> >         struct swap_info_struct *sis = swap_info[type];
> >
> > +       if (!backend_registered)
> > +               return;
> > +
> 
> I'm not sure whether __frontswap_invalidate_page() will be called if
> backend not registered.

Yes.

User could do:

swapon /dev/sda3
swapoff /dev/sda3
modprobe zcache

> 
> >         BUG_ON(sis == NULL);
> >         if (frontswap_test(sis, offset)) {
> >                 frontswap_ops.invalidate_page(type, offset);
> > @@ -226,12 +264,16 @@ void __frontswap_invalidate_area(unsigned type)
> >  {
> >         struct swap_info_struct *sis = swap_info[type];
> >
> > -       BUG_ON(sis == NULL);
> > -       if (sis->frontswap_map == NULL)
> > -               return;
> > -       frontswap_ops.invalidate_area(type);
> > -       atomic_set(&sis->frontswap_pages, 0);
> > -       memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> > +       if (backend_registered) {
> > +               BUG_ON(sis == NULL);
> > +               if (sis->frontswap_map == NULL)
> > +                       return;
> > +               (*frontswap_ops.invalidate_area)(type);
> > +               atomic_set(&sis->frontswap_pages, 0);
> > +               memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> > +       } else {
> > +               bitmap_zero(sds, MAX_SWAPFILES);
> 
> Use clear_bit(type, sds) here;

Yikes. Yes. It actually could be unconditional too
> 
> > +       }
> >  }
> >  EXPORT_SYMBOL(__frontswap_invalidate_area);
> >
> > @@ -364,6 +406,9 @@ static int __init init_frontswap(void)
> >         debugfs_create_u64("invalidates", S_IRUGO,
> >                                 root, &frontswap_invalidates);
> >  #endif
> > +       bitmap_zero(sds, MAX_SWAPFILES);
> > +
> > +       frontswap_enabled = 1;
> 
> We'd  better  init backend_registered = false also.

I think we are OK. The .bss is set to zero so that means
backend_registered is by default zero.

The end result would look like this (I had not compiled tested it yet):
