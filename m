Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E75E56B003D
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 10:02:25 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so7338837pad.16
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 07:02:25 -0700 (PDT)
Message-ID: <5252BEE4.20707@redhat.com>
Date: Mon, 07 Oct 2013 10:02:12 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/63] mm: numa: Sanitize task_numa_fault() callsites
References: <1381141781-10992-1-git-send-email-mgorman@suse.de> <1381141781-10992-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1381141781-10992-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 10/07/2013 06:28 AM, Mel Gorman wrote:
> There are three callers of task_numa_fault():
> 
>  - do_huge_pmd_numa_page():
>      Accounts against the current node, not the node where the
>      page resides, unless we migrated, in which case it accounts
>      against the node we migrated to.
> 
>  - do_numa_page():
>      Accounts against the current node, not the node where the
>      page resides, unless we migrated, in which case it accounts
>      against the node we migrated to.
> 
>  - do_pmd_numa_page():
>      Accounts not at all when the page isn't migrated, otherwise
>      accounts against the node we migrated towards.
> 
> This seems wrong to me; all three sites should have the same
> sementaics, furthermore we should accounts against where the page
> really is, we already know where the task is.
> 
> So modify all three sites to always account; we did after all receive
> the fault; and always account to where the page is after migration,
> regardless of success.
> 
> They all still differ on when they clear the PTE/PMD; ideally that
> would get sorted too.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
