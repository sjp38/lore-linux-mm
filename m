Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12AD06B025E
	for <linux-mm@kvack.org>; Tue, 24 May 2016 10:54:43 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so24516272pad.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 07:54:43 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bon0085.outbound.protection.outlook.com. [157.56.111.85])
        by mx.google.com with ESMTPS id qk1si5237584pac.100.2016.05.24.07.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 May 2016 07:54:41 -0700 (PDT)
Subject: Re: [RFC PATCH v1 10/18] x86/efi: Access EFI related tables in the
 clear
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
 <20160426225740.13567.85438.stgit@tlendack-t1.amdoffice.net>
 <20160510134358.GR2839@codeblueprint.co.uk> <20160510135758.GA16783@pd.tnic>
 <5734C97D.8060803@amd.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <57446B27.20406@amd.com>
Date: Tue, 24 May 2016 09:54:31 -0500
MIME-Version: 1.0
In-Reply-To: <5734C97D.8060803@amd.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Matt Fleming <matt@codeblueprint.co.uk>, Leif Lindholm <leif.lindholm@linaro.org>, Mark Salter <msalter@redhat.com>, Daniel Kiper <daniel.kiper@oracle.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 05/12/2016 01:20 PM, Tom Lendacky wrote:
> On 05/10/2016 08:57 AM, Borislav Petkov wrote:
>> On Tue, May 10, 2016 at 02:43:58PM +0100, Matt Fleming wrote:
>>> Is it not possible to maintain some kind of kernel virtual address
>>> mapping so memremap*() and friends can figure out when to twiddle the
>>> mapping attributes and map with/without encryption?
>>
>> I guess we can move the sme_* specific stuff one indirection layer
>> below, i.e., in the *memremap() routines so that callers don't have to
>> care... That should keep the churn down...
>>
> 
> We could do that, but we'll have to generate that list of addresses so
> that it can be checked against the range being mapped.  Since this is
> part of early memmap support searching that list every time might not be
> too bad. I'll have to look into that and see what that looks like.

I looked into this and this would be a large change also to parse tables
and build lists.  It occurred to me that this could all be taken care of
if the early_memremap calls were changed to early_ioremap calls. Looking
in the git log I see that they were originally early_ioremap calls but
were changed to early_memremap calls with this commit:

commit abc93f8eb6e4 ("efi: Use early_mem*() instead of early_io*()")

Looking at the early_memremap code and the early_ioremap code they both
call __early_ioremap so I don't see how this change makes any
difference (especially since FIXMAP_PAGE_NORMAL and FIXMAP_PAGE_IO are
identical in this case).

Is it safe to change these back to early_ioremap calls (at least on
x86)?

Thanks,
Tom

> 
> Thanks,
> Tom
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
