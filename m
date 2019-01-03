Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4E938E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:51:59 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w28so5736411qkj.22
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:51:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor22635753qkg.11.2019.01.03.08.51.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 08:51:59 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: survive in a low-memory situation
References: <20190102165931.GB6584@arrakis.emea.arm.com>
 <20190102180619.12392-1-cai@lca.pw> <20190103093201.GB31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <9197d86b-a684-c7f4-245b-63c890f1104f@lca.pw>
Date: Thu, 3 Jan 2019 11:51:57 -0500
MIME-Version: 1.0
In-Reply-To: <20190103093201.GB31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/3/19 4:32 AM, Michal Hocko wrote:
> On Wed 02-01-19 13:06:19, Qian Cai wrote:
> [...]
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index f9d9dc250428..9e1aa3b7df75 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>>  	struct rb_node **link, *rb_parent;
>>  
>>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
>> +#ifdef CONFIG_PREEMPT_COUNT
>> +	if (!object) {
>> +		/* last-ditch effort in a low-memory situation */
>> +		if (irqs_disabled() || is_idle_task(current) || in_atomic())
>> +			gfp = GFP_ATOMIC;
>> +		else
>> +			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
>> +		object = kmem_cache_alloc(object_cache, gfp);
>> +	}
>> +#endif
> 
> I do not get it. How can this possibly help when gfp_kmemleak_mask()
> adds __GFP_NOFAIL modifier to the given gfp mask? Or is this not the
> case anymore in some tree?

Well, __GFP_NOFAIL can still fail easily without __GFP_DIRECT_RECLAIM in a
low-memory situation.

__alloc_pages_slowpath():

/* Caller is not willing to reclaim, we can't balance anything */
if (!can_direct_reclaim)
	goto nopage;

nopage:

/*
 * All existing users of the __GFP_NOFAIL are blockable, so
 * warn of any new users that actually require GFP_NOWAIT
 */
if (WARN_ON_ONCE(!can_direct_reclaim))
	goto fail;
