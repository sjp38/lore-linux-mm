Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 883E86B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 10:42:48 -0400 (EDT)
Received: by gxk3 with SMTP id 3so1651074gxk.14
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 07:44:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2f11576a0906250714o5d77db11wd32c1c7139753cb5@mail.gmail.com>
References: <20090625183616.23b55b24.minchan.kim@barrios-desktop>
	 <2f11576a0906250714o5d77db11wd32c1c7139753cb5@mail.gmail.com>
Date: Thu, 25 Jun 2009 23:44:09 +0900
Message-ID: <28c262360906250744h5bf9f0a0w265d8c35e7d69335@mail.gmail.com>
Subject: Re: [PATCH] prevent to reclaim anon page of lumpy reclaim for no swap
	space
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 11:14 PM, KOSAKI
Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
>> This patch prevent to reclaim anon page in case of no swap space.
>> VM already prevent to reclaim anon page in various place.
>> But it doesnt't prevent it for lumpy reclaim.
>>
>> It shuffles lru list unnecessary so that it is pointless.
>
> NAK.
>
> 1. if system have no swap, add_to_swap() never get swap entry.
>   eary check don't improve performance so much.

Hmm. I mean no swap space but not no swap device.
add_to_swap ? You mean Rik pointed me out ?
If system have swap device, Rik's pointing is right.
I will update his suggestion.

> 2. __isolate_lru_page() is not only called lumpy reclaim case, but
> also be called
>    normal reclaim.

You mean about performance degradation ?
I think most case have enough swap space and then one condition
variable(nr_swap_page) check is trivial. I think.
We can also use [un]likely but I am not sure it help us.


> 3. if system have no swap, anon pages shuffuling doesn't cause any matter.

Again, I mean no swap space but no swap device system.
And I have a plan to remove anon_vma in no swap device system.

As you point me out, it's pointless in no swap device system.
I don't like unnecessary structure memory footprint and locking overhead.
I think no swap device system is problem in server environment as well
as embedded. but I am not sure when I will do. :)


> Then, I don't think this patch's benefit is bigger than side effect.
>
>
>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> ---
>>  mm/vmscan.c |    6 ++++++
>>  1 files changed, 6 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 026f452..fb401fe 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -830,7 +830,13 @@ int __isolate_lru_page(struct page *page, int mode, int file)
>>         * When this function is being called for lumpy reclaim, we
>>         * initially look into all LRU pages, active, inactive and
>>         * unevictable; only give shrink_page_list evictable pages.
>> +
>> +        * If we don't have enough swap space, reclaiming of anon page
>> +        * is pointless.
>>         */
>> +       if (nr_swap_pages <= 0 && PageAnon(page))
>> +               return ret;
>> +
>>        if (PageUnevictable(page))
>>                return ret;
>>
>> --
>> 1.5.4.3
>>
>>
>>
>>
>> --
>> Kinds Regards
>> Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>



--
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
