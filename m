Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E28026B005A
	for <linux-mm@kvack.org>; Sun, 19 Jul 2009 09:39:28 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so901335ana.26
        for <linux-mm@kvack.org>; Sun, 19 Jul 2009 06:39:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com>
References: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org>
	 <20090714102735.GD28569@csn.ul.ie>
	 <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com>
Date: Mon, 20 Jul 2009 01:39:30 +1200
Message-ID: <202cde0e0907190639k7bbebc63k143734ad696f90f5@mail.gmail.com>
Subject: Re: HugeTLB mapping for drivers (sample driver)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel,

>>
>> I ran out of time to review this properly, but glancing through I would be
>> concerned with what happens on fork() and COW. At a short read, it would
>> appear that pages get allocated from alloc_buddy_huge_page() instead of your
>> normal function altering the counters for hstate_nores.
>>

I've done some more investigations. You are right it is necessary to
track cases with private mappings some how if we are going to provide
hugetlb remap for drivers. OOM killer starts to work on COW caused by
private hugetlb mapping. (In case of non huge tlb mapping memory just
copied)

In fact there should be quite few cases when private mapping makes
sense for drivers and mapping DMA buffers. I thought about possible
solutions. The question is what to choose.

1. Forbid private mappings for drivers in case of hugetlb. (But this
limits functionality - it is not so good)
2. Allow private mapping. Use hugetlbfs hstates. (But it forces user
to know how much hugetlb memory it is necessary to reserve for
drivers)
3. Allow private mapping. Use special hstate for driver and driver
should tell how much memory needs to be reserved for it. (Not clear
yet how to behave if we are out of reserved space)

Could you please suggest what is the best solution? May be some other options?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
