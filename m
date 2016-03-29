Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id BBC216B025E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 10:20:10 -0400 (EDT)
Received: by mail-wm0-f53.google.com with SMTP id 191so52736954wmq.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 07:20:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y184si13558669wmd.74.2016.03.29.07.20.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 07:20:09 -0700 (PDT)
Subject: Re: memory fragmentation issues on 4.4
References: <56F8F5DA.6040206@kyup.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FA8F18.60306@suse.cz>
Date: Tue, 29 Mar 2016 16:20:08 +0200
MIME-Version: 1.0
In-Reply-To: <56F8F5DA.6040206@kyup.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>, Linux MM <linux-mm@kvack.org>
Cc: mgorman@techsingularity.net

On 03/28/2016 11:14 AM, Nikolay Borisov wrote:
> Hello,
>
> On kernel 4.4 I observe that the memory gets really fragmented fairly
> quickly. E.g. there are no order  > 4 pages even after 2 days of uptime.
> This leads to certain data structures on XFS (in my case order 4/order 5
> allocations)  not being allocated and causes the server to stall. When
> this happens either someone has to log on the server and manually invoke
> the memory compaction or plain reboot the server. Before that the server
> was running with the exact same workload but with 3.12.52 kernel and no
> such issue were observed. That is - memory was fragmented but allocation
> didn't fail, maybe alloc_pages_direct_compact was doing a better job?
>
> FYI the allocation is performed with GFP_KERNEL | GFP_NOFS

GFP_NOFS is indeed excluded from memory compaction in the allocation 
context (i.e. direct compaction).

> Manual compaction usually does the job, however I'm wondering why isn't
> invoking __alloc_pages_direct_compact from within __alloc_pages_nodemask
> satisfying the request if manual compaction would do the job. Is there a
> difference in the efficiency of manually invoking memory compaction and
> the one invoked from the page allocator path?

Manual compaction via /proc is known to be safe in not holding any locks 
that XFS might be holding. Compaction relies on page migration and IIRC 
some filesystems cannot migrate dirty pages unless there's writeback, 
and if that writeback called back to xfs, it would be a deadlock. 
However, we could investigate if the async compaction would be safe.

In any case, such high-order allocations should always have an order-0 
fallback. You're suggesting there's an infinite loop around the 
allocation attempt instead? Do you have the full backtrace?

Even an infinite loop should eventually proceed by having kswapd do the 
compaction work with unrestricted context. But it turns out kswapd 
compaction was broken. Hopefully good news is that 4.6-rc1 has kcompactd 
for that, which should work better. If you're able to test such 
experimental kernel, I would be interested to hear if it helped.

> Another question for my own satisfaction - I created a kernel module
> which allocate pages of very high order - 8/9) then later when those
> pages are returned I see the number of unmovable pages increase by the
> amount of pages returned. So should freed pages go to the unmovable
> category?

Your kernel was likely doing unmovable allocations (e.g. GFP_KERNEL), so 
freed pages are returned to unmovable freelists. But once they merge to 
order-9 or higher, it doesn't really matter, as it's trivial to 
transform them to movable lists in response to movable allocation 
demand, without causing permanent fragmentation.

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
