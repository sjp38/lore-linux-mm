Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 640466B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 04:28:33 -0400 (EDT)
Message-ID: <506018DC.2020907@parallels.com>
Date: Mon, 24 Sep 2012 12:25:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 15/16] memcg/sl[au]b: shrink dead caches
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-16-git-send-email-glommer@parallels.com> <20120921204035.GQ7264@google.com>
In-Reply-To: <20120921204035.GQ7264@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 09/22/2012 12:40 AM, Tejun Heo wrote:
> Hello, Glauber.
> 
> On Tue, Sep 18, 2012 at 06:12:09PM +0400, Glauber Costa wrote:
>> @@ -764,10 +777,21 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>>  		goto out;
>>  	}
>>  
>> +	/*
>> +	 * Because the cache is expected to duplicate the string,
>> +	 * we must make sure it has opportunity to copy its full
>> +	 * name. Only now we can remove the dead part from it
>> +	 */
>> +	name = (char *)new_cachep->name;
>> +	if (name)
>> +		name[strlen(name) - 4] = '\0';
> 
> This is kinda nasty.  Do we really need to do this?  How long would a
> dead cache stick around?

Without targeted shrinking, until all objects are manually freed, which
may need to wait global reclaim to kick in.

In general, if we agree with duplicating the caches, the problem that
they may stick around for some time will not be avoidable. If you have
any suggestions about alternative ways for it, I'm all ears.

> 
>> diff --git a/mm/slab.c b/mm/slab.c
>> index bd9928f..6cb4abf 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -3785,6 +3785,8 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
>>  	}
>>  
>>  	ac_put_obj(cachep, ac, objp);
>> +
>> +	kmem_cache_verify_dead(cachep);
> 
> Reaping dead caches doesn't exactly sound like a high priority thing
> and adding a branch to hot path for that might not be the best way to
> do it.  Why not schedule an extremely lazy deferrable delayed_work
> which polls for emptiness, say, every miniute or whatever?
> 

Because this branch is marked as unlikely, I would expect it not to be a
big problem. It will be not taken most of the time, and becomes a very
cheap branch. I considered this to be simpler than a deferred work
mechanism.

If even then, you guys believe this is still too high, I can resort to that.



> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
