Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87F426B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:26:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25-v6so468746pfi.20
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:26:59 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n22-v6si3044275pff.370.2018.06.20.15.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 15:26:58 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:26:53 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
Message-ID: <20180620222653.GC11479@bombadil.infradead.org>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com

On Wed, Jun 20, 2018 at 03:09:28PM -0700, Rick Edgecombe wrote:
>  
>  /**
> + *	__vmalloc_try_addr  -  try to alloc at a specific address
> + *	@addr:		address to try
> + *	@size:		size to try
> + *	@gfp_mask:	flags for the page level allocator
> + *	@prot:		protection mask for the allocated pages
> + *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
> + *	@node:		node to use for allocation or NUMA_NO_NODE
> + *	@caller:	caller's return address
> + *
> + *	Try to allocate at the specific address. If it succeeds the address is
> + *	returned. If it fails NULL is returned.  It may trigger TLB flushes.

 * Try to allocate memory at a specific address.  May trigger TLB flushes.
 *
 * Context: Process context.
 * Return: The allocated address if it succeeds.  NULL if it fails.

> @@ -1759,8 +1795,9 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  	return addr;
>  
>  fail:
> -	warn_alloc(gfp_mask, NULL,
> -			  "vmalloc: allocation failure: %lu bytes", real_size);
> +	if (!(gfp_mask & __GFP_NOWARN))
> +		warn_alloc(gfp_mask, NULL,
> +			"vmalloc: allocation failure: %lu bytes", real_size);
>  	return NULL;

Not needed:

void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
{
...
        if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
                return;
