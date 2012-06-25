Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 7CD2B6B039D
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 18:30:42 -0400 (EDT)
Message-ID: <4FE8E5F0.9080406@parallels.com>
Date: Tue, 26 Jun 2012 02:28:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <20120625180619.GD3869@google.com>
In-Reply-To: <20120625180619.GD3869@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@cs.helsinki.fi>

On 06/25/2012 10:06 PM, Tejun Heo wrote:
> Again, nits.
>
> On Mon, Jun 25, 2012 at 06:15:23PM +0400, Glauber Costa wrote:
>> +#define mem_cgroup_kmem_on 1
>> +bool __mem_cgroup_new_kmem_page(gfp_t gfp, void *handle, int order);
>> +void __mem_cgroup_commit_kmem_page(struct page *page, void *handle, int order);
>> +void __mem_cgroup_free_kmem_page(struct page *page, int order);
>> +#define is_kmem_tracked_alloc (gfp & __GFP_KMEMCG)
>
> Ugh... please do the following instead.
>
> static inline bool is_kmem_tracked_alloc(gfp_t gfp)
> {
> 	return gfp & __GFP_KMEMCG;
> }
>
>>   #else
>>   static inline void sock_update_memcg(struct sock *sk)
>>   {
>> @@ -416,6 +423,43 @@ static inline void sock_update_memcg(struct sock *sk)
>>   static inline void sock_release_memcg(struct sock *sk)
>>   {
>>   }
>> +
>> +#define mem_cgroup_kmem_on 0
>> +#define __mem_cgroup_new_kmem_page(a, b, c) false
>> +#define __mem_cgroup_free_kmem_page(a,b )
>> +#define __mem_cgroup_commit_kmem_page(a, b, c)
>> +#define is_kmem_tracked_alloc (false)
>
> I would prefer static inlines here too.  It's a bit more code in the
> header but leads to less surprises (e.g. arg evals w/ side effects or
> compiler warning about unused vars) and makes it easier to avoid
> cosmetic errors.
>
> Thanks.
>

Sure thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
