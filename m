Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6E6A6B0007
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 09:22:05 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e1-v6so10063080pld.23
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 06:22:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z12-v6si14472350plk.48.2018.06.18.06.22.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 06:22:04 -0700 (PDT)
Subject: Re: [PATCHv3 14/17] x86/mm: Introduce direct_mapping_size
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-15-kirill.shutemov@linux.intel.com>
 <4ece14a4-27bd-e10a-4c2c-822c3e629dcd@intel.com>
 <20180618131247.myt6vjiav3nwww5p@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ba2950ff-dc47-43c0-a096-ad993114c301@intel.com>
Date: Mon, 18 Jun 2018 06:22:01 -0700
MIME-Version: 1.0
In-Reply-To: <20180618131247.myt6vjiav3nwww5p@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/18/2018 06:12 AM, Kirill A. Shutemov wrote:
> On Wed, Jun 13, 2018 at 06:37:07PM +0000, Dave Hansen wrote:
>> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
>>> Kernel need to have a way to access encrypted memory. We are going to
>> "The kernel needs"...
>>
>>> use per-KeyID direct mapping to facilitate the access with minimal
>>> overhead.
>>
>> What are the security implications of this approach?
> 
> I'll add this to the message:
> 
> Per-KeyID mappings require a lot more virtual address space. On 4-level
> machine with 64 KeyIDs we max out 46-bit virtual address space dedicated
> for direct mapping with 1TiB of RAM. Given that we round up any
> calculation on direct mapping size to 1TiB, we effectively claim all
> 46-bit address space for direct mapping on such machine regardless of
> RAM size.
...

I was thinking more in terms of the exposure of keeping the plaintext
mapped all the time.

Imagine Meltdown if the decrypted page is not mapped into the kernel:
this feature could actually have protected user data.

But, with this scheme, it exposes the data... all the data... with all
possible keys... all the time.  That's one heck of an attack surface.
Can we do better?

>>>  struct page_ext_operations page_mktme_ops = {
>>>  	.need = need_page_mktme,
>>>  };
>>> +
>>> +void __init setup_direct_mapping_size(void)
>>> +{
...
>>> +}
>>
>> Do you really need two copies of this function?  Shouldn't it see
>> mktme_status!=MKTME_ENUMERATED and just jump out?  How is the code
>> before that "goto out" different from the CONFIG_MKTME=n case?
> 
> mktme.c is not compiled for CONFIG_MKTME=n.

I'd rather have one copy in shared code which is mosty optimized away
when CONFIG_MKTME=n than two copies.
