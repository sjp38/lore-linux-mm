Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4376A9000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 23:39:57 -0400 (EDT)
Message-ID: <4E7567E0.9010401@parallels.com>
Date: Sun, 18 Sep 2011 00:39:12 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/7] Basic kernel memory functionality for the Memory
 Controller
References: <1316051175-17780-1-git-send-email-glommer@parallels.com> <1316051175-17780-2-git-send-email-glommer@parallels.com> <20110917174535.GA1658@shutemov.name>
In-Reply-To: <20110917174535.GA1658@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org


>>   	struct mem_cgroup_stat_cpu *stat;
>> @@ -391,6 +404,7 @@ enum charge_type {
>>   #define _MEM			(0)
>>   #define _MEMSWAP		(1)
>>   #define _OOM_TYPE		(2)
>> +#define _KMEM			(3)
>
> Ditto. Can we use enum instead?
Yes we can (tm)

>>   	if (!mem_cgroup_is_root(mem)) {
>>   		if (!swap)
>> -			return res_counter_read_u64(&mem->res, RES_USAGE);
>> +			kmem += res_counter_read_u64(&mem->res, RES_USAGE);
>>   		else
>> -			return res_counter_read_u64(&mem->memsw, RES_USAGE);
>> +			kmem += res_counter_read_u64(&mem->memsw, RES_USAGE);
>> +
>> +		return kmem;
>>   	}
>>
>>   	val = mem_cgroup_recursive_stat(mem, MEM_CGROUP_STAT_CACHE);
>
> No kernel memory accounting for root cgroup, right?
Not sure. Maybe kernel memory accounting is useful even for root cgroup. 
Same as normal memory accounting... what we want to avoid is kernel 
memory limits. OTOH, if we are not limiting it anyway, accounting it is 
just useless overhead... Even the statistics can then be gathered 
through all
the proc files that show slab usage, I guess?

>
>> @@ -3979,6 +3999,10 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>>   		else
>>   			val = res_counter_read_u64(&mem->memsw, name);
>>   		break;
>> +	case _KMEM:
>> +		val = res_counter_read_u64(&mem->kmem, name);
>> +		break;
>> +
>
> Always zero in root cgroup?

Yes, if we're not accounting, it should be zero. WARN_ON, maybe?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
