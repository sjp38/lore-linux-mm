Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 379A96B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:44:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s63so37795944wme.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:44:16 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id u64si8911464wmd.74.2016.04.27.05.44.15
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 05:44:15 -0700 (PDT)
Date: Tue, 22 Mar 2016 14:03:54 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH v1 03/18] x86: Secure Memory Encryption (SME) support
Message-ID: <20160322130354.GC16528@xo-6d-61-c0.localdomain>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225626.13567.72425.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160426225626.13567.72425.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue 2016-04-26 17:56:26, Tom Lendacky wrote:
> Provide support for Secure Memory Encryption (SME). This initial support
> defines the memory encryption mask as a variable for quick access and an
> accessor for retrieving the number of physical addressing bits lost if
> SME is enabled.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   37 ++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/Makefile           |    2 ++
>  arch/x86/kernel/mem_encrypt.S      |   29 ++++++++++++++++++++++++++++
>  arch/x86/kernel/x8664_ksyms_64.c   |    6 ++++++
>  4 files changed, 74 insertions(+)
>  create mode 100644 arch/x86/include/asm/mem_encrypt.h
>  create mode 100644 arch/x86/kernel/mem_encrypt.S
> 
> index 0000000..ef7f325
> --- /dev/null
> +++ b/arch/x86/kernel/mem_encrypt.S
> @@ -0,0 +1,29 @@
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
> +#include <linux/linkage.h>
> +
> +	.text
> +	.code64
> +ENTRY(sme_get_me_loss)
> +	xor	%rax, %rax
> +	mov	sme_me_loss(%rip), %al
> +	ret
> +ENDPROC(sme_get_me_loss)

Does this really need to be implemented in assembly?


-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
