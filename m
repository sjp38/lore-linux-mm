Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A2A686B01EE
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 21:26:56 -0400 (EDT)
Message-ID: <4BD0F797.6020704@cn.fujitsu.com>
Date: Fri, 23 Apr 2010 09:27:51 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
References: <4BD05929.8040900@cn.fujitsu.com> <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

on 2010-4-23 5:20, David Rientjes wrote:
> On Thu, 22 Apr 2010, Miao Xie wrote:
> 
>> - local variable might be an empty nodemask, so must be checked before setting
>>   pol->v.nodes to it.
>>
>> - nodes_remap() may cause the weight of pol->v.nodes being monotonic decreasing.
>>   and never become large even we pass a nodemask with large weight after
>>   ->v.nodes become little.
>>
> 
> That's always been the intention of rebinding a mempolicy nodemask: we 
> remap the current mempolicy nodes over the new nodemask given the set of 
> allowed nodes.  The nodes_remap() shouldn't be removed.

Suppose the current mempolicy nodes is 0-2, we can remap it from 0-2 to 2,
then we can remap it from 2 to 1, but we can't remap it from 2 to 0-2.

that is to say it can't be remaped to a large set of allowed nodes, and the task
just can use the small set of nodes for ever, even the large set of nodes is allowed,
I think it is unreasonable.

Thanks
Miao

> 
>> this patch fixes these two problem.
>>
>> Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
>> ---
>>  mm/mempolicy.c |    9 ++++++---
>>  1 files changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index 08f40a2..03ba9fc 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -291,12 +291,15 @@ static void mpol_rebind_nodemask(struct mempolicy *pol,
>>  	else if (pol->flags & MPOL_F_RELATIVE_NODES)
>>  		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
>>  	else {
>> -		nodes_remap(tmp, pol->v.nodes, pol->w.cpuset_mems_allowed,
>> -			    *nodes);
>> +		tmp = *nodes;
>>  		pol->w.cpuset_mems_allowed = *nodes;
>>  	}
>>  
>> -	pol->v.nodes = tmp;
>> +	if (nodes_empty(tmp))
>> +		pol->v.nodes = *nodes;
>> +	else
>> +		pol->v.nodes = tmp;
>> +
>>  	if (!node_isset(current->il_next, tmp)) {
>>  		current->il_next = next_node(current->il_next, tmp);
>>  		if (current->il_next >= MAX_NUMNODES)
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
