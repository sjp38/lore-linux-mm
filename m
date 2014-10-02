Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id ED2156B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 13:05:31 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id rl12so2896339iec.31
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 10:05:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ls7si11612963icb.30.2014.10.02.10.05.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 10:05:31 -0700 (PDT)
Message-ID: <542D7C06.1070501@redhat.com>
Date: Thu, 02 Oct 2014 12:23:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fremap use linux header
References: <1412264057-3146-1-git-send-email-paulmcquad@gmail.com>
In-Reply-To: <1412264057-3146-1-git-send-email-paulmcquad@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: akpm@linux-foundation.org, hughd@google.com, gorcunov@openvz.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/02/2014 11:34 AM, Paul McQuade wrote:
> Use #include <linux/mmu_context.h> instead of <asm/mmu_context.h>

linux/mmu_context.h does not include asm/mmu_context.h

This leads me to believe that either fremap.c does not use
any definitions from either mmu_context.h file, or after
your change the code that fremap.c needs is no longer directly
included (but only imported indirectly due to sheer luck).

Could you verify which of these is the case?

If fremap.c is not using any code from mmu_context.h, we are
better off simply removing that line, instead of replacing it
with an unnecessary include...

> diff --git a/mm/fremap.c b/mm/fremap.c
> index 72b8fa3..d614f1c 100644
> --- a/mm/fremap.c
> +++ b/mm/fremap.c
> @@ -1,6 +1,6 @@
>  /*
>   *   linux/mm/fremap.c
> - * 
> + *
>   * Explicit pagetable population and nonlinear (random) mappings support.
>   *
>   * started by Ingo Molnar, Copyright (C) 2002, 2003
> @@ -16,8 +16,8 @@
>  #include <linux/rmap.h>
>  #include <linux/syscalls.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/mmu_context.h>
>  
> -#include <asm/mmu_context.h>
>  #include <asm/cacheflush.h>
>  #include <asm/tlbflush.h>
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
