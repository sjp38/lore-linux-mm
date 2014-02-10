Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8AECD6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 18:27:42 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id kl14so6864207pab.29
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:27:42 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ye6si16902104pbc.170.2014.02.10.15.27.40
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 15:27:41 -0800 (PST)
Date: Mon, 10 Feb 2014 15:27:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] memblock: memblock_virt_alloc_internal(): alloc
 from specified node only
Message-Id: <20140210152739.6253f77b78ec9ef7d971ddd2@linux-foundation.org>
In-Reply-To: <1392053268-29239-2-git-send-email-lcapitulino@redhat.com>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
	<1392053268-29239-2-git-send-email-lcapitulino@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

On Mon, 10 Feb 2014 12:27:45 -0500 Luiz Capitulino <lcapitulino@redhat.com> wrote:

> From: Luiz capitulino <lcapitulino@redhat.com>
> 
> If an allocation from the node specified by the nid argument fails,
> memblock_virt_alloc_internal() automatically tries to allocate memory
> from other nodes.
> 
> This is fine is the caller don't care which node is going to allocate
> the memory. However, there are cases where the caller wants memory to
> be allocated from the specified node only. If that's not possible, then
> memblock_virt_alloc_internal() should just fail.
> 
> This commit adds a new flags argument to memblock_virt_alloc_internal()
> where the caller can control this behavior.
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1028,6 +1028,8 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
>  	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>  }
>  
> +#define ALLOC_SPECIFIED_NODE_ONLY 0x1
> +
>  /**
>   * memblock_virt_alloc_internal - allocate boot memory block
>   * @size: size of memory block to be allocated in bytes
> @@ -1058,7 +1060,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
>  static void * __init memblock_virt_alloc_internal(
>  				phys_addr_t size, phys_addr_t align,
>  				phys_addr_t min_addr, phys_addr_t max_addr,
> -				int nid)
> +				int nid, unsigned int flags)
>  {
>  	phys_addr_t alloc;
>  	void *ptr;
> @@ -1085,6 +1087,8 @@ again:
>  					    nid);
>  	if (alloc)
>  		goto done;
> +	else if (flags & ALLOC_SPECIFIED_NODE_ONLY)
> +		goto error;

"else" is unneeded.

>  	if (nid != NUMA_NO_NODE) {
>  		alloc = memblock_find_in_range_node(size, align, min_addr,
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
