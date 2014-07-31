Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6D96B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 03:02:41 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so8839459igb.3
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 00:02:40 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id ga7si38093761igd.49.2014.07.31.00.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Jul 2014 00:02:40 -0700 (PDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so1063635igi.2
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 00:02:40 -0700 (PDT)
Date: Thu, 31 Jul 2014 00:02:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm: BUG when __kmap_atomic_idx equals KM_TYPE_NR
In-Reply-To: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org>
Message-ID: <alpine.DEB.2.02.1407310001360.18238@chino.kir.corp.google.com>
References: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jul 2014, Chintan Pandya wrote:

> __kmap_atomic_idx is per_cpu variable. Each CPU can
> use KM_TYPE_NR entries from FIXMAP i.e. from 0 to
> KM_TYPE_NR - 1. Allowing __kmap_atomic_idx to over-
> shoot to KM_TYPE_NR can mess up with next CPU's 0th
> entry which is a bug. Hence BUG_ON if
> __kmap_atomic_idx >= KM_TYPE_NR.
> 

This appears to be a completely different patch, not a v2.  Why is this 
check only done for CONFIG_DEBUG_HIGHMEM?

I think Andrew's comment earlier was referring to the changelog only and 
not the patch, which looked correct.

> Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
> ---
> Changes:
> 
> V1 --> V2
> 
> 	Not touching CONFIG_DEBUG_HIGHMEM.
> 
>  include/linux/highmem.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
> index 7fb31da..9286a46 100644
> --- a/include/linux/highmem.h
> +++ b/include/linux/highmem.h
> @@ -93,7 +93,7 @@ static inline int kmap_atomic_idx_push(void)
>  
>  #ifdef CONFIG_DEBUG_HIGHMEM
>  	WARN_ON_ONCE(in_irq() && !irqs_disabled());
> -	BUG_ON(idx > KM_TYPE_NR);
> +	BUG_ON(idx >= KM_TYPE_NR);
>  #endif
>  	return idx;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
