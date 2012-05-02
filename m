Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 6EF396B0083
	for <linux-mm@kvack.org>; Wed,  2 May 2012 11:17:38 -0400 (EDT)
Message-ID: <4FA14F9F.10401@parallels.com>
Date: Wed, 2 May 2012 12:15:43 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/23] kmem slab accounting basic infrastructure
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1334959051-18203-10-git-send-email-glommer@parallels.com> <CABCjUKBCqBWXuyzx73y3sekNqAKpYqAhRjQDtSWF5o7qUbC-RA@mail.gmail.com>
In-Reply-To: <CABCjUKBCqBWXuyzx73y3sekNqAKpYqAhRjQDtSWF5o7qUbC-RA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <suleiman@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>


>> @@ -3951,8 +3966,26 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>>                         break;
>>                 if (type == _MEM)
>>                         ret = mem_cgroup_resize_limit(memcg, val);
>> -               else
>> +               else if (type == _MEMSWAP)
>>                         ret = mem_cgroup_resize_memsw_limit(memcg, val);
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +               else if (type == _KMEM) {
>> +                       ret = res_counter_set_limit(&memcg->kmem, val);
>> +                       if (ret)
>> +                               break;
>> +                       /*
>> +                        * Once enabled, can't be disabled. We could in theory
>> +                        * disable it if we haven't yet created any caches, or
>> +                        * if we can shrink them all to death.
>> +                        *
>> +                        * But it is not worth the trouble
>> +                        */
>> +                       if (!memcg->kmem_accounted&&  val != RESOURCE_MAX)
>> +                               memcg->kmem_accounted = true;
>> +               }
>> +#endif
>> +               else
>> +                       return -EINVAL;
>>                 break;
>>         case RES_SOFT_LIMIT:
>>                 ret = res_counter_memparse_write_strategy(buffer,&val);
>
> Why is RESOURCE_MAX special?

Because I am using the convention that setting it to any value different 
than that will enable accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
