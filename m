Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6F5928071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:50:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j28so63994183pfk.14
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:50:44 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0080.outbound.protection.outlook.com. [104.47.32.80])
        by mx.google.com with ESMTPS id e39si9142369plg.13.2017.05.19.13.50.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 May 2017 13:50:43 -0700 (PDT)
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
 <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
 <20170518090212.kebstmnjv4h3cjf2@pd.tnic>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <c0cb8a50-e860-169b-ee0c-7eb4db7c3fda@amd.com>
Date: Fri, 19 May 2017 15:50:32 -0500
MIME-Version: 1.0
In-Reply-To: <20170518090212.kebstmnjv4h3cjf2@pd.tnic>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S.
 Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 5/18/2017 4:02 AM, Borislav Petkov wrote:
> On Wed, May 17, 2017 at 01:54:39PM -0500, Tom Lendacky wrote:
>> I was worried what the compiler might do when CONFIG_EFI is not set,
>> but it appears to take care of it. I'll double check though.
>
> There's a efi_enabled() !CONFIG_EFI version too, so should be fine.
>
>> I may introduce a length variable to capture data->len right after
>> paddr_next is set and then have just a single memunmap() call before
>> the if check.
>
> Yap.
>
>> I tried that, but calling an "__init" function (early_memremap()) from
>> a non "__init" function generated warnings. I suppose I can pass in a
>> function for the map and unmap but that looks worse to me (also the
>> unmap functions take different arguments).
>
> No, the other way around: the __init function should call the non-init
> one and you need the non-init one anyway for memremap_is_setup_data().
>

The "worker" function would be doing the loop through the setup data,
but since the setup data is mapped inside the loop I can't do the __init
calling the non-init function and still hope to consolidate the code.
Maybe I'm missing something here...

Thanks,
Tom

>> This is like the chicken and the egg scenario. In order to determine if
>> an address is setup data I have to explicitly map the setup data chain
>> as decrypted. In order to do that I have to supply a flag to explicitly
>> map the data decrypted otherwise I wind up back in the
>> memremap_is_setup_data() function again and again and again...
>
> Oh, fun.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
