Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFC88E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c18-v6so19103358oiy.3
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 03:32:23 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v50-v6si13632583otb.289.2018.09.24.03.32.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 03:32:22 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8OATMq5134046
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:21 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mptwk8ccc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:21 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 24 Sep 2018 11:32:18 +0100
Date: Mon, 24 Sep 2018 13:32:05 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 3/4] devres: provide devm_kstrdup_const()
References: <20180924101150.23349-1-brgl@bgdev.pl>
 <20180924101150.23349-4-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924101150.23349-4-brgl@bgdev.pl>
Message-Id: <20180924103204.GC6264@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 24, 2018 at 12:11:49PM +0200, Bartosz Golaszewski wrote:
> Provide a resource managed version of kstrdup_const(). This variant
> internally calls devm_kstrdup() on pointers that are outside of
> .rodata section and returns the string as is otherwise.
> 
> Also provide a corresponding version of devm_kfree().
> 
> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

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
> +	if (is_kernel_rodata((unsigned long)s))
> +		return s;
> +
> +	return devm_kstrdup(dev, s, gfp);
> +}
> +EXPORT_SYMBOL(devm_kstrdup_const);
> +
>  /**
>   * devm_kvasprintf - Allocate resource managed space and format a string
>   *		     into that.
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
> +	if (!is_kernel_rodata((unsigned long)p))
> +		devm_kfree(dev, p);
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
>  	return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
>  }
>  extern void devm_kfree(struct device *dev, const void *p);
> +extern void devm_kfree_const(struct device *dev, const void *p);
>  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
> +extern const char *devm_kstrdup_const(struct device *dev,
> +				      const char *s, gfp_t gfp);
>  extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
>  			  gfp_t gfp);
> 
> -- 
> 2.18.0
> 

-- 
Sincerely yours,
Mike.
