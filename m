Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA4B6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 10:17:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x134-v6so8815526oif.19
        for <linux-mm@kvack.org>; Wed, 02 May 2018 07:17:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 93-v6si4274755otd.5.2018.05.02.07.17.22
        for <linux-mm@kvack.org>;
        Wed, 02 May 2018 07:17:22 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v10 00/25] Speculative page faults
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
Date: Wed, 02 May 2018 15:17:19 +0100
In-Reply-To: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
	(Laurent Dufour's message of "Tue, 17 Apr 2018 16:33:06 +0200")
Message-ID: <87bmdynnv4.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists., ozlabs.org, x86@kernel.org

Hi Laurent,

One query below -

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

[...]

>
> Ebizzy:
> -------
> The test is counting the number of records per second it can manage, the
> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
> result I repeated the test 100 times and measure the average result. The
> number is the record processes per second, the higher is the best.
>
>   		BASE		SPF		delta	
> 16 CPUs x86 VM	12405.52	91104.52	634.39%
> 80 CPUs P8 node 37880.01	76201.05	101.16%

How do you measure the number of records processed? Is there a specific
version of ebizzy that reports this? I couldn't find a way to get this
information with the ebizzy that's included in ltp.

>
> Here are the performance counter read during a run on a 16 CPUs x86 VM:
>  Performance counter stats for './ebizzy -mRTp':
>             860074      faults
>             856866      spf
>                285      pagefault:spf_pte_lock
>               1506      pagefault:spf_vma_changed
>                  0      pagefault:spf_vma_noanon
>                 73      pagefault:spf_vma_notsup
>                  0      pagefault:spf_vma_access
>                  0      pagefault:spf_pmd_changed
>
> And the ones captured during a run on a 80 CPUs Power node:
>  Performance counter stats for './ebizzy -mRTp':
>             722695      faults
>             699402      spf
>              16048      pagefault:spf_pte_lock
>               6838      pagefault:spf_vma_changed
>                  0      pagefault:spf_vma_noanon
>                277      pagefault:spf_vma_notsup
>                  0      pagefault:spf_vma_access
>                  0      pagefault:spf_pmd_changed
>
> In ebizzy's case most of the page fault were handled in a speculative way,
> leading the ebizzy performance boost.

A trial run showed increased fault handling when SPF is enabled on an
8-core ARM64 system running 4.17-rc3. I am using a port of your x86
patch to enable spf on arm64.

SPF
---

Performance counter stats for './ebizzy -vvvmTRp':

         1,322,736      faults                                                      
         1,299,241      software/config=11/                                         

      10.005348034 seconds time elapsed

No SPF
-----

 Performance counter stats for './ebizzy -vvvmTRp':

           708,916      faults
                 0      software/config=11/

      10.005807432 seconds time elapsed

Thanks,
Punit

[...]
