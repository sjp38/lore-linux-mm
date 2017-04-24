Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93F8E6B02EE
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:54:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id l30so15683326pgc.15
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:54:09 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0088.outbound.protection.outlook.com. [104.47.38.88])
        by mx.google.com with ESMTPS id g73si19491854pfg.34.2017.04.24.08.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 08:54:08 -0700 (PDT)
Subject: Re: [PATCH v5 09/32] x86/mm: Provide general kernel support for
 memory encryption
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211754.10190.25082.stgit@tlendack-t1.amdoffice.net>
 <0106e3fc-9780-e872-2274-fecf79c28923@intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <9fc79e28-ad64-1c2f-4c46-a4efcdd550b0@amd.com>
Date: Mon, 24 Apr 2017 10:53:58 -0500
MIME-Version: 1.0
In-Reply-To: <0106e3fc-9780-e872-2274-fecf79c28923@intel.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 4/21/2017 4:52 PM, Dave Hansen wrote:
> On 04/18/2017 02:17 PM, Tom Lendacky wrote:
>> @@ -55,7 +57,7 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
>>  	__phys_addr_symbol(__phys_reloc_hide((unsigned long)(x)))
>>
>>  #ifndef __va
>> -#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
>> +#define __va(x)			((void *)(__sme_clr(x) + PAGE_OFFSET))
>>  #endif
>
> It seems wrong to be modifying __va().  It currently takes a physical
> address, and this modifies it to take a physical address plus the SME bits.

This actually modifies it to be sure the encryption bit is not part of
the physical address.

>
> How does that end up ever happening?  If we are pulling physical
> addresses out of the page tables, we use p??_phys().  I'd expect *those*
> to be masking off the SME bits.
>
> Is it these cases?
>
> 	pgd_t *base = __va(read_cr3());
>
> For those, it seems like we really want to create two modes of reading
> cr3.  One that truly reads CR3 and another that reads the pgd's physical
> address out of CR3.  Then you only do the SME masking on the one
> fetching a physical address, and the SME bits never leak into __va().

I'll investigate this and see if I can remove the mod to __va().

Thanks,
Tom

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
