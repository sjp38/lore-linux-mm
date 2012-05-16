Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 8A9CA6B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 03:05:59 -0400 (EDT)
Message-ID: <4FB35153.3080309@parallels.com>
Date: Wed, 16 May 2012 11:03:47 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB0621C.3010604@huawei.com>
In-Reply-To: <4FB0621C.3010604@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 05/14/2012 05:38 AM, Li Zefan wrote:
>> +static void disarm_static_keys(struct mem_cgroup *memcg)
> 
>> +{
>> +#ifdef CONFIG_INET
>> +	if (memcg->tcp_mem.cg_proto.activated)
>> +		static_key_slow_dec(&memcg_socket_limit_enabled);
>> +#endif
>> +}
> 
> 
> Move this inside the ifdef/endif below ?
> 
> Otherwise I think you'll get compile error if !CONFIG_INET...

I don't fully get it.

We are supposed to provide a version of it for
CONFIG_CGROUP_MEM_RES_CTLR_KMEM and an empty version for
!CONFIG_CGROUP_MEM_RES_CTLR_KMEM

Inside the first, we take an action for CONFIG_INET, and no action for
!CONFIG_INET.

Bear in mind that the slab patches will add another test to that place,
and that's why I am doing it this way from the beginning.

Well, that said, I not only can be wrong, I very frequently am.

But I just compiled this one with and without CONFIG_INET, and it seems
to be going alright.


>> +
>>   #ifdef CONFIG_INET
>>   struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>>   {
>> @@ -452,6 +462,11 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>>   }
>>   EXPORT_SYMBOL(tcp_proto_cgroup);
>>   #endif /* CONFIG_INET */
>> +#else
>> +static inline void disarm_static_keys(struct mem_cgroup *memcg)
>> +{
>> +}
>> +
>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
