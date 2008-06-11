Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5BDGwKS025824
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 23:16:58 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BDHtdU220368
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 23:17:55 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BDDiIC024538
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 23:13:44 +1000
Message-ID: <484FCF82.1050100@linux.vnet.ibm.com>
Date: Wed, 11 Jun 2008 18:43:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFD][PATCH] memcg: Move Usage at Task Move
References: <20080611212126.317a95f7.d-nishimura@mtf.biglobe.ne.jp> <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com> <484F8C76.4080300@linux.vnet.ibm.com> <22652920.1213188663353.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <22652920.1213188663353.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: nishimura@mxp.nes.nec.co.jp, Paul Menage <menage@google.com>, linux-mm@kvack.org, containers@lists.osdl.org, xemul@openvz.org, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>> On Wed, 11 Jun 2008 13:57:34 +0530
>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> (snip)
>>
>>>>>  2. Don't move any usage at task move. (current implementation.)
>>>>>    Pros.
>>>>>      - no complication in the code.
>>>>>    Cons.
>>>>>      - A task's usage is chareged to wrong cgroup.
>>>>>      - Not sure, but I believe the users don't want this.
>>>> I'd say stick with this unless there a strong arguments in favour of
>>>> changing, based on concrete needs.
>>>>
>>>>> One reasone is that I think a typical usage of memory controller is
>>>>> fork()->move->exec(). (by libcg ?) and exec() will flush the all usage.
>>>> Exactly - this is a good reason *not* to implement move - because then
>>>> you drag all the usage of the middleware daemon into the new cgroup.
>>>>
>>> Yes. The other thing is that charges will eventually fade away. Please see 
> the
>>> cgroup implementation of page_referenced() and mark_page_accessed(). The
>>> original group on memory pressure will drop pages that were left behind by 
> a
>>> task that migrates. The new group will pick it up if referenced.
>>>
>> Hum..
>> So, it seems that some kind of "Lazy Mode"(#3 of Kamezawa-san's)
>> has been implemented already.
>>
>> But, one of the reason that I think usage should be moved
>> is to make the usage as accurate as possible, that is
>> the size of memory used by processes in the group at the moment.
>>
>> I agree that statistics is not the purpose of memcg(and swap),
>> but, IMHO, it's useful feature of memcg.
>> Administrators can know how busy or idle each groups are by it.
>>
> One more point. This kinds of lazy "drop" approach canoot works well when
> there are mlocked processes. lazy "move" approarch is better if we do in lazy
> way. And how quickly they drops depends on vm.swappiness.
> 
> Anyway, I don't like complicated logic in the kernel.
> So, let's see how simple "move" can be implemented. Then, it will be just a
> trade-off problem, IMHO.
> If policy is fixed, implementation itself will not be complicated, I think.
> 

I agree with you that it is a trade-off problem and we should keep move as
simple as possible.



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
