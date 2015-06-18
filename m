Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 97AFF6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 21:20:20 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so49777117igb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:20:20 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com. [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id ej3si5309632icb.90.2015.06.17.18.20.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 18:20:20 -0700 (PDT)
Received: by igboe5 with SMTP id oe5so7095394igb.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 18:20:20 -0700 (PDT)
Date: Wed, 17 Jun 2015 18:20:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/4] mm, thp: try fault allocations only if we expect them
 to succeed
In-Reply-To: <1431354940-30740-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.10.1506171802160.8203@chino.kir.corp.google.com>
References: <1431354940-30740-1-git-send-email-vbabka@suse.cz> <1431354940-30740-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Alex Thorlton <athorlton@sgi.com>

On Mon, 11 May 2015, Vlastimil Babka wrote:

> Since we track THP availability for khugepaged THP collapses, we can use it
> also for page fault THP allocations. If khugepaged with its sync compaction
> is not able to allocate a hugepage, then it's unlikely that the less involved
> attempt on page fault would succeed, and the cost could be higher than THP
> benefits. Also clear the THP availability flag if we do attempt and fail to
> allocate during page fault, and set the flag if we are freeing a large enough
> page from any context. The latter doesn't include merges, as that's a fast
> path and unlikely to make much difference.
> 

That depends on how long {scan,alloc}_sleep_millisecs are, so if 
khugepaged fails to allocate a hugepage on all nodes, it sleeps for 
alloc_sleep_millisecs (default 60s), and then there's immediate memory 
freeing, thp page faults don't happen again for 60s.  That's scary to me 
when thp_avail_nodes is clear, a large process terminates, and then 
immediately starts back up.  None of its memory is faulted as thp and 
depending on how large it is, khugepaged may fail to allocate hugepages 
when it wakes back up so it never scans (the only reason why 
thp_avail_nodes was clear before it terminated originally).

I'm not sure that approach can work unless the inference of whether a 
hugepage can be allocated at a given time is a very good indicator of 
whether a hugepage can be allocated alloc_sleep_millisecs later, and I'm 
afraid that's not the case.

I'm very happy that you're looking at thp fault latency and the role that 
khugepaged can play in accepting responsibility for defragmentation, 
though.  It's an area that has caused me some trouble lately and I'd like 
to be able to improve.

We see an immediate benefit when experimenting with doing synchronous 
memory compactions of all memory every 15s.  That's done using a cronjob 
rather than khugepaged, but the idea is the same.

What would your thoughts be about doing something radical like

 - having khugepaged do synchronous memory compaction of all memory at
   regulary intervals,

 - track how many pageblocks are free for thp memory to be allocated,

 - terminate collapsing if free pageblocks are below a threshold,

 - trigger a khugepaged wakeup at page fault when that number of 
   pageblocks falls below a threshold,

 - determine the next full sync memory compaction based on how many
   pageblocks were defragmented on the last wakeup, and

 - avoid memory compaction for all thp page faults.

(I'd ignore what is actually the responsibility of khugepaged and what is 
done in task work at this time.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
