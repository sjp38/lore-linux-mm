Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3AADE6B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:22:14 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so17999526iec.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:22:14 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id q10si34458604ioi.93.2015.06.29.08.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 08:22:13 -0700 (PDT)
Received: by ieqy10 with SMTP id y10so117560390ieq.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:22:13 -0700 (PDT)
In-Reply-To: <20150629150311.GC4612@dhcp22.suse.cz>
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com> <20150629150311.GC4612@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain;
 charset=UTF-8
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
From: Nicholas Krause <xerofoify@gmail.com>
Date: Mon, 29 Jun 2015 11:23:08 -0400
Message-ID: <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On June 29, 2015 11:03:11 AM EDT, Michal Hocko <mhocko@suse.cz> wrote:
>On Mon 29-06-15 10:13:53, Nicholas Krause wrote:
>[...]
>> -static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg,
>int node)
>> +static bool alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg,
>int node)
>>  {
>>  	struct mem_cgroup_per_node *pn;
>>  	struct mem_cgroup_per_zone *mz;
>> @@ -4442,7 +4442,7 @@ static int
>alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>>  		tmp = -1;
>>  	pn = kzalloc_node(sizeof(*pn), GFP_KERNEL, tmp);
>>  	if (!pn)
>> -		return 1;
>> +		return true;
>
>Have you tried to think about the semantic of the function? The
>function
>has returned 0 to signal the success which is pretty common. It could
>have
>returned -ENOMEM for the allocation failure which would be much more
>nicer than 1.
>
>After your change we have bool semantic where the success is reported
>by
>false while failure is true. Doest this make any sense to you? Because
>it doesn't make to me and it only shows that this is a mechanical
>conversion without deeper thinking about consequences.
>
>Nacked-by: Michal Hocko <mhocko@suse.cz>
>
>Btw. I can see your other patches which trying to do similar. I would
>strongly discourage you from this path. Try to understand the code and
>focus on changes which would actually make any improvements to the code
>base. Doing stylist changes which do not help readability and neither
>help compiler to generate a better code is simply waste of your and
>reviewers time.
>
>>  	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
>>  		mz = &pn->zoneinfo[zone];
>> @@ -4452,7 +4452,7 @@ static int
>alloc_mem_cgroup_per_zone_info(struct mem_cgroup *memcg, int node)
>>  		mz->memcg = memcg;
>>  	}
>>  	memcg->nodeinfo[node] = pn;
>> -	return 0;
>> +	return false;
>>  }
>>  
>>  static void free_mem_cgroup_per_zone_info(struct mem_cgroup *memcg,
>int node)
>> -- 
>> 2.1.4
>> 
I agree with and looked into the callers about this wasn't sure if you you wanted me to return - ENOMEM.  I will rewrite this patch the other way.  Furthermore I apologize about this and do have actual useful patches but will my rep it's hard to get replies from maintainers. If you would like to take a look at them please let know. 
Nick 
-- 
Sent from my Android device with K-9 Mail. Please excuse my brevity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
