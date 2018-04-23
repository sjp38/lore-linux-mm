Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 15E7C6B0008
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:11:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 31-v6so19324837wrr.2
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:11:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t43si1231950edd.391.2018.04.23.08.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:11:18 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3NFB7KS066344
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:11:17 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hhg2fxaeh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:11:16 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 23 Apr 2018 16:10:33 +0100
Subject: Re: [PATCH v10 01/25] mm: introduce CONFIG_SPECULATIVE_PAGE_FAULT
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-2-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423055809.GA114098@rodete-desktop-imager.corp.google.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 23 Apr 2018 17:10:15 +0200
MIME-Version: 1.0
In-Reply-To: <20180423055809.GA114098@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <10b5f8da-9c53-f833-1212-7a1eb215d534@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 23/04/2018 07:58, Minchan Kim wrote:
> Hi Laurent,
> 
> I guess it's good timing to review. Guess LSF/MM goes so might change
> a lot since then. :) Anyway, I grap a time to review.

Hi,

Thanks a lot for reviewing this series.

> On Tue, Apr 17, 2018 at 04:33:07PM +0200, Laurent Dufour wrote:
>> This configuration variable will be used to build the code needed to
>> handle speculative page fault.
>>
>> By default it is turned off, and activated depending on architecture
>> support, SMP and MMU.
> 
> Can we have description in here why it depends on architecture?

The reason is that the per architecture page fault code must handle the
speculative page fault. It is done in this series for x86 and ppc64.

I'll make it explicit here.

> 
>>
>> Suggested-by: Thomas Gleixner <tglx@linutronix.de>
>> Suggested-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>>  mm/Kconfig | 22 ++++++++++++++++++++++
>>  1 file changed, 22 insertions(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index d5004d82a1d6..5484dca11199 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -752,3 +752,25 @@ config GUP_BENCHMARK
>>  	  performance of get_user_pages_fast().
>>  
>>  	  See tools/testing/selftests/vm/gup_benchmark.c
>> +
>> +config ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +       def_bool n
>> +
>> +config SPECULATIVE_PAGE_FAULT
>> +       bool "Speculative page faults"
>> +       default y
>> +       depends on ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>> +       depends on MMU && SMP
>> +       help
>> +         Try to handle user space page faults without holding the mmap_sem.
>> +
>> +	 This should allow better concurrency for massively threaded process
>> +	 since the page fault handler will not wait for other threads memory
>> +	 layout change to be done, assuming that this change is done in another
>> +	 part of the process's memory space. This type of page fault is named
>> +	 speculative page fault.
>> +
>> +	 If the speculative page fault fails because of a concurrency is
>> +	 detected or because underlying PMD or PTE tables are not yet
>> +	 allocating, it is failing its processing and a classic page fault
>> +	 is then tried.
>> -- 
>> 2.7.4
>>
> 
