Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1954B6B026C
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 21:24:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 204so258820646pge.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:24:29 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id s75si21739699pgs.53.2017.01.24.18.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 18:24:28 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 3so394547pgj.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 18:24:28 -0800 (PST)
Subject: Re: [PATCH RFC 3/3] mm, vmscan: correct prepare_kswapd_sleep return
 value
References: <1485244144-13487-1-git-send-email-hejianet@gmail.com>
 <1485244144-13487-4-git-send-email-hejianet@gmail.com>
 <1485295267.15964.38.camel@redhat.com>
From: hejianet <hejianet@gmail.com>
Message-ID: <1f17d49a-90dc-aa2b-6a3a-6fb5291e318f@gmail.com>
Date: Wed, 25 Jan 2017 10:24:08 +0800
MIME-Version: 1.0
In-Reply-To: <1485295267.15964.38.camel@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vaishali Thakkar <vaishali.thakkar@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>



On 25/01/2017 6:01 AM, Rik van Riel wrote:
> On Tue, 2017-01-24 at 15:49 +0800, Jia He wrote:
>> When there is no reclaimable pages in the zone, even the zone is
>> not balanced, we let kswapd go sleeping. That is prepare_kswapd_sleep
>> will return true in this case.
>>
>> Signed-off-by: Jia He <hejianet@gmail.com>
>> ---
>>  mm/vmscan.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 7396a0a..54445e2 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -3140,7 +3140,8 @@ static bool prepare_kswapd_sleep(pg_data_t
>> *pgdat, int order, int classzone_idx)
>>  		if (!managed_zone(zone))
>>  			continue;
>>
>> -		if (!zone_balanced(zone, order, classzone_idx))
>> +		if (!zone_balanced(zone, order, classzone_idx)
>> +			&& !zone_reclaimable_pages(zone))
>>  			return false;
>>  	}
>
> This patch does the opposite of what your changelog
> says.  The above keeps kswapd running forever if
> the zone is not balanced, and there are no reclaimable
> pages.
sorry for the mistake, I will check what happened.
I tested in my local system.

B.R.
Jia
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
