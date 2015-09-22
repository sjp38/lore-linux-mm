Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 184F36B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:28:45 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so12274832pad.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 08:28:44 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id lp10si3379418pab.101.2015.09.22.08.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 08:28:44 -0700 (PDT)
Date: Tue, 22 Sep 2015 11:28:36 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 09/10] mm: make frontswap.c explicitly non-modular
Message-ID: <20150922152836.GG4454@l.oracle.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
 <1440454482-12250-10-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440454482-12250-10-git-send-email-paul.gortmaker@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 24, 2015 at 06:14:41PM -0400, Paul Gortmaker wrote:
> The Kconfig currently controlling compilation of this code is:
> 
> config FRONTSWAP
>     bool "Enable frontswap to cache swap pages if tmem is present"
> 
> ...meaning that it currently is not being built as a module by anyone.
> 
> Lets remove the couple traces of modularity so that when reading the
> driver there is no doubt it is builtin-only.
> 
> Since module_init translates to device_initcall in the non-modular
> case, the init ordering remains unchanged with this commit.  However
> one could argue that subsys_initcall might make more sense here.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

I would add to the commit:

Frontswap depends on CONFIG_SWAP and there is currently no way
to make swap dynamically loaded.

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  mm/frontswap.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index 27a9924caf61..b36409766831 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -15,7 +15,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/security.h>
> -#include <linux/module.h>
> +#include <linux/init.h>
>  #include <linux/debugfs.h>
>  #include <linux/frontswap.h>
>  #include <linux/swapfile.h>
> @@ -500,5 +500,4 @@ static int __init init_frontswap(void)
>  #endif
>  	return 0;
>  }
> -
> -module_init(init_frontswap);
> +device_initcall(init_frontswap);
> -- 
> 2.5.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
