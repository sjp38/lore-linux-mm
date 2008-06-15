MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18517.39513.867328.171299@cargo.ozlabs.ibm.com>
Date: Mon, 16 Jun 2008 08:40:25 +1000
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit architectures (v2)
In-Reply-To: <1213543436-15254-1-git-send-email-righi.andrea@gmail.com>
References: <1213543436-15254-1-git-send-email-righi.andrea@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righi.andrea@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, Sudhir Kumar <skumar@linux.vnet.ibm.com>, yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Righi writes:

> Also move the PAGE_ALIGN() definitions out of include/asm-*/page.h in
> include/linux/mm.h.

I'd rather see it in some other place than this, because
include/linux/mm.h is a large header that includes quite a lot of
other stuff.  What's wrong with leaving it in each arch's page.h and
only changing it on those archs that have both 32-bit and 64-bit
variants?  Or perhaps there is some other, lower-level header in
include/linux where it could go?

> diff --git a/arch/powerpc/boot/of.c b/arch/powerpc/boot/of.c
> index 61d9899..6bc72b1 100644
> --- a/arch/powerpc/boot/of.c
> +++ b/arch/powerpc/boot/of.c
> @@ -8,6 +8,7 @@
>   */
>  #include <stdarg.h>
>  #include <stddef.h>
> +#include <linux/mm.h>
>  #include "types.h"
>  #include "elf.h"
>  #include "string.h"
> diff --git a/arch/powerpc/boot/page.h b/arch/powerpc/boot/page.h
> index 14eca30..aa42298 100644
> --- a/arch/powerpc/boot/page.h
> +++ b/arch/powerpc/boot/page.h
> @@ -28,7 +28,4 @@
>  /* align addr on a size boundary - adjust address up if needed */
>  #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
>  
> -/* to align the pointer to the (next) page boundary */
> -#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
> -
>  #endif				/* _PPC_BOOT_PAGE_H */

These parts are NAKed, because arch/powerpc/boot is a separate program
that doesn't use the kernel include files.

> diff --git a/include/asm-powerpc/page.h b/include/asm-powerpc/page.h
> index cffdf0e..e088545 100644
> --- a/include/asm-powerpc/page.h
> +++ b/include/asm-powerpc/page.h
> @@ -119,9 +119,6 @@ extern phys_addr_t kernstart_addr;
>  /* align addr on a size boundary - adjust address up if needed */
>  #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
>  
> -/* to align the pointer to the (next) page boundary */
> -#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
> -
>  /*
>   * Don't compare things with KERNELBASE or PAGE_OFFSET to test for
>   * "kernelness", use is_kernel_addr() - it should do what you want.

We had already come across this issue on powerpc, and we fixed it by
making sure that the type of PAGE_MASK was int, not unsigned int.
However, I have no objection to using the ALIGN() macro from
include/linux/kernel.h instead.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
