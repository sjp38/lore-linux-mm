Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4A36B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 16:22:34 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so1738064pad.21
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 13:22:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uf3si2495036pab.66.2014.10.23.13.22.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 13:22:33 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:22:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/cma: Make kmemleak ignore CMA regions
Message-Id: <20141023132233.b156cd79badc1254eff08494@linux-foundation.org>
In-Reply-To: <1413893696-25484-1-git-send-email-thierry.reding@gmail.com>
References: <1413893696-25484-1-git-send-email-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>

On Tue, 21 Oct 2014 14:14:56 +0200 Thierry Reding <thierry.reding@gmail.com> wrote:

> From: Thierry Reding <treding@nvidia.com>
> 
> kmemleak will add allocations as objects to a pool. The memory allocated
> for each object in this pool is periodically searched for pointers to
> other allocated objects. This only works for memory that is mapped into
> the kernel's virtual address space, which happens not to be the case for
> most CMA regions.
> 
> Furthermore, CMA regions are typically used to store data transferred to
> or from a device and therefore don't contain pointers to other objects.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
> Note: I'm not sure this is really the right fix. But without this, the
> kernel crashes on the first execution of the scan_gray_list() because
> it tries to access highmem. Perhaps a more appropriate fix would be to
> reject any object that can't map to a kernel virtual address?

Let's cc Catalin.

> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -280,6 +280,7 @@ int __init cma_declare_contiguous(phys_addr_t base,
>  			ret = -ENOMEM;
>  			goto err;
>  		} else {
> +			kmemleak_ignore(phys_to_virt(addr));
>  			base = addr;
>  		}
>  	}

And let's tell our poor readers why we did stuff.  Something like this.

--- a/mm/cma.c~mm-cma-make-kmemleak-ignore-cma-regions-fix
+++ a/mm/cma.c
@@ -280,6 +280,10 @@ int __init cma_declare_contiguous(phys_a
 			ret = -ENOMEM;
 			goto err;
 		} else {
+			/*
+			 * kmemleak writes metadata to the tracked objects, but
+			 * this address isn't mapped and accessible.
+			 */
 			kmemleak_ignore(phys_to_virt(addr));
 			base = addr;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
