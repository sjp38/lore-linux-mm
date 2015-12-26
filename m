Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id D24E882FCE
	for <linux-mm@kvack.org>; Sat, 26 Dec 2015 11:02:57 -0500 (EST)
Received: by mail-qg0-f48.google.com with SMTP id 6so45735223qgy.1
        for <linux-mm@kvack.org>; Sat, 26 Dec 2015 08:02:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s67si55744782qhs.12.2015.12.26.08.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Dec 2015 08:02:56 -0800 (PST)
Date: Sun, 27 Dec 2015 00:05:22 +0800
From: Minfei Huang <mhuang@redhat.com>
Subject: Re: [PATCH v2 14/16] x86,nvdimm,kexec: Use walk_iomem_res_desc() for
 iomem search
Message-ID: <20151226160522.GA28533@dhcp-128-25.nay.redhat.com>
References: <1451081365-15190-1-git-send-email-toshi.kani@hpe.com>
 <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1451081365-15190-14-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, x86@kernel.org, linux-nvdimm@ml01.01.org, kexec@lists.infradead.org

Ccing kexec maillist.

On 12/25/15 at 03:09pm, Toshi Kani wrote:
> diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
> index c245085..e2bd737 100644
> --- a/kernel/kexec_file.c
> +++ b/kernel/kexec_file.c
> @@ -522,10 +522,10 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
>  
>  	/* Walk the RAM ranges and allocate a suitable range for the buffer */
>  	if (image->type == KEXEC_TYPE_CRASH)
> -		ret = walk_iomem_res("Crash kernel",
> -				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
> -				     crashk_res.start, crashk_res.end, kbuf,
> -				     locate_mem_hole_callback);
> +		ret = walk_iomem_res_desc(IORES_DESC_CRASH_KERNEL,

Since crashk_res's desc has been assigned to IORES_DESC_CRASH_KERNEL, it
is better to use crashk_res.desc, instead of using
IORES_DESC_CRASH_KERNEL directly.

Thanks
Minfei

> +				IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
> +				crashk_res.start, crashk_res.end, kbuf,
> +				locate_mem_hole_callback);
>  	else
>  		ret = walk_system_ram_res(0, -1, kbuf,
>  					  locate_mem_hole_callback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
