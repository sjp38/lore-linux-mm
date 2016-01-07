Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id C1FAC6B0007
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 07:38:40 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id e32so235919788qgf.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 04:38:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e132si89116448qhc.70.2016.01.07.04.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 04:38:40 -0800 (PST)
Date: Thu, 7 Jan 2016 20:38:25 +0800
From: Dave Young <dyoung@redhat.com>
Subject: Re: [PATCH v3 07/17] kexec: Set IORESOURCE_SYSTEM_RAM to System RAM
Message-ID: <20160107123825.GB2870@dhcp-128-65.nay.redhat.com>
References: <1452020081-26534-1-git-send-email-toshi.kani@hpe.com>
 <1452020081-26534-7-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452020081-26534-7-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kexec@lists.infradead.org

On 01/05/16 at 11:54am, Toshi Kani wrote:
> Set IORESOURCE_SYSTEM_RAM to 'flags' and IORES_DESC_CRASH_KERNEL
> to 'desc' of "Crash kernel" resource ranges, which are child
> nodes of System RAM.
> 
> Change crash_shrink_memory() to set IORESOURCE_SYSTEM_RAM for
> a System RAM range.
> 
> Change kexec_add_buffer() to call walk_iomem_res() with
> IORESOURCE_SYSTEM_RAM type for "Crash kernel".
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Young <dyoung@redhat.com>
> Cc: kexec@lists.infradead.org
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> ---
>  kernel/kexec_core.c |    8 +++++---
>  kernel/kexec_file.c |    2 +-
>  2 files changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index 11b64a6..80bff05 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -66,13 +66,15 @@ struct resource crashk_res = {
>  	.name  = "Crash kernel",
>  	.start = 0,
>  	.end   = 0,
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
> +	.desc  = IORES_DESC_CRASH_KERNEL
>  };
>  struct resource crashk_low_res = {
>  	.name  = "Crash kernel",
>  	.start = 0,
>  	.end   = 0,
> -	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
> +	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
> +	.desc  = IORES_DESC_CRASH_KERNEL
>  };
>  
>  int kexec_should_crash(struct task_struct *p)
> @@ -934,7 +936,7 @@ int crash_shrink_memory(unsigned long new_size)
>  
>  	ram_res->start = end;
>  	ram_res->end = crashk_res.end;
> -	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
> +	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
>  	ram_res->name = "System RAM";
>  
>  	crashk_res.end = end - 1;
> diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
> index b70ada0..c245085 100644
> --- a/kernel/kexec_file.c
> +++ b/kernel/kexec_file.c
> @@ -523,7 +523,7 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
>  	/* Walk the RAM ranges and allocate a suitable range for the buffer */
>  	if (image->type == KEXEC_TYPE_CRASH)
>  		ret = walk_iomem_res("Crash kernel",
> -				     IORESOURCE_MEM | IORESOURCE_BUSY,
> +				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
>  				     crashk_res.start, crashk_res.end, kbuf,
>  				     locate_mem_hole_callback);
>  	else

Reviewed-by: Dave Young <dyoung@redhat.com>

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
