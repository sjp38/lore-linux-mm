Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 828346B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 12:55:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 93so334341405qtg.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 09:55:31 -0700 (PDT)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id p63si5530210vkf.156.2016.09.12.09.55.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 09:55:30 -0700 (PDT)
Received: by mail-vk0-x22f.google.com with SMTP id v189so143464431vkv.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 09:55:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net> <20160822223738.29880.6909.stgit@tlendack-t1.amdoffice.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 12 Sep 2016 09:55:09 -0700
Message-ID: <CALCETrUk2kRSzKfwhio6KV3iuYaSV2uxybd-e95kK3vY=yTSfg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 11/20] mm: Access BOOT related data in the clear
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Matt Fleming <mfleming@suse.de>
Cc: kasan-dev <kasan-dev@googlegroups.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, iommu@lists.linux-foundation.org, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, kvm list <kvm@vger.kernel.org>

On Aug 22, 2016 6:53 PM, "Tom Lendacky" <thomas.lendacky@amd.com> wrote:
>
> BOOT data (such as EFI related data) is not encyrpted when the system is
> booted and needs to be accessed as non-encrypted.  Add support to the
> early_memremap API to identify the type of data being accessed so that
> the proper encryption attribute can be applied.  Currently, two types
> of data are defined, KERNEL_DATA and BOOT_DATA.

What happens when you memremap boot services data outside of early
boot?  Matt just added code that does this.

IMO this API is not so great.  It scatters a specialized consideration
all over the place.  Could early_memremap not look up the PA to figure
out what to do?

--Andy

[leaving the rest here for Matt's benefit]

>                      unsigned long size,
> +                                                   enum memremap_owner owner,
> +                                                   pgprot_t prot)
> +{
> +       return prot;
> +}
> +
>  void __init early_ioremap_reset(void)
>  {
>         early_ioremap_shutdown();
> @@ -213,16 +221,23 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
>
>  /* Remap memory */
>  void __init *
> -early_memremap(resource_size_t phys_addr, unsigned long size)
> +early_memremap(resource_size_t phys_addr, unsigned long size,
> +              enum memremap_owner owner)
>  {
> -       return (__force void *)__early_ioremap(phys_addr, size,
> -                                              FIXMAP_PAGE_NORMAL);
> +       pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size, owner,
> +                                                    FIXMAP_PAGE_NORMAL);
> +
> +       return (__force void *)__early_ioremap(phys_addr, size, prot);
>  }
>  #ifdef FIXMAP_PAGE_RO
>  void __init *
> -early_memremap_ro(resource_size_t phys_addr, unsigned long size)
> +early_memremap_ro(resource_size_t phys_addr, unsigned long size,
> +                 enum memremap_owner owner)
>  {
> -       return (__force void *)__early_ioremap(phys_addr, size, FIXMAP_PAGE_RO);
> +       pgprot_t prot = early_memremap_pgprot_adjust(phys_addr, size, owner,
> +                                                    FIXMAP_PAGE_RO);
> +
> +       return (__force void *)__early_ioremap(phys_addr, size, prot);
>  }
>  #endif
>
> @@ -236,7 +251,8 @@ early_memremap_prot(resource_size_t phys_addr, unsigned long size,
>
>  #define MAX_MAP_CHUNK  (NR_FIX_BTMAPS << PAGE_SHIFT)
>
> -void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
> +void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size,
> +                               enum memremap_owner owner)
>  {
>         unsigned long slop, clen;
>         char *p;
> @@ -246,7 +262,7 @@ void __init copy_from_early_mem(void *dest, phys_addr_t src, unsigned long size)
>                 clen = size;
>                 if (clen > MAX_MAP_CHUNK - slop)
>                         clen = MAX_MAP_CHUNK - slop;
> -               p = early_memremap(src & PAGE_MASK, clen + slop);
> +               p = early_memremap(src & PAGE_MASK, clen + slop, owner);
>                 memcpy(dest, p + slop, clen);
>                 early_memunmap(p, clen + slop);
>                 dest += clen;
> @@ -265,12 +281,14 @@ early_ioremap(resource_size_t phys_addr, unsigned long size)
>
>  /* Remap memory */
>  void __init *
> -early_memremap(resource_size_t phys_addr, unsigned long size)
> +early_memremap(resource_size_t phys_addr, unsigned long size,
> +              enum memremap_owner owner)
>  {
>         return (void *)phys_addr;
>  }
>  void __init *
> -early_memremap_ro(resource_size_t phys_addr, unsigned long size)
> +early_memremap_ro(resource_size_t phys_addr, unsigned long size,
> +                 enum memremap_owner owner)
>  {
>         return (void *)phys_addr;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
