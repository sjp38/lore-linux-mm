Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD51D6B0311
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:17:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v74so87979070oie.10
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:17:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l202si3703874oig.222.2017.06.20.09.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:17:48 -0700 (PDT)
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D50D8239E2
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:17:47 +0000 (UTC)
Received: by mail-ua0-f175.google.com with SMTP id 70so20946981uau.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:17:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170616185154.18967.71073.stgit@tlendack-t1.amdoffice.net>
References: <20170616184947.18967.84890.stgit@tlendack-t1.amdoffice.net> <20170616185154.18967.71073.stgit@tlendack-t1.amdoffice.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 20 Jun 2017 09:17:26 -0700
Message-ID: <CALCETrVkyj=wfcgNMVG_BU+xGb3yBNhxrDdSTxJLx7UYraVcUA@mail.gmail.com>
Subject: Re: [PATCH v7 11/36] x86/mm: Add SME support for read_cr3_pa()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, kvm list <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, X86 ML <x86@kernel.org>, kexec@lists.infradead.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, xen-devel <xen-devel@lists.xen.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, iommu@lists.linux-foundation.org, Brijesh Singh <brijesh.singh@amd.com>, Toshimitsu Kani <toshi.kani@hpe.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Matt Fleming <matt@codeblueprint.co.uk>, Alexander Potapenko <glider@google.com>, "H. Peter Anvin" <hpa@zytor.com>, Larry Woodman <lwoodman@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, "Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave Young <dyoung@redhat.com>, Rik van Riel <riel@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dmitry Vyukov <dvyukov@google.com>, Juergen Gross <jgross@suse.com>, Thomas Gleixner <tglx@linutronix.de>, Paolo Bonzini <pbonzini@redhat.com>

On Fri, Jun 16, 2017 at 11:51 AM, Tom Lendacky <thomas.lendacky@amd.com> wrote:
> The cr3 register entry can contain the SME encryption mask that indicates
> the PGD is encrypted.  The encryption mask should not be used when
> creating a virtual address from the cr3 register, so remove the SME
> encryption mask in the read_cr3_pa() function.
>
> During early boot SME will need to use a native version of read_cr3_pa(),
> so create native_read_cr3_pa().
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/processor-flags.h |    3 ++-
>  arch/x86/include/asm/processor.h       |    5 +++++
>  2 files changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
> index 79aa2f9..cb6999c 100644
> --- a/arch/x86/include/asm/processor-flags.h
> +++ b/arch/x86/include/asm/processor-flags.h
> @@ -2,6 +2,7 @@
>  #define _ASM_X86_PROCESSOR_FLAGS_H
>
>  #include <uapi/asm/processor-flags.h>
> +#include <linux/mem_encrypt.h>
>
>  #ifdef CONFIG_VM86
>  #define X86_VM_MASK    X86_EFLAGS_VM
> @@ -33,7 +34,7 @@
>   */
>  #ifdef CONFIG_X86_64
>  /* Mask off the address space ID bits. */
> -#define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
> +#define CR3_ADDR_MASK __sme_clr(0x7FFFFFFFFFFFF000ull)

Can you update the comment one line above, too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
