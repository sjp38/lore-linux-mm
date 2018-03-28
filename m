Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 018926B002D
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:15:42 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t19so1060158wmh.3
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:15:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j30si2938739edc.316.2018.03.28.04.15.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 04:15:41 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2SBF6Gt066515
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:15:40 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h090djpp7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:15:39 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 28 Mar 2018 12:15:37 +0100
Subject: Re: [PATCH v9 01/24] mm: Introduce CONFIG_SPECULATIVE_PAGE_FAULT
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1520963994-28477-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803251442090.80485@chino.kir.corp.google.com>
 <32c80b6a-28c6-bf63-ed7b-6a042ae18e8f@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1803280310380.68839@chino.kir.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 28 Mar 2018 13:15:25 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803280310380.68839@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <aa678038-9c5c-a8cb-0aed-ef19bde5d623@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 28/03/2018 12:16, David Rientjes wrote:
> On Wed, 28 Mar 2018, Laurent Dufour wrote:
> 
>>>> This configuration variable will be used to build the code needed to
>>>> handle speculative page fault.
>>>>
>>>> By default it is turned off, and activated depending on architecture
>>>> support.
>>>>
>>>> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
>>>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>>>> ---
>>>>  mm/Kconfig | 3 +++
>>>>  1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>>> index abefa573bcd8..07c566c88faf 100644
>>>> --- a/mm/Kconfig
>>>> +++ b/mm/Kconfig
>>>> @@ -759,3 +759,6 @@ config GUP_BENCHMARK
>>>>  	  performance of get_user_pages_fast().
>>>>  
>>>>  	  See tools/testing/selftests/vm/gup_benchmark.c
>>>> +
>>>> +config SPECULATIVE_PAGE_FAULT
>>>> +       bool
>>>
>>> Should this be configurable even if the arch supports it?
>>
>> Actually, this is not configurable unless by manually editing the .config file.
>>
>> I made it this way on the Thomas's request :
>> https://lkml.org/lkml/2018/1/15/969
>>
>> That sounds to be the smarter way to achieve that, isn't it ?
>>
> 
> Putting this in mm/Kconfig is definitely the right way to go about it 
> instead of any generic option in arch/*.
> 
> My question, though, was making this configurable by the user:
> 
> config SPECULATIVE_PAGE_FAULT
> 	bool "Speculative page faults"
> 	depends on X86_64 || PPC
> 	default y
> 	help
> 	  ..
> 
> It's a question about whether we want this always enabled on x86_64 and 
> power or whether the user should be able to disable it (right now they 
> can't).  With a large feature like this, you may want to offer something 
> simple (disable CONFIG_SPECULATIVE_PAGE_FAULT) if someone runs into 
> regressions.

I agree, but I think it would be important to get the per architecture
enablement to avoid complex check here. For instance in the case of powerPC
this is only supported for PPC_BOOK3S_64.

To avoid exposing such per architecture define here, what do you think about
having supporting architectures setting ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
and the SPECULATIVE_PAGE_FAULT depends on this, like this:

In mm/Kconfig:
config SPECULATIVE_PAGE_FAULT
 	bool "Speculative page faults"
 	depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT && SMP
 	default y
 	help
		...

In arch/powerpc/Kconfig:
config PPC
	...
	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT	if PPC_BOOK3S_64

In arch/x86/Kconfig:
config X86_64
	...
	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
