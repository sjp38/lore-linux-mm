Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 598286B3F9B
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:42:52 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s14-v6so13519972ioc.0
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:42:52 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0073.hostedemail.com. [216.40.44.73])
        by mx.google.com with ESMTPS id q129-v6si909654itb.8.2018.08.27.01.42.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 01:42:51 -0700 (PDT)
Message-ID: <4a576f65b8fb3a0e6f0ca662e89070eb982be298.camel@perches.com>
Subject: Re: [PATCH 1/2] devres: provide devm_kstrdup_const()
From: Joe Perches <joe@perches.com>
Date: Mon, 27 Aug 2018 01:42:46 -0700
In-Reply-To: <20180827082101.5036-1-brgl@bgdev.pl>
References: <20180827082101.5036-1-brgl@bgdev.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>, Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>
Cc: linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2018-08-27 at 10:21 +0200, Bartosz Golaszewski wrote:
> Provide a resource managed version of kstrdup_const(). This variant
> internally calls devm_kstrdup() on pointers that are outside of
> .rodata section. Also provide a corresponding version of devm_kfree().
[]
> diff --git a/mm/util.c b/mm/util.c
[]
>  /**
>   * kstrdup - allocate space for and copy an existing string
>   * @s: the string to duplicate
> @@ -78,6 +92,27 @@ const char *kstrdup_const(const char *s, gfp_t gfp)
>  }
>  EXPORT_SYMBOL(kstrdup_const);
>  
> +/**
> + * devm_kstrdup_const - resource managed conditional string duplication
> + * @dev: device for which to duplicate the string
> + * @s: the string to duplicate
> + * @gfp: the GFP mask used in the kmalloc() call when allocating memory
> + *
> + * Function returns source string if it is in .rodata section otherwise it
> + * fallbacks to devm_kstrdup.
> + *
> + * Strings allocated by devm_kstrdup_const will be automatically freed when
> + * the associated device is detached.
> + */
> +char *devm_kstrdup_const(struct device *dev, const char *s, gfp_t gfp)
> +{
> +	if (is_kernel_rodata((unsigned long)s))
> +		return s;
> +
> +	return devm_kstrdup(dev, s, gfp);
> +}
> +EXPORT_SYMBOL(devm_kstrdup_const);

Doesn't this lose constness and don't you get
a compiler warning here?

The kstrdup_const function returns a const char *,
why shouldn't this?
