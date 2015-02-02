Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8620F6B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 12:48:45 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id h15so3895897igd.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:48:45 -0800 (PST)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id ga8si7972506icb.31.2015.02.02.09.48.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 09:48:45 -0800 (PST)
Received: by mail-ig0-f178.google.com with SMTP id hl2so18595308igb.5
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:48:45 -0800 (PST)
Date: Mon, 2 Feb 2015 09:48:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] staging/lustre: use __vmalloc_node() to avoid __GFP_FS
 default
In-Reply-To: <1422846627-26890-3-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.DEB.2.10.1502020945370.5117@chino.kir.corp.google.com>
References: <1422846627-26890-1-git-send-email-green@linuxhacker.ru> <1422846627-26890-3-git-send-email-green@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: green@linuxhacker.ru
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Bruno Faccini <bruno.faccini@intel.com>, Oleg Drokin <oleg.drokin@intel.com>

On Sun, 1 Feb 2015, green@linuxhacker.ru wrote:

> From: Bruno Faccini <bruno.faccini@intel.com>
> 
> When possible, try to use of __vmalloc_node() instead of
> vzalloc/vzalloc_node which allows for protection flag specification,
> and particularly to not set __GFP_FS, which can cause some deadlock
> situations in our code due to recursive calls.
> 

You're saying that all usage of OBD_ALLOC_LARGE() and 
OBD_CPT_ALLOC_LARGE() are in contexts where we need GFP_NOFS?  It would be 
much better to keep using vzalloc{,_node)() in contexts that permit 
__GFP_FS for a higher likelihood of being able to allocate the memory.

> Additionally fixed a typo in the macro name: VEROBSE->VERBOSE
> 
> Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
> Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
> Reviewed-on: http://review.whamcloud.com/11190
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5349
> ---
>  drivers/staging/lustre/lustre/include/obd_support.h | 18 ++++++++++++------
>  1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
> index 2991d2e..c90a88e 100644
> --- a/drivers/staging/lustre/lustre/include/obd_support.h
> +++ b/drivers/staging/lustre/lustre/include/obd_support.h
> @@ -655,11 +655,17 @@ do {									      \
>  #define OBD_CPT_ALLOC_PTR(ptr, cptab, cpt)				      \
>  	OBD_CPT_ALLOC(ptr, cptab, cpt, sizeof(*(ptr)))
>  
> -# define __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)			      \
> +/* Direct use of __vmalloc_node() allows for protection flag specification
> + * (and particularly to not set __GFP_FS, which is likely to cause some
> + * deadlock situations in our code).
> + */
> +# define __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)			      \
>  do {									      \
> -	(ptr) = cptab == NULL ?						      \
> -		vzalloc(size) :						      \
> -		vzalloc_node(size, cfs_cpt_spread_node(cptab, cpt));	      \
> +	(ptr) = __vmalloc_node(size, 1, GFP_NOFS | __GFP_HIGHMEM | __GFP_ZERO,\
> +			       PAGE_KERNEL,				      \
> +			       cptab == NULL ? NUMA_NO_NODE :		      \
> +					      cfs_cpt_spread_node(cptab, cpt),\
> +			       __builtin_return_address(0));		      \
>  	if (unlikely((ptr) == NULL)) {					\
>  		CERROR("vmalloc of '" #ptr "' (%d bytes) failed\n",	   \
>  		       (int)(size));					  \
> @@ -671,9 +677,9 @@ do {									      \
>  } while (0)
>  
>  # define OBD_VMALLOC(ptr, size)						      \
> -	 __OBD_VMALLOC_VEROBSE(ptr, NULL, 0, size)
> +	 __OBD_VMALLOC_VERBOSE(ptr, NULL, 0, size)
>  # define OBD_CPT_VMALLOC(ptr, cptab, cpt, size)				      \
> -	 __OBD_VMALLOC_VEROBSE(ptr, cptab, cpt, size)
> +	 __OBD_VMALLOC_VERBOSE(ptr, cptab, cpt, size)
>  
>  
>  /* Allocations above this size are considered too big and could not be done

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
