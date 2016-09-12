Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81C416B0069
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 09:43:26 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x24so357576574pfa.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 06:43:26 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0043.outbound.protection.outlook.com. [104.47.40.43])
        by mx.google.com with ESMTPS id cz4si21759074pad.270.2016.09.12.06.43.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 06:43:25 -0700 (PDT)
Subject: Re: [RFC PATCH v2 07/20] x86: Provide general kernel support for
 memory encryption
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
 <20160822223646.29880.28794.stgit@tlendack-t1.amdoffice.net>
 <20160906093113.GA18319@pd.tnic>
 <f4125cae-63af-f8c7-086f-e297ce480a07@amd.com>
 <20160907155535.i7wh46uxxa2bj3ik@pd.tnic>
 <bc8f22db-b6f9-951f-145c-fed919098cbe@amd.com>
 <20160908135551.3gtbwezbb7xpyud2@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <e92f1f20-a847-acb3-51ef-ced0329ccbd1@amd.com>
Date: Mon, 12 Sep 2016 08:43:14 -0500
MIME-Version: 1.0
In-Reply-To: <20160908135551.3gtbwezbb7xpyud2@pd.tnic>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 09/08/2016 08:55 AM, Borislav Petkov wrote:
> On Thu, Sep 08, 2016 at 08:26:27AM -0500, Tom Lendacky wrote:
>> When does this value get initialized?  Since _PAGE_ENC is #defined to
>> sme_me_mask, which is not set until the boot process begins, I'm afraid
>> we'd end up using the initial value of sme_me_mask, which is zero.  Do
>> I have that right?
> 
> Hmm, but then that would hold true for all the other defines where you
> OR-in _PAGE_ENC, no?

As long as the #define is not a global variable like this one it's ok.

> 
> In any case, the preprocessed source looks like this:
> 
> pmdval_t early_pmd_flags = (((((((pteval_t)(1)) << 0) | (((pteval_t)(1)) << 1) | (((pteval_t)(1)) << 6) | (((pteval_t)(1)) << 5) | (((pteval_t)(1)) << 8)) | (((pteval_t)(1)) << 63)) | (((pteval_t)(1)) << 7)) | sme_me_mask) & ~((((pteval_t)(1)) << 8) | (((pteval_t)(1)) << 63));
> 
> but the problem is later, when building:
> 
> arch/x86/kernel/head64.c:39:28: error: initializer element is not constant
>  pmdval_t early_pmd_flags = (__PAGE_KERNEL_LARGE | _PAGE_ENC) & ~(_PAGE_GLOBAL | _PAGE_NX);
>                             ^
> scripts/Makefile.build:153: recipe for target 'arch/x86/kernel/head64.s' failed
> 
> so I guess not. :-\
> 
> Ok, then at least please put the early_pmd_flags init after
> sme_early_init() along with a small comment explaning what happens.

Let me verify that we won't possibly take any kind of page fault during
sme_early_init() and cause a page to be not be marked encrypted. Or... I
can add a comment indicating I need to set this as early as possible to
cover any page faults that might occur.

Thanks,
Tom

> 
> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
