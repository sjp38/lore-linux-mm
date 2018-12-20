Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1581C8E0002
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:32:41 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so2695177edz.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 07:32:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor13175143edc.17.2018.12.20.07.32.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 07:32:39 -0800 (PST)
Date: Thu, 20 Dec 2018 15:32:37 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_alloc: Fix has_unmovable_pages for HugePages
Message-ID: <20181220153237.bhepsqw27mjmc4g5@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181217225113.17864-1-osalvador@suse.de>
 <20181219142528.yx6ravdyzcqp5wtd@master>
 <20181219233914.2fxe26pih26ifvmt@d104.suse.de>
 <20181220091228.GB14234@dhcp22.suse.cz>
 <20181220124925.itwuuacgztpgsk7s@d104.suse.de>
 <20181220130606.GG9104@dhcp22.suse.cz>
 <20181220134132.6ynretwlndmyupml@d104.suse.de>
 <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220142124.r34fnuv6b33luj5a@d104.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, pavel.tatashin@microsoft.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 03:21:27PM +0100, Oscar Salvador wrote:
>On Thu, Dec 20, 2018 at 02:41:32PM +0100, Oscar Salvador wrote:
>> On Thu, Dec 20, 2018 at 02:06:06PM +0100, Michal Hocko wrote:
>> > You did want iter += skip_pages - 1 here right?
>> 
>> Bleh, yeah.
>> I am taking vacation today so my brain has left me hours ago, sorry.
>> Should be:
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 4812287e56a0..0634fbdef078 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -8094,7 +8094,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>                                 goto unmovable;
>>  
>>                         skip_pages = (1 << compound_order(head)) - (page - head);
>> -                       iter = round_up(iter + 1, skip_pages) - 1;
>> +                       iter += skip_pages - 1;
>>                         continue;
>>                 }
>
>On a second thought, I think it should not really matter.
>
>AFAICS, we can have these scenarios:
>
>1) the head page is the first page in the pabeblock
>2) first page in the pageblock is not a head but part of a hugepage
>3) the head is somewhere within the pageblock
>
>For cases 1) and 3), iter will just get the right value and we will
>break the loop afterwards.
>
>In case 2), iter will be set to a value to skip over the remaining pages.
>
>I am assuming that hugepages are allocated and packed together.
>
>Note that I am not against the change, but I just wanted to see if there is
>something I am missing.

I have another way of classification.

First is three cases of expected new_iter.

             1          2                        3
             v          v                        v
 HugePage    +-----------------------------------+
                                                  ^
                                                  |
                                               new_iter

>From this char, we may have three cases:

  1) iter is the head page 
  2) iter is the middle page
  2) iter is the tail page

No matter which case iter starts, new_iter should be point to tail + 1.

Second is the relationship between the new_iter and the pageblock, only
two cases:

  1) new_iter is still in current pageblock
  2) new_iter is out of current pageblock

For both cases, current loop handles it well.

Now let's go back to see how to calculate new_iter. From the chart
above, we can see this formula stands for all three cases:

    new_iter = round_up(iter + 1, page_size(HugePage))

So it looks the first version is correct.

>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me
