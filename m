Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A69916B025F
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:32:35 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id m198so9583745oig.20
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:32:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l125si5218884oib.84.2017.11.06.00.32.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 00:32:34 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
Date: Mon, 6 Nov 2017 09:32:25 +0100
MIME-Version: 1.0
In-Reply-To: <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On 11/06/2017 09:30 AM, Aneesh Kumar K.V wrote:
> On 11/06/2017 01:55 PM, Nicholas Piggin wrote:
>> On Mon, 6 Nov 2017 09:11:37 +0100
>> Florian Weimer <fweimer@redhat.com> wrote:
>>
>>> On 11/06/2017 07:47 AM, Nicholas Piggin wrote:
>>>> "You get < 128TB unless explicitly requested."
>>>>
>>>> Simple, reasonable, obvious rule. Avoids breaking apps that store
>>>> some bits in the top of pointers (provided that memory allocator
>>>> userspace libraries also do the right thing).
>>>
>>> So brk would simplify fail instead of crossing the 128 TiB threshold?
>>
>> Yes, that was the intention and that's what x86 seems to do.
>>
>>>
>>> glibc malloc should cope with that and switch to malloc, but this code
>>> path is obviously less well-tested than the regular way.
>>
>> Switch to mmap() I guess you meant?

Yes, sorry.

>> powerpc has a couple of bugs in corner cases, so those should be fixed
>> according to intended policy for stable kernels I think.
>>
>> But I question the policy. Just seems like an ugly and ineffective wart.
>> Exactly for such cases as this -- behaviour would change from run to run
>> depending on your address space randomization for example! In case your
>> brk happens to land nicely on 128TB then the next one would succeed.
> 
> Why ? It should not change between run to run. We limit the free
> area search range based on hint address. So we should get consistent 
> results across run. even if we changed the context.addr_limit.

The size of the gap to the 128 TiB limit varies between runs because of 
ASLR.  So some runs would use brk alone, others would use brk + malloc. 
That's not really desirable IMHO.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
