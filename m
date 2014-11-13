Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1ABBC6B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 20:46:36 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hn18so4162886igb.1
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:46:35 -0800 (PST)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id x10si38543114ich.34.2014.11.12.17.46.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 12 Nov 2014 17:46:35 -0800 (PST)
Received: by mail-ie0-f181.google.com with SMTP id rp18so14894929iec.12
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:46:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141112193450.GA18936@dhcp22.suse.cz>
References: <000001cff998$ee0b31d0$ca219570$%yang@samsung.com>
	<20141112193450.GA18936@dhcp22.suse.cz>
Date: Thu, 13 Nov 2014 09:46:34 +0800
Message-ID: <CAL1ERfOJm0HW90Xwe9wuKij_ZXedoKPMo4HdU627XmmpuZExPg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: page_isolation: check pfn validity before access
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Weijie Yang <weijie.yang@samsung.com>, kamezawa.hiroyu@jp.fujitsu.com, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, mina86@mina86.com, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Nov 13, 2014 at 3:34 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 06-11-14 16:08:02, Weijie Yang wrote:
>> In the undo path of start_isolate_page_range(), we need to check
>> the pfn validity before access its page, or it will trigger an
>> addressing exception if there is hole in the zone.
>
> This looks a bit fishy to me. I am not familiar with the code much but
> at least __offline_pages zone = page_zone(pfn_to_page(start_pfn)) so it
> would blow up before we got here. Same applies to the other caller
> alloc_contig_range. So either both need a fix and then
> start_isolate_page_range doesn't need more checks or this is all
> unnecessary.

Thanks for your suggestion.
If start_isolate_page_range()'s user can ensure there isn't hole in
the [start_pfn, end_pfn) range, we can remove the checks. But if we
cann't, I think it's better reserve these "unnecessary" code.
That's really obfuscated : (

> Please do not make this code more obfuscated than it is already...
>
>> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
>> ---
>>  mm/page_isolation.c |    7 +++++--
>>  1 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
>> index d1473b2..3ddc8b3 100644
>> --- a/mm/page_isolation.c
>> +++ b/mm/page_isolation.c
>> @@ -137,8 +137,11 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>>  undo:
>>       for (pfn = start_pfn;
>>            pfn < undo_pfn;
>> -          pfn += pageblock_nr_pages)
>> -             unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
>> +          pfn += pageblock_nr_pages) {
>> +             page = __first_valid_page(pfn, pageblock_nr_pages);
>> +             if (page)
>> +                     unset_migratetype_isolate(page, migratetype);
>> +     }
>>
>>       return -EBUSY;
>>  }
>> --
>> 1.7.0.4
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
