Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 29C4F900117
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 02:23:26 -0400 (EDT)
Message-ID: <4E8AA635.5000100@parallels.com>
Date: Tue, 4 Oct 2011 10:22:45 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 6/8] tcp buffer limitation: per-cgroup limit
References: <1317637123-18306-1-git-send-email-glommer@parallels.com> <1317637123-18306-7-git-send-email-glommer@parallels.com> <20111004102114.08b06ae8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111004102114.08b06ae8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On 10/04/2011 05:21 AM, KAMEZAWA Hiroyuki wrote:
> On Mon,  3 Oct 2011 14:18:41 +0400
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
>> effectively control the amount of kernel memory pinned by a cgroup.
>>
>> We have to make sure that none of the memory pressure thresholds
>> specified in the namespace are bigger than the current cgroup.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>> ---
>>   Documentation/cgroups/memory.txt |    1 +
>>   include/linux/memcontrol.h       |   10 +++++
>>   include/net/tcp.h                |    1 +
>>   mm/memcontrol.c                  |   76 +++++++++++++++++++++++++++++++++++---
>>   net/ipv4/sysctl_net_ipv4.c       |   20 ++++++++++
>>   5 files changed, 102 insertions(+), 6 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
>> index 6f1954a..1ffde3e 100644
>> --- a/Documentation/cgroups/memory.txt
>> +++ b/Documentation/cgroups/memory.txt
>> @@ -78,6 +78,7 @@ Brief summary of control files.
>>
>>    memory.independent_kmem_limit	 # select whether or not kernel memory limits are
>>   				   independent of user limits
>> + memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
>>
>
> What is the releationship between tcp.max_memory and kmem_limit ?
Quite loose.

> tcp.max_memory<  kmem_limit ?
> usage of tcp memory is included in kmem usage ?
tcp.max_memory is < kmem_limit, for it to be meaningful. But I don't 
think we need to force that. I may want to start with a high value for 
tcp_max_memory and low on kmem_limit, and raise it later.

So here is how it goes:

Memory is allocated from the slab, and then it's usage is independently 
controlled by the network-specific memory pressure conditions until it
is reclaimed.

Memory allocation can succeed, but then fail to be assigned to the 
socket due to memory pressure.

Since we more or less agree that on accounting the slab according to 
Greg's idea, I am not concerning myself with the actual accounting here, 
since it will come for free when we account the slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
