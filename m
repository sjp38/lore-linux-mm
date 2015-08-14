Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 01FD66B0255
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 01:04:01 -0400 (EDT)
Received: by oio137 with SMTP id 137so38720508oio.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 22:04:00 -0700 (PDT)
Received: from BLU004-OMC1S29.hotmail.com (blu004-omc1s29.hotmail.com. [65.55.116.40])
        by mx.google.com with ESMTPS id gm2si3351093obb.35.2015.08.13.22.03.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 13 Aug 2015 22:04:00 -0700 (PDT)
Message-ID: <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Fri, 14 Aug 2015 13:03:53 +0800
MIME-Version: 1.0
In-Reply-To: <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 8/14/15 12:19 PM, Naoya Horiguchi wrote:
> On Thu, Aug 13, 2015 at 06:27:40PM +0800, Wanpeng Li wrote:
>> On 8/13/15 6:04 PM, Naoya Horiguchi wrote:
>>> On Thu, Aug 13, 2015 at 05:18:56PM +0800, Wanpeng Li wrote:
>>>> On 8/13/15 4:53 PM, Naoya Horiguchi wrote:
>>> ...
>>>>> I think that unpoison is used only in testing so this race never affects
>>>>> our end-users/customers, so going back to this migratetype change stuff
>>>>> looks unworthy to me.
>>>> Migratetype stuff is just removed by you two months ago, then this bug
>>>> occurs recently since the more and more patches which you fix some races.
>>> Yes, this race (which existed before my recent changes) became more visible
>> IIUC, no. The page will be freed before PageHWPoison is set. So the race
>> doesn't exist.
> OK ...
>
>>> with that changes. But I don't think that simply reverting them is a right solution.
>>>
>>>>> If I read correctly, the old migratetype approach has a few problems:
>>>>>   1) it doesn't fix the problem completely, because
>>>>>      set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to the
>>>>>      target page if the pageblock of the page contains one or more
>>>>>      unmovable pages (i.e. has_unmovable_pages() returns true).
>>>>>   2) the original code changes migratetype to MIGRATE_ISOLATE forcibly,
>>>>>      and sets it to MIGRATE_MOVABLE forcibly after soft offline, regardless
>>>>>      of the original migratetype state, which could impact other subsystems
>>>>>      like memory hotplug or compaction.
>>>> Maybe we can add a "FIXME" comment on the Migratetype stuff, since the
>>>> current linus tree calltrace and it should be fixed immediately, and I
>>>> don't see obvious bugs appear on migratetype stuffs at least currently,
>>>> so "FIXME" is enough. :-)
>>> Sorry if confusing, but my intention in saying about "FIXME" comment was
>>> that we can find another solution for this race rather than just reverting,
>>> so adding comment about the reported bug in current code (keeping code from
>>> 4491f712606) is OK for very short term.
>>> I understand that leaving a race window of BUG_ON is not the best thing, but
>>> as I said, this race shouldn't affect end-users, so this is not an urgent bug.
>>> # It's enough if testers know this.
>> The 4.2 is coming, this patch can be applied as a temporal solution in
>> order to fix the broken linus tree, and the any final solution can be
>> figured out later.
> I didn't reproduce this problem yet in my environment, but from code reading
> I guess that checking PageHWPoison flag in unmap_and_move() like below could
> avoid the problem. Could you testing with this, please?

I have already try to modify unmap_and_move() the same as what you do
before I post migratetype stuff. It doesn't work and have other calltrace.

Regards,
Wanpeng Li

>
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 14 Aug 2015 08:04:03 +0900
> Subject: [PATCH] mm: hwpoison: migrate: fix race b/w soft-offline and unpoison
>
> [description to be written ...]
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/migrate.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index eb4267107d1f..24f5b9acc26a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -953,7 +953,13 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>  				page_is_file_cache(page));
>  		/* Soft-offlined page shouldn't go through lru cache list */
>  		if (reason == MR_MEMORY_FAILURE)
> -			put_page(page);
> +			/*
> +			 * Check race condition with unpoison, where the source
> +			 * page is handled by unpoison handler which decrements
> +			 * the refcount, so no need to call put_page() here.
> +			 */
> +			if (PageHWPoison(page))
> +				put_page(page);
>  		else
>  			putback_lru_page(page);
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
