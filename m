Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0338F6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:46:42 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p62so3445876wrc.13
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 08:46:41 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id r22si2995434wrc.146.2017.04.27.08.46.40
        for <linux-mm@kvack.org>;
        Thu, 27 Apr 2017 08:46:40 -0700 (PDT)
Date: Thu, 27 Apr 2017 17:46:31 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 06/32] x86/mm: Add Secure Memory Encryption (SME)
 support
Message-ID: <20170427154631.2tsqgax4kqcvydnx@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211727.10190.18774.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170418211727.10190.18774.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, Apr 18, 2017 at 04:17:27PM -0500, Tom Lendacky wrote:
> Add support for Secure Memory Encryption (SME). This initial support
> provides a Kconfig entry to build the SME support into the kernel and
> defines the memory encryption mask that will be used in subsequent
> patches to mark pages as encrypted.

...

> diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
> new file mode 100644
> index 0000000..d5c4a2b
> --- /dev/null
> +++ b/arch/x86/include/asm/mem_encrypt.h
> @@ -0,0 +1,42 @@
> +/*
> + * AMD Memory Encryption Support
> + *
> + * Copyright (C) 2016 Advanced Micro Devices, Inc.
> + *
> + * Author: Tom Lendacky <thomas.lendacky@amd.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +

These ifdeffery closing #endif markers look strange:

> +#ifndef __X86_MEM_ENCRYPT_H__
> +#define __X86_MEM_ENCRYPT_H__
> +
> +#ifndef __ASSEMBLY__
> +
> +#ifdef CONFIG_AMD_MEM_ENCRYPT
> +
> +extern unsigned long sme_me_mask;
> +
> +static inline bool sme_active(void)
> +{
> +	return !!sme_me_mask;
> +}
> +
> +#else	/* !CONFIG_AMD_MEM_ENCRYPT */
> +
> +#ifndef sme_me_mask
> +#define sme_me_mask	0UL
> +
> +static inline bool sme_active(void)
> +{
> +	return false;
> +}
> +#endif

this endif is the sme_me_mask closing one and it has sme_active() in it.
Shouldn't it be:

#ifndef sme_me_mask
#define sme_me_mask  0UL
#endif

and have sme_active below it, in the !CONFIG_AMD_MEM_ENCRYPT branch?

The same thing is in include/linux/mem_encrypt.h

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
