Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B25DA6B0319
	for <linux-mm@kvack.org>; Sat,  4 May 2013 09:33:01 -0400 (EDT)
Message-ID: <51850E0A.5010803@bitsync.net>
Date: Sat, 04 May 2013 15:32:58 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: lru milestones, timestamps and ages
References: <20130430110214.22179.26139.stgit@zurg> <5183C49D.1010000@bitsync.net> <5184F6C9.4060506@openvz.org>
In-Reply-To: <5184F6C9.4060506@openvz.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org

On 04.05.2013 13:53, Konstantin Khlebnikov wrote:
> Zlatko Calusic wrote:
>> On 30.04.2013 13:02, Konstantin Khlebnikov wrote:
>>> This patch adds engine for estimating rotation time for pages in lru
>>> lists.
>>>
>>> This adds bunch of 'milestones' into each struct lruvec and inserts
>>> them into
>>> lru lists periodically. Milestone flows in lru together with pages
>>> and brings
>>> timestamp to the end of lru. Because milestones are embedded into
>>> lruvec they
>>> can be easily distinguished from pages by comparing pointers.
>>> Only few functions should care about that.
>>>
>>> This machinery provides discrete-time estimation for age of pages
>>> from the end
>>> of each lru and average age of each kind of evictable lrus in each zone.
>>
>> Great stuff!
>
> Thanks!
>
>>
>> Believe it or not, I had an idea of writing something similar to this,
>> but of course having an idea and actually implementing it are two very
>> different things. Thank you for your work!
>>
>> I will use this to prove (or not) that file pages in the normal zone
>> on a 4GB RAM machine are reused waaaay too soon. Actually, I already
>> have the patch applied and running on the desktop, but it should be
>> much more useful on server workloads. Desktops have erratic load and
>> can go for a long time with very little I/O activity. But, here are
>> the current numbers anyway:
>>
>> Node 0, zone DMA32
>> pages free 5371
>> nr_inactive_anon 4257
>> nr_active_anon 139719
>> nr_inactive_file 617537
>> nr_active_file 51671
>> inactive_ratio: 5
>> avg_age_inactive_anon: 2514752
>> avg_age_active_anon: 2514752
>> avg_age_inactive_file: 876416
>> avg_age_active_file: 2514752
>> Node 0, zone Normal
>> pages free 424
>> nr_inactive_anon 253
>> nr_active_anon 54480
>> nr_inactive_file 63274
>> nr_active_file 44116
>> inactive_ratio: 1
>> avg_age_inactive_anon: 2531712
>> avg_age_active_anon: 2531712
>> avg_age_inactive_file: 901120
>> avg_age_active_file: 2531712
>>
>>> In our kernel we use similar engine as source of statistics for
>>> scheduler in
>>> memory reclaimer. This is O(1) scheduler which shifts vmscan
>>> priorities for lru
>>> vectors depending on their sizes, limits and ages. It tries to
>>> balance memory
>>> pressure among containers. I'll try to rework it for the mainline
>>> kernel soon.
>>>
>>> Seems like these ages also can be used for optimal memory pressure
>>> distribution
>>> between file and anon pages, and probably for balancing pressure
>>> among zones.
>>
>> This all sounds very promising. Especially because I currently observe
>> quite some imbalance among zones.
>
> As I see, most likely reason of such imbalances is 'break' condition
> inside of shrink_lruvec().
> So can try to disable it see what will happen.

Thanks for the hint. I will pay some more attention to this function 
next time I investigate code.

>
> But these numbers from your desktop actually doesn't proves this
> problem. Seems like difference
> between zones is within the precision of this method. I don't know how
> to describe this precisely.
> Probably irregularity between milestones also should be taken into the
> account to describe current
> situation and quality of measurement.
>

Ah, no, the numbers were more like a proof that your patch is running 
fine, nothing specific about them. I was just making a quick check that 
your patch is stable enough before I run it in production, and it seems 
it's working just fine.

In the next hour or so I will patch the kernel on the server where I 
intend to do much more analysis. I also prepared a set of graphs based 
on the numbers your code provides. Based on the preliminary tests, I 
believe that I'll be interested only in the aging of the inactive file 
lists. What I'm after is the bug explained here 
http://marc.info/?l=linux-mm&m=136571221426984 and if I'm right, your 
patch will help to better reveal extreme disbalance observed between 
dma32 and normal zone file LRU aging. But only on a 4GB nodes. I haven't 
seen anything similar on a 8GB nodes, where dma32 and normal zones are 
approximately the same sizes.
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
