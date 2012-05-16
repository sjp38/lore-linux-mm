Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id DF4726B0092
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:14:10 -0400 (EDT)
Message-ID: <4FB34534.3070306@parallels.com>
Date: Wed, 16 May 2012 10:12:04 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/29] slab: dup name string
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-2-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205151502000.18595@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205151502000.18595@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/16/2012 02:04 AM, David Rientjes wrote:
> On Fri, 11 May 2012, Glauber Costa wrote:
>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index e901a36..91b9c13 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2118,6 +2118,7 @@ static void __kmem_cache_destroy(struct kmem_cache *cachep)
>>   			kfree(l3);
>>   		}
>>   	}
>> +	kfree(cachep->name);
>>   	kmem_cache_free(&cache_cache, cachep);
>>   }
>>
>> @@ -2526,7 +2527,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
>>   		BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cache));
>>   	}
>>   	cachep->ctor = ctor;
>> -	cachep->name = name;
>> +	cachep->name = kstrdup(name, GFP_KERNEL);
>>
>>   	if (setup_cpu_cache(cachep, gfp)) {
>>   		__kmem_cache_destroy(cachep);
>
> Couple problems:
>
>   - allocating memory for a string of an unknown, unchecked size, and
>
>   - could potentially return NULL which I suspect will cause problems
>     later.

Well, this is what slub does.

I sent already two patches for it: One removing this from the slub, one 
adding this to the slab.

Right now I am comfortable with this one, because it makes it slightly 
easier in the latest patches of my series.

But note the word: slightest.

I am comfortable with any, provided slub and slab start behaving the same.

So whatever you guys decide between yourselves is fine, provided there 
is a decision.

Thanks for your review, David!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
