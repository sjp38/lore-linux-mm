Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 073516B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 21:27:16 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n1so10104219pgt.4
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 18:27:15 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id f67si8623974pgc.768.2017.10.02.18.27.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Oct 2017 18:27:14 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 00/20] Speculative page faults
In-Reply-To: <64e9759b-a4fb-63d3-a811-3e35ae5a1028@linux.vnet.ibm.com>
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com> <20170925163443.260d6092160ec704e2b04653@linux-foundation.org> <924a79af-6d7a-316a-1eee-3aebbfd4addf@linux.vnet.ibm.com> <20170928133850.90c5bf2aac0f1a63e29c01a3@linux-foundation.org> <64e9759b-a4fb-63d3-a811-3e35ae5a1028@linux.vnet.ibm.com>
Date: Tue, 03 Oct 2017 12:27:10 +1100
Message-ID: <873771dnrl.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> Hi Andrew,
>
> On 28/09/2017 22:38, Andrew Morton wrote:
>> On Thu, 28 Sep 2017 14:29:02 +0200 Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:
>> 
>>>> Laurent's [0/n] provides some nice-looking performance benefits for
>>>> workloads which are chosen to show performance benefits(!) but, alas,
>>>> no quantitative testing results for workloads which we may suspect will
>>>> be harmed by the changes(?).  Even things as simple as impact upon
>>>> single-threaded pagefault-intensive workloads and its effect upon
>>>> CONFIG_SMP=n .text size?
>>>
>>> I forgot to mention in my previous email the impact on the .text section.
>>>
>>> Here are the metrics I got :
>>>
>>> .text size	UP		SMP		Delta
>>> 4.13-mmotm	8444201		8964137		6.16%
>>> '' +spf		8452041		8971929		6.15%
>>> 	Delta	0.09%		0.09%	
>>>
>>> No major impact as you could see.
>> 
>> 8k text increase seems rather a lot actually.  That's a lot more
>> userspace cacheclines that get evicted during a fault...
>> 
>> Is the feature actually beneficial on uniprocessor?
>
> This is useless on uniprocessor, and I will disable it on x86 when !SMP 
> by not defining __HAVE_ARCH_CALL_SPF.
> So the speculative page fault handler will not be built but the vm 
> sequence counter and the SCRU stuff will still be there. I may also make 
> it disabled through macro when __HAVE_ARCH_CALL_SPF is not defined, but 
> this may obfuscated the code a bit...
>
> On ppc64, as this feature requires book3s, it can't be built without SMP 
> support.

Book3S doesn't force SMP, eg. PMAC is Book3S but can be built with SMP=n.

It's true that POWERNV and PSERIES both force SMP, and those are the
platforms used on modern Book3S CPUs.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
