Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id D274C8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 04:53:22 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id y73-v6so199663ita.2
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 01:53:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor685942jaj.53.2018.09.27.01.53.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 01:53:21 -0700 (PDT)
MIME-Version: 1.0
References: <20180924101150.23349-1-brgl@bgdev.pl> <20180924101150.23349-4-brgl@bgdev.pl>
 <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
In-Reply-To: <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Thu, 27 Sep 2018 10:53:09 +0200
Message-ID: <CAMRc=McNoV6JA=ON71LByVn7e+mMDQW2-YrSMBOPDML2k=Z4bQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/4] devres: provide devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

czw., 27 wrz 2018 o 01:20 Kees Cook <keescook@chromium.org> napisa=C5=82(a)=
:
>
> On Mon, Sep 24, 2018 at 3:11 AM, Bartosz Golaszewski <brgl@bgdev.pl> wrot=
e:
> > Provide a resource managed version of kstrdup_const(). This variant
> > internally calls devm_kstrdup() on pointers that are outside of
> > .rodata section and returns the string as is otherwise.
> >
> > Also provide a corresponding version of devm_kfree().
> >
> > Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> > Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> > ---
> >  drivers/base/devres.c  | 38 ++++++++++++++++++++++++++++++++++++++
> >  include/linux/device.h |  3 +++
> >  2 files changed, 41 insertions(+)
> >
> > diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> > index 438c91a43508..48185d57bc5b 100644
> > --- a/drivers/base/devres.c
> > +++ b/drivers/base/devres.c
> > @@ -11,6 +11,8 @@
> >  #include <linux/slab.h>
> >  #include <linux/percpu.h>
> >
> > +#include <asm/sections.h>
> > +
> >  #include "base.h"
> >
> >  struct devres_node {
> > @@ -822,6 +824,28 @@ char *devm_kstrdup(struct device *dev, const char =
*s, gfp_t gfp)
> >  }
> >  EXPORT_SYMBOL_GPL(devm_kstrdup);
> >
> > +/**
> > + * devm_kstrdup_const - resource managed conditional string duplicatio=
n
> > + * @dev: device for which to duplicate the string
> > + * @s: the string to duplicate
> > + * @gfp: the GFP mask used in the kmalloc() call when allocating memor=
y
> > + *
> > + * Strings allocated by devm_kstrdup_const will be automatically freed=
 when
> > + * the associated device is detached.
> > + *
> > + * RETURNS:
> > + * Source string if it is in .rodata section otherwise it falls back t=
o
> > + * devm_kstrdup.
> > + */
> > +const char *devm_kstrdup_const(struct device *dev, const char *s, gfp_=
t gfp)
> > +{
> > +       if (is_kernel_rodata((unsigned long)s))
> > +               return s;
> > +
> > +       return devm_kstrdup(dev, s, gfp);
> > +}
> > +EXPORT_SYMBOL(devm_kstrdup_const);
> > +
> >  /**
> >   * devm_kvasprintf - Allocate resource managed space and format a stri=
ng
> >   *                  into that.
> > @@ -895,6 +919,20 @@ void devm_kfree(struct device *dev, const void *p)
> >  }
> >  EXPORT_SYMBOL_GPL(devm_kfree);
> >
> > +/**
> > + * devm_kfree_const - Resource managed conditional kfree
> > + * @dev: device this memory belongs to
> > + * @p: memory to free
> > + *
> > + * Function calls devm_kfree only if @p is not in .rodata section.
> > + */
> > +void devm_kfree_const(struct device *dev, const void *p)
> > +{
> > +       if (!is_kernel_rodata((unsigned long)p))
> > +               devm_kfree(dev, p);
> > +}
> > +EXPORT_SYMBOL(devm_kfree_const);
> > +
> >  /**
> >   * devm_kmemdup - Resource-managed kmemdup
> >   * @dev: Device this memory belongs to
> > diff --git a/include/linux/device.h b/include/linux/device.h
> > index 33f7cb271fbb..79ccc6eb0975 100644
> > --- a/include/linux/device.h
> > +++ b/include/linux/device.h
> > @@ -693,7 +693,10 @@ static inline void *devm_kcalloc(struct device *de=
v,
> >         return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
> >  }
> >  extern void devm_kfree(struct device *dev, const void *p);
> > +extern void devm_kfree_const(struct device *dev, const void *p);
>
> With devm_kfree and devm_kfree_const both taking "const", how are
> devm_kstrdup_const() and devm_kfree_const() going to be correctly
> paired at compile time? (i.e. I wasn't expecting the prototype change
> to devm_kfree())
>

I guess the same as with kfree() and kfree_const() which both take
const void * as argument - it's up to users to only use
devm_kfree_const() on resources allocated with devm_kstrdup_const().

Bart

> -Kees
>
> >  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp=
) __malloc;
> > +extern const char *devm_kstrdup_const(struct device *dev,
> > +                                     const char *s, gfp_t gfp);
> >  extern void *devm_kmemdup(struct device *dev, const void *src, size_t =
len,
> >                           gfp_t gfp);
> >
> > --
> > 2.18.0
> >
>
>
>
> --
> Kees Cook
> Pixel Security
