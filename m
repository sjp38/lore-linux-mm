Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE13C6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:09:53 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id b143so5349118vka.8
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:09:53 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 1si3079276uax.33.2017.12.15.23.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 23:09:52 -0800 (PST)
Subject: Re: [PATCH] mm: Reduce memory bloat with THP
References: <1513301359-117568-1-git-send-email-nitin.m.gupta@oracle.com>
 <20171215100024.gxuijdovjhkugarz@node.shutemov.name>
From: Nitin Gupta <nitin.m.gupta@oracle.com>
Message-ID: <d3e77b2c-2164-743d-4f88-527091790006@oracle.com>
Date: Fri, 15 Dec 2017 23:04:03 -0800
MIME-Version: 1.0
In-Reply-To: <20171215100024.gxuijdovjhkugarz@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, steven.sistare@oracle.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Mel Gorman <mgorman@suse.de>, Nadav Amit <namit@vmware.com>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Vegard Nossum <vegard.nossum@oracle.com>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, SeongJae Park <sj38.park@gmail.com>, Shaohua Li <shli@fb.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Tobin C Harding <me@tobin.cc>, open list <linux-kernel@vger.kernel.org>

On 12/15/17 2:00 AM, Kirill A. Shutemov wrote:
> On Thu, Dec 14, 2017 at 05:28:52PM -0800, Nitin Gupta wrote:
>> Currently, if the THP enabled policy is "always", or the mode
>> is "madvise" and a region is marked as MADV_HUGEPAGE, a hugepage
>> is allocated on a page fault if the pud or pmd is empty.  This
>> yields the best VA translation performance, but increases memory
>> consumption if some small page ranges within the huge page are
>> never accessed.
>>
>> An alternate behavior for such page faults is to install a
>> hugepage only when a region is actually found to be (almost)
>> fully mapped and active.  This is a compromise between
>> translation performance and memory consumption.  Currently there
>> is no way for an application to choose this compromise for the
>> page fault conditions above.
>>
>> With this change, when an application issues MADV_DONTNEED on a
>> memory region, the region is marked as "space-efficient". For
>> such regions, a hugepage is not immediately allocated on first
>> write.  Instead, it is left to the khugepaged thread to do
>> delayed hugepage promotion depending on whether the region is
>> actually mapped and active. When application issues
>> MADV_HUGEPAGE, the region is marked again as non-space-efficient
>> wherein hugepage is allocated on first touch.
> 
> I think this would be NAK. At least in this form.
> 
> What performance testing have you done? Any numbers?
> 

I wrote a throw-away code which mmaps 128G area and writes to a random
address in a loop. Together with writes, madvise(MADV_DONTNEED) are
issued at another random addresses. Writes are issued with 70%
probability and DONTNEED with 30%. With this test, I'm trying to emulate
workload of a large in-memory hash-table.

With the patch, I see that memory bloat is much less severe.
I've uploaded the test program with the memory usage plot here:

https://gist.github.com/nitingupta910/42ddf969e17556d74a14fbd84640ddb3

THP was set to 'always' mode in both cases but the result would be the
same if madvise mode was used instead.

> Making whole vma "space_efficient" just because somebody freed one page
> from it is just wrong. And there's no way back after this.
>

I'm using MADV_DONTNEED as a hint that although user wants to
transparently use hugepages but at the same time wants to be more
conservative with respect to memory usage. If a MADV_HUGEPAGE is issued
for a VMA range after any DONTNEEDs then the space_efficient bit is
again cleared, so we revert back to allocating hugepage on fault on
empty pud/pmd.

>>
>> Orabug: 26910556
> 
> Wat?
> 

It's oracle internal identifier used to track this work.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
