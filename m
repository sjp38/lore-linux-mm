Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id E9D856B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 05:32:34 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id l15so24291277wiw.5
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 02:32:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ej4si22773469wid.64.2015.02.24.02.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 02:32:33 -0800 (PST)
Message-ID: <54EC533E.8040805@suse.cz>
Date: Tue, 24 Feb 2015 11:32:30 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>	<1424731603.6539.51.camel@stgolabs.net> <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
In-Reply-To: <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 02/23/2015 11:56 PM, Andrew Morton wrote:
> On Mon, 23 Feb 2015 14:46:43 -0800 Davidlohr Bueso <dave@stgolabs.net> wrote:
>
>> On Mon, 2015-02-23 at 13:58 +0100, Vlastimil Babka wrote:
>>> Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
>>> THP allocation attempts on page faults are a good performance trade-off.
>>>
>>> - THP allocations add to page fault latency, as high-order allocations are
>>>    notoriously expensive. Page allocation slowpath now does extra checks for
>>>    GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
>>>    compaction for user page faults. But even async compaction can be expensive.
>>> - During the first page fault in a 2MB range we cannot predict how much of the
>>>    range will be actually accessed - we can theoretically waste as much as 511
>>>    worth of pages [2]. Or, the pages in the range might be accessed from CPUs
>>>    from different NUMA nodes and while base pages could be all local, THP could
>>>    be remote to all but one CPU. The cost of remote accesses due to this false
>>>    sharing would be higher than any savings on the TLB.
>>> - The interaction with memcg are also problematic [1].
>>>
>>> Now I don't have any hard data to show how big these problems are, and I
>>> expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
>>> But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
>>> for performance reasons.
>>
>> There are plenty of examples of this, ie for Oracle:
>>
>> https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge
>
> hm, five months ago and I don't recall seeing any followup to this.

Actually it's year + five months, but nevertheless...

> Does anyone know what's happening?

I would suspect mmap_sem being held during whole THP page fault 
(including the needed reclaim and compaction), which I forgot to mention 
in the first e-mail - it's not just the problem page fault latency, but 
also potentially holding back other processes, why we should allow 
shifting from THP page faults to deferred collapsing.
Although the attempts for opportunistic page faults without mmap_sem 
would also help in this particular case.

Khugepaged also used to hold mmap_sem (for read) during the allocation 
attempt, but that was fixed since then. It could be also zone lru_lock 
pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
