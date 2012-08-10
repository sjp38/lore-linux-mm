Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1792A6B005A
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 11:48:33 -0400 (EDT)
Message-ID: <50252D45.50308@redhat.com>
Date: Fri, 10 Aug 2012 11:48:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH -mm 1/3] mm,vmscan: track recent pressure on each
 LRU set
References: <20120808174549.1b10d51a@cuia.bos.redhat.com> <20120808174750.615d9974@cuia.bos.redhat.com> <CALWz4ixBJNu8s9irH9G8O=vMQo1JAzG-jLhOfH4Zbod2EWM-6g@mail.gmail.com>
In-Reply-To: <CALWz4ixBJNu8s9irH9G8O=vMQo1JAzG-jLhOfH4Zbod2EWM-6g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, mhocko@suse.cz, Mel Gorman <mel@csn.ul.ie>

On 08/09/2012 09:22 PM, Ying Han wrote:

>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index f222e06..b03be69 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -189,12 +189,20 @@ struct zone_reclaim_stat {
>>           * The pageout code in vmscan.c keeps track of how many of the
>>           * mem/swap backed and file backed pages are referenced.
>>           * The higher the rotated/scanned ratio, the more valuable
>> -        * that cache is.
>> +        * that cache is. These numbers are aged separately for each LRU.
>>           *
>>           * The anon LRU stats live in [0], file LRU stats in [1]
>>           */
>>          unsigned long           recent_rotated[2];
>>          unsigned long           recent_scanned[2];
>> +       /*
>> +        * This number is incremented together with recent_rotated,
>
> s/recent_rotated/recent/scanned.
>
> I assume the idea here is to associate the scanned to the amount of
> pressure applied on the list.

Indeed.  Pageout scanning equals pressure :)

>> +/*
>> + * Ensure that the ->recent_pressure statistics for this lruvec are
>> + * aged to the same degree as those elsewhere in the system, before
>> + * we do reclaim on this lruvec or evaluate its reclaim priority.
>> + */
>> +static DEFINE_SPINLOCK(recent_pressure_lock);
>> +static int recent_pressure_seq;
>> +static void age_recent_pressure(struct lruvec *lruvec, struct zone *zone)
>> +{
>> +       struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>> +       unsigned long anon  = get_lru_size(lruvec, LRU_ACTIVE_ANON) +
>> +                             get_lru_size(lruvec, LRU_INACTIVE_ANON);
>> +       unsigned long file  = get_lru_size(lruvec, LRU_ACTIVE_FILE) +
>> +                             get_lru_size(lruvec, LRU_INACTIVE_FILE);
>> +       int shift;
>> +
>> +       /*
>> +        * Do not bother recalculating unless we are behind with the
>> +        * system wide statistics, or our local recent_pressure numbers
>> +        * have grown too large. We have to keep the number somewhat
>> +        * small, to ensure that reclaim_score returns non-zero.
>> +        */
>> +       if (reclaim_stat->recent_pressure_seq != recent_pressure_seq &&
>> +                       reclaim_stat->recent_pressure[0] < anon / 4 &&
>> +                       reclaim_stat->recent_pressure[1] < file / 4)
>> +               return;
>
> Let's see if I understand the logic here:
>
> If updating the reclaim_stat->recent_pressure for this lruvec is
> falling behind, don't bother to update it unless the scan count grows
> fast enough. When that happens, recent_pressure is adjusted based on
> the gap between the global pressure level (recent_pressure_seq) and
> local pressure level (reclaim_stat->recent_pressure_seq). The lager
> the gap, the more pressure applied on the lruvec.
>
> 1. if the usage activity(scan_count) is always low on a lruvec, the
> pressure will be low.

The scan count being low, indicates that the lruvec has seen little
pageout pressure recently.

This is essentially unrelated to how actively programs are using
(touching) the pages that are sitting on the lists in this lruvec.

> 2. if the usage activity is low for a while, and then when the
> scan_count jumps suddenly, it will cause the pressure to jump as well
> 3. if the usage activity is always high, the pressure will be high .
>
> So, the mechanism here is a way to balance the system pressure across
> lruvec over time?

Yes.

>> +
>> +       spin_lock(&recent_pressure_lock);
>> +       /*
>> +        * If we are aging due to local activity, increment the global
>> +        * sequence counter. Leave the global counter alone if we are
>> +        * merely playing catchup.
>> +        */
>> +       if (reclaim_stat->recent_pressure_seq == recent_pressure_seq)
>> +               recent_pressure_seq++;
>> +       shift = recent_pressure_seq - reclaim_stat->recent_pressure_seq;
>> +       shift = min(shift, (BITS_PER_LONG-1));
>> +       reclaim_stat->recent_pressure_seq = recent_pressure_seq;
>> +       spin_unlock(&recent_pressure_lock);
>> +
>> +       /* For every aging interval, do one division by two. */
>> +       spin_lock_irq(&zone->lru_lock);
>> +       reclaim_stat->recent_pressure[0] >>= shift;
>> +       reclaim_stat->recent_pressure[1] >>= shift;
>
> This is a bit confusing. I would assume the bigger the shift, the less
> pressure it causes. However, the end result is the other way around.

The longer ago it has been since this lruvec was last scanned by
the page reclaim code, the more the pressure is aged.

The less recent pressure an lruvec has recently seen, the more
likely it is that it will be scanned in the future (see patch 2/3).

Is there anything that I could explain better?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
