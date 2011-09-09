Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 798446B017C
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 00:20:23 -0400 (EDT)
Message-ID: <4E6993BC.5030004@parallels.com>
Date: Fri, 9 Sep 2011 01:19:08 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/9] per-netns ipv4 sysctl_tcp_mem
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-2-git-send-email-glommer@parallels.com> <20110909114720.f050c520.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110909114720.f050c520.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>

On 09/08/2011 11:47 PM, KAMEZAWA Hiroyuki wrote:
> On Wed,  7 Sep 2011 01:23:11 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> This patch allows each namespace to independently set up
>> its levels for tcp memory pressure thresholds. This patch
>> alone does not buy much: we need to make this values
>> per group of process somehow. This is achieved in the
>> patches that follows in this patchset.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>
>
> Hmm, it may be better to post this patch as independent one.


Maybe we can search acks from eric about this one
specifically prior to merging, but I'd still like it to be part of
the whole. It will put us in a weird state if this is merged, and
the rest is not.

> I'm not familiar with this area...but try review ;)
Thank you!

>
>> ---
>>   include/net/netns/ipv4.h   |    1 +
>>   include/net/tcp.h          |    1 -
>>   net/ipv4/sysctl_net_ipv4.c |   51 +++++++++++++++++++++++++++++++++++++------
>>   net/ipv4/tcp.c             |   13 +++-------
>>   4 files changed, 49 insertions(+), 17 deletions(-)
>>
>> diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
>> index d786b4f..bbd023a 100644
>> --- a/include/net/netns/ipv4.h
>> +++ b/include/net/netns/ipv4.h
>> @@ -55,6 +55,7 @@ struct netns_ipv4 {
>>   	int current_rt_cache_rebuild_count;
>>
>>   	unsigned int sysctl_ping_group_range[2];
>> +	long sysctl_tcp_mem[3];
>>
>>   	atomic_t rt_genid;
>>   	atomic_t dev_addr_genid;
>
> Hmm, in original placement, sysctl_tcp_mem[] was on __read_mostly
> area. Doesn't this placement cause many cache invalidations ?
>
Yes, you are right. I will move back to the old way of doing it.

>
>> diff --git a/include/net/tcp.h b/include/net/tcp.h
>> index 149a415..6bfdd9b 100644
>> --- a/include/net/tcp.h
>> +++ b/include/net/tcp.h
>> @@ -230,7 +230,6 @@ extern int sysctl_tcp_fack;
>>   extern int sysctl_tcp_reordering;
>>   extern int sysctl_tcp_ecn;
>>   extern int sysctl_tcp_dsack;
>> -extern long sysctl_tcp_mem[3];
>>   extern int sysctl_tcp_wmem[3];
>>   extern int sysctl_tcp_rmem[3];
>>   extern int sysctl_tcp_app_win;
>> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
>> index 69fd720..0d74b9d 100644
>> --- a/net/ipv4/sysctl_net_ipv4.c
>> +++ b/net/ipv4/sysctl_net_ipv4.c
>> @@ -14,6 +14,7 @@
>>   #include<linux/init.h>
>>   #include<linux/slab.h>
>>   #include<linux/nsproxy.h>
>> +#include<linux/swap.h>
>>   #include<net/snmp.h>
>>   #include<net/icmp.h>
>>   #include<net/ip.h>
>> @@ -174,6 +175,36 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
>>   	return ret;
>>   }
>>
>> +static int ipv4_tcp_mem(ctl_table *ctl, int write,
>> +			   void __user *buffer, size_t *lenp,
>> +			   loff_t *ppos)
>> +{
>> +	int ret;
>> +	unsigned long vec[3];
>> +	struct net *net = current->nsproxy->net_ns;
>> +	int i;
>> +
>> +	ctl_table tmp = {
>> +		.data =&vec,
>> +		.maxlen = sizeof(vec),
>> +		.mode = ctl->mode,
>> +	};
>> +
>> +	if (!write) {
>> +		ctl->data =&net->ipv4.sysctl_tcp_mem;
>> +		return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
>> +	}
>> +
>> +	ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
>> +	if (ret)
>> +		return ret;
>> +
>> +	for (i = 0; i<  3; i++)
>> +		net->ipv4.sysctl_tcp_mem[i] = vec[i];
>> +
>> +	return 0;
>> +}
>> +
>>   static struct ctl_table ipv4_table[] = {
>>   	{
>>   		.procname	= "tcp_timestamps",
>> @@ -433,13 +464,6 @@ static struct ctl_table ipv4_table[] = {
>>   		.proc_handler	= proc_dointvec
>>   	},
>>   	{
>> -		.procname	= "tcp_mem",
>> -		.data		=&sysctl_tcp_mem,
>> -		.maxlen		= sizeof(sysctl_tcp_mem),
>> -		.mode		= 0644,
>> -		.proc_handler	= proc_doulongvec_minmax
>> -	},
>> -	{
>>   		.procname	= "tcp_wmem",
>>   		.data		=&sysctl_tcp_wmem,
>>   		.maxlen		= sizeof(sysctl_tcp_wmem),
>> @@ -721,6 +745,12 @@ static struct ctl_table ipv4_net_table[] = {
>>   		.mode		= 0644,
>>   		.proc_handler	= ipv4_ping_group_range,
>>   	},
>> +	{
>> +		.procname	= "tcp_mem",
>> +		.maxlen		= sizeof(init_net.ipv4.sysctl_tcp_mem),
>> +		.mode		= 0644,
>> +		.proc_handler	= ipv4_tcp_mem,
>> +	},
>>   	{ }
>>   };
>>
>
>
>
>
>> @@ -734,6 +764,7 @@ EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
>>   static __net_init int ipv4_sysctl_init_net(struct net *net)
>>   {
>>   	struct ctl_table *table;
>> +	unsigned long limit;
>>
>>   	table = ipv4_net_table;
>>   	if (!net_eq(net,&init_net)) {
>> @@ -769,6 +800,12 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
>>
>>   	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
>>
>> +	limit = nr_free_buffer_pages() / 8;
>> +	limit = max(limit, 128UL);
>> +	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
>> +	net->ipv4.sysctl_tcp_mem[1] = limit;
>> +	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
>> +
>>   	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
>>   			net_ipv4_ctl_path, table);
>>   	if (net->ipv4.ipv4_hdr == NULL)
>> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
>> index 46febca..f06df24 100644
>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -266,6 +266,7 @@
>>   #include<linux/crypto.h>
>>   #include<linux/time.h>
>>   #include<linux/slab.h>
>> +#include<linux/nsproxy.h>
>>
>>   #include<net/icmp.h>
>>   #include<net/tcp.h>
>> @@ -282,11 +283,9 @@ int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
>>   struct percpu_counter tcp_orphan_count;
>>   EXPORT_SYMBOL_GPL(tcp_orphan_count);
>>
>> -long sysctl_tcp_mem[3] __read_mostly;
>>   int sysctl_tcp_wmem[3] __read_mostly;
>>   int sysctl_tcp_rmem[3] __read_mostly;
>>
>> -EXPORT_SYMBOL(sysctl_tcp_mem);
>>   EXPORT_SYMBOL(sysctl_tcp_rmem);
>>   EXPORT_SYMBOL(sysctl_tcp_wmem);
>>
>> @@ -3277,14 +3276,10 @@ void __init tcp_init(void)
>>   	sysctl_tcp_max_orphans = cnt / 2;
>>   	sysctl_max_syn_backlog = max(128, cnt / 256);
>>
>> -	limit = nr_free_buffer_pages() / 8;
>> -	limit = max(limit, 128UL);
>> -	sysctl_tcp_mem[0] = limit / 4 * 3;
>> -	sysctl_tcp_mem[1] = limit;
>> -	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
>> -
>>   	/* Set per-socket limits to no more than 1/128 the pressure threshold */
>> -	limit = ((unsigned long)sysctl_tcp_mem[1])<<  (PAGE_SHIFT - 7);
>> +	limit = (unsigned long)init_net.ipv4.sysctl_tcp_mem[1];
>> +	limit<<= (PAGE_SHIFT - 7);
>> +
>
> I'm not sure but...why defined as 'long'  ?
>

It is part of the "it was there
before" bundle.

It is defined as long not only for tcp, but for all of the
equivalents sysctl as well. So no reason to touch it, at least not
in this series =)

>
> BTW, when I grep,
>
> tcp_input.c:        atomic_long_read(&tcp_memory_allocated)<  sysctl_tcp_mem[0])
> tcp_input.c:    if (atomic_long_read(&tcp_memory_allocated)>= sysctl_tcp_mem[0])
>
> Don't you need to change this ?

It ended up being changed in another patch, and I missed the right
split.

Thank you, I will reorder it so it gets changed correctly.
>
>
> Thanks,
> -Kame
>
>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
