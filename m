Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5E49E6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 06:43:04 -0400 (EDT)
Received: by gxk3 with SMTP id 3so102930gxk.14
        for <linux-mm@kvack.org>; Thu, 09 Jul 2009 03:58:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090709140234.239F.A69D9226@jp.fujitsu.com>
References: <20090707184714.0C73.A69D9226@jp.fujitsu.com>
	 <28c262360907070620n3e22801egd4493c149a263ecd@mail.gmail.com>
	 <20090709140234.239F.A69D9226@jp.fujitsu.com>
Date: Thu, 9 Jul 2009 19:58:59 +0900
Message-ID: <28c262360907090358q7cdbd067y22b7312c489e7598@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] Don't continue reclaim if the system have plenty
	free memory
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 9, 2009 at 2:08 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Hi, Kosaki.
>>
>> On Tue, Jul 7, 2009 at 6:48 PM, KOSAKI
>> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > Subject: [PATCH] Don't continue reclaim if the system have plenty free memory
>> >
>> > On concurrent reclaim situation, if one reclaimer makes OOM, maybe other
>> > reclaimer can stop reclaim because OOM killer makes enough free memory.
>> >
>> > But current kernel doesn't have its logic. Then, we can face following accidental
>> > 2nd OOM scenario.
>> >
>> > 1. System memory is used by only one big process.
>> > 2. memory shortage occur and concurrent reclaim start.
>> > 3. One reclaimer makes OOM and OOM killer kill above big process.
>> > 4. Almost reclaimable page will be freed.
>> > 5. Another reclaimer can't find any reclaimable page because those pages are
>> > ? already freed.
>> > 6. Then, system makes accidental and unnecessary 2nd OOM killer.
>> >
>>
>> Did you see the this situation ?
>> Why I ask is that we have already a routine for preventing parallel
>> OOM killing in __alloc_pages_may_oom.
>>
>> Couldn't it protect your scenario ?
>
> Can you please see actual code of this patch?

I mean follow as,

static inline struct page *
__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
        struct zonelist *zonelist, enum zone_type high_zoneidx,
...
<snip>

        /*
         * Go through the zonelist yet one more time, keep very high watermark
         * here, this is only to catch a parallel oom killing, we must fail if
         * we're still under heavy pressure.
         */
        page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
                order, zonelist, high_zoneidx,
                ALLOC_WMARK_HIGH|ALLOC_CPUSET,
                preferred_zone, migratetype);


> Those two patches fix different problem.
>
> 1/2 fixes the issue of that concurrent direct reclaimer makes
> too many isolated pages.
> 2/2 fixes the issue of that reclaim and exit race makes accidental oom.
>
>
>> If it can't, Could you explain the scenario in more detail ?
>
> __alloc_pages_may_oom() check don't effect the threads of already
> entered reclaim. it's obvious.

Threads which are entered into direct reclaim mode will call
__alloc_pages_may_oom before out_of_memory.
At that time, if one big process is killed a while ago,
get_page_from_freelist in __alloc_pages_may_oom will be succeeded at
last. So I think it doesn't occur OOM.

But in that case, we suffered from unnecessary page scanning per each
priority(12~0). So in this case, your patch is good to me. then you
would be better to change log. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
