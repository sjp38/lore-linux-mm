Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 70D3D6B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 19:53:39 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id mc6so948379lab.14
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 16:53:38 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id y6si13201950lal.1.2014.02.05.16.53.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 16:53:36 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id q8so954637lbi.0
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 16:53:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140205081148.GI2936@laptop.programming.kicks-ass.net>
References: <1391563546-26052-1-git-send-email-pingfank@linux.vnet.ibm.com> <20140205081148.GI2936@laptop.programming.kicks-ass.net>
From: liu ping fan <qemulist@gmail.com>
Date: Thu, 6 Feb 2014 08:53:15 +0800
Message-ID: <CAJnKYQmv3gwGXS9_HbFa6igT5d-=mGj26DX7oUbSdwZWRmr5TA@mail.gmail.com>
Subject: Re: [PATCH] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mel Gorman <mgorman@suse.de>

On Wed, Feb 5, 2014 at 4:11 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Wed, Feb 05, 2014 at 09:25:46AM +0800, Liu Ping Fan wrote:
>> When doing some numa tests on powerpc, I triggered an oops bug. I find
>> it is caused by using page->_last_cpupid.  It should be initialized as
>> "-1 & LAST_CPUPID_MASK", but not "-1". Otherwise, in task_numa_fault(),
>> we will miss the checking (last_cpupid == (-1 & LAST_CPUPID_MASK)).
>> And finally cause an oops bug in task_numa_group(), since the online cpu is
>> less than possible cpu.
>
>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index a7b4e31..ddc66df4 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -727,7 +727,7 @@ static inline int page_cpupid_last(struct page *page)
>>  }
>>  static inline void page_cpupid_reset_last(struct page *page)
>>  {
>> -     page->_last_cpupid = -1;
>> +     page->_last_cpupid = -1 & LAST_CPUPID_MASK;
>>  }
>>  #else
>>  static inline int page_cpupid_last(struct page *page)
>
> OK, the changelog explained this part, and that makes sense I suppose.
>
>
>> diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
>> index da52366..3cbaa20 100644
>> --- a/include/linux/page-flags-layout.h
>> +++ b/include/linux/page-flags-layout.h
>> @@ -69,15 +69,15 @@
>>  #define LAST__CPU_MASK  ((1 << LAST__CPU_SHIFT)-1)
>>
>>  #define LAST_CPUPID_SHIFT (LAST__PID_SHIFT+LAST__CPU_SHIFT)
>> +
>> +#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT > BITS_PER_LONG - NR_PAGEFLAGS
>> +#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
>> +#endif
>>  #else
>>  #define LAST_CPUPID_SHIFT 0
>>  #endif
>>
>> -#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
>>  #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
>> -#else
>> -#define LAST_CPUPID_WIDTH 0
>> -#endif
>>
>>  /*
>>   * We are going to use the flags for the page to node mapping if its in
>> @@ -87,8 +87,4 @@
>>  #define NODE_NOT_IN_PAGE_FLAGS
>>  #endif
>>
>> -#if defined(CONFIG_NUMA_BALANCING) && LAST_CPUPID_WIDTH == 0
>> -#define LAST_CPUPID_NOT_IN_PAGE_FLAGS
>> -#endif
>> -
>>  #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
>
> But what's this all about? And why does PPC end up needing the
> not-in-page-flags case?

Since ppc needs to support a large physical address region, up to 2^46
but small section size (2^24). So when NR_CPUS grows up, it is easily
to cause not-in-page-flags.

Regards,
Fan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
