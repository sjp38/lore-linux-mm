Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E13C66B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 03:20:41 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.1/8.13.1) with ESMTP id o3K7L4fX008523
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 07:21:04 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3K7L3X41708060
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 09:21:04 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3K7L3Fi007167
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 09:21:03 +0200
Message-ID: <4BCD55DA.2020000@linux.vnet.ibm.com>
Date: Tue, 20 Apr 2010 09:20:58 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org>
In-Reply-To: <20100419214412.GB5336@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>



Johannes Weiner wrote:
> On Mon, Apr 19, 2010 at 02:22:36PM +0200, Christian Ehrhardt wrote:
>> So now coming to the probably most critical part - the evict once discussion in this thread.
>> I'll try to explain what I found in the meanwhile - let me know whats unclear and I'll add data etc.
>>
>> In the past we identified that "echo 3 > /proc/sys/vm/drop_caches" helps to improve the accuracy of the used testcase by lowering the noise from 5-8% to <1%.
>> Therefore I ran all tests and verifications with that drops.
>> In the meanwhile I unfortunately discovered that Mel's fix only helps for the cases when the caches are dropped.
>> Without it seems to be bad all the time. So don't cast the patch away due to that discovery :-)
>>
>> On the good side I was also able to analyze a few more things due to that insight - and it might give us new data to debug the root cause.
>> Like Mel I also had identified "56e49d21 vmscan: evict use-once pages first" to be related in the past. But without the watermark wait fix, unapplying it 56e49d21 didn't change much for my case so I left this analysis path.
>>
>> But now after I found dropping caches is the key to "get back good performance" and "subsequent writes for bad performance" even with watermark wait applied I checked what else changes:
>> - first write/read load after reboot or dropping caches -> read TP good
>> - second write/read load after reboot or dropping caches -> read TP bad
>> => so what changed.
>>
>> I went through all kind of logs and found something in the system activity report which very probably is related to 56e49d21.
>> When issuing subsequent writes after I dropped caches to get a clean start I get this in Buffers/Caches from Meminfo:
>>
>> pre write 1
>> Buffers:             484 kB
>> Cached:             5664 kB
>> pre write 2
>> Buffers:           33500 kB
>> Cached:           149856 kB
>> pre write 3
>> Buffers:           65564 kB
>> Cached:           115888 kB
>> pre write 4
>> Buffers:           85556 kB
>> Cached:            97184 kB
>>
>> It stays at ~85M with more writes which is approx 50% of my free 160M memory.
> 
> Ok, so I am the idiot that got quoted on 'the active set is not too big, so
> buffer heads are not a problem when avoiding to scan it' in eternal history.
> 
> But the threshold inactive/active ratio for skipping active file pages is
> actually 1:1.
> 
> The easiest 'fix' is probably to change that ratio, 2:1 (or even 3:1?) appears
> to be a bit more natural anyway?  Below is a patch that changes it to 2:1.
> Christian, can you check if it fixes your regression?

I'll check it out.
from the numbers I have up to now I know that the good->bad transition 
for my case is somewhere between 30M/60M e.g. first and second write.
The ratio 2:1 will eat max 53M of my ~160M that gets split up.

That means setting the ratio to 2:1 or whatever else might help or not, 
but eventually there is just another setting of workload vs. memory 
constraints that would still be affected. Still I guess 3:1 (and I'll 
try that as well) should be enough to be a bit more towards the save side.

> Additionally, we can always scan active file pages but only deactivate them
> when the ratio is off and otherwise strip buffers of clean pages.

In think we need something that allows the system to forget its history 
somewhen - be it 1:1 or x:1 - if the workload changes "long enough"(tm) 
it should eventually throw all old things out.
Like I described before many systems have different usage patterns when 
e.g. comparing day/night workload. So it is far from optimal if e.g. day 
write loads eat so much cache and never give it back for nightly huge 
reads tasks or something similar.

Would your suggestion achieve that already?
If not what kind change could?

> What do people think?
> 
> 	Hannes
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f4ede99..a4aea76 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -898,7 +898,7 @@ int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
>  	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
>  	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
> 
> -	return (active > inactive);
> +	return (active > inactive / 2);
>  }
> 
>  unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3ff3311..8f1a846 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1466,7 +1466,7 @@ static int inactive_file_is_low_global(struct zone *zone)
>  	active = zone_page_state(zone, NR_ACTIVE_FILE);
>  	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> 
> -	return (active > inactive);
> +	return (active > inactive / 2);
>  }
> 
>  /**
> 

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
