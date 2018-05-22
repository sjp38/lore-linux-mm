Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A495B6B0280
	for <linux-mm@kvack.org>; Tue, 22 May 2018 07:47:24 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p7-v6so14037857wrj.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 04:47:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d4-v6si11699281wmi.167.2018.05.22.04.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 04:47:23 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4MBcvFH051813
	for <linux-mm@kvack.org>; Tue, 22 May 2018 07:47:22 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j4j7k15as-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 May 2018 07:47:21 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 22 May 2018 12:47:19 +0100
Subject: Re: [PATCH v11 01/26] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
References: <1526555193-7242-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1526555193-7242-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <2cb8256d-5822-d94d-b0e6-c46f21d84852@infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 22 May 2018 13:47:08 +0200
MIME-Version: 1.0
In-Reply-To: <2cb8256d-5822-d94d-b0e6-c46f21d84852@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <8a4016fb-2c2f-ad9a-9dd4-0ed3e664b659@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, sergey.senozhatsky.work@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>, Punit Agrawal <punitagrawal@gmail.com>, vinayak menon <vinayakm.list@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 17/05/2018 18:36, Randy Dunlap wrote:
> Hi,
> 
> On 05/17/2018 04:06 AM, Laurent Dufour wrote:
>> This configuration variable will be used to build the code needed to
>> handle speculative page fault.
>>
>> By default it is turned off, and activated depending on architecture
>> support, ARCH_HAS_PTE_SPECIAL, SMP and MMU.
>>
>> The architecture support is needed since the speculative page fault handler
>> is called from the architecture's page faulting code, and some code has to
>> be added there to handle the speculative handler.
>>
>> The dependency on ARCH_HAS_PTE_SPECIAL is required because vm_normal_page()
>> does processing that is not compatible with the speculative handling in the
>> case ARCH_HAS_PTE_SPECIAL is not set.
>>
>> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
>> Suggested-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/Kconfig | 22 ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 1d0888c5b97a..a38796276113 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -761,3 +761,25 @@ config GUP_BENCHMARK
>>  
>>  config ARCH_HAS_PTE_SPECIAL
>>  	bool
>> +
>> +config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +       def_bool n
>> +
>> +config SPECULATIVE_PAGE_FAULT
>> +       bool "Speculative page faults"
>> +       default y
>> +       depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +       depends on ARCH_HAS_PTE_SPECIAL && MMU && SMP
>> +       help
>> +         Try to handle user space page faults without holding the mmap_sem.
>> +
>> +	 This should allow better concurrency for massively threaded process
> 
> 	                                                             processes
> 
>> +	 since the page fault handler will not wait for other threads memory
> 
> 	                                                      thread's
> 
>> +	 layout change to be done, assuming that this change is done in another
>> +	 part of the process's memory space. This type of page fault is named
>> +	 speculative page fault.
>> +
>> +	 If the speculative page fault fails because of a concurrency is
> 
> 	                                     because a concurrency is
> 
>> +	 detected or because underlying PMD or PTE tables are not yet
>> +	 allocating, it is failing its processing and a classic page fault
> 
> 	 allocated, the speculative page fault fails and a classic page fault
> 
>> +	 is then tried.
> 
> 
> Also, all of the help text (below the "help" line) should be indented by
> 1 tab + 2 spaces (in coding-style.rst).

Thanks, Randy for reviewing my miserable English grammar.
I'll fix that and the indentation.
