Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFD08E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 07:02:51 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id c73so18454982itd.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 04:02:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t134sor15959657ita.12.2018.12.26.04.02.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Dec 2018 04:02:50 -0800 (PST)
MIME-Version: 1.0
References: <20181226023534.64048-1-cai@lca.pw>
In-Reply-To: <20181226023534.64048-1-cai@lca.pw>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 26 Dec 2018 13:02:38 +0100
Message-ID: <CAKv+Gu_fiEDffKq_fONBYTOdSk-L7__+LgNEyVaNF3FGzBfAow@mail.gmail.com>
Subject: Re: [PATCH -mmotm] efi: drop kmemleak_ignore() for page allocator
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>, Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Linux-MM <linux-mm@kvack.org>, linux-efi <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 26 Dec 2018 at 03:35, Qian Cai <cai@lca.pw> wrote:
>
> a0fc5578f1d (efi: Let kmemleak ignore false positives) is no longer
> needed due to efi_mem_reserve_persistent() uses __get_free_page()
> instead where kmemelak is not able to track regardless. Otherwise,
> kernel reported "kmemleak: Trying to color unknown object at
> 0xffff801060ef0000 as Black"
>
> Signed-off-by: Qian Cai <cai@lca.pw>

Why are you sending this to -mmotm?

Andrew, please disregard this patch. This is EFI/tip material.

> ---
>  drivers/firmware/efi/efi.c | 3 ---
>  1 file changed, 3 deletions(-)
>
> diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
> index 7ac09dd8f268..4c46ff6f2242 100644
> --- a/drivers/firmware/efi/efi.c
> +++ b/drivers/firmware/efi/efi.c
> @@ -31,7 +31,6 @@
>  #include <linux/acpi.h>
>  #include <linux/ucs2_string.h>
>  #include <linux/memblock.h>
> -#include <linux/kmemleak.h>
>
>  #include <asm/early_ioremap.h>
>
> @@ -1027,8 +1026,6 @@ int __ref efi_mem_reserve_persistent(phys_addr_t addr, u64 size)
>         if (!rsv)
>                 return -ENOMEM;
>
> -       kmemleak_ignore(rsv);
> -
>         rsv->size = EFI_MEMRESERVE_COUNT(PAGE_SIZE);
>         atomic_set(&rsv->count, 1);
>         rsv->entry[0].base = addr;

The patch that adds the kmemleak_ignore() call here is queued in
efi/urgent branch in the tip tree, but did not make it into v4.20.

efi/urgent does not apply cleanly to efi/core, since the kmalloc()
call [which requires the kmemleak_ignore() call] has been replaced
with alloc_pages() [which doesn't], necessitating this patch to remove
the kmemleak_ignore() call again.

So what I would like to suggest is that Ingo resolves this conflict by
simply dropping the call to kmemleak_ignore(). That way, we don't need
this patch, and we can still backport the efi/urgent change to
v4.20-stable.
