Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA026B0254
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 10:01:50 -0500 (EST)
Received: by oiww189 with SMTP id w189so11156436oiw.3
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:01:50 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id v186si11354628oib.14.2015.11.24.07.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 07:01:49 -0800 (PST)
Subject: Re: [PATCH] x86/mm: fix regression with huge pages on PAE
References: <20151110135303.GA11246@node.shutemov.name>
 <20151110144648.GG19187@pd.tnic> <20151110150713.GA11956@node.shutemov.name>
 <20151110170447.GH19187@pd.tnic> <20151111095101.GA22512@pd.tnic>
 <20151112074854.GA5376@gmail.com> <20151112075758.GA20702@node.shutemov.name>
 <20151112080059.GA6835@gmail.com>
 <20151112084616.EABFE19B@black.fi.intel.com>
 <20151112085418.GA18963@gmail.com>
 <20151112090018.GA22481@node.shutemov.name>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <56547B4F.6030902@oracle.com>
Date: Tue, 24 Nov 2015 09:59:27 -0500
MIME-Version: 1.0
In-Reply-To: <20151112090018.GA22481@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hpe.com, Toshi Kani <toshi.kani@hpe.com>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/12/2015 04:00 AM, Kirill A. Shutemov wrote:
> On Thu, Nov 12, 2015 at 09:54:18AM +0100, Ingo Molnar wrote:
>> * Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:
>>
>>> diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
>>> index c5b7fb2774d0..cc071c6f7d4d 100644
>>> --- a/arch/x86/include/asm/page_types.h
>>> +++ b/arch/x86/include/asm/page_types.h


Kirill, where are we with this patch?

-boris

>>> @@ -9,19 +9,21 @@
>>>   #define PAGE_SIZE	(_AC(1,UL) << PAGE_SHIFT)
>>>   #define PAGE_MASK	(~(PAGE_SIZE-1))
>>>   
>>> +#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
>>> +#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
>>> +
>>> +#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
>>> +#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
>>> +
>>>   #define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
>>>   #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
>>>   
>>> -/* Cast PAGE_MASK to a signed type so that it is sign-extended if
>>> +/* Cast *PAGE_MASK to a signed type so that it is sign-extended if
>>>      virtual addresses are 32-bits but physical addresses are larger
>>>      (ie, 32-bit PAE). */
>>>   #define PHYSICAL_PAGE_MASK	(((signed long)PAGE_MASK) & __PHYSICAL_MASK)
>>> -
>>> -#define PMD_PAGE_SIZE		(_AC(1, UL) << PMD_SHIFT)
>>> -#define PMD_PAGE_MASK		(~(PMD_PAGE_SIZE-1))
>>> -
>>> -#define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
>>> -#define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
>>> +#define PHYSICAL_PMD_PAGE_MASK	(((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
>>> +#define PHYSICAL_PUD_PAGE_MASK	(((signed long)PUD_PAGE_MASK) & __PHYSICAL_MASK)
>> that's a really odd way of writing it, 'long' is signed by default ...
> See the comment above (it was there before the patch). 'signed' can be
> considered as documentation -- we want sign-extension here.
>
>> There seems to be 150+ such cases in the kernel source though - weird.
>>
>> More importantly, how does this improve things on 32-bit PAE kernels? If I follow
>> the values correctly then PMD_PAGE_MASK is 'UL' i.e. 32-bit:
>>
>>> +#define PMD_PAGE_SIZE                (_AC(1, UL) << PMD_SHIFT)
>>> +#define PMD_PAGE_MASK                (~(PMD_PAGE_SIZE-1))
>> thus PHYSICAL_PMD_PAGE_MASK is 32-bit too:
>>
>>> +#define PHYSICAL_PMD_PAGE_MASK       (((signed long)PMD_PAGE_MASK) & __PHYSICAL_MASK)
>> so how is the bug fixed?
> Again, see the comment.
> I've checked that it generates correct value (using kernel/bounds.c).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
