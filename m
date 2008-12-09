Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB9ESYjc028566
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 23:28:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 52AE545DE55
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 23:28:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A2F745DE52
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 23:28:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E82A91DB8040
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 23:28:33 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 863D21DB803E
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 23:28:33 +0900 (JST)
Message-ID: <3526.10.75.179.61.1228832912.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20081209122731.GB4174@balbir.in.ibm.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
    <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com>
    <20081209122731.GB4174@balbir.in.ibm.com>
Date: Tue, 9 Dec 2008 23:28:32 +0900 (JST)
Subject: Re: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh said:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-09
> 20:09:15]:
>
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Implement hierarchy reclaim by cgroup_id.
>>
>> What changes:
>> 	- Page reclaim is not done by tree-walk algorithm
>> 	- mem_cgroup->last_schan_child is changed to be ID, not pointer.
>> 	- no cgroup_lock, done under RCU.
>> 	- scanning order is just defined by ID's order.
>> 	  (Scan by round-robin logic.)
>>
>> Changelog: v3 -> v4
>> 	- adjusted to changes in base kernel.
>> 	- is_acnestor() is moved to other patch.
>>
>> Changelog: v2 -> v3
>> 	- fixed use_hierarchy==0 case
>>
>> Changelog: v1 -> v2
>> 	- make use of css_tryget();
>> 	- count # of loops rather than remembering position.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
>
> I have not yet run the patch, but the heuristics seem a lot like
> magic. I am not against scanning by order, but is order the right way
> to scan groups?
My consideration is
  - Both of current your implementation and this round robin is just
    an example. I never think some kind of search algorighm detemined by
    shape of tree is the best way.
  - No one knows what order is the best, now. We have to find it.
  - The best order will be determined by some kind of calculation rather
    than shape of tree and must pass by tons of tests.
    This needs much amount of time and patient work. VM management is not
    so easy thing.
    I think your soft-limit idea can be easily merged onto this patch set.

> Does this order reflect their position in the hierarchy?
  No. just scan IDs from last scannned one in RR.
  BTW, can you show what an algorithm works well in following case ?
  ex)
    groupA/   limit=1G     usage=300M
          01/ limit=600M   usage=600M
          02/ limit=700M   usage=70M
          03/ limit=100M   usage=30M
   Which one should be shrinked at first and why ?
   1) when group_A hit limits.
   2) when group_A/01 hit limits.
   3) when group_A/02 hit limits.
   I can't now.

   This patch itself uses round-robin and have no special order.
   I think implenting good algorithm under this needs some amount of time.

> Shouldn't id's belong to cgroups instead of just memory controller?
If Paul rejects, I'll move this to memcg. But bio-cgroup people also use
ID and, in this summer, I posted swap-cgroup-ID patch and asked to
implement IDs under cgroup rather than subsys. (asked by Paul or you.)

>From implementation, hierarchy code management at el. should go into
cgroup.c and it gives us clear view rather than implemented under memcg.

-Kame
> I would push back ids to cgroups infrastructure.
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
