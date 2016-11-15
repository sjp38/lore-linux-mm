Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C98D6B0298
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 11:06:35 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id q186so6537688itb.0
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:06:35 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0063.outbound.protection.outlook.com. [104.47.32.63])
        by mx.google.com with ESMTPS id 32si16194051ios.116.2016.11.15.08.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 08:06:33 -0800 (PST)
Subject: Re: [RFC PATCH v3 04/20] x86: Handle reduction in physical address
 size with SME
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
 <20161110003513.3280.12104.stgit@tlendack-t1.amdoffice.net>
 <20161115121035.GD24857@8bytes.org> <20161115121456.f4slpk4i2jl3e2ke@pd.tnic>
 <a4cc5b07-89e1-aaa0-1977-1de95883ba62@amd.com>
 <20161115153338.a2cxmatnpqcgiaiy@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <bb47e943-f5b6-0d73-cf9a-fea002a5c70e@amd.com>
Date: Tue, 15 Nov 2016 10:06:16 -0600
MIME-Version: 1.0
In-Reply-To: <20161115153338.a2cxmatnpqcgiaiy@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Joerg Roedel <joro@8bytes.org>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 11/15/2016 9:33 AM, Borislav Petkov wrote:
> On Tue, Nov 15, 2016 at 08:40:05AM -0600, Tom Lendacky wrote:
>> The feature may be present and enabled even if it is not currently
>> active.  In other words, the SYS_CFG MSR bit could be set but we aren't
>> actually using encryption (sme_me_mask is 0).  As long as the SYS_CFG
>> MSR bit is set we need to take into account the physical reduction in
>> address space.
> 
> But later in the series I see sme_early_mem_enc() which tests exactly
> that mask.

Yes, but that doesn't relate to the physical address space reduction.

Once the SYS_CFG MSR bit for SME is set, even if the encryption bit is
never used, there is a physical reduction of the address space. So when
checking whether to adjust the physical address bits I can't rely on the
sme_me_mask, I have to look at the MSR.

But when I'm looking to decide whether to encrypt or decrypt something,
I use the sme_me_mask to decide if that is needed.  If the sme_me_mask
is not set then the encrypt/decrypt op shouldn't be performed.

I might not be grasping the point you're trying to make...

Thanks,
Tom

> 
> And in patch 12 you have:
> 
> +       /*
> +        * If memory encryption is active, the trampoline area will need to
> +        * be in un-encrypted memory in order to bring up other processors
> +        * successfully.
> +        */
> +       sme_early_mem_dec(__pa(base), size);
> +       sme_set_mem_unenc(base, size);
> 
> What's up?
> 
> IOW, it all sounds to me like you want to have an sme_active() helper
> and use it everywhere.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
