Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8255F6B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 19:34:18 -0400 (EDT)
Received: by wyg34 with SMTP id 34so4571939wyg.14
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 16:34:15 -0700 (PDT)
Date: Fri, 28 Oct 2011 08:34:07 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 5/5]thp: split huge page if head page is isolated
Message-ID: <20111027233407.GC29407@barrios-laptop.redhat.com>
References: <1319511580.22361.141.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319511580.22361.141.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, aarcange@redhat.com, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Oct 25, 2011 at 10:59:40AM +0800, Shaohua Li wrote:
> With current logic, if page reclaim finds a huge page, it will just reclaim
> the head page and leave tail pages reclaimed later. Let's take an example,
> lru list has page A and B, page A is huge page:
> 1. page A is isolated
> 2. page B is isolated
> 3. shrink_page_list() adds page A to swap page cache. so page A is split.
> page A+1, page A+2, ... are added to lru list.
> 4. shrink_page_list() adds page B to swap page cache.
> 5. page A and B is written out and reclaimed.
> 6. page A+1, A+2 ... is isolated and reclaimed later.
> So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...

I don't see your code yet but have a question.
You mitigate this problem by 4/5 which could add subpages into lru tail
so subpages would reclaim next interation of reclaim.

What do we need 5/5?
Do I miss something?

> 
> We expected the whole huge page A is reclaimed in the meantime, so
> the order is A, A+1, ... A+HPAGE_PMD_NR-1, B, ....
> 
> With this patch, we do huge page split just after the head page is isolated
> for inactive lru list, so the tail pages will be reclaimed immediately.
> 
> In a test, a range of anonymous memory is written and will trigger swap.
> Without the patch:
> #cat /proc/vmstat|grep thp
> thp_fault_alloc 451
> thp_fault_fallback 0
> thp_collapse_alloc 0
> thp_collapse_alloc_failed 0
> thp_split 238
> 
> With the patch:
> #cat /proc/vmstat|grep thp
> thp_fault_alloc 450
> thp_fault_fallback 1
> thp_collapse_alloc 0
> thp_collapse_alloc_failed 0
> thp_split 103
> 
> So the thp_split number is reduced a lot, though there is one extra
> thp_fault_fallback.

Wow. The result seems to be good.
Is it result of effect only 5/5? or both 4/5 and 5/5?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
