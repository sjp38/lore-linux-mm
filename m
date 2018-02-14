Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 056AD6B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 19:56:29 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id h33so10124707plh.19
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 16:56:28 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k185si356051pgd.533.2018.02.13.16.56.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 16:56:27 -0800 (PST)
Subject: Re: [patch 1/2] mm, page_alloc: extend kernelcore and movablecore for
 percent
References: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a064d937-5746-3e14-bb63-5ff9d845a428@oracle.com>
Date: Tue, 13 Feb 2018 16:37:52 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1802121622470.179479@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org

On 02/12/2018 04:24 PM, David Rientjes wrote:
> Both kernelcore= and movablecore= can be used to define the amount of
> ZONE_NORMAL and ZONE_MOVABLE on a system, respectively.  This requires
> the system memory capacity to be known when specifying the command line,
> however.
> 
> This introduces the ability to define both kernelcore= and movablecore=
> as a percentage of total system memory.  This is convenient for systems
> software that wants to define the amount of ZONE_MOVABLE, for example, as
> a proportion of a system's memory rather than a hardcoded byte value.
> 
> To define the percentage, the final character of the parameter should be
> a '%'.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/admin-guide/kernel-parameters.txt | 44 ++++++++++++-------------
>  mm/page_alloc.c                                 | 43 +++++++++++++++++++-----
>  2 files changed, 57 insertions(+), 30 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -1825,30 +1825,30 @@
>  	keepinitrd	[HW,ARM]
>  
>  	kernelcore=	[KNL,X86,IA-64,PPC]
> -			Format: nn[KMGTPE] | "mirror"
> -			This parameter
> -			specifies the amount of memory usable by the kernel
> -			for non-movable allocations.  The requested amount is
> -			spread evenly throughout all nodes in the system. The
> -			remaining memory in each node is used for Movable
> -			pages. In the event, a node is too small to have both
> -			kernelcore and Movable pages, kernelcore pages will
> -			take priority and other nodes will have a larger number
> -			of Movable pages.  The Movable zone is used for the
> -			allocation of pages that may be reclaimed or moved
> -			by the page migration subsystem.  This means that
> -			HugeTLB pages may not be allocated from this zone.
> -			Note that allocations like PTEs-from-HighMem still
> -			use the HighMem zone if it exists, and the Normal
> -			zone if it does not.
> -
> -			Instead of specifying the amount of memory (nn[KMGTPE]),
> -			you can specify "mirror" option. In case "mirror"
> +			Format: nn[KMGTPE] | nn% | "mirror"
> +			This parameter specifies the amount of memory usable by
> +			the kernel for non-movable allocations.  The requested
> +			amount is spread evenly throughout all nodes in the
> +			system as ZONE_NORMAL.  The remaining memory is used for
> +			movable memory in its own zone, ZONE_MOVABLE.  In the
> +			event, a node is too small to have both ZONE_NORMAL and
> +			ZONE_MOVABLE, kernelcore memory will take priority and
> +			other nodes will have a larger ZONE_MOVABLE.
> +
> +			ZONE_MOVABLE is used for the allocation of pages that
> +			may be reclaimed or moved by the page migration
> +			subsystem.  This means that HugeTLB pages may not be
> +			allocated from this zone.  Note that allocations like
> +			PTEs-from-HighMem still use the HighMem zone if it
> +			exists, and the Normal zone if it does not.

I know you are just updating the documentation for the new ability to
specify a percentage.  However, while looking at this I noticed that
the existing description is out of date.  HugeTLB pages CAN be treated
as movable and allocated from ZONE_MOVABLE.

If you have to respin, could you drop that line while making this change?

> +
> +			It is possible to specify the exact amount of memory in
> +			the form of "nn[KMGTPE]", a percentage of total system
> +			memory in the form of "nn%", or "mirror".  If "mirror"
>  			option is specified, mirrored (reliable) memory is used
>  			for non-movable allocations and remaining memory is used
> -			for Movable pages. nn[KMGTPE] and "mirror" are exclusive,
> -			so you can NOT specify nn[KMGTPE] and "mirror" at the same
> -			time.
> +			for Movable pages.  "nn[KMGTPE]", "nn%", and "mirror"
> +			are exclusive, so you cannot specify multiple forms.
>  
>  	kgdbdbgp=	[KGDB,HW] kgdb over EHCI usb debug port.
>  			Format: <Controller#>[,poll interval]

Don't you need to make the same type percentage changes for 'movablecore='?

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
