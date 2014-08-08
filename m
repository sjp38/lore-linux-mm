Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7423F6B0036
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:05:34 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id k15so6138624qaq.41
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 15:05:34 -0700 (PDT)
Received: from relay.variantweb.net ([104.131.199.242])
        by mx.google.com with ESMTP id 66si11829424qgg.117.2014.08.08.15.05.33
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 15:05:33 -0700 (PDT)
Received: from mail (unknown [10.42.10.20])
	by relay.variantweb.net (Postfix) with ESMTP id E1B72100ED7
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 18:05:30 -0400 (EDT)
Date: Fri, 8 Aug 2014 17:05:28 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH] mm/zpool: use prefixed module loading
Message-ID: <20140808220528.GA32510@cerebellum.variantweb.net>
References: <20140808075316.GA21919@www.outflux.net>
 <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONBNEg7kzUtwKihQuAU48MNh5NjhZcWoOxe-1-vgWqSLiw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Aug 08, 2014 at 01:11:55PM -0400, Dan Streetman wrote:
> On Fri, Aug 8, 2014 at 3:53 AM, Kees Cook <keescook@chromium.org> wrote:
> > To avoid potential format string expansion via module parameters,
> > do not use the zpool type directly in request_module() without a
> > format string. Additionally, to avoid arbitrary modules being loaded
> > via zpool API (e.g. via the zswap_zpool_type module parameter) add a
> > "zpool-" prefix to the requested module, as well as module aliases for
> > the existing zpool types (zbud and zsmalloc).
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  mm/zbud.c     | 1 +
> >  mm/zpool.c    | 2 +-
> >  mm/zsmalloc.c | 1 +
> >  3 files changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/zbud.c b/mm/zbud.c
> > index a05790b1915e..aa74f7addab1 100644
> > --- a/mm/zbud.c
> > +++ b/mm/zbud.c
> > @@ -619,3 +619,4 @@ module_exit(exit_zbud);
> >  MODULE_LICENSE("GPL");
> >  MODULE_AUTHOR("Seth Jennings <sjenning@linux.vnet.ibm.com>");
> >  MODULE_DESCRIPTION("Buddy Allocator for Compressed Pages");
> > +MODULE_ALIAS("zpool-zbud");
> 
> If we keep this, I'd recommend putting this inside the #ifdef
> CONFIG_ZPOOL section, to keep all the zpool stuff together in zbud and
> zsmalloc.
> 
> > diff --git a/mm/zpool.c b/mm/zpool.c
> > index e40612a1df00..739cdf0d183a 100644
> > --- a/mm/zpool.c
> > +++ b/mm/zpool.c
> > @@ -150,7 +150,7 @@ struct zpool *zpool_create_pool(char *type, gfp_t gfp, struct zpool_ops *ops)
> >         driver = zpool_get_driver(type);
> >
> >         if (!driver) {
> > -               request_module(type);
> > +               request_module("zpool-%s", type);
> 
> I agree with a change of (type) to ("%s", type), but what's the need
> to prefix "zpool-"?  Anyone who has access to modify the
> zswap_zpool_type parameter is already root and can just as easily load
> any module they want.  Additionally, the zswap_compressor parameter
> also runs through request_module() (in crypto/api.c) and could be used
> to load any kernel module.
> 
> I'd prefer to leave out the "zpool-" prefix unless there is a specific
> reason to include it.

I think I agree with this.  Having the zpool- prefix makes it to where
the would-be exploit couldn't load an arbitrary module; just those with a
zpool- prefix.  But then again, the exploit would need root privileges
to do any of this stuff and if it has that, it can just directly
load module so... yeah.

Seth

> 
> >                 driver = zpool_get_driver(type);
> >         }
> >
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 4e2fc83cb394..36af729eb3f6 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1199,3 +1199,4 @@ module_exit(zs_exit);
> >
> >  MODULE_LICENSE("Dual BSD/GPL");
> >  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> > +MODULE_ALIAS("zpool-zsmalloc");
> > --
> > 1.9.1
> >
> >
> > --
> > Kees Cook
> > Chrome OS Security
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
