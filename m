Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32C626B074C
	for <linux-mm@kvack.org>; Fri,  9 Nov 2018 19:40:54 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id l15-v6so2801537ita.4
        for <linux-mm@kvack.org>; Fri, 09 Nov 2018 16:40:54 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s12-v6si6322199jad.65.2018.11.09.16.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Nov 2018 16:40:52 -0800 (PST)
Subject: Re: [RFC PATCH] mm: thp: implement THP reservations for anonymous
 memory
References: <1541746138-6706-1-git-send-email-anthony.yznaga@oracle.com>
 <20181109121318.3f3ou56ceegrqhcp@kshutemo-mobl1>
 <20181109131128.GE23260@techsingularity.net>
 <EEBCAF4D-138C-4CF7-B4B7-C55F1192A026@cs.rutgers.edu>
From: anthony.yznaga@oracle.com
Message-ID: <dc53e320-d35c-3cb8-df9e-8dc6ffbe2163@oracle.com>
Date: Fri, 9 Nov 2018 16:39:43 -0800
MIME-Version: 1.0
In-Reply-To: <EEBCAF4D-138C-4CF7-B4B7-C55F1192A026@cs.rutgers.edu>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, jglisse@redhat.com, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, mhocko@kernel.org, minchan@kernel.org, peterz@infradead.org, rientjes@google.com, vbabka@suse.cz, willy@infradead.org, ying.huang@intel.com, nitingupta910@gmail.com



On 11/09/2018 07:34 AM, Zi Yan wrote:
> On 9 Nov 2018, at 8:11, Mel Gorman wrote:
>
>> On Fri, Nov 09, 2018 at 03:13:18PM +0300, Kirill A. Shutemov wrote:
>>> On Thu, Nov 08, 2018 at 10:48:58PM -0800, Anthony Yznaga wrote:
>>>> The basic idea as outlined by Mel Gorman in [2] is:
>>>>
>>>> 1) On first fault in a sufficiently sized range, allocate a huge page
>>>>    sized and aligned block of base pages.  Map the base page
>>>>    corresponding to the fault address and hold the rest of the pages in
>>>>    reserve.
>>>> 2) On subsequent faults in the range, map the pages from the reservation.
>>>> 3) When enough pages have been mapped, promote the mapped pages and
>>>>    remaining pages in the reservation to a huge page.
>>>> 4) When there is memory pressure, release the unused pages from their
>>>>    reservations.
>>> I haven't yet read the patch in details, but I'm skeptical about the
>>> approach in general for few reasons:
>>>
>>> - PTE page table retracting to replace it with huge PMD entry requires
>>>   down_write(mmap_sem). It makes the approach not practical for many
>>>   multi-threaded workloads.
>>>
>>>   I don't see a way to avoid exclusive lock here. I will be glad to
>>>   be proved otherwise.
>>>
>> That problem is somewhat fundamental to the mmap_sem itself and
>> conceivably it could be alleviated by range-locking (if that gets
>> completed). The other thing to bear in mind is the timing. If the
>> promotion is in-place due to reservations, there isn't the allocation
>> overhead and the hold times *should* be short.
>>
> Is it possible to convert all these PTEs to migration entries during
> the promotion and replace them with a huge PMD entry afterwards?
> AFAIK, migrating pages does not require holding a mmap_sem.
> Basically, it will act like migrating 512 base pages to a THP without
> actually doing the page copy.
That's an interesting idea.A  I'll look into it.

Thanks,
Anthony

>
> --
> Best Regards
> Yan Zi
