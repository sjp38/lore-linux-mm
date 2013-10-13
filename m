Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 07FD96B0037
	for <linux-mm@kvack.org>; Sun, 13 Oct 2013 15:51:16 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so6467811pdj.26
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 12:51:16 -0700 (PDT)
Received: by mail-qa0-f52.google.com with SMTP id w8so1740849qac.11
        for <linux-mm@kvack.org>; Sun, 13 Oct 2013 12:51:14 -0700 (PDT)
Date: Sun, 13 Oct 2013 15:51:11 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 08/23] mm/memblock: debug: don't free reserved array if
 !ARCH_DISCARD_MEMBLOCK
Message-ID: <20131013195111.GB18075@htj.dyndns.org>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
 <1381615146-20342-9-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381615146-20342-9-git-send-email-santosh.shilimkar@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: yinghai@kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Andrew Morton <akpm@linux-foundation.org>

On Sat, Oct 12, 2013 at 05:58:51PM -0400, Santosh Shilimkar wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> 
> Now the Nobootmem allocator will always try to free memory allocated for
> reserved memory regions (free_low_memory_core_early()) without taking
> into to account current memblock debugging configuration
> (CONFIG_ARCH_DISCARD_MEMBLOCK and CONFIG_DEBUG_FS state).
> As result if:
>  - CONFIG_DEBUG_FS defined
>  - CONFIG_ARCH_DISCARD_MEMBLOCK not defined;
> -  reserved memory regions array have been resized during boot
> 
> then:
> - memory allocated for reserved memory regions array will be freed to
> buddy allocator;
> - debug_fs entry "sys/kernel/debug/memblock/reserved" will show garbage
> instead of state of memory reservations. like:
>    0: 0x98393bc0..0x9a393bbf
>    1: 0xff120000..0xff11ffff
>    2: 0x00000000..0xffffffff
> 
> Hence, do not free memory allocated for reserved memory regions if
> defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK).
> 
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
> ---
>  mm/memblock.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index d903138..1bb2cc0 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -169,6 +169,10 @@ phys_addr_t __init_memblock get_allocated_memblock_reserved_regions_info(
>  	if (memblock.reserved.regions == memblock_reserved_init_regions)
>  		return 0;
>  

Please add comment explaining why the following test exists.  It's
pretty difficult to deduce the reason only from the code.

> +	if (IS_ENABLED(CONFIG_DEBUG_FS) &&
> +	    !IS_ENABLED(CONFIG_ARCH_DISCARD_MEMBLOCK))
> +		return 0;
> +

Also, as this is another fix patch, can you please move this to the
head of the series?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
