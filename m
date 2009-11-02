Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3B2B16B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 18:02:32 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA2N2TCh017916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Nov 2009 08:02:30 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B63D45DE53
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:02:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AA471EF084
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:02:29 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D573E1DB805F
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:02:28 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 83F861DB8040
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 08:02:28 +0900 (JST)
Message-ID: <c33e080dcc375d55a4dee1a1314e73f0.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911021159120.2028@V090114053VZO-1>
References: <20091102162244.9425e49b.kamezawa.hiroyu@jp.fujitsu.com>
    <20091102162412.107ff8ac.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0911021159120.2028@V090114053VZO-1>
Date: Tue, 3 Nov 2009 08:02:28 +0900 (JST)
Subject: Re: [RFC][-mm][PATCH 1/6] oom-killer: updates for classification
 of OOM
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, aarcange@redhat.com, akpm@linux-foundation.org, minchan.kim@gmail.com, rientjes@google.com, vedran.furac@gmail.com, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Thanks! your review is very helpful around NUMA.

Christoph Lameter wrote:
> On Mon, 2 Nov 2009, KAMEZAWA Hiroyuki wrote:
>
>>  /*
>> - * Types of limitations to the nodes from which allocations may occur
>> + * Types of limitations to zones from which allocations may occur
>>   */
>
> "Types of limitations that may cause OOMs"? MEMCG limitations are not zone
> based.
>
ah, will rewrite.

>>   */
>>
>> -unsigned long badness(struct task_struct *p, unsigned long uptime)
>> +static unsigned long __badness(struct task_struct *p,
>> +		      unsigned long uptime, enum oom_constraint constraint,
>> +		      struct mem_cgroup *mem)
>>  {
>>  	unsigned long points, cpu_time, run_time;
>>  	struct mm_struct *mm;
>
> Why rename this function? You are adding a global_badness anyways.
>
just because of history of my own updates...i.e. mistake.
no reason. sorry.

>
>> +	/*
>> +	 * In numa environ, almost all allocation will be against NORMAL zone.
>
> The typical allocations will be against the policy_zone! SGI IA64 (and
> others) have policy_zone == GFP_DMA.
>
Hmm ? ok. I thought GPF_DMA for ia64 was below 4G zone.
If all memory are GFP_DMA(as ppc), that means no lowemem.
I'll just rewrite above comments as
"typical allocation will be against policy_zone".


>> +	 * But some small area, ex)GFP_DMA for ia64 or GFP_DMA32 for x86-64
>> +	 * can cause OOM. We can use policy_zone for checking lowmem.
>> +	 */
>
> Simply say that we are checking if the zone constraint is below the policy
> zone?
>
ok, will rewrite. Too verbose just bacause policy_zone isn't well unknown.


>> +	 * Now, only mempolicy specifies nodemask. But if nodemask
>> +	 * covers all nodes, this oom is global oom.
>> +	 */
>> +	if (nodemask && !nodes_equal(node_states[N_HIGH_MEMORY], *nodemask))
>> +		ret = CONSTRAINT_MEMORY_POLICY;
>
> Huh? A cpuset can also restrict the nodes?
>
cpuset doesn't pass nodemask for allocation(now).
It checks its nodemask in get_free_page_from_freelist(), internally.

>> +	/*
>> + 	 * If not __GFP_THISNODE, zonelist containes all nodes. And if
>
> Dont see any __GFP_THISNODE checks here.
>
If __GFP_THISNODE, zonelist includes local node only. Then zonelist/nodemask
check will hunt it and result will be CONSTRAINT_MEMPOLICY.
Then...hum....recommending CONSTRAINT_THISNODE ?

>>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>>
>>  	read_lock(&tasklist_lock);
>> -	__out_of_memory(0, 0); /* unknown gfp_mask and order */
>> +	/*
>> +	 * Considering nature of pages required for page-fault,this must be
>> +	 * global OOM (if not cpuset...). Then, CONSTRAINT_NONE is correct.
>> +	 * zonelist, nodemasks are unknown...
>> +	 */
>> +	__out_of_memory(0, CONSTRAINT_NONE, 0, NULL);
>>  	read_unlock(&tasklist_lock);
>
> Page faults can occur on processes that have memory restrictions.
>
yes. comments are bad. will rewrite. But we don't have any useful
information here.Fixing pagefault_out_of_memory is on my to-do-list.
It seems wrong.

But a condition unclear to me is when VM_FAULT_OOM can be returned
without oom-kill...so plz give me time.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
