Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 50A836B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 03:53:03 -0400 (EDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOJ00LFU1WDFAI0@mailout2.samsung.com> for linux-mm@kvack.org;
 Mon, 17 Jun 2013 16:53:01 +0900 (KST)
Message-id: <51BEC0A1.7090807@samsung.com>
Date: Mon, 17 Jun 2013 16:54:09 +0900
From: Heesub Shin <heesub.shin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: vmscan: remove redundant querying to shrinker
References: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
 <20130617000827.GI29338@dastard>
In-reply-to: <20130617000827.GI29338@dastard>
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com

Hello,

On 06/17/2013 09:08 AM, Dave Chinner wrote:
> On Fri, Jun 14, 2013 at 07:07:51PM +0900, Heesub Shin wrote:
>> shrink_slab() queries each slab cache to get the number of
>> elements in it. In most cases such queries are cheap but,
>> on some caches. For example, Android low-memory-killer,
>> which is operates as a slab shrinker, does relatively
>> long calculation once invoked and it is quite expensive.
>
> As has already been pointed out, the low memory killer is a badly
> broken piece of code. I can't run a normal machine with it enabled
> because it randomly kills processes whenever memory pressure is
> generated. What it does is simply broken and hence arguing that it
> has too much overhead is not a convincing argument for changing core
> shrinker infrastructure.
>
>> This patch removes redundant queries to shrinker function
>> in the loop of shrink batch.
>>
>> Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
>> ---
>>   mm/vmscan.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index fa6a853..11b6695 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -282,9 +282,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>   					max_pass, delta, total_scan);
>>
>>   		while (total_scan >= batch_size) {
>> -			int nr_before;
>> +			int nr_before = max_pass;
>>
>> -			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
>>   			shrink_ret = do_shrinker_shrink(shrinker, shrink,
>>   							batch_size);
>>   			if (shrink_ret == -1)
>> @@ -293,6 +292,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
>>   				ret += nr_before - shrink_ret;
>>   			count_vm_events(SLABS_SCANNED, batch_size);
>>   			total_scan -= batch_size;
>> +			max_pass = shrink_ret;
>>
>>   			cond_resched();
>>   		}
>
> Shrinkers run concurrently on different CPUs, and so the state of
> the cache being shrunk can change significantly when cond_resched()
> actually yields the CPU.  Hence we need to recalculate the current
> state of the cache before we shrink again to get an accurate idea of
> how much work the current loop has done. If we get this badly wrong,
> the caller of shrink_slab() will get an incorrect idea of how much
> work was actually done by the shrinkers....
>
> This problem is fixed in mmtom by the change of shrinker API that
> results shrinker->scan_objects() returning the number of objects
> freed directly, and hence it isn't necessary to have a
> shrinker->count_objects() call in the scan loop anymore. i.e. the
> reworked scan loop ends up like:
>
> 	while (total_scan >= batch_size) {
> 		unsigned long ret;
> 		shrinkctl->nr_to_scan = batch_size;
> 		ret = shrinker->scan_objects(shrinker, shrinkctl);
>
> 		if (ret == SHRINK_STOP)
> 			break;
> 		freed += ret;
>
> 		count_vm_events(SLABS_SCANNED, batch_size);
> 		total_scan -= batch_size;
> 	}
>
> So we've already solved the problem you are concerned about....
>
> Cheers,
>
> Dave.
>

Thank you for all your comments. I have been keeping up with the mm-list 
for a while, but it was my first time having to send out patches and 
stuff. I only intended to ask for your reviews and feedbacks. Will make 
sure I get over the learning curve until next time around.

Thank you mm guys, Dave, Minchan and Andrew again.

-- 
Heesub

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
