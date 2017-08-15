Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8584E6B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 10:32:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id h70so10673158ioi.14
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 07:32:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y81si1822136itc.118.2017.08.15.07.32.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 07:32:36 -0700 (PDT)
Subject: Re: [PATCH v7 7/9] mm: Add address parameter to arch_validate_prot()
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <43c120f0cbbebd1398997b9521013ced664e5053.1502219353.git.khalid.aziz@oracle.com>
 <87tw1flftz.fsf@concordia.ellerman.id.au>
 <2e97b439-dd71-8997-4824-15f2b1f53787@oracle.com>
 <877ey5v2y7.fsf@concordia.ellerman.id.au>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <4b17a1f2-c6a9-ab4e-5df6-0f9aa47214cb@oracle.com>
Date: Tue, 15 Aug 2017 08:32:11 -0600
MIME-Version: 1.0
In-Reply-To: <877ey5v2y7.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, davem@davemloft.net, dave.hansen@linux.intel.com
Cc: bsingharora@gmail.com, dja@axtens.net, tglx@linutronix.de, mgorman@suse.de, aarcange@redhat.com, kirill.shutemov@linux.intel.com, heiko.carstens@de.ibm.com, ak@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On 08/14/2017 11:02 PM, Michael Ellerman wrote:
> Khalid Aziz <khalid.aziz@oracle.com> writes:
> 
>> On 08/10/2017 07:20 AM, Michael Ellerman wrote:
>>> Khalid Aziz <khalid.aziz@oracle.com> writes:
>>>
>>>> A protection flag may not be valid across entire address space and
>>>> hence arch_validate_prot() might need the address a protection bit is
>>>> being set on to ensure it is a valid protection flag. For example, sparc
>>>> processors support memory corruption detection (as part of ADI feature)
>>>> flag on memory addresses mapped on to physical RAM but not on PFN mapped
>>>> pages or addresses mapped on to devices. This patch adds address to the
>>>> parameters being passed to arch_validate_prot() so protection bits can
>>>> be validated in the relevant context.
>>>>
>>>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>>>> Cc: Khalid Aziz <khalid@gonehiking.org>
>>>> ---
>>>> v7:
>>>> 	- new patch
>>>>
>>>>    arch/powerpc/include/asm/mman.h | 2 +-
>>>>    arch/powerpc/kernel/syscalls.c  | 2 +-
>>>>    include/linux/mman.h            | 2 +-
>>>>    mm/mprotect.c                   | 2 +-
>>>>    4 files changed, 4 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
>>>> index 30922f699341..bc74074304a2 100644
>>>> --- a/arch/powerpc/include/asm/mman.h
>>>> +++ b/arch/powerpc/include/asm/mman.h
>>>> @@ -40,7 +40,7 @@ static inline bool arch_validate_prot(unsigned long prot)
>>>>    		return false;
>>>>    	return true;
>>>>    }
>>>> -#define arch_validate_prot(prot) arch_validate_prot(prot)
>>>> +#define arch_validate_prot(prot, addr) arch_validate_prot(prot)
>>>
>>> This can be simpler, as just:
>>>
>>> #define arch_validate_prot arch_validate_prot
>>>
>>
>> Hi Michael,
>>
>> Thanks for reviewing!
>>
>> My patch expands parameter list for arch_validate_prot() from one to two
>> parameters. Existing powerpc version of arch_validate_prot() is written
>> with one parameter. If I use the above #define, compilation fails with:
>>
>> mm/mprotect.c: In function a??do_mprotect_pkeya??:
>> mm/mprotect.c:399: error: too many arguments to function
>> a??arch_validate_prota??
>>
>> Another way to solve it would be to add the new addr parameter to
>> powerpc version of arch_validate_prot() but I chose the less disruptive
>> solution of tackling it through #define and expanded the existing
>> #define to include the new parameter. Make sense?
> 
> Yes, it makes sense. But it's a bit gross.
> 
> At first glance it looks like our arch_validate_prot() has an incorrect
> signature.
> 
> I'd prefer you just updated it to have the correct signature, I think
> you'll have to change one more line in do_mmap2(). So it's not very
> intrusive.

Thanks, Michael. I can do that.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
