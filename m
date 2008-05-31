From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <25360008.1212199156779.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 31 May 2008 10:59:16 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: <48407DC3.8060001@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48407DC3.8060001@linux.vnet.ibm.com>
 <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

>KAMEZAWA Hiroyuki wrote:
>> This patch tries to implements _simple_ 'hierarchy policy' in res_counter.
>> 
>> While several policy of hierarchy can be considered, this patch implements
>> simple one 
>>    - the parent includes, over-commits the child
>>    - there are no shared resource
>
>I am not sure if this is desirable. The concept of a hierarchy applies really
>well when there are shared resources.
>
>>    - dynamic hierarchy resource usage management in the kernel is not neces
sary
>> 
>
>Could you please elaborate as to why? I am not sure I understand your point
>

ok, let's consider a _miiddleware_ wchich has following paramater.

An expoterd param to the user.
   - user_memory_limit
parameters for co-operation with the kernel
   - kernel_memory_limit

And here,
   user_memory_limit >= kernel_memory_limit == cgroup's memory.limits_in_bytes

When a user ask the miidleware to set limit to 1Gbytes
   user_memory_limit = 1G
   kernel_memory_limit = 0-1G.
It moves kernel_memory_limit dynamically 0 to 1Gbytes and reset limits_in_byte
s in dynamic way with checking memory cgroup's statistics.
Of course, we can add some kind of interdace , as following
  - failure_notifier - triggered at failcnt increment.
  - threshhold_notifier - triggered as usage > threshold.

>> works as following.
>> 
>>  1. create a child. set default child limits to be 0.
>>  2. set limit to child.
>>     2-a. before setting limit to child, prepare enough room in parent.
>>     2-b. increase 'usage' of parent by child's limit.
>
>The problem with this is that you are forcing the parent will run into a recl
aim
>loop even if the child is not using the assigned limit to it.
>
That's not problem because it's avoildable by users.
But it's ok to limit the sum of child's limit to be below XX % ot the parent.

>>  3. the child sets its limit to the val moved from the parent.
>>     the parent remembers what amount of resource is to the children.
>> 
>
>All of this needs to be dynamic
>
As explained, this can be dynamic by middleware.

>>  Above means that
>> 	- a directory's usage implies the sum of all sub directories +
>>           own usage.
>> 	- there are no shared resource between parent <-> child.
>> 
>>  Pros.
>>   - simple and easy policy.
>>   - no hierarchy overhead.
>>   - no resource share among child <-> parent. very suitable for multilevel
>>     resource isolation.
>
>Sharing is an important aspect of hierachies. I am not convinced of this
>approach. Did you look at the patches I sent out? Was there something
>fundamentally broken in them?
>

Yes, I read. And tried to make it faster and found it will be complicated.
One problem is overhead of counter itself.
Another problem is overhead of shrinking multi-level LRU with feedback.
One more problem is that it's hard to implement various kinds of hierarchy
policy. I believe there are other hierarhcy policies rather than OpenVZ
want to use. Kicking out functions to middleware AMAP is what I'm thinking
now.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
