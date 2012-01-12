Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id A95D96B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 03:24:58 -0500 (EST)
Message-ID: <4F0E991C.7010009@freescale.com>
Date: Thu, 12 Jan 2012 16:26:04 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/compaction : do optimazition when the migration
 scanner gets no page
References: <1326347222-9980-1-git-send-email-b32955@freescale.com> <20120112080311.GA30634@barrios-desktop.redhat.com>
In-Reply-To: <20120112080311.GA30634@barrios-desktop.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, linux-mm@kvack.org

Hi,
> On Thu, Jan 12, 2012 at 01:47:02PM +0800, Huang Shijie wrote:
>> In the real tests, there are maybe many times the cc->nr_migratepages is zero,
>> but isolate_migratepages() returns ISOLATE_SUCCESS.
>>
>> Memory in our mx6q board:
>> 	2G memory, 8192 pages per page block
>>
>> We use the following command to test in two types system loads:
>> 	#echo 1>  /proc/sys/vm/compact_memory
>>
>> Test Result:
>> 	[1] little load(login in the ubuntu):
>> 		all the scanned pageblocks	: 79
>> 		pageblocks which get no pages	: 46
>>
>> 		The ratio of `get no pages` pageblock is 58.2%.
>>
>> 	[2] heavy load(start thunderbird, firefox, ..etc):
>> 		all the scanned pageblocks	: 89
>> 		pageblocks which get no pages	: 36
>>
>> 		The ratio of `get no pages` pageblock is 40.4%.
>>
>> In order to get better performance, we should check the number of the
>> really isolated pages. And do the optimazition for this case.
>>
>> Also fix the confused comments(from Mel Gorman).
>>
>> Tested this patch in MX6Q board.
>>
>> Signed-off-by: Huang Shijie<b32955@freescale.com>
>> Acked-by: Mel Gorman<mgorman@suse.de>
>> ---
>>   mm/compaction.c |   28 ++++++++++++++++------------
>>   1 files changed, 16 insertions(+), 12 deletions(-)
>>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index f4f514d..41d1b72a 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -246,8 +246,8 @@ static bool too_many_isolated(struct zone *zone)
>>   /* possible outcome of isolate_migratepages */
>>   typedef enum {
>>   	ISOLATE_ABORT,		/* Abort compaction now */
>> -	ISOLATE_NONE,		/* No pages isolated, continue scanning */
>> -	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>> +	ISOLATE_NONE,		/* No pages scanned, consider next pageblock*/
>> +	ISOLATE_SUCCESS,	/* Pages scanned and maybe isolated, migrate */
>>   } isolate_migrate_t;
>>
> Hmm, I don't like this change.
> ISOLATE_NONE mean "we don't isolate any page at all"
> ISOLATE_SUCCESS mean "We isolaetssome pages"
> It's very clear but you are changing semantic slighly.
I think Mel Gorman's new explain is more proper.
> How about this?
>
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
>
>          trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
>
> -       return ISOLATE_SUCCESS;
> +       return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
>   }
>
>   /*
> @@ -542,6 +542,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>                  unsigned long nr_migrate, nr_remaining;
>                  int err;
>
> +               count_vm_event(COMPACTBLOCKS);
not right.
the isolate_migratepage may returns ISOLATE_NONE. We should not account 
this case.

Best Regards
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
