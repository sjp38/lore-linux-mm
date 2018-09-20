Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D49B78E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 12:33:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v9-v6so4618835ply.13
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 09:33:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f26-v6sor2785989pgf.275.2018.09.20.09.33.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 09:33:53 -0700 (PDT)
Date: Thu, 20 Sep 2018 09:38:02 -0700
From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH v2 1/4] devres: constify p in devm_kfree()
Message-ID: <20180920163802.GF1367@tuxbook-pro>
References: <20180828093332.20674-1-brgl@bgdev.pl>
 <20180828093332.20674-2-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828093332.20674-2-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 28 Aug 02:33 PDT 2018, Bartosz Golaszewski wrote:

> Make devm_kfree() signature uniform with that of kfree(). To avoid
> compiler warnings: cast p to (void *) when calling devres_destroy().
> 

Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Regards,
Bjorn

> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> ---
>  drivers/base/devres.c  | 5 +++--
>  include/linux/device.h | 2 +-
>  2 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index f98a097e73f2..438c91a43508 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -885,11 +885,12 @@ EXPORT_SYMBOL_GPL(devm_kasprintf);
>   *
>   * Free memory allocated with devm_kmalloc().
>   */
> -void devm_kfree(struct device *dev, void *p)
> +void devm_kfree(struct device *dev, const void *p)
>  {
>  	int rc;
>  
> -	rc = devres_destroy(dev, devm_kmalloc_release, devm_kmalloc_match, p);
> +	rc = devres_destroy(dev, devm_kmalloc_release,
> +			    devm_kmalloc_match, (void *)p);
>  	WARN_ON(rc);
>  }
>  EXPORT_SYMBOL_GPL(devm_kfree);
> diff --git a/include/linux/device.h b/include/linux/device.h
> index 8f882549edee..33f7cb271fbb 100644
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -692,7 +692,7 @@ static inline void *devm_kcalloc(struct device *dev,
>  {
>  	return devm_kmalloc_array(dev, n, size, flags | __GFP_ZERO);
>  }
> -extern void devm_kfree(struct device *dev, void *p);
> +extern void devm_kfree(struct device *dev, const void *p);
>  extern char *devm_kstrdup(struct device *dev, const char *s, gfp_t gfp) __malloc;
>  extern void *devm_kmemdup(struct device *dev, const void *src, size_t len,
>  			  gfp_t gfp);
> -- 
> 2.18.0
> 
