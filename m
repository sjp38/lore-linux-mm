Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C74D36B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 18:12:46 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id y13so9727173oty.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 15:12:46 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0074.outbound.protection.outlook.com. [104.47.42.74])
        by mx.google.com with ESMTPS id y74si6105972ioi.133.2017.02.23.15.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 15:12:45 -0800 (PST)
Subject: Re: [RFC PATCH v4 07/28] x86: Provide general kernel support for
 memory encryption
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
 <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
 <a3f56612-396e-b230-d909-93a7128ea2fc@intel.com>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <73a2c1f7-bc71-3ca8-c312-9a930250cb18@amd.com>
Date: Thu, 23 Feb 2017 17:12:38 -0600
MIME-Version: 1.0
In-Reply-To: <a3f56612-396e-b230-d909-93a7128ea2fc@intel.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

On 2/22/2017 12:13 PM, Dave Hansen wrote:
> On 02/16/2017 07:43 AM, Tom Lendacky wrote:
>>  static inline unsigned long pte_pfn(pte_t pte)
>>  {
>> -	return (pte_val(pte) & PTE_PFN_MASK) >> PAGE_SHIFT;
>> +	return (pte_val(pte) & ~sme_me_mask & PTE_PFN_MASK) >> PAGE_SHIFT;
>>  }
>>
>>  static inline unsigned long pmd_pfn(pmd_t pmd)
>>  {
>> -	return (pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
>> +	return (pmd_val(pmd) & ~sme_me_mask & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
>>  }
>
> Could you talk a bit about why you chose to do the "~sme_me_mask" bit in
> here instead of making it a part of PTE_PFN_MASK / pmd_pfn_mask(pmd)?

I think that's a good catch.  Let me look at it, but I believe that it
should be possible to do and avoid what you're worried about below.

Thanks,
Tom

>
> It might not matter, but I'd be worried that this ends up breaking
> direct users of PTE_PFN_MASK / pmd_pfn_mask(pmd) since they now no
> longer mask the PFN out of a PTE.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
