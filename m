Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1358C6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 19:31:39 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ld10so2103964pab.25
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 16:31:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id am2si49517061pad.183.2013.12.02.16.31.38
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 16:31:38 -0800 (PST)
Date: Mon, 2 Dec 2013 16:31:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/24] mm/memblock: Add memblock memory allocation apis
Message-Id: <20131202163136.f31f39c5940c0ba6d20f4a00@linux-foundation.org>
In-Reply-To: <1383954120-24368-10-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
	<1383954120-24368-10-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, Grygorii Strashko <grygorii.strashko@ti.com>

On Fri, 8 Nov 2013 18:41:45 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> Introduce memblock memory allocation APIs which allow to support
> PAE or LPAE extension on 32 bits archs where the physical memory start
> address can be beyond 4GB. In such cases, existing bootmem APIs which
> operate on 32 bit addresses won't work and needs memblock layer which
> operates on 64 bit addresses.
> 
> So we add equivalent APIs so that we can replace usage of bootmem
> with memblock interfaces. Architectures already converted to NO_BOOTMEM
> use these new interfaces and other which still uses bootmem, these new
> APIs just fallback to exiting bootmem APIs. So no functional change as
> such.
> 
> In long run, once all the achitectures moves to NO_BOOTMEM, we can get rid of
> bootmem layer completely. This is one step to remove the core code dependency
> with bootmem and also gives path for architectures to move away from bootmem.
> 
> The proposed interface will became active if both CONFIG_HAVE_MEMBLOCK
> and CONFIG_NO_BOOTMEM are specified by arch. In case !CONFIG_NO_BOOTMEM,
> the memblock() wrappers will fallback to the existing bootmem apis so
> that arch's not converted to NO_BOOTMEM continue to work as is.
> 
> The meaning of MEMBLOCK_ALLOC_ACCESSIBLE and MEMBLOCK_ALLOC_ANYWHERE is
> kept same.
> 
> ...
>
> +static void * __init _memblock_virt_alloc_try_nid_nopanic(
> +				phys_addr_t size, phys_addr_t align,
> +				phys_addr_t from, phys_addr_t max_addr,
> +				int nid)
> +{
> +	phys_addr_t alloc;
> +	void *ptr;
> +
> +	if (WARN_ON_ONCE(slab_is_available())) {
> +		if (nid == MAX_NUMNODES)
> +			return kzalloc(size, GFP_NOWAIT);
> +		else
> +			return kzalloc_node(size, GFP_NOWAIT, nid);
> +	}

The use of MAX_NUMNODES is a bit unconventional here.  I *think* we
generally use NUMA_NO_NODE to indicate "don't care".  I Also *think*
that if this code did s/MAX_NUMNODES/NUMA_NO_NODE/g then the above
simply becomes

	return kzalloc_node(size, GFP_NOWAIT, nid);

and kzalloc_node() handles NUMA_NO_NODE appropriately.

I *think* ;)  Please check all this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
