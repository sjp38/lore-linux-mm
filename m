Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE8A6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 14:24:31 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l66so25352758wml.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 11:24:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 137si6045635wmb.8.2016.01.28.11.24.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 28 Jan 2016 11:24:29 -0800 (PST)
Subject: Re: [PATCH] vmpressure: Fix subtree pressure detection
References: <1453912137-25473-1-git-send-email-vdavydov@virtuozzo.com>
 <20160128155531.GE15948@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56AA6AEE.30004@suse.cz>
Date: Thu, 28 Jan 2016 20:24:30 +0100
MIME-Version: 1.0
In-Reply-To: <20160128155531.GE15948@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 28.1.2016 16:55, Michal Hocko wrote:
> On Wed 27-01-16 19:28:57, Vladimir Davydov wrote:
>> When vmpressure is called for the entire subtree under pressure we
>> mistakenly use vmpressure->scanned instead of vmpressure->tree_scanned
>> when checking if vmpressure work is to be scheduled. This results in
>> suppressing all vmpressure events in the legacy cgroup hierarchy. Fix
>> it.
>>
>> Fixes: 8e8ae645249b ("mm: memcontrol: hook up vmpressure to socket pressure")
>> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> 
> a = b += c made me scratch my head for a second but this looks correct

Ugh, it's actually a = b += a

While clever and compact, this will make scratch their head anyone looking at
the code in the future. Is it worth it?

> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>  mm/vmpressure.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> index 9a6c0704211c..149fdf6c5c56 100644
>> --- a/mm/vmpressure.c
>> +++ b/mm/vmpressure.c
>> @@ -248,9 +248,8 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
>>  
>>  	if (tree) {
>>  		spin_lock(&vmpr->sr_lock);
>> -		vmpr->tree_scanned += scanned;
>> +		scanned = vmpr->tree_scanned += scanned;
>>  		vmpr->tree_reclaimed += reclaimed;
>> -		scanned = vmpr->scanned;
>>  		spin_unlock(&vmpr->sr_lock);
>>  
>>  		if (scanned < vmpressure_win)
>> -- 
>> 2.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
