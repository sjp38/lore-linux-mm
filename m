Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 675986B004F
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 07:40:59 -0500 (EST)
Message-ID: <4EE201A0.9040601@parallels.com>
Date: Fri, 9 Dec 2011 10:40:00 -0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 1/9] Basic kernel memory functionality for the Memory
 Controller
References: <1323120903-2831-1-git-send-email-glommer@parallels.com> <1323120903-2831-2-git-send-email-glommer@parallels.com> <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111209102113.cdb85da8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, Paul Menage <paul@paulmenage.org>

On 12/08/2011 11:21 PM, KAMEZAWA Hiroyuki wrote:
> On Mon,  5 Dec 2011 19:34:55 -0200
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> This patch lays down the foundation for the kernel memory component
>> of the Memory Controller.
>>
>> As of today, I am only laying down the following files:
>>
>>   * memory.independent_kmem_limit
>>   * memory.kmem.limit_in_bytes (currently ignored)
>>   * memory.kmem.usage_in_bytes (always zero)
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> Reviewed-by: Kirill A. Shutemov<kirill@shutemov.name>
>> CC: Paul Menage<paul@paulmenage.org>
>> CC: Greg Thelen<gthelen@google.com>
>
> As I wrote, please CC Johannes and  Michal Hocko for memcg related parts.

I forgot to add them to the patch itself, but they are in the CC list of 
the messages.

So they did get the mail.

> A few questions.
> ==
>> +	val = !!val;
>> +
>> +	if (parent&&  parent->use_hierarchy&&
>> +	   (val != parent->kmem_independent_accounting))
>> +		return -EINVAL;
> ==
> Hm, why you check val != parent->kmem_independent_accounting ?
>
> 	if (parent&&  parent->use_hierarchy)
> 		return -EINVAL;
> ?

Because I thought that making sure that everybody in the chain is 
consistent, it will make things simpler for us. But I am happy to change 
that if you prefer.

> BTW, you didn't check this cgroup has children or not.
> I think
>
> 	if (this_cgroup->use_hierarchy&&
>               !list_empty(this_cgroup->childlen))
> 		return -EINVAL;
>
Noted.

> ==
>> +	/*
>> +	 * TODO: We need to handle the case in which we are doing
>> +	 * independent kmem accounting as authorized by our parent,
>> +	 * but then our parent changes its parameter.
>> +	 */
>> +	cgroup_lock();
>> +	memcg->kmem_independent_accounting = val;
>> +	cgroup_unlock();
>
> Do we need cgroup_lock() here ?

Well, I removed almost all instances of it from previous patches, so I 
guess this one can go as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
