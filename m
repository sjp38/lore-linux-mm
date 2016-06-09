Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A925F6B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 12:16:51 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i187so89078617qkd.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 09:16:51 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0059.outbound.protection.outlook.com. [65.55.169.59])
        by mx.google.com with ESMTPS id 88si3795128qkt.97.2016.06.09.09.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 09:16:50 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk> <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com> <57446B27.20406@amd.com>
 <20160525193011.GC2984@codeblueprint.co.uk> <5746FE16.9070408@amd.com>
 <20160608100713.GU2658@codeblueprint.co.uk>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <57599668.20000@amd.com>
Date: Thu, 9 Jun 2016 11:16:40 -0500
MIME-Version: 1.0
In-Reply-To: <20160608100713.GU2658@codeblueprint.co.uk>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Fleming <matt@codeblueprint.co.uk>
Cc: Borislav Petkov <bp@alien8.de>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

On 06/08/2016 05:07 AM, Matt Fleming wrote:
> (Sorry for the delay)

No worries, thanks for all the feedback.

> 
> On Thu, 26 May, at 08:45:58AM, Tom Lendacky wrote:
>>
>> The patch in question is patch 6/18 where PAGE_KERNEL is changed to
>> include the _PAGE_ENC attribute (the encryption mask). This now
>> makes FIXMAP_PAGE_NORMAL contain the encryption mask while
>> FIXMAP_PAGE_IO does not. In this way, anything mapped using the
>> early_ioremap call won't be mapped encrypted.
> 
> There are semantics attached to early_ioremap() that do not apply in
> this case; that you're mapping an MMIO region but for EFI we just care
> about noting where the firmware (not the kernel) populated the region
> with data. Similar problems exist for other early boot code such as
> the devicetree stuff.
> 
> early_ioremap() is not the answer.
> 
> What you really want is just some way to distinguish kernel-owned
> regions from those owned by "somebody else".
> 
> I have no problem updating early_memremap() to take a @flags argument
> to make that distinction, provided that the naming is generic and not
> tied to AMD's SME technology via an "sme" prefix/suffix.

So maybe something along the lines of an enum that would have entries
(initially) like KERNEL_DATA (equal to zero) and EFI_DATA. Others could
be added later as needed.

Would you then want to allow the protection attributes to be updated
by architecture specific code through something like a __weak function?
In the x86 case I can add this function as a non-SME specific function
that would initially just have the SME-related mask modification in it.

Thanks,
Tom

> 
> And making it generic should allow it to be easily sprinkled into the
> shared architecture code in drivers/firmware/efi/ without issue.
> 
> I'm going to follow up with some additional comments/questions on
> PATCH 10.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
