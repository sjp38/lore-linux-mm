Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE7D8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 01:08:37 -0500 (EST)
Received: by fxm18 with SMTP id 18so922139fxm.14
        for <linux-mm@kvack.org>; Thu, 10 Mar 2011 22:08:34 -0800 (PST)
Message-ID: <4D79BC60.1040106@gmail.com>
Date: Fri, 11 Mar 2011 09:08:32 +0300
From: "avagin@gmail.com" <avagin@gmail.com>
Reply-To: avagin@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable()
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>	<20110305152056.GA1918@barrios-desktop>	<4D72580D.4000208@gmail.com>	<20110305155316.GB1918@barrios-desktop>	<4D7267B6.6020406@gmail.com>	<20110305170759.GC1918@barrios-desktop>	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>	<AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>	<20110311085833.874c6c0e.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTi=1695Wp9UheV_OKk5MixNUY2aHWfQ2WO1evSe2@mail.gmail.com>
In-Reply-To: <AANLkTi=1695Wp9UheV_OKk5MixNUY2aHWfQ2WO1evSe2@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/11/2011 03:18 AM, Minchan Kim wrote:
> On Fri, Mar 11, 2011 at 8:58 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com>  wrote:
>> On Thu, 10 Mar 2011 15:58:29 +0900
>> Minchan Kim<minchan.kim@gmail.com>  wrote:
>>
>>> Hi Kame,
>>>
>>> Sorry for late response.
>>> I had a time to test this issue shortly because these day I am very busy.
>>> This issue was interesting to me.
>>> So I hope taking a time for enough testing when I have a time.
>>> I should find out root cause of livelock.
>>>
>>
>> Thanks. I and Kosaki-san reproduced the bug with swapless system.
>> Now, Kosaki-san is digging and found some issue with scheduler boost at OOM
>> and lack of enough "wait" in vmscan.c.
>>
>> I myself made patch like attached one. This works well for returning TRUE at
>> all_unreclaimable() but livelock(deadlock?) still happens.
>
> I saw the deadlock.
> It seems to happen by following code by my quick debug but not sure. I
> need to investigate further but don't have a time now. :(
>
>
>                   * Note: this may have a chance of deadlock if it gets
>                   * blocked waiting for another task which itself is waiting
>                   * for memory. Is there a better alternative?
>                   */
>                  if (test_tsk_thread_flag(p, TIF_MEMDIE))
>                          return ERR_PTR(-1UL);
> It would be wait to die the task forever without another victim selection.
> If it's right, It's a known BUG and we have no choice until now. Hmm.


I fixed this bug too and sent patch "mm: skip zombie in OOM-killer".

http://groups.google.com/group/linux.kernel/browse_thread/thread/b9c6ddf34d1671ab/2941e1877ca4f626?lnk=raot&pli=1

-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
+		if (test_tsk_thread_flag(p, TIF_MEMDIE) && p->mm)
   			return ERR_PTR(-1UL);

It is not committed yet, because Devid Rientjes and company think what 
to do with "[patch] oom: prevent unnecessary oom kills or kernel panics.".
>
>> I wonder vmscan itself isn't a key for fixing issue.
>
> I agree.
>
>> Then, I'd like to wait for Kosaki-san's answer ;)
>
> Me, too. :)
>
>>
>> I'm now wondering how to catch fork-bomb and stop it (without using cgroup).
>
> Yes. Fork throttling without cgroup is very important.
> And as off-topic, mem_notify without memcontrol you mentioned is
> important to embedded people, I gues.
>
>> I think the problem is that fork-bomb is faster than killall...
>
> And deadlock problem I mentioned.
>
>>
>> Thanks,
>> -Kame
>
> Thanks for the investigation, Kame.
>
>> ==
>>
>> This is just a debug patch.
>>
>> ---
>>   mm/vmscan.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
>>   1 file changed, 54 insertions(+), 4 deletions(-)
>>
>> Index: mmotm-0303/mm/vmscan.c
>> ===================================================================
>> --- mmotm-0303.orig/mm/vmscan.c
>> +++ mmotm-0303/mm/vmscan.c
>> @@ -1983,9 +1983,55 @@ static void shrink_zones(int priority, s
>>         }
>>   }
>>
>> -static bool zone_reclaimable(struct zone *zone)
>> +static bool zone_seems_empty(struct zone *zone, struct scan_control *sc)
>>   {
>> -       return zone->pages_scanned<  zone_reclaimable_pages(zone) * 6;
>> +       unsigned long nr, wmark, free, isolated, lru;
>> +
>> +       /*
>> +        * If scanned, zone->pages_scanned is incremented and this can
>> +        * trigger OOM.
>> +        */
>> +       if (sc->nr_scanned)
>> +               return false;
>> +
>> +       free = zone_page_state(zone, NR_FREE_PAGES);
>> +       isolated = zone_page_state(zone, NR_ISOLATED_FILE);
>> +       if (nr_swap_pages)
>> +               isolated += zone_page_state(zone, NR_ISOLATED_ANON);
>> +
>> +       /* In we cannot do scan, don't count LRU pages. */
>> +       if (!zone->all_unreclaimable) {
>> +               lru = zone_page_state(zone, NR_ACTIVE_FILE);
>> +               lru += zone_page_state(zone, NR_INACTIVE_FILE);
>> +               if (nr_swap_pages) {
>> +                       lru += zone_page_state(zone, NR_ACTIVE_ANON);
>> +                       lru += zone_page_state(zone, NR_INACTIVE_ANON);
>> +               }
>> +       } else
>> +               lru = 0;
>> +       nr = free + isolated + lru;
>> +       wmark = min_wmark_pages(zone);
>> +       wmark += zone->lowmem_reserve[gfp_zone(sc->gfp_mask)];
>> +       wmark += 1<<  sc->order;
>> +       printk("thread %d/%ld all %d scanned %ld pages %ld/%ld/%ld/%ld/%ld/%ld\n",
>> +               current->pid, sc->nr_scanned, zone->all_unreclaimable,
>> +               zone->pages_scanned,
>> +               nr,free,isolated,lru,
>> +               zone_reclaimable_pages(zone), wmark);
>> +       /*
>> +        * In some case (especially noswap), almost all page cache are paged out
>> +        * and we'll see the amount of reclaimable+free pages is smaller than
>> +        * zone->min. In this case, we canoot expect any recovery other
>> +        * than OOM-KILL. We can't reclaim memory enough for usual tasks.
>> +        */
>> +
>> +       return nr<= wmark;
>> +}
>> +
>> +static bool zone_reclaimable(struct zone *zone, struct scan_control *sc)
>> +{
>> +       /* zone_reclaimable_pages() can return 0, we need<= */
>> +       return zone->pages_scanned<= zone_reclaimable_pages(zone) * 6;
>>   }
>>
>>   /*
>> @@ -2006,11 +2052,15 @@ static bool all_unreclaimable(struct zon
>>                         continue;
>>                 if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
>>                         continue;
>> -               if (zone_reclaimable(zone)) {
>> +               if (zone_seems_empty(zone, sc))
>> +                       continue;
>> +               if (zone_reclaimable(zone, sc)) {
>>                         all_unreclaimable = false;
>>                         break;
>>                 }
>>         }
>> +       if (all_unreclaimable)
>> +               printk("all_unreclaimable() returns TRUE\n");
>>
>>         return all_unreclaimable;
>>   }
>> @@ -2456,7 +2506,7 @@ loop_again:
>>                         if (zone->all_unreclaimable)
>>                                 continue;
>>                         if (!compaction&&  nr_slab == 0&&
>> -                           !zone_reclaimable(zone))
>> +                           !zone_reclaimable(zone,&sc))
>>                                 zone->all_unreclaimable = 1;
>>                         /*
>>                          * If we've done a decent amount of scanning and
>>
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
