Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 383746B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 09:13:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j28so14258613pfk.14
        for <linux-mm@kvack.org>; Wed, 31 May 2017 06:13:06 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0047.outbound.protection.outlook.com. [104.47.40.47])
        by mx.google.com with ESMTPS id f34si25028576ple.151.2017.05.31.06.13.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 May 2017 06:13:05 -0700 (PDT)
Subject: Re: [PATCH v5 29/32] x86/mm: Add support to encrypt the kernel
 in-place
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212149.10190.70894.stgit@tlendack-t1.amdoffice.net>
 <20170518124626.hqyqqbjpy7hmlpqc@pd.tnic>
 <7e2ae014-525c-76f2-9fce-2124596db2d2@amd.com>
 <20170526162522.p7prrqqalx2ivfxl@pd.tnic>
 <33c075b1-71f6-b5d0-b1fa-d742d0659d38@amd.com>
 <20170531095148.pba6ju6im4qxbwfg@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <17394b27-d693-4ff9-9dbd-11b5237fcf6a@amd.com>
Date: Wed, 31 May 2017 08:12:56 -0500
MIME-Version: 1.0
In-Reply-To: <20170531095148.pba6ju6im4qxbwfg@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/31/2017 4:51 AM, Borislav Petkov wrote:
> On Tue, May 30, 2017 at 11:39:07AM -0500, Tom Lendacky wrote:
>> Yes, it's from objtool:
>>
>> arch/x86/mm/mem_encrypt_boot.o: warning: objtool: .text+0xd2: return
>> instruction outside of a callable function
> 
> Oh, well, let's make it a global symbol then. Who knows, we might have
> to live-patch it someday :-)

Can do.

Thanks,
Tom

> 
> ---
> diff --git a/arch/x86/mm/mem_encrypt_boot.S b/arch/x86/mm/mem_encrypt_boot.S
> index fb58f9f953e3..7720b0050840 100644
> --- a/arch/x86/mm/mem_encrypt_boot.S
> +++ b/arch/x86/mm/mem_encrypt_boot.S
> @@ -47,9 +47,9 @@ ENTRY(sme_encrypt_execute)
>   	movq	%rdx, %r12		/* Kernel length */
>   
>   	/* Copy encryption routine into the workarea */
> -	movq	%rax, %rdi		/* Workarea encryption routine */
> -	leaq	.Lenc_start(%rip), %rsi	/* Encryption routine */
> -	movq	$(.Lenc_stop - .Lenc_start), %rcx	/* Encryption routine length */
> +	movq	%rax, %rdi				/* Workarea encryption routine */
> +	leaq	__enc_copy(%rip), %rsi			/* Encryption routine */
> +	movq	$(.L__enc_copy_end - __enc_copy), %rcx	/* Encryption routine length */
>   	rep	movsb
>   
>   	/* Setup registers for call */
> @@ -70,8 +70,7 @@ ENTRY(sme_encrypt_execute)
>   	ret
>   ENDPROC(sme_encrypt_execute)
>   
> -.Lenc_start:
> -ENTRY(sme_enc_routine)
> +ENTRY(__enc_copy)
>   /*
>    * Routine used to encrypt kernel.
>    *   This routine must be run outside of the kernel proper since
> @@ -147,5 +146,5 @@ ENTRY(sme_enc_routine)
>   	wrmsr
>   
>   	ret
> -ENDPROC(sme_enc_routine)
> -.Lenc_stop:
> +.L__enc_copy_end:
> +ENDPROC(__enc_copy)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
