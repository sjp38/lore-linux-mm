Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C2E236B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:36:51 -0500 (EST)
Received: by pfdd184 with SMTP id d184so2527091pfd.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:36:51 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id g79si7663186pfj.185.2015.12.02.15.36.50
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 15:36:51 -0800 (PST)
Subject: Re: [PATCH V2 2/7] mm/gup: add gup trace points
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
 <1449096813-22436-3-git-send-email-yang.shi@linaro.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <565F8092.7000001@intel.com>
Date: Wed, 2 Dec 2015 15:36:50 -0800
MIME-Version: 1.0
In-Reply-To: <1449096813-22436-3-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>, akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 12/02/2015 02:53 PM, Yang Shi wrote:
> diff --git a/mm/gup.c b/mm/gup.c
> index deafa2c..10245a4 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -13,6 +13,9 @@
>  #include <linux/rwsem.h>
>  #include <linux/hugetlb.h>
>  
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/gup.h>
> +
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>

This needs to be _the_ last thing that gets #included.  Otherwise, you
risk colliding with any other trace header that gets implicitly included
below.

> @@ -1340,6 +1346,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  					start, len)))
>  		return 0;
>  
> +	trace_gup_get_user_pages_fast(start, nr_pages, write, pages);
> +
>  	/*
>  	 * Disable interrupts.  We use the nested form as we can already have
>  	 * interrupts disabled by get_futex_key.

It would be _really_ nice to be able to see return values from the
various gup calls as well.  Is that feasible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
