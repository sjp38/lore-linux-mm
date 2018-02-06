Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E1CAD6B0007
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 03:39:27 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id a61so1203669pla.22
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 00:39:27 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id x190si6604041pgd.675.2018.02.06.00.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 00:39:26 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm, swap, frontswap: Fix THP swap if frontswap enabled
References: <20180206065404.18815-1-ying.huang@intel.com>
	<20180206083101.GA17082@eng-minchan1.roam.corp.google.com>
Date: Tue, 06 Feb 2018 16:39:18 +0800
In-Reply-To: <20180206083101.GA17082@eng-minchan1.roam.corp.google.com>
	(Minchan Kim's message of "Tue, 6 Feb 2018 00:31:01 -0800")
Message-ID: <871shy3421.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjenning@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Shakeel Butt <shakeelb@google.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hi, Minchan,

Minchan Kim <minchan@kernel.org> writes:

> Hi Huang,
>
> On Tue, Feb 06, 2018 at 02:54:04PM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> It was reported by Sergey Senozhatsky that if THP (Transparent Huge
>> Page) and frontswap (via zswap) are both enabled, when memory goes low
>> so that swap is triggered, segfault and memory corruption will occur
>> in random user space applications as follow,
>> 
>> kernel: urxvt[338]: segfault at 20 ip 00007fc08889ae0d sp 00007ffc73a7fc40 error 6 in libc-2.26.so[7fc08881a000+1ae000]
>>  #0  0x00007fc08889ae0d _int_malloc (libc.so.6)
>>  #1  0x00007fc08889c2f3 malloc (libc.so.6)
>>  #2  0x0000560e6004bff7 _Z14rxvt_wcstoutf8PKwi (urxvt)
>>  #3  0x0000560e6005e75c n/a (urxvt)
>>  #4  0x0000560e6007d9f1 _ZN16rxvt_perl_interp6invokeEP9rxvt_term9hook_typez (urxvt)
>>  #5  0x0000560e6003d988 _ZN9rxvt_term9cmd_parseEv (urxvt)
>>  #6  0x0000560e60042804 _ZN9rxvt_term6pty_cbERN2ev2ioEi (urxvt)
>>  #7  0x0000560e6005c10f _Z17ev_invoke_pendingv (urxvt)
>>  #8  0x0000560e6005cb55 ev_run (urxvt)
>>  #9  0x0000560e6003b9b9 main (urxvt)
>>  #10 0x00007fc08883af4a __libc_start_main (libc.so.6)
>>  #11 0x0000560e6003f9da _start (urxvt)
>> 
>> After bisection, it was found the first bad commit is
>> bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped
>> out").
>> 
>> The root cause is as follow.
>> 
>> When the pages are written to storage device during swapping out in
>> swap_writepage(), zswap (fontswap) is tried to compress the pages
>> instead to improve the performance.  But zswap (frontswap) will treat
>> THP as normal page, so only the head page is saved.  After swapping
>> in, tail pages will not be restored to its original contents, so cause
>> the memory corruption in the applications.
>> 
>> This is fixed via splitting THP at the begin of swapping out if
>> frontswap is enabled.  To avoid frontswap to be enabled at runtime,
>> whether the page is THP is checked before using frontswap during
>> swapping out too.
>
> Nice catch, Huang. However, before the adding a new dependency between
> frontswap and vmscan that I want to avoid if it is possible, let's think
> whether frontswap can support THP page or not.
> Can't we handle it with some loop to handle all of subpages of THP page?
> It might be not hard?

Yes.  That could be an optimization over this patch.  This patch is just
a simple fix to make things work and be suitable for stable tree.

I think it may be too complex for stable tree to handle THP in zswap.

Best Regards,
Huang, Ying

>> 
>> Reported-and-tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> Cc: Dan Streetman <ddstreet@ieee.org>
>> Cc: Seth Jennings <sjenning@redhat.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Cc: Shaohua Li <shli@kernel.org>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Shakeel Butt <shakeelb@google.com>
>> Cc: stable@vger.kernel.org # 4.14
>> Fixes: bd4c82c22c367e068 ("mm, THP, swap: delay splitting THP after swapped out")
>> ---
>>  mm/page_io.c |  2 +-
>>  mm/vmscan.c  | 16 +++++++++++++---
>>  2 files changed, 14 insertions(+), 4 deletions(-)
>> 
>> diff --git a/mm/page_io.c b/mm/page_io.c
>> index b41cf9644585..6dca817ae7a0 100644
>> --- a/mm/page_io.c
>> +++ b/mm/page_io.c
>> @@ -250,7 +250,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
>>  		unlock_page(page);
>>  		goto out;
>>  	}
>> -	if (frontswap_store(page) == 0) {
>> +	if (!PageTransHuge(page) && frontswap_store(page) == 0) {
>>  		set_page_writeback(page);
>>  		unlock_page(page);
>>  		end_page_writeback(page);
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index bee53495a829..d1c1e00b08bb 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -55,6 +55,7 @@
>>  
>>  #include <linux/swapops.h>
>>  #include <linux/balloon_compaction.h>
>> +#include <linux/frontswap.h>
>>  
>>  #include "internal.h"
>>  
>> @@ -1063,14 +1064,23 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>>  					/* cannot split THP, skip it */
>>  					if (!can_split_huge_page(page, NULL))
>>  						goto activate_locked;
>> +					/*
>> +					 * Split THP if frontswap enabled,
>> +					 * because it cannot process THP
>> +					 */
>> +					if (frontswap_enabled()) {
>> +						if (split_huge_page_to_list(
>> +							page, page_list))
>> +							goto activate_locked;
>> +					}
>>  					/*
>>  					 * Split pages without a PMD map right
>>  					 * away. Chances are some or all of the
>>  					 * tail pages can be freed without IO.
>>  					 */
>> -					if (!compound_mapcount(page) &&
>> -					    split_huge_page_to_list(page,
>> -								    page_list))
>> +					else if (!compound_mapcount(page) &&
>> +						 split_huge_page_to_list(page,
>> +							page_list))
>>  						goto activate_locked;
>>  				}
>>  				if (!add_to_swap(page)) {
>> -- 
>> 2.15.1
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
