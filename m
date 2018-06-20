Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BDCF6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:17:10 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z11-v6so473013pfn.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:17:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k91-v6si3301276pld.248.2018.06.20.15.17.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Jun 2018 15:17:03 -0700 (PDT)
Subject: Re: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
 <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <12014310-19f7-dc31-d983-9c7e00c8b446@infradead.org>
Date: Wed, 20 Jun 2018 15:16:50 -0700
MIME-Version: 1.0
In-Reply-To: <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com

On 06/20/2018 03:09 PM, Rick Edgecombe wrote:
> Create __vmalloc_node_try_addr function that tries to allocate at a specific
> address.  The implementation relies on __vmalloc_node_range for the bulk of the
> work.  To keep this function from spamming the logs when an allocation failure
> is fails, __vmalloc_node_range is changed to only warn when __GFP_NOWARN is not
> set.  This behavior is consistent with this flags interpretation in
> alloc_vmap_area.
> 
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
> ---
>  include/linux/vmalloc.h |  3 +++
>  mm/vmalloc.c            | 41 +++++++++++++++++++++++++++++++++++++++--
>  2 files changed, 42 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 398e9c9..6eaa896 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -82,6 +82,9 @@ extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  			unsigned long start, unsigned long end, gfp_t gfp_mask,
>  			pgprot_t prot, unsigned long vm_flags, int node,
>  			const void *caller);
> +extern void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
> +			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
> +			int node, const void *caller);
>  #ifndef CONFIG_MMU
>  extern void *__vmalloc_node_flags(unsigned long size, int node, gfp_t flags);
>  static inline void *__vmalloc_node_flags_caller(unsigned long size, int node,

> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index cfea25b..9e0820c9 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1710,6 +1710,42 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  }
>  
>  /**
> + *	__vmalloc_try_addr  -  try to alloc at a specific address

    *   __vmalloc_node_try_addr - try to allocate at a specific address

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
> + */
> +void *__vmalloc_node_try_addr(unsigned long addr, unsigned long size,
> +			gfp_t gfp_mask,	pgprot_t prot, unsigned long vm_flags,
> +			int node, const void *caller)
> +{

so this isn't optional, eh?  You are going to force it on people because?

thanks,
-- 
~Randy
