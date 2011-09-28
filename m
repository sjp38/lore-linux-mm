Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9B2609000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 08:12:26 -0400 (EDT)
Message-ID: <4E830EF1.5080704@parallels.com>
Date: Wed, 28 Sep 2011 09:11:29 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/7] per-cgroup tcp buffers control
References: <1316051175-17780-1-git-send-email-glommer@parallels.com> <1316051175-17780-5-git-send-email-glommer@parallels.com> <CANaxB-wy8VDv0Wjni6UzcfBzSgNn=bZBey5f+fXHebNuek=O1A@mail.gmail.com>
In-Reply-To: <CANaxB-wy8VDv0Wjni6UzcfBzSgNn=bZBey5f+fXHebNuek=O1A@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Wagin <avagin@gmail.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On 09/28/2011 08:58 AM, Andrew Wagin wrote:
> * tcp_destroy_cgroup_fill() is executed for each cgroup and
> initializes some proto methods. proto_list is global and we can
> initialize each proto one time. Do we need this really?
>
> * And when a cgroup is destroyed, it cleans proto methods
> (tcp_destroy_cgroup_fill), how other cgroups will work after that?

I've already realized that, and removed destruction from my upcoming
series. Thanks

> * What about proto, which is registered when cgroup mounted?
>
> My opinion that we may initialize proto by the following way:
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM+       .enter_memory_pressure
> = tcp_enter_memory_pressure_nocg,
> +       .sockets_allocated      = sockets_allocated_tcp_nocg,
> +       .memory_allocated       = memory_allocated_tcp_nocg,
> +       .memory_pressure        = memory_pressure_tcp_nocg,
> +#else
>          .enter_memory_pressure  = tcp_enter_memory_pressure,
>          .sockets_allocated      = sockets_allocated_tcp,
>          .memory_allocated       = memory_allocated_tcp,
>          .memory_pressure        = memory_pressure_tcp,
> +#endif
>
> It should work, because the root memory cgroup always exists.
Yeah, I was still doing the initialization through cgroups, but I think
this works.

The reason I was keeping it cgroup's initialization method, was because 
we have a parameter that allowed kmem accounting to be disabled.
But Kame suggested we'd remove it, and so I did.

>
>> +int tcp_init_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
>> +                        struct cgroup_subsys *ss)
>> +{
>> +       prot->enter_memory_pressure     = tcp_enter_memory_pressure;
>> +       prot->memory_allocated          = memory_allocated_tcp;
>> +       prot->prot_mem                  = tcp_sysctl_mem;
>> +       prot->sockets_allocated         = sockets_allocated_tcp;
>> +       prot->memory_pressure           = memory_pressure_tcp;
>> +
>> +       return 0;
>> +}
>
>
>> +void tcp_destroy_cgroup_fill(struct proto *prot, struct cgroup *cgrp,
>> +                            struct cgroup_subsys *ss)
>> +{
>> +       prot->enter_memory_pressure     = tcp_enter_memory_pressure_nocg;
>> +       prot->memory_allocated          = memory_allocated_tcp_nocg;
>> +       prot->prot_mem                  = tcp_sysctl_mem_nocg;
>> +       prot->sockets_allocated         = sockets_allocated_tcp_nocg;
>> +       prot->memory_pressure           = memory_pressure_tcp_nocg;
>>
>
>> @@ -2220,12 +2220,16 @@ struct proto tcpv6_prot = {
>>        .hash                   = tcp_v6_hash,
>>        .unhash                 = inet_unhash,
>>        .get_port               = inet_csk_get_port
>> +       .enter_memory_pressure  = tcp_enter_memory_pressure_nocg,
>> +       .sockets_allocated      = sockets_allocated_tcp_nocg,
>> +       .memory_allocated       = memory_allocated_tcp_nocg,
>> +       .memory_pressure        = memory_pressure_tcp_nocg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
