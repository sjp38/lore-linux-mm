Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF698E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 19:20:46 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id c6-v6so412004ybm.10
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 16:20:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15-v6sor149860ybs.149.2018.09.26.16.20.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Sep 2018 16:20:45 -0700 (PDT)
Received: from mail-yw1-f49.google.com (mail-yw1-f49.google.com. [209.85.161.49])
        by smtp.gmail.com with ESMTPSA id 129-v6sm140567ywm.87.2018.09.26.16.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 16:20:44 -0700 (PDT)
Received: by mail-yw1-f49.google.com with SMTP id v1-v6so314607ywv.6
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 16:20:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180924101150.23349-4-brgl@bgdev.pl>
References: <20180924101150.23349-1-brgl@bgdev.pl> <20180924101150.23349-4-brgl@bgdev.pl>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 26 Sep 2018 16:13:39 -0700
Message-ID: <CAGXu5j+GGbRyQDU=TKKXb9EbRSczEJYqjTaDSsmeBeQn3Qdu_g@mail.gmail.com>
Subject: Re: [PATCH v3 3/4] devres: provide devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 24, 2018 at 3:11 AM, Bartosz Golaszewski <brgl@bgdev.pl> wrote:
> Provide a resource managed version of kstrdup_const(). This variant
> internally calls devm_kstrdup() on pointers that are outside of
> .rodata section and returns the string as is otherwise.
>
> Also provide a corresponding version of devm_kfree().
>
> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> ---
>  drivers/base/devres.c  | 38 ++++++++++++++++++++++++++++++++++++++
>  include/linux/device.h |  3 +++
>  2 files changed, 41 insertions(+)
>
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index 438c91a43508..48185d57bc5b 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -11,6 +11,8 @@
>  #include <linux/slab.h>
>  #include <linux/percpu.h>
>
> +#include <asm/sections.h>
> +
>  #include "base.h"
>
>  struct devres_node {
> @@ -822,6 +824,28 @@ char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp)
>  }
>  EXPORT_SYMBOL_GPL(devm_kstrdup);
>
> +/**
> + * devm_kstrdup_const - resource managed conditional string duplication
> + * @dev: device for which to duplicate the string
> + * @s: the string to duplicate
> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
> + *
> + * Strings allocated by devm_kstrdup_const will be automatically freed when
> + * the associated device is detached.
> + *
> + * RETURNS:
> + * Source string if it is in .rodata section otherwise it falls back to
> + * devm_kstrdup.
> + */
> +const char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
> +{
> +       if (is_kernel_rodata((unsigned long)s))
> +               return s;
> +
> +       return devm_kstrdup(dev, s, gfp);
> +}
> +EXPORT_SYMBOL(devm_kstrdup_const);
> +
>  /**
>   * devm_kvasprintf - Allocate resource managed space and format a string
>   *                  into that.
> @@ -895,6 +919,20 @@ void devm_kfree(struct device *dev, const void *p)
>  }
>  EXPORT_SYMBOL_GPL(devm_kfree);
>
> +/**
> + * devm_kfree_const - Resource managed conditional kfree
> + * @dev: device this memory belongs to
> + * @p: memory to free
> + *
> + * Function calls devm_kfree only if @p is not in .rodata section.
> + */
> +void devm_kfree_const(struct device *dev, const void *p)
> +{
> +       if (!is_kernel_rodata((unsigned long)p))
> +               devm_kfree(dev, p);
> +}
> +EXPORT_SYMBOL(devm_kfree_const);
> +
>  /**
>   * devm_kmemdup - Resource-managed kmemdup
>   * @dev: Device this memory belongs to
> diff --git a/include/linux/device.h b/include/linux/device.h
> index 33f7cb271fbb..79ccc6eb0975 100644
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -693,7 +693,10 @@ static inline void *devm_kcalloc(struct device *dev,
>         return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
>  }
>  extern void devm_kfree(struct device *dev, const void *p);
> +extern void devm_kfree_const(struct device *dev, const void *p);

With devm_kfree and devm_kfree_const both taking "const", how are
devm_kstrdup_const() and devm_kfree_const() going to be correctly
paired at compile time? (i.e. I wasn't expecting the prototype change
to devm_kfree())

-Kees

>  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
> +extern const char *devm_kstrdup_const(struct device *dev,
> +                                     const char *s, gfp_t gfp);
>  extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
>                           gfp_t gfp);
>
> --
> 2.18.0
>



-- 
Kees Cook
Pixel Security
