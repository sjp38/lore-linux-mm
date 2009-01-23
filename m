Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 98FBA6B004F
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 04:50:02 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0N9nxcI001062
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Jan 2009 18:49:59 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4078645DE51
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 18:49:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0365B45DE4E
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 18:49:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D6B141DB803B
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 18:49:58 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 821FF1DB8043
	for <linux-mm@kvack.org>; Fri, 23 Jan 2009 18:49:58 +0900 (JST)
Message-ID: <c2cf91864adcd1461b14f491dcafd17e.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090123162232.5a81e0d3.nishimura@mxp.nes.nec.co.jp>
References: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
    <20090122183557.3b058e98.kamezawa.hiroyu@jp.fujitsu.com>
    <20090123162232.5a81e0d3.nishimura@mxp.nes.nec.co.jp>
Date: Fri, 23 Jan 2009 18:49:57 +0900 (JST)
Subject: Re: [PATCH 2/7] memcg : use CSS ID in memcg
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura さんは書きました：
> On Thu, 22 Jan 2009 18:35:57 +0900, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Use css ID in memcg.
>>
>> Assigning CSS ID for each memcg and use css_get_next() for scanning
>> hierarchy.
>>
>> 	Assume folloing tree.
>>
>> 	group_A (ID=3)
>> 		/01 (ID=4)
>> 		   /0A (ID=7)
>> 		/02 (ID=10)
>> 	group_B (ID=5)
>> 	and task in group_A/01/0A hits limit at group_A.
>>
>> 	reclaim will be done in following order (round-robin).
>> 	group_A(3) -> group_A/01 (4) -> group_A/01/0A (7) -> group_A/02(10)
>> 	-> group_A -> .....
>>
>> 	Round robin by ID. The last visited cgroup is recorded and restart
>> 	from it when it start reclaim again.
>> 	(More smart algorithm can be implemented..)
>>
>> 	No cgroup_mutex or hierarchy_mutex is required.
>>
>> Changelog (v3) -> (v4)
>>   - dropped css_is_populated() check
>>   - removed scan_age and use more simple logic.
>>
> I think a check for mem_cgroup_local_usage is also added by this version
> :)
>
>> Changelog (v2) -> (v3)
>>   - Added css_is_populatd() check
>>   - Adjusted to rc1 + Nishimrua's fixes.
>>   - Increased comments.
>>
>> Changelog (v1) -> (v2)
>>   - Updated texts.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>> ---
>>  mm/memcontrol.c |  220
>> ++++++++++++++++++++------------------------------------
>>  1 file changed, 82 insertions(+), 138 deletions(-)
>>
>> Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
>> ===================================================================
>> --- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
>> +++ mmotm-2.6.29-Jan16/mm/memcontrol.c
>> @@ -95,6 +95,15 @@ static s64 mem_cgroup_read_stat(struct m
>>  	return ret;
>>  }
>>
>> +static s64 mem_cgroup_local_usage(struct mem_cgroup_stat *stat)
>> +{
>> +	s64 ret;
>> +
> It would be better to initialize it to 0.
>
Hmm ? why ?
> 	Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> Thanks,
> Daisuke Nishimura.
>

Thanks,
-Kame


>> +	ret = mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_CACHE);
>> +	ret += mem_cgroup_read_stat(stat, MEM_CGROUP_STAT_RSS);
>> +	return ret;
>> +}
>> +


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
