Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f181.google.com (mail-ea0-f181.google.com [209.85.215.181])
	by kanga.kvack.org (Postfix) with ESMTP id F40FA6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:15:07 -0500 (EST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2768225eaj.26
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:15:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id m49si18318558eeg.115.2013.12.11.02.15.07
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 02:15:07 -0800 (PST)
Date: Wed, 11 Dec 2013 10:15:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 7/8] sched/numa: fix record hinting faults check
Message-ID: <20131211101503.GY11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131211091422.GU11295@suse.de>
 <20131211094156.GB26093@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131211094156.GB26093@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 05:41:56PM +0800, Wanpeng Li wrote:
> Hi Mel,
> On Wed, Dec 11, 2013 at 09:14:22AM +0000, Mel Gorman wrote:
> >On Wed, Dec 11, 2013 at 08:50:00AM +0800, Wanpeng Li wrote:
> >> Adjust numa_scan_period in task_numa_placement, depending on how much useful
> >> work the numa code can do. The local faults and remote faults should be used
> >> to check if there is record hinting faults instead of local faults and shared
> >> faults. This patch fix it.
> >> 
> >> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >
> >This potentially has the side-effect of making it easier to reduce the
> >scan rate because it'll only take the most recent scan window into
> >account. The existing code takes recent shared accesses into account.
> 
> The local/remote and share/private both accumulate the just finished
> scan window, why takes the most recent scan window into account will 
> reduce the scan rate than takes recent shared accesses into account?
> 

Ok, shoddy reasoning and explanation on my part. It was the second question
I really cared about -- was this tested? It wasn't and this patch is
surprisingly subtle.

The intent of the code was to check "is this processes recent activity
of interest to automatic numa balancing?"

If it's incurring local faults, then it's interesting.

If it's sharing faults then it is interesting. Shared accesses are
inherently dirty data because it is racing with other threads to be the
first to trap the hinting fault.

The current code takes those points into account and decides to slow
scanning on that basis. The change to using remote accesses is not
equivalent. The change is not necessarily better or worse because it's
workload dependant. It's just different and should be supported by more
detailed reasoning than either you or I are giving it right now. It could
also be argued that it should also be taking remote accesses into account
but again, it is a subtle patch that would require a bit of backup.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
