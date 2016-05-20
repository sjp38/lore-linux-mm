Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 084BF6B0253
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:19:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so68486342wme.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:19:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c15si6761336wmh.64.2016.05.20.06.19.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 06:19:13 -0700 (PDT)
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
 <20160520130649.GB5197@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573F0ED0.4010908@suse.cz>
Date: Fri, 20 May 2016 15:19:12 +0200
MIME-Version: 1.0
In-Reply-To: <20160520130649.GB5197@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/20/2016 03:06 PM, Michal Hocko wrote:
> On Thu 19-05-16 15:11:23, David Rientjes wrote:
>> If page migration fails due to -ENOMEM, nr_failed should still be
>> incremented for proper statistics.
>>
>> This was encountered recently when all page migration vmstats showed 0,
>> and inferred that migrate_pages() was never called, although in reality
>> the first page migration failed because compaction_alloc() failed to find
>> a migration target.
>>
>> This patch increments nr_failed so the vmstat is properly accounted on
>> ENOMEM.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>
> Acked-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> One question though
>
>> ---
>>   mm/migrate.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>>
>>   			switch(rc) {
>>   			case -ENOMEM:
>> +				nr_failed++;
>>   				goto out;
>>   			case -EAGAIN:
>>   				retry++;
>
> Why don't we need also to count also retries?

We could, but not like you suggest.

> ---
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 53ab6398e7a2..ef9c5211ae3c 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>   			}
>   		}
>   	}
> +out:
>   	nr_failed += retry;
>   	rc = nr_failed;

This overwrites rc == -ENOMEM, which at least compaction needs to 
recognize. But we could duplicate "nr_failed += retry" in the case -ENOMEM.

> -out:
>   	if (nr_succeeded)
>   		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
>   	if (nr_failed)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
