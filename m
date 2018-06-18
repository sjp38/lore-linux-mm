Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 554946B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:59:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u16-v6so8669000pfm.15
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:59:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d1-v6si16221092pln.471.2018.06.18.06.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:59:19 -0700 (PDT)
Subject: Re: [PATCHv3 16/17] x86/mm: Handle encrypted memory in page_to_virt()
 and __pa()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-17-kirill.shutemov@linux.intel.com>
 <f8b9da42-1f7b-529c-bfdd-e82f669f6fe8@intel.com>
 <20180618133455.aumn4wihygvds543@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <48fe7072-e92d-959a-67f7-ded82124f79f@intel.com>
Date: Mon, 18 Jun 2018 06:59:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180618133455.aumn4wihygvds543@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/18/2018 06:34 AM, Kirill A. Shutemov wrote:
> On Wed, Jun 13, 2018 at 06:43:08PM +0000, Dave Hansen wrote:
>>> diff --git a/arch/x86/include/asm/mktme.h b/arch/x86/include/asm/mktme.h
>>> index efc0d4bb3b35..d6edcabacfc7 100644
>>> --- a/arch/x86/include/asm/mktme.h
>>> +++ b/arch/x86/include/asm/mktme.h
>>> @@ -43,6 +43,9 @@ void mktme_disable(void);
>>>  void setup_direct_mapping_size(void);
>>>  int sync_direct_mapping(void);
>>>  
>>> +#define page_to_virt(x) \
>>> +	(__va(PFN_PHYS(page_to_pfn(x))) + page_keyid(x) * direct_mapping_size)
>>
>> This looks like a super important memory management function being
>> defined in some obscure Intel-specific feature header.  How does that work?
> 
> No magic. It overwrites define in <linux/mm.h>.

It frankly looks like magic to me.  How can this possibly work without
ensuring that asm/mktme.h is #included everywhere on every file compiled
for the entire architecture?

If we look at every definition of page_to_virt() on every architecture
in the kernel, we see it uniquely defined in headers that look rather
generic.  I don't see any precedent for feature-specific definitions.

> arch/arm64/include/asm/memory.h:#define page_to_virt(page)	((void *)((__page_to_voff(page)) | PAGE_OFFSET))
> arch/hexagon/include/asm/page.h:#define page_to_virt(page)	__va(page_to_phys(page))
> arch/m68k/include/asm/page_mm.h:#define page_to_virt(page) ({						\
> arch/m68k/include/asm/page_no.h:#define page_to_virt(page)	__va(((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET))
> arch/microblaze/include/asm/page.h:#  define page_to_virt(page)   __va(page_to_pfn(page) << PAGE_SHIFT)
> arch/microblaze/include/asm/page.h:#  define page_to_virt(page)	(pfn_to_virt(page_to_pfn(page)))
> arch/nios2/include/asm/page.h:#define page_to_virt(page)	\
> arch/riscv/include/asm/page.h:#define page_to_virt(page)	(pfn_to_virt(page_to_pfn(page)))
> arch/s390/include/asm/page.h:#define page_to_virt(page)	pfn_to_virt(page_to_pfn(page))
> arch/xtensa/include/asm/page.h:#define page_to_virt(page)	__va(page_to_pfn(page) << PAGE_SHIFT)

*If* you do this, I think it 100% *HAS* to be done in a central header,
like x86's page.h.  We need a single x86 macro for this, not something
which can and will change based on #include ordering and Kconfig.
