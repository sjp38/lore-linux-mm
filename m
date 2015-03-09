Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7E02A6B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 23:17:28 -0400 (EDT)
Received: by wghl18 with SMTP id l18so24705736wgh.5
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 20:17:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dk4si22680961wib.95.2015.03.08.20.17.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Mar 2015 20:17:26 -0700 (PDT)
Message-ID: <54FD10BF.3010709@suse.cz>
Date: Mon, 09 Mar 2015 04:17:19 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz> <1424731603.6539.51.camel@stgolabs.net>
In-Reply-To: <1424731603.6539.51.camel@stgolabs.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On 02/23/2015 11:46 PM, Davidlohr Bueso wrote:
> On Mon, 2015-02-23 at 13:58 +0100, Vlastimil Babka wrote:
>> Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
>> THP allocation attempts on page faults are a good performance trade-off.
>>
>> - THP allocations add to page fault latency, as high-order allocations are
>>    notoriously expensive. Page allocation slowpath now does extra checks for
>>    GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
>>    compaction for user page faults. But even async compaction can be expensive.
>> - During the first page fault in a 2MB range we cannot predict how much of the
>>    range will be actually accessed - we can theoretically waste as much as 511
>>    worth of pages [2]. Or, the pages in the range might be accessed from CPUs
>>    from different NUMA nodes and while base pages could be all local, THP could
>>    be remote to all but one CPU. The cost of remote accesses due to this false
>>    sharing would be higher than any savings on the TLB.
>> - The interaction with memcg are also problematic [1].
>>
>> Now I don't have any hard data to show how big these problems are, and I
>> expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
>> But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
>> for performance reasons.
>
> There are plenty of examples of this, ie for Oracle:
>
> https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge
> http://oracle-base.com/articles/linux/configuring-huge-pages-for-oracle-on-linux-64.php

Just stumbled upon more references when catching up on lwn:

http://lwn.net/Articles/634797/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
