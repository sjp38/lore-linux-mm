Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B98DE6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 10:45:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 88-v6so10201343wrc.21
        for <linux-mm@kvack.org>; Wed, 02 May 2018 07:45:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z45-v6si5727593edc.451.2018.05.02.07.45.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 07:45:34 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w42Ec1m9124579
	for <linux-mm@kvack.org>; Wed, 2 May 2018 10:45:33 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hqcgh0jpn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 May 2018 10:45:32 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 2 May 2018 15:45:30 +0100
Subject: Re: [PATCH v10 00/25] Speculative page faults
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <87bmdynnv4.fsf@e105922-lin.cambridge.arm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 2 May 2018 16:45:19 +0200
MIME-Version: 1.0
In-Reply-To: <87bmdynnv4.fsf@e105922-lin.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <eef94f4f-800e-9994-d926-a71b80552ebc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Punit Agrawal <punit.agrawal@arm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org



On 02/05/2018 16:17, Punit Agrawal wrote:
> Hi Laurent,
> 
> One query below -
> 
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
> [...]
> 
>>
>> Ebizzy:
>> -------
>> The test is counting the number of records per second it can manage, the
>> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
>> result I repeated the test 100 times and measure the average result. The
>> number is the record processes per second, the higher is the best.
>>
>>   		BASE		SPF		delta	
>> 16 CPUs x86 VM	12405.52	91104.52	634.39%
>> 80 CPUs P8 node 37880.01	76201.05	101.16%
> 
> How do you measure the number of records processed? Is there a specific
> version of ebizzy that reports this? I couldn't find a way to get this
> information with the ebizzy that's included in ltp.

I'm using the original one : http://ebizzy.sourceforge.net/

> 
>>
>> Here are the performance counter read during a run on a 16 CPUs x86 VM:
>>  Performance counter stats for './ebizzy -mRTp':
>>             860074      faults
>>             856866      spf
>>                285      pagefault:spf_pte_lock
>>               1506      pagefault:spf_vma_changed
>>                  0      pagefault:spf_vma_noanon
>>                 73      pagefault:spf_vma_notsup
>>                  0      pagefault:spf_vma_access
>>                  0      pagefault:spf_pmd_changed
>>
>> And the ones captured during a run on a 80 CPUs Power node:
>>  Performance counter stats for './ebizzy -mRTp':
>>             722695      faults
>>             699402      spf
>>              16048      pagefault:spf_pte_lock
>>               6838      pagefault:spf_vma_changed
>>                  0      pagefault:spf_vma_noanon
>>                277      pagefault:spf_vma_notsup
>>                  0      pagefault:spf_vma_access
>>                  0      pagefault:spf_pmd_changed
>>
>> In ebizzy's case most of the page fault were handled in a speculative way,
>> leading the ebizzy performance boost.
> 
> A trial run showed increased fault handling when SPF is enabled on an
> 8-core ARM64 system running 4.17-rc3. I am using a port of your x86
> patch to enable spf on arm64.
> 
> SPF
> ---
> 
> Performance counter stats for './ebizzy -vvvmTRp':
> 
>          1,322,736      faults                                                      
>          1,299,241      software/config=11/                                         
> 
>       10.005348034 seconds time elapsed
> 
> No SPF
> -----
> 
>  Performance counter stats for './ebizzy -vvvmTRp':
> 
>            708,916      faults
>                  0      software/config=11/
> 
>       10.005807432 seconds time elapsed

Thanks for sharing these good numbers !

> Thanks,
> Punit
> 
> [...]
> 
