Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 655FD6B0261
	for <linux-mm@kvack.org>; Wed, 25 May 2016 15:30:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f75so33637721wmf.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 12:30:17 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id k199si735826lfb.146.2016.05.25.12.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 12:30:16 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id w16so10396902lfd.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 12:30:15 -0700 (PDT)
Date: Wed, 25 May 2016 20:30:11 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
Message-ID: <20160525193011.GC2984@codeblueprint.co.uk>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk>
 <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com>
 <57446B27.20406@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57446B27.20406@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Borislav Petkov <bp@alien8.de>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On Tue, 24 May, at 09:54:31AM, Tom Lendacky wrote:
> 
> I looked into this and this would be a large change also to parse tables
> and build lists.  It occurred to me that this could all be taken care of
> if the early_memremap calls were changed to early_ioremap calls. Looking
> in the git log I see that they were originally early_ioremap calls but
> were changed to early_memremap calls with this commit:
> 
> commit abc93f8eb6e4 ("efi: Use early_mem*() instead of early_io*()")
> 
> Looking at the early_memremap code and the early_ioremap code they both
> call __early_ioremap so I don't see how this change makes any
> difference (especially since FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are
> identical in this case).
> 
> Is it safe to change these back to early_ioremap calls (at least on
> x86)?

I really don't want to begin mixing early_ioremap() calls and
early_memremap() calls for any of the EFI code if it can be avoided.

There is slow but steady progress to move more and more of the
architecture specific EFI code out into generic code. Swapping
early_memremap() for early_ioremap() would be a step backwards,
because FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are not identical on
ARM/arm64.

Could you point me at the patch that in this series that fixes up
early_ioremap() to work with mem encrypt/decrypt? I took another
(quick) look through but couldn't find it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
