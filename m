Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 995126B034F
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:42:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u19so734887pfl.3
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:42:56 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id c24-v6si1374176plo.608.2018.02.07.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 09:42:55 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <cover.1517497017.git.khalid.aziz@oracle.com>
	<87wozwi0p1.fsf@xmission.com>
	<0f1bdb63-60d5-467c-a6a4-c06ba62b1f6e@oracle.com>
	<87h8qtfdvj.fsf@xmission.com>
	<c50c053f-1ee7-81f9-99bb-e5f6fe6bb43e@oracle.com>
Date: Wed, 07 Feb 2018 11:42:24 -0600
In-Reply-To: <c50c053f-1ee7-81f9-99bb-e5f6fe6bb43e@oracle.com> (Khalid Aziz's
	message of "Wed, 7 Feb 2018 09:04:50 -0700")
Message-ID: <87r2pwae7z.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v11 00/10] Application Data Integrity feature introduced by SPARC M7
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, allen.pais@oracle.com, anthony.yznaga@oracle.com, arnd@arndb.de, babu.moger@oracle.com, benh@kernel.crashing.org, bob.picco@oracle.com, bsingharora@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, dave.jiang@intel.com, david.j.aldridge@oracle.com, elena.reshetova@intel.com, glx@linutronix.de, gregkh@linuxfoundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hpa@zytor.com, hughd@google.com, imbrenda@linux.vnet.ibm.com, jack@suse.cz, jag.raman@oracle.com, jane.chu@oracle.com, jglisse@redhat.com, jroedel@suse.de, khalid@gonehiking.org, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, kstewart@linuxfoundation.org, ktkhai@virtuozzo.com, liam.merwick@oracle.com, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, me@tobin.cc, mgorman@suse.de, mgorman@techsingularity.net, mhocko@suse.com, mike.kravetz@oracle.com, minchan@kernel.org, mingo@kernel.org, mingo@redhat.com, mpe@ellerman.id.au, nadav.amit@gmail.com, nagarathnam.muthusamy@oracle.com, nborisov@suse.com, n-horiguchi@ah.jp.nec.com, nick.alcock@oracle.com, nitin.m.gupta@oracle.com, ombredanne@nexb.com, pasha.tatashin@oracle.com, paulus@samba.org, pombredanne@nexb.com, punit.agrawal@arm.com, rob.gardner@oracle.com, ross.zwisler@linux.intel.com, shannon.nelson@oracle.com, shli@fb.com, sparclinux@vger.kernel.org, steven.sistare@oracle.com, tglx@linutronix.de, thomas.tai@oracle.com, tklauser@distanz.ch, tom.hromatka@oracle.com, vegard.nossum@oracle.com, vijay.ac.kumar@oracle.com, willy@infradead.org, x86@kernel.org, zi.yan@cs.rutgers.edu

Khalid Aziz <khalid.aziz@oracle.com> writes:

> On 02/07/2018 12:38 AM, ebiederm@xmission.com wrote:
>> Khalid Aziz <khalid.aziz@oracle.com> writes:
>>
>>> On 02/01/2018 07:29 PM, ebiederm@xmission.com wrote:
>>>> Khalid Aziz <khalid.aziz@oracle.com> writes:
>>>>
>>>>> V11 changes:
>>>>> This series is same as v10 and was simply rebased on 4.15 kernel. Can
>>>>> mm maintainers please review patches 2, 7, 8 and 9 which are arch
>>>>> independent, and include/linux/mm.h and mm/ksm.c changes in patch 10
>>>>> and ack these if everything looks good?
>>>>
>>>> I am a bit puzzled how this differs from the pkey's that other
>>>> architectures are implementing to achieve a similar result.
>>>>
>>>> I am a bit mystified why you don't store the tag in a vma
>>>> instead of inventing a new way to store data on page out.
>>>
>>> Hello Eric,
>>>
>>> As Steven pointed out, sparc sets tags per cacheline unlike pkey. This results
>>> in much finer granularity for tags that pkey and hence requires larger tag
>>> storage than what we can do in a vma.
>>
>> *Nod*   I am a bit mystified where you keep the information in memory.
>> I would think the tags would need to be stored per cacheline or per
>> tlb entry, in some kind of cache that could overflow.  So I would be
>> surprised if swapping is the only time this information needs stored
>> in memory.  Which makes me wonder if you have the proper data
>> structures.
>>
>> I would think an array per vma or something in the page tables would
>> tend to make sense.
>>
>> But perhaps I am missing something.
>
> The ADI tags are stored in spare bits in the RAM. ADI tag storage is
> managed entirely by memory controller which maintains these tags per
> ADI block. An ADI block is the same size as cacheline on M7. Tags for
> each ADI block are associated with the physical ADI block, not the
> virtual address. When a physical page is reused, the physical ADI tag
> storage for that page is overwritten with new ADI tags, hence we need
> to store away the tags when we swap out a page. Kernel updates the ADI
> tags for physical page when it swaps a new page in. Each vma can cover
> variable number of pages so it is best to store a pointer to the tag
> storage in vma as opposed to actual tags in an array. Each 8K page can
> have 128 tags on it. Since each tag is 4 bits, we need 64 bytes per
> page to store the tags. That can add up for a large vma.

If the tags are already stored in RAM I can see why it does not make any
sense to store them except on page out.  Management wise this feels a
lot like the encrypted memory options I have been seeing on x86.

>>>> Can you please use force_sig_fault to send these signals instead
>>>> of force_sig_info.  Emperically I have found that it is very
>>>> error prone to generate siginfo's by hand, especially on code
>>>> paths where several different si_codes may apply.  So it helps
>>>> to go through a helper function to ensure the fiddly bits are
>>>> all correct.  AKA the unused bits all need to be set to zero before
>>>> struct siginfo is copied to userspace.
>>>>
>>>
>>> What you say makes sense. I followed the same code as other fault handlers for
>>> sparc. I could change just the fault handlers for ADI related faults. Would it
>>> make more sense to change all the fault handlers in a separate patch and keep
>>> the code in arch/sparc/kernel/traps_64.c consistent? Dave M, do you have a
>>> preference?
>>
>> It is my intention post -rc1 to start sending out patches to get the
>> rest of not just sparc but all of the architectures using the new
>> helpers.  I have the code I just ran out of time befor the merge
>> window opened to ensure everything had a good thorough review.
>>
>> So if you can handle the your new changes I expect I will handle the
>> rest.
>>
>
> I can add a patch at the end of my series to update all
> force_sig_info() in my patchset to force_sig_fault(). That will sync
> my patches up with your changes cleanly. Does that work for you? I can
> send an updated series with this change. Can you review and ack the
> patches after this change.

One additional patch would be fine.  I can certainly review and ack that
part.  You probably want to wait until post -rc1 so that you have a
clean base to work off of.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
