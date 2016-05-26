Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 001CF6B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 09:46:15 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id dh6so126572573obb.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 06:46:15 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1on0076.outbound.protection.outlook.com. [157.56.110.76])
        by mx.google.com with ESMTPS id w189si5197745itc.91.2016.05.26.06.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 May 2016 06:46:15 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk> <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com> <57446B27.20406@amd.com>
 <20160525193011.GC2984@codeblueprint.co.uk>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <5746FE16.9070408@amd.com>
Date: Thu, 26 May 2016 08:45:58 -0500
MIME-Version: 1.0
In-Reply-To: <20160525193011.GC2984@codeblueprint.co.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Borislav Petkov <bp@alien8.de>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On 05/25/2016 02:30 PM, Matt Fleming wrote:
> On Tue, 24 May, at 09:54:31AM, Tom Lendacky wrote:
>>
>> I looked into this and this would be a large change also to parse tables
>> and build lists.  It occurred to me that this could all be taken care of
>> if the early_memremap calls were changed to early_ioremap calls. Looking
>> in the git log I see that they were originally early_ioremap calls but
>> were changed to early_memremap calls with this commit:
>>
>> commit abc93f8eb6e4 ("efi: Use early_mem*() instead of early_io*()")
>>
>> Looking at the early_memremap code and the early_ioremap code they both
>> call __early_ioremap so I don't see how this change makes any
>> difference (especially since FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are
>> identical in this case).
>>
>> Is it safe to change these back to early_ioremap calls (at least on
>> x86)?
> 
> I really don't want to begin mixing early_ioremap() calls and
> early_memremap() calls for any of the EFI code if it can be avoided.

I definitely wouldn't mix them, it would be all or nothing.

> 
> There is slow but steady progress to move more and more of the
> architecture specific EFI code out into generic code. Swapping
> early_memremap() for early_ioremap() would be a step backwards,
> because FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are not identical on
> ARM/arm64.

Maybe adding something similar to __acpi_map_table would be more
appropriate?

> 
> Could you point me at the patch that in this series that fixes up
> early_ioremap() to work with mem encrypt/decrypt? I took another
> (quick) look through but couldn't find it.

The patch in question is patch 6/18 where PAGE_KERNEL is changed to
include the _PAGE_ENC attribute (the encryption mask). This now
makes FIXMAP_PAGE_NORMAL contain the encryption mask while
FIXMAP_PAGE_IO does not. In this way, anything mapped using the
early_ioremap call won't be mapped encrypted.

Thanks,
Tom

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
