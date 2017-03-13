Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5466B0389
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 08:00:18 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id f21so295089056pgi.4
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 05:00:18 -0700 (PDT)
Received: from dggrg03-dlp.huawei.com ([45.249.212.189])
        by mx.google.com with ESMTPS id h5si302934plk.127.2017.03.13.05.00.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Mar 2017 05:00:16 -0700 (PDT)
Subject: Re: [PATCH v3 RFC] mm/vmscan: more restrictive condition for retry of
 shrink_zones
References: <1489316770-25362-1-git-send-email-ysxie@foxmail.com>
 <20170313083314.GA31518@dhcp22.suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <8de4c31e-cfa3-25c4-52f9-f341a826534d@huawei.com>
Date: Mon, 13 Mar 2017 20:00:02 +0800
MIME-Version: 1.0
In-Reply-To: <20170313083314.GA31518@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Yisheng Xie <ysxie@foxmail.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

Hi Michal,

Thanks for reviewing.
On 2017/3/13 16:33, Michal Hocko wrote:
> Please do not post new version after a single feedback and try to wait
> for more review to accumulate. This is in the 3rd version and it is not
> clear why it is still an RFC.
Get it, thanks for pointing out these.

> 
> On Sun 12-03-17 19:06:10, Yisheng Xie wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> When we enter do_try_to_free_pages, the may_thrash is always clear, and
>> it will retry shrink zones to tap cgroup's reserves memory by setting
>> may_thrash when the former shrink_zones reclaim nothing.
>>
>> However, when memcg is disabled or on legacy hierarchy, it should not do
>> this useless retry at all, for we do not have any cgroup's reserves
>> memory to tap, and we have already done hard work but made no progress.
>>
>> To avoid this time costly and useless retrying, add a stub function
>> mem_cgroup_thrashed() and return true when memcg is disabled or on
>> legacy hierarchy.
> 
> Have you actually seen this as a bad behavior? On which workload? Or
> have spotted this by the code review?
Sorry, this is just spotted by code review. I will point it out changelog.

> 
> Please note that more than _what_ it is more interesting _why_ the patch
> has been prepared.
Get it.

> 
> I agree the current additional round of reclaim is just lame because we
> are trying hard to control the retry logic from the page allocator which
> is a sufficient justification to fix this IMO. 
Right.

But I really hate the
> name. At this point we do not have any idea that the memcg is trashing
> as the name of the function suggests.
> 
> All of them simply might not have any reclaimable pages. So I would
> suggest either a better name e.g. memcg_allow_lowmem_reclaim() or,
> preferably, fix this properly. E.g. something like the following.
hmm, it is pretty a good idea than just rename the function, I will check
it's logical carefully, and then send out a new version based on this,
if you do not mind.

Thanks
Yisheng Xie.

> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bae698484e8e..989ba9761921 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -99,6 +99,9 @@ struct scan_control {
>  	/* Can cgroups be reclaimed below their normal consumption range? */
>  	unsigned int may_thrash:1;
>  
> +	/* Did we have any memcg protected by the low limit */
> +	unsigned int memcg_low_protection:1;
> +
>  	unsigned int hibernation_mode:1;
>  
>  	/* One of the zones is ready for compaction */
> @@ -2513,6 +2516,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>  			if (mem_cgroup_low(root, memcg)) {
>  				if (!sc->may_thrash)
>  					continue;
> +				sc->memcg_low_protection = true;
>  				mem_cgroup_events(memcg, MEMCG_LOW, 1);
>  			}
>  
> @@ -2774,7 +2778,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		return 1;
>  
>  	/* Untapped cgroup reserves?  Don't OOM, retry. */
> -	if (!sc->may_thrash) {
> +	if ( sc->memcg_low_protection && !sc->may_thrash) {
>  		sc->priority = initial_priority;
>  		sc->may_thrash = 1;
>  		goto retry;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
