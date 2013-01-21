Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2A7CE6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 08:29:20 -0500 (EST)
Message-ID: <50FD4245.3070402@redhat.com>
Date: Mon, 21 Jan 2013 21:27:33 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
References: <4FEE7665.6020409@jp.fujitsu.com> <389106003.8637801.1358757547754.JavaMail.root@redhat.com> <20130121105624.GF7798@dhcp22.suse.cz>
In-Reply-To: <20130121105624.GF7798@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On 01/21/2013 06:56 PM, Michal Hocko wrote:
> On Mon 21-01-13 03:39:07, Zhouping Liu wrote:
>>
>> ----- Original Message -----
>>> From: "Kamezawa Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
>>> To: "Tejun Heo" <tj@kernel.org>
>>> Cc: "David Rientjes" <rientjes@google.com>, "Michal Hocko" <mhocko@suse.cz>, "Zhouping Liu" <zliu@redhat.com>,
>>> linux-mm@kvack.org, "Li Zefan" <lizefan@huawei.com>, "CAI Qian" <caiqian@redhat.com>, "LKML"
>>> <linux-kernel@vger.kernel.org>, "Andrew Morton" <akpm@linux-foundation.org>
>>> Sent: Saturday, June 30, 2012 11:45:41 AM
>>> Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
>>>
>>> (2012/06/29 3:31), Tejun Heo wrote:
>>>> Hello, KAME.
>>>>
>>>> On Thu, Jun 28, 2012 at 01:04:16PM +0900, Kamezawa Hiroyuki wrote:
>>>>>> I still wish it's folded into CONFIG_MEMCG and conditionalized
>>>>>> just on
>>>>>> CONFIG_SWAP tho.
>>>>>>
>>>>> In old days, memsw controller was not very stable. So, we devided
>>>>> the config.
>>>>> And, it makes size of memory for swap-device double (adds 2bytes
>>>>> per swapent.)
>>>>> That is the problem.
>>>> I see.  Do you think it's now reasonable to drop the separate
>>>> config
>>>> option?  Having memcg enabled but swap unaccounted sounds
>>>> half-broken
>>>> to me.
>>>>
>>> Hmm. Maybe it's ok if we can keep boot option. I'll cook a patch in
>>> the next week.
>> Hello Kame and All,
>>
>> Sorry for so delay to open the thread. (please open the link https://lkml.org/lkml/2012/6/26/547 if you don't remember the topic)
>>
>> do you have any updates for the issue?
>>
>> I checked the latest version, if we don't open CONFIG_MEMCG_SWAP_ENABLED(commit c255a458055e changed
>> CONFIG_CGROUP_MEM_RES_CTLR_SWAP_ENABLED as CONFIG_MEMCG_SWAP_ENABLED), the issue still exist:
>>
>> [root@dhcp-8-128 ~] cat .config  | grep -i memcg
>> CONFIG_MEMCG=y
>> CONFIG_MEMCG_SWAP=y
>> # CONFIG_MEMCG_SWAP_ENABLED is not set
>> CONFIG_MEMCG_KMEM=y
>> [root@dhcp-8-128 ~] uname -r
>> 3.8.0-rc4+
>> [root@dhcp-8-128 ~] cat memory.memsw.*
>> cat: memory.memsw.failcnt: Operation not supported
>> cat: memory.memsw.limit_in_bytes: Operation not supported
>> cat: memory.memsw.max_usage_in_bytes: Operation not supported
>> cat: memory.memsw.usage_in_bytes: Operation not supported
> Ohh, this one got lost. I thought Kame was working on that.
> Anyway the patch bellow should work:
> ---
>  From 5f8141bf7d27014cfbc7b450f13f6146b5ab099d Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Mon, 21 Jan 2013 11:33:26 +0100
> Subject: [PATCH] memcg: Do not create memsw files if swap accounting is
>   disabled
>
> Zhouping Liu has reported that memsw files are exported even though
> swap accounting is runtime disabled if CONFIG_MEMCG_SWAP is enabled.
> This behavior has been introduced by af36f906 (memcg: always create
> memsw files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP) and it causes any
> attempt to open the file to return EOPNOTSUPP. Although EOPNOTSUPP
> should say be clear that memsw operations are not supported in the given
> configuration it is fair to say that this behavior could be quite
> confusing.
>
> Let's tear memsw files out of default cgroup files and add
> them only if the swap accounting is really enabled (either by
> CONFIG_MEMCG_SWAP_ENABLED or swapaccount=1 boot parameter). We can
> hook into mem_cgroup_init which is called when the memcg subsystem is
> initialized and which happens after boot command line is processed.

Thanks for your quick patch, your patch looks good for me.

I tested it with or without CONFIG_MEMCG_SWAP_ENABLED=y,
and also tested it with swapaccount=1 kernel parameters, all are okay.

Tested-by: Zhouping Liu <zliu@redhat.com>

Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
