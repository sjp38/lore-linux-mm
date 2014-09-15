Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1A16B0039
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 06:55:48 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id q58so3827824wes.9
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:55:48 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id sf4si13857578wic.1.2014.09.15.03.55.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 03:55:42 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:55:25 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC Resend] arm:extend __init_end to a page align address
Message-ID: <20140915105525.GC12361@n2100.arm.linux.org.uk>
References: <35FD53F367049845BC99AC72306C23D103CDBFBFB028@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103D6DB4915FB@CNBJMBX05.corpusers.net> <35FD53F367049845BC99AC72306C23D103D6DB491607@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103D6DB491607@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Jiang Liu <jiang.liu@huawei.com>
Cc: 'Will Deacon' <will.deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>

On Mon, Sep 15, 2014 at 06:26:43PM +0800, Wang, Yalin wrote:
> this patch change the __init_end address to a page align address, so that free_initmem()
> can free the whole .init section, because if the end address is not page aligned,
> it will round down to a page align address, then the tail unligned page will not be freed.

Please wrap commit messages at or before column 72 - this makes "git log"
much easier to read once the change has been committed.

I have no objection to the arch/arm part of this patch.  However, since
different people deal with arch/arm and arch/arm64, this patch needs to
be split.

Also, it may be worth patching include/asm-generic/vmlinux.lds.h to
indicate that __initrd_end should be page aligned - this seems to be a
requirement by the (new-ish) free_reserved_area() function, otherwise
it does indeed round down.

(Added Jiang Liu as the person responsible for free_reserved_area() for
any further comments.)

> 
> Signed-off-by: Yalin wang <yalin.wang@sonymobile.com>
> ---
>  arch/arm/kernel/vmlinux.lds.S   | 2 +-
>  arch/arm64/kernel/vmlinux.lds.S | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S index 6f57cb9..8e95aa4 100644
> --- a/arch/arm/kernel/vmlinux.lds.S
> +++ b/arch/arm/kernel/vmlinux.lds.S
> @@ -219,8 +219,8 @@ SECTIONS
>  	__data_loc = ALIGN(4);		/* location in binary */
>  	. = PAGE_OFFSET + TEXT_OFFSET;
>  #else
> -	__init_end = .;
>  	. = ALIGN(THREAD_SIZE);
> +	__init_end = .;
>  	__data_loc = .;
>  #endif
>  
> diff --git a/arch/arm64/kernel/vmlinux.lds.S b/arch/arm64/kernel/vmlinux.lds.S index 97f0c04..edf8715 100644
> --- a/arch/arm64/kernel/vmlinux.lds.S
> +++ b/arch/arm64/kernel/vmlinux.lds.S
> @@ -97,9 +97,9 @@ SECTIONS
>  
>  	PERCPU_SECTION(64)
>  
> +	. = ALIGN(PAGE_SIZE);
>  	__init_end = .;
>  
> -	. = ALIGN(PAGE_SIZE);
>  	_data = .;
>  	_sdata = .;
>  	RW_DATA_SECTION(64, PAGE_SIZE, THREAD_SIZE)
> --
> 1.9.2.msysgit.0

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
