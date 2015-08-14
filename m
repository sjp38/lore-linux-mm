Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 469076B0255
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 03:54:45 -0400 (EDT)
Received: by oio137 with SMTP id 137so40313831oio.0
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 00:54:45 -0700 (PDT)
Received: from BLU004-OMC1S11.hotmail.com (blu004-omc1s11.hotmail.com. [65.55.116.22])
        by mx.google.com with ESMTPS id i81si1436921oia.44.2015.08.14.00.54.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Aug 2015 00:54:44 -0700 (PDT)
Message-ID: <BLU437-SMTP24AA9CF28EF66D040D079B807C0@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
 <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Fri, 14 Aug 2015 15:54:36 +0800
MIME-Version: 1.0
In-Reply-To: <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 8/14/15 3:26 PM, Naoya Horiguchi wrote:
> On Fri, Aug 14, 2015 at 01:03:53PM +0800, Wanpeng Li wrote:
>> On 8/14/15 12:19 PM, Naoya Horiguchi wrote:
> ...
>>>>>>> If I read correctly, the old migratetype approach has a few problems:
>>>>>>>   1) it doesn't fix the problem completely, because
>>>>>>>      set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to the
>>>>>>>      target page if the pageblock of the page contains one or more
>>>>>>>      unmovable pages (i.e. has_unmovable_pages() returns true).
>>>>>>>   2) the original code changes migratetype to MIGRATE_ISOLATE forcibly,
>>>>>>>      and sets it to MIGRATE_MOVABLE forcibly after soft offline, regardless
>>>>>>>      of the original migratetype state, which could impact other subsystems
>>>>>>>      like memory hotplug or compaction.
>>>>>> Maybe we can add a "FIXME" comment on the Migratetype stuff, since the
>>>>>> current linus tree calltrace and it should be fixed immediately, and I
>>>>>> don't see obvious bugs appear on migratetype stuffs at least currently,
>>>>>> so "FIXME" is enough. :-)
>>>>> Sorry if confusing, but my intention in saying about "FIXME" comment was
>>>>> that we can find another solution for this race rather than just reverting,
>>>>> so adding comment about the reported bug in current code (keeping code from
>>>>> 4491f712606) is OK for very short term.
>>>>> I understand that leaving a race window of BUG_ON is not the best thing, but
>>>>> as I said, this race shouldn't affect end-users, so this is not an urgent bug.
>>>>> # It's enough if testers know this.
>>>> The 4.2 is coming, this patch can be applied as a temporal solution in
>>>> order to fix the broken linus tree, and the any final solution can be
>>>> figured out later.
>>> I didn't reproduce this problem yet in my environment, but from code reading
>>> I guess that checking PageHWPoison flag in unmap_and_move() like below could
>>> avoid the problem. Could you testing with this, please?
>> I have already try to modify unmap_and_move() the same as what you do
>> before I post migratetype stuff. It doesn't work and have other calltrace.
> OK, then I rethink of handling the race in unpoison_memory().
>
> Currently properly contained/hwpoisoned pages should have page refcount 1
> (when the memory error hits LRU pages or hugetlb pages) or refcount 0
> (when the memory error hits the buddy page.) And current unpoison_memory()
> implicitly assumes this because otherwise the unpoisoned page has no place
> to go and it's just leaked.
> So to avoid the kernel panic, adding prechecks of refcount and mapcount
> to limit the page to unpoison for only unpoisonable pages looks OK to me.
> The page under soft offlining always has refcount >=2 and/or mapcount > 0,
> so such pages should be filtered out.
>
> Here's a patch. In my testing (run soft offline stress testing then repeat
> unpoisoning in background,) the reported (or similar) bug doesn't happen.
> Can I have your comments?

As page_action() prints out page maybe still referenced by some users,
however, PageHWPoison has already set. So you will leak many poison pages.

Regards,
Wanpeng Li

>
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] mm/hwpoison: don't unpoison for pinned or mapped page
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d1f85f6278ee..c6f14d2cd919 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -1442,6 +1442,16 @@ int unpoison_memory(unsigned long pfn)
>  		return 0;
>  	}
>  
> +	if (page_count(page) > 1) {
> +		pr_info("MCE: Someone grabs the hwpoison page %#lx\n", pfn);
> +		return 0;
> +	}
> +
> +	if (page_mapped(page)) {
> +		pr_info("MCE: Someone maps the hwpoison page %#lx\n", pfn);
> +		return 0;
> +	}
> +
>  	/*
>  	 * unpoison_memory() can encounter thp only when the thp is being
>  	 * worked by memory_failure() and the page lock is not held yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
