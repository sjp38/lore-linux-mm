Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 534D06B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 03:45:24 -0400 (EDT)
Received: by lagz14 with SMTP id z14so425737lag.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 00:45:22 -0700 (PDT)
Message-ID: <4F9A4E8E.4040700@openvz.org>
Date: Fri, 27 Apr 2012 11:45:18 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH next 00/12] mm: replace struct mem_cgroup_zone with struct
 lruvec
References: <20120426074632.18961.17803.stgit@zurg> <20120426162546.90991b7c.akpm@linux-foundation.org>
In-Reply-To: <20120426162546.90991b7c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>

Andrew Morton wrote:
> On Thu, 26 Apr 2012 11:53:44 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> This patchset depends on Johannes Weiner's patch
>> "mm: memcg: count pte references from every member of the reclaimed hierarchy".
>>
>> bloat-o-meter delta for patches 2..12
>>
>> add/remove: 6/6 grow/shrink: 6/14 up/down: 4414/-4625 (-211)
>
> That's the sole effect and intent of the patchset?  To save 211 bytes?

This is almost last bunch of cleanups for lru_lock splitting,
code reducing is only nice side-effect.
Also this patchset removes many redundant lruvec relookups.

Now mostly all page-to-lruvec translations are located at the same level
as zone->lru_lock locking. So lru-lock splitting patchset can something like this:

-zone = page_zone(page)
-spin_lock_irq(&zone->lru_lock)
-lruvec = mem_cgroup_page_lruvec(page)
+lruvec = lock_page_lruvec_irq(page)

>
>> ...
>>
>>   include/linux/memcontrol.h |   16 +--
>>   include/linux/mmzone.h     |   14 ++
>>   mm/memcontrol.c            |   33 +++--
>>   mm/mmzone.c                |   14 ++
>>   mm/page_alloc.c            |    8 -
>>   mm/vmscan.c                |  277 ++++++++++++++++++++------------------------
>>   6 files changed, 177 insertions(+), 185 deletions(-)
>
> If so, I'm not sure that it is worth the risk and effort?

After lumpy-reclaim removal there a lot of dead or redundant code, maybe someone else
wants to cleanup this code, I specifically sent this set early to avoid conflicts.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
