Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2A946B0003
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 12:36:46 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bf1-v6so8489737plb.2
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:36:46 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f32-v6si8752851plf.38.2018.06.25.09.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 09:36:45 -0700 (PDT)
Subject: Re: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
 <848a6836-1f54-4775-0b87-e926d7b7991d@intel.com>
 <20180625092937.gmu6m7kwet5s5w6m@black.fi.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <0ac027dd-ca4b-316e-ee2c-64305e633b1b@intel.com>
Date: Mon, 25 Jun 2018 09:36:43 -0700
MIME-Version: 1.0
In-Reply-To: <20180625092937.gmu6m7kwet5s5w6m@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/25/2018 02:29 AM, Kirill A. Shutemov wrote:
> On Mon, Jun 18, 2018 at 04:28:27PM +0000, Dave Hansen wrote:
>>>  
>>>  	remove_pagetable(start, end, true, NULL);
>>> +	ret = sync_direct_mapping();
>>> +	WARN_ON(ret);
>>>  }
>>
>> I understand why you implemented it this way, I really do.  It's
>> certainly the quickest way to hack something together and make a
>> standalone piece of code.  But, I don't think it's maintainable.
>>
>> For instance, this call to sync_direct_mapping() could be entirely
>> replaced by a call to:
>>
>> 	for_each_keyid(k)...
>> 		remove_pagetable(start + offset_per_keyid * k,
>> 			         end   + offset_per_keyid * k,
>> 				 true, NULL);
>>
>> No?
> 
> Yes. But what's the point if we need to have the sync routine anyway for
> the add path?

Because you are working to remove the sync routine and make an effort to
share more code with the regular direct map manipulation.  Right?

My point is that this patch did not even make an _effort_ to reuse code
where it would have been quite trivial to do so.  I think such an effort
needs to be put forth before we add 400 more lines of page table
manipulation.

>>>  int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
>>> @@ -1290,6 +1295,7 @@ void mark_rodata_ro(void)
>>>  			(unsigned long) __va(__pa_symbol(rodata_end)),
>>>  			(unsigned long) __va(__pa_symbol(_sdata)));
>>>  
>>> +	sync_direct_mapping();
>>>  	debug_checkwx();
>>
>> Huh, checking the return code in some cases and not others.  Curious.
>> Why is it that way?
> 
> There's no sensible way to handle failure in any of these path. But in
> remove path we don't expect the failure -- no allocation required.
> It can only happen if we missed sync_direct_mapping() somewhere else.

So, should we just silently drop the error?  Or, would it be sensible to
make this a WARN_ON_ONCE()?
