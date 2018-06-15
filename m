Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 426626B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 09:43:08 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r8-v6so3413534pgq.2
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 06:43:08 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l65-v6si6516952pge.46.2018.06.15.06.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 06:43:06 -0700 (PDT)
Subject: Re: [PATCHv3 07/17] x86/mm: Preserve KeyID on pte_modify() and
 pgprot_modify()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-8-kirill.shutemov@linux.intel.com>
 <8c31f6d2-6512-2726-763e-6dd1cbb0350a@intel.com>
 <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <645a4ca8-ae77-dcdd-0cbc-0da467fc210d@intel.com>
Date: Fri, 15 Jun 2018 06:43:03 -0700
MIME-Version: 1.0
In-Reply-To: <20180615125720.r755xaegvfcqfr6x@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/15/2018 05:57 AM, Kirill A. Shutemov wrote:
>>> +#define _PAGE_CHG_MASK	(PTE_PFN_MASK_MAX | _PAGE_PCD | _PAGE_PWT |		\
>>>  			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
>>>  			 _PAGE_SOFT_DIRTY)
>>>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
>> This makes me a bit nervous.  We have some places (here) where we
>> pretend that the KeyID is part of the paddr and then other places like
>> pte_pfn() where it's not.
> Other option is to include KeyID mask into _PAGE_CHG_MASK. But it means
> _PAGE_CHG_MASK would need to reference *two* variables: physical_mask and
> mktme_keyid_mask. I mentioned this in the commit message.

Why can't it be one variable with a different name that's populated by
OR'ing physical_mask and mktme_keyid_mask together?

My issue here is that it this approach adds confusion around the logical
separation between physical address and the bits immediately above the
physical address in the PTE that are stolen for the keyID.

Whatever you come up with will probably fine, as long as things that are
called "PFN" or physical address don't also get used for keyID bits.
