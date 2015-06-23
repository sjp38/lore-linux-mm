From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [RFC 3/4] mm, thp: try fault allocations only if we expect them
 to succeed
Date: Tue, 23 Jun 2015 18:23:11 +0200
Message-ID: <558987EF.8090906@suse.cz>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz> <1431354940-30740-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1506171802160.8203@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1506171802160.8203@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>
List-Id: linux-mm.kvack.org

On 06/18/2015 03:20 AM, David Rientjes wrote:
> On Mon, 11 May 2015, Vlastimil Babka wrote:
>
>> Since we track THP availability for khugepaged THP collapses, we can use it
>> also for page fault THP allocations. If khugepaged with its sync compaction
>> is not able to allocate a hugepage, then it's unlikely that the less involved
>> attempt on page fault would succeed, and the cost could be higher than THP
>> benefits. Also clear the THP availability flag if we do attempt and fail to
>> allocate during page fault, and set the flag if we are freeing a large enough
>> page from any context. The latter doesn't include merges, as that's a fast
>> path and unlikely to make much difference.
>>
>
> That depends on how long {scan,alloc}_sleep_millisecs are, so if
> khugepaged fails to allocate a hugepage on all nodes, it sleeps for
> alloc_sleep_millisecs (default 60s)

Waking up khugepaged earlier is handled in patch 4.

> and then there's immediate memory
> freeing, thp page faults don't happen again for 60s.  That's scary to me
> when thp_avail_nodes is clear, a large process terminates, and then
> immediately starts back up.

The last hunk of this patch makes sure that freeing a >=HPAGE_PMD_ORDER 
page sets the thp availability bit so that scenario should be OK. This 
wouldn't handle merging of free pages to form a large enough page, but 
that should be rare enough to be negligible.

> None of its memory is faulted as thp and
> depending on how large it is, khugepaged may fail to allocate hugepages
> when it wakes back up so it never scans (the only reason why
> thp_avail_nodes was clear before it terminated originally).
>
> I'm not sure that approach can work unless the inference of whether a
> hugepage can be allocated at a given time is a very good indicator of
> whether a hugepage can be allocated alloc_sleep_millisecs later, and I'm
> afraid that's not the case.

So does the explanation above solve the concern?

> I'm very happy that you're looking at thp fault latency and the role that
> khugepaged can play in accepting responsibility for defragmentation,
> though.  It's an area that has caused me some trouble lately and I'd like
> to be able to improve.

Good.

> We see an immediate benefit when experimenting with doing synchronous
> memory compactions of all memory every 15s.  That's done using a cronjob
> rather than khugepaged, but the idea is the same.
>
> What would your thoughts be about doing something radical like
>
>   - having khugepaged do synchronous memory compaction of all memory at
>     regulary intervals,

I'm also thinking towards something like this for some time, yeah. Also 
maybe not khugepaged but per-node "kcompatd" that's handles just the 
compation and not thp collapses.

>   - track how many pageblocks are free for thp memory to be allocated,

That should be easy to determine from free lists already? There are 
per-order counts AFAIK, you just have to sum up over all zones and 
orders between pageblock order and MAX_ORDER (which should be just 1 or 
2 orders).

>   - terminate collapsing if free pageblocks are below a threshold,

Why not.

>   - trigger a khugepaged wakeup at page fault when that number of
>     pageblocks falls below a threshold,
>
>   - determine the next full sync memory compaction based on how many
>     pageblocks were defragmented on the last wakeup, and
>
>   - avoid memory compaction for all thp page faults.

Right. That should also reduce the amount of GFP_TRANSHUGE decisions 
done in the allocator right now...

I think there are more benefits possible when a thread is responsible 
for thorough defragmentation and its activity is tuned appropriately 
(and doesn't depend on the collapse scanning results as it's now the 
case for khugepaged - it won't compact anything on a node if there's 
nothing to collapse there).

- direct compaction can quickly skip a block of memory in migrate 
scanner as soon as it finds a page that cannot be isolated. I had a 
patch for that [1], but dropped it due to longer-term fragmentation 
becoming worse.

- I think that direct compaction could also stop using the current free 
scanner and just get free pages from free lists. In my current testing I 
see that free scanner spends an awful lot of time to find those free 
pages, if we are near the watermarks. I think this approach should work 
better, combined with implementing the previous point:
   - if the free page that came from the free list is within the 
order-aligned block that the migrate scanner is processing, then of 
course we don't use it as migration target. We keep the page aside on a 
list so it can later merge with the pages freed by migration.
   - since getting pages from free lists is done in increasing order 
starting from 0, it would also have some natural antifragmentation 
effects. Right now the free scanner can be easily breaking an order-8 
page to obtain one or few pages as migration targets.

Of course after such modifications direct compaction is no longer truly 
a "compaction", that's why complementing it with the traditional one 
done by a dedicated thread would be needed to avoid regressions in 
long-term fragmentation.

[1] http://www.spinics.net/lists/linux-mm/msg76307.html

> (I'd ignore what is actually the responsibility of khugepaged and what is
> done in task work at this time.)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
