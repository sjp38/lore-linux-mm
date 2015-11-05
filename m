Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id B1F4882F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 20:06:14 -0500 (EST)
Received: by igdg1 with SMTP id g1so515201igd.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:06:14 -0800 (PST)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id x1si21493133igl.103.2015.11.04.17.06.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 17:06:14 -0800 (PST)
Received: by igvi2 with SMTP id i2so1289554igv.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:06:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
References: <1446685239-28522-1-git-send-email-labbott@fedoraproject.org>
Date: Wed, 4 Nov 2015 17:06:13 -0800
Message-ID: <CAGXu5jLdZ_xFyokoXW5ZhUdTXf-O1MBLk83cG_AM_51PxXbH5A@mail.gmail.com>
Subject: Re: [PATCH] arm: Use kernel mm when updating section permissions
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@fedoraproject.org>
Cc: Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Nov 4, 2015 at 5:00 PM, Laura Abbott <labbott@fedoraproject.org> wrote:
> Currently, read only permissions are not being applied even
> when CONFIG_DEBUG_RODATA is set. This is because section_update
> uses current->mm for adjusting the page tables. current->mm
> need not be equivalent to the kernel version. Use pgd_offset_k
> to get the proper page directory for updating.
>
> Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
> ---
> I found this while trying to convince myself of something.
> Dumping the page table via debugfs and writing to kernel text were both
> showing the lack of mappings. This was observed on QEMU. Maybe it's just a
> QEMUism but if not it probably should go to stable.

Well that's weird! debugfs showed the actual permissions that lacked
RO? I wonder what changed. I tested this both with debugfs and lkdtm's
KERN_WRITE test when the patches originally landed.

-Kees

> ---
>  arch/arm/mm/init.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index 8a63b4c..4bb936a 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -629,11 +629,9 @@ static struct section_perm ro_perms[] = {
>  static inline void section_update(unsigned long addr, pmdval_t mask,
>                                   pmdval_t prot)
>  {
> -       struct mm_struct *mm;
>         pmd_t *pmd;
>
> -       mm = current->active_mm;
> -       pmd = pmd_offset(pud_offset(pgd_offset(mm, addr), addr), addr);
> +       pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
>
>  #ifdef CONFIG_ARM_LPAE
>         pmd[0] = __pmd((pmd_val(pmd[0]) & mask) | prot);
> --
> 2.5.0
>



-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
