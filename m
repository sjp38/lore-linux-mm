Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF466B025F
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:03:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b189so5568735wmd.5
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:03:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b42si1994403edb.12.2017.10.03.01.03.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 01:03:34 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v937x5nl100248
	for <linux-mm@kvack.org>; Tue, 3 Oct 2017 04:03:32 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2dbwsyfs13-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Oct 2017 04:03:31 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 3 Oct 2017 09:03:26 +0100
Subject: Re: [PATCH v3 00/20] Speculative page faults
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
 <20170925163443.260d6092160ec704e2b04653@linux-foundation.org>
 <924a79af-6d7a-316a-1eee-3aebbfd4addf@linux.vnet.ibm.com>
 <20170928133850.90c5bf2aac0f1a63e29c01a3@linux-foundation.org>
 <64e9759b-a4fb-63d3-a811-3e35ae5a1028@linux.vnet.ibm.com>
 <873771dnrl.fsf@concordia.ellerman.id.au>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 3 Oct 2017 10:03:18 +0200
MIME-Version: 1.0
In-Reply-To: <873771dnrl.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <177195b3-2d99-94e6-f334-843bd19042a1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On 03/10/2017 03:27, Michael Ellerman wrote:
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> Hi Andrew,
>>
>> On 28/09/2017 22:38, Andrew Morton wrote:
>>> On Thu, 28 Sep 2017 14:29:02 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
>>>
>>>>> Laurent's [0/n] provides some nice-looking performance benefits for
>>>>> workloads which are chosen to show performance benefits(!) but, alas,
>>>>> no quantitative testing results for workloads which we may suspect will
>>>>> be harmed by the changes(?).  Even things as simple as impact upon
>>>>> single-threaded pagefault-intensive workloads and its effect upon
>>>>> CONFIG_SMP=n .text size?
>>>>
>>>> I forgot to mention in my previous email the impact on the .text section.
>>>>
>>>> Here are the metrics I got :
>>>>
>>>> .text size	UP		SMP		Delta
>>>> 4.13-mmotm	8444201		8964137		6.16%
>>>> '' +spf		8452041		8971929		6.15%
>>>> 	Delta	0.09%		0.09%	
>>>>
>>>> No major impact as you could see.
>>>
>>> 8k text increase seems rather a lot actually.  That's a lot more
>>> userspace cacheclines that get evicted during a fault...
>>>
>>> Is the feature actually beneficial on uniprocessor?
>>
>> This is useless on uniprocessor, and I will disable it on x86 when !SMP 
>> by not defining __HAVE_ARCH_CALL_SPF.
>> So the speculative page fault handler will not be built but the vm 
>> sequence counter and the SCRU stuff will still be there. I may also make 
>> it disabled through macro when __HAVE_ARCH_CALL_SPF is not defined, but 
>> this may obfuscated the code a bit...
>>
>> On ppc64, as this feature requires book3s, it can't be built without SMP 
>> support.
> 
> Book3S doesn't force SMP, eg. PMAC is Book3S but can be built with SMP=n.
> 
> It's true that POWERNV and PSERIES both force SMP, and those are the
> platforms used on modern Book3S CPUs.

Thanks Michael,

I'll add a check on CONFIG_SMP on ppc too.

Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
