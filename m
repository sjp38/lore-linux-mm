Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 739366B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:30:23 -0500 (EST)
Received: by wggz12 with SMTP id z12so54670470wgg.2
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:30:23 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si12945419wjb.168.2015.03.05.08.30.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 08:30:20 -0800 (PST)
Message-ID: <54F88498.2000902@suse.cz>
Date: Thu, 05 Mar 2015 17:30:16 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] the big khugepaged redesign
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>	<1424731603.6539.51.camel@stgolabs.net> <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org> <54EC533E.8040805@suse.cz>
In-Reply-To: <54EC533E.8040805@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andres Freund <andres@anarazel.de>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>

On 02/24/2015 11:32 AM, Vlastimil Babka wrote:
> On 02/23/2015 11:56 PM, Andrew Morton wrote:
>> On Mon, 23 Feb 2015 14:46:43 -0800 Davidlohr Bueso <dave@stgolabs.net> wrote:
>>
>>> On Mon, 2015-02-23 at 13:58 +0100, Vlastimil Babka wrote:
>>>> Recently, there was concern expressed (e.g. [1]) whether the quite aggressive
>>>> THP allocation attempts on page faults are a good performance trade-off.
>>>>
>>>> - THP allocations add to page fault latency, as high-order allocations are
>>>>    notoriously expensive. Page allocation slowpath now does extra checks for
>>>>    GFP_TRANSHUGE && !PF_KTHREAD to avoid the more expensive synchronous
>>>>    compaction for user page faults. But even async compaction can be expensive.
>>>> - During the first page fault in a 2MB range we cannot predict how much of the
>>>>    range will be actually accessed - we can theoretically waste as much as 511
>>>>    worth of pages [2]. Or, the pages in the range might be accessed from CPUs
>>>>    from different NUMA nodes and while base pages could be all local, THP could
>>>>    be remote to all but one CPU. The cost of remote accesses due to this false
>>>>    sharing would be higher than any savings on the TLB.
>>>> - The interaction with memcg are also problematic [1].
>>>>
>>>> Now I don't have any hard data to show how big these problems are, and I
>>>> expect we will discuss this on LSF/MM (and hope somebody has such data [3]).
>>>> But it's certain that e.g. SAP recommends to disable THPs [4] for their apps
>>>> for performance reasons.
>>>
>>> There are plenty of examples of this, ie for Oracle:
>>>
>>> https://blogs.oracle.com/linux/entry/performance_issues_with_transparent_huge
>>
>> hm, five months ago and I don't recall seeing any followup to this.
> 
> Actually it's year + five months, but nevertheless...
> 
>> Does anyone know what's happening?

So I think that post was actually about THP support enabled in .config slowing
down hugetlbfs, and found a followup post here
https://blogs.oracle.com/linuxkernel/entry/performance_impact_of_transparent_huge and
that was after all solved in 3.12. Sasha also mentioned that split PTL patchset
helped as well, and the degradation in IOPS due to THP enabled is now limited to
5%, and possibly the refcounting redesign could help.

That however means the workload is based on hugetlbfs and shouldn't trigger THP
page fault activity, which is the aim of this patchset. Some more googling made
me recall that last LSF/MM, postgresql people mentioned THP issues and pointed
at compaction. See http://lwn.net/Articles/591723/ That's exactly where this
patchset should help, but I obviously won't be able to measure this before LSF/MM...

I'm CCing the psql guys from last year LSF/MM - do you have any insight about
psql performance with THPs enabled/disabled on recent kernels, where e.g.
compaction is no longer synchronous for THP page faults?

Thanks,
Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
