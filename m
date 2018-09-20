Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 337778E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 12:34:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a8-v6so4619933pla.10
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 09:34:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t23-v6sor2749111pgi.180.2018.09.20.09.34.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Sep 2018 09:34:36 -0700 (PDT)
Date: Thu, 20 Sep 2018 09:38:45 -0700
From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH v2 2/4] mm: move is_kernel_rodata() to
 asm-generic/sections.h
Message-ID: <20180920163845.GG1367@tuxbook-pro>
References: <20180828093332.20674-1-brgl@bgdev.pl>
 <20180828093332.20674-3-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828093332.20674-3-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 28 Aug 02:33 PDT 2018, Bartosz Golaszewski wrote:

> Export this routine so that we can use it later in devm_kstrdup_const()
> and devm_kfree_const().
> 

Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Regards,
Bjorn

> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> ---
>  include/asm-generic/sections.h | 14 ++++++++++++++
>  mm/util.c                      |  7 -------
>  2 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/include/asm-generic/sections.h b/include/asm-generic/sections.h
> index 849cd8eb5ca0..d79abca81a52 100644
> --- a/include/asm-generic/sections.h
> +++ b/include/asm-generic/sections.h
> @@ -141,4 +141,18 @@ static inline bool init_section_intersects(void *virt, size_t size)
>  	return memory_intersects(__init_begin, __init_end, virt, size);
>  }
>  
> +/**
> + * is_kernel_rodata - checks if the pointer address is located in the
> + *                    .rodata section
> + *
> + * @addr: address to check
> + *
> + * Returns: true if the address is located in .rodata, false otherwise.
> + */
> +static inline bool is_kernel_rodata(unsigned long addr)
> +{
> +	return addr >= (unsigned long)__start_rodata &&
> +	       addr < (unsigned long)__end_rodata;
> +}
> +
>  #endif /* _ASM_GENERIC_SECTIONS_H_ */
> diff --git a/mm/util.c b/mm/util.c
> index d2890a407332..41e9892a50ce 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -15,17 +15,10 @@
>  #include <linux/vmalloc.h>
>  #include <linux/userfaultfd_k.h>
>  
> -#include <asm/sections.h>
>  #include <linux/uaccess.h>
>  
>  #include "internal.h"
>  
> -static inline int is_kernel_rodata(unsigned long addr)
> -{
> -	return addr >= (unsigned long)__start_rodata &&
> -		addr < (unsigned long)__end_rodata;
> -}
> -
>  /**
>   * kfree_const - conditionally free memory
>   * @x: pointer to the memory
> -- 
> 2.18.0
> 
