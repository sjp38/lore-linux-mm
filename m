Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 42CE98E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:05 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a21-v6so19479914otf.8
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 03:32:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v22-v6si13055876ota.331.2018.09.24.03.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 03:32:04 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8OATU0F135052
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:03 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mpx7gr338-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 06:32:03 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 24 Sep 2018 11:32:00 +0100
Date: Mon, 24 Sep 2018 13:31:45 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 2/4] mm: move is_kernel_rodata() to
 asm-generic/sections.h
References: <20180924101150.23349-1-brgl@bgdev.pl>
 <20180924101150.23349-3-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924101150.23349-3-brgl@bgdev.pl>
Message-Id: <20180924103144.GB6264@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 24, 2018 at 12:11:48PM +0200, Bartosz Golaszewski wrote:
> Export this routine so that we can use it later in devm_kstrdup_const()
> and devm_kfree_const().
> 
> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

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
> index 9e3ebd2ef65f..470f5cd80b64 100644
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

-- 
Sincerely yours,
Mike.
