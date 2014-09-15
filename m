Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 32BEC6B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 07:33:50 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id z12so3804201wgg.16
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 04:33:48 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id jz3si18443759wjc.2.2014.09.15.04.33.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 04:33:42 -0700 (PDT)
Date: Mon, 15 Sep 2014 12:33:25 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be page
	aligned
Message-ID: <20140915113325.GD12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>

On Mon, Sep 15, 2014 at 07:07:20PM +0800, Wang, Yalin wrote:
> this patch extend the start and end address of initrd to be page aligned,
> so that we can free all memory including the un-page aligned head or tail
> page of initrd, if the start or end address of initrd are not page
> aligned, the page can't be freed by free_initrd_mem() function.

Better, but I think it's more complicated than it needs to be:

> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/mm/init.c   | 19 +++++++++++++++++--
>  arch/arm64/mm/init.c | 37 +++++++++++++++++++++++++++++++++----
>  2 files changed, 50 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 659c75d..8490b70 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -277,6 +277,8 @@ phys_addr_t __init arm_memblock_steal(phys_addr_t size, phys_addr_t align)
>  void __init arm_memblock_init(const struct machine_desc *mdesc)
>  {
>  	/* Register the kernel text, kernel data and initrd with memblock. */
> +	phys_addr_t phys_initrd_start_orig __maybe_unused;
> +	phys_addr_t phys_initrd_size_orig __maybe_unused;
>  #ifdef CONFIG_XIP_KERNEL
>  	memblock_reserve(__pa(_sdata), _end - _sdata);
>  #else
> @@ -289,6 +291,13 @@ void __init arm_memblock_init(const struct machine_desc *mdesc)
>  		phys_initrd_size = initrd_end - initrd_start;
>  	}
>  	initrd_start = initrd_end = 0;
> +	phys_initrd_start_orig = phys_initrd_start;
> +	phys_initrd_size_orig = phys_initrd_size;
> +	/* make sure the start and end address are page aligned */
> +	phys_initrd_size = round_up(phys_initrd_start + phys_initrd_size, PAGE_SIZE);
> +	phys_initrd_start = round_down(phys_initrd_start, PAGE_SIZE);
> +	phys_initrd_size -= phys_initrd_start;
> +
>  	if (phys_initrd_size &&
>  	    !memblock_is_region_memory(phys_initrd_start, phys_initrd_size)) {
>  		pr_err("INITRD: 0x%08llx+0x%08lx is not a memory region - disabling initrd\n",
> @@ -305,9 +314,10 @@ void __init arm_memblock_init(const struct machine_desc *mdesc)
>  		memblock_reserve(phys_initrd_start, phys_initrd_size);
>  
>  		/* Now convert initrd to virtual addresses */
> -		initrd_start = __phys_to_virt(phys_initrd_start);
> -		initrd_end = initrd_start + phys_initrd_size;
> +		initrd_start = __phys_to_virt(phys_initrd_start_orig);
> +		initrd_end = initrd_start + phys_initrd_size_orig;
>  	}
> +

I think all the above is entirely unnecessary.  The memblock APIs
(especially memblock_reserve()) will mark the overlapped pages as reserved
- they round down the starting address, and round up the end address
(calculated from start + size).

Hence, this:

> @@ -636,6 +646,11 @@ static int keep_initrd;
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {
>  	if (!keep_initrd) {
> +		if (start == initrd_start)
> +			start = round_down(start, PAGE_SIZE);
> +		if (end == initrd_end)
> +			end = round_up(end, PAGE_SIZE);
> +
>  		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
>  		free_reserved_area((void *)start, (void *)end, -1, "initrd");
>  	}

is the only bit of code you likely need to achieve your goal.

Thinking about this, I think that you are quite right to align these.
The memory around the initrd is defined to be system memory, and we
already free the pages around it, so it *is* wrong not to free the
partial initrd pages.

Good catch.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
