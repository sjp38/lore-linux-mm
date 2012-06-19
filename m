Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 555F86B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 20:18:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E67A43EE0C7
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:29 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CC78445DEB4
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B272D45DEA6
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 677C61DB8041
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F7D61DB803F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 09:18:29 +0900 (JST)
Message-ID: <4FDFC4D4.1030303@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 09:16:20 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 23/25] memcg: propagate kmem limiting information to
 children
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-24-git-send-email-glommer@parallels.com> <4FDF20ED.4090401@jp.fujitsu.com> <4FDF227B.3080601@parallels.com>
In-Reply-To: <4FDF227B.3080601@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2012/06/18 21:43), Glauber Costa wrote:
> On 06/18/2012 04:37 PM, Kamezawa Hiroyuki wrote:
>> (2012/06/18 19:28), Glauber Costa wrote:
>>> The current memcg slab cache management fails to present satisfatory hierarchical
>>> behavior in the following scenario:
>>>
>>> ->   /cgroups/memory/A/B/C
>>>
>>> * kmem limit set at A
>>> * A and B empty taskwise
>>> * bash in C does find /
>>>
>>> Because kmem_accounted is a boolean that was not set for C, no accounting
>>> would be done. This is, however, not what we expect.
>>>
>>
>> Hmm....do we need this new routines even while we have mem_cgroup_iter() ?
>>
>> Doesn't this work ?
>>
>> 	struct mem_cgroup {
>> 		.....
>> 		bool kmem_accounted_this;
>> 		atomic_t kmem_accounted;
>> 		....
>> 	}
>>
>> at set limit
>>
>> 	....set_limit(memcg) {
>>
>> 		if (newly accounted) {
>> 			mem_cgroup_iter() {
>> 				atomic_inc(&iter->kmem_accounted)
>> 			}
>> 		} else {
>> 			mem_cgroup_iter() {
>> 				atomic_dec(&iter->kmem_accounted);
>> 			}
>> 	}
>>
>>
>> hm ? Then, you can see kmem is accounted or not by atomic_read(&memcg->kmem_accounted);
>>
> 
> Accounted by itself / parent is still useful, and I see no reason to use
> an atomic + bool if we can use a pair of bits.
> 
> As for the routine, I guess mem_cgroup_iter will work... It does a lot
> more than I need, but for the sake of using what's already in there, I
> can switch to it with no problems.
> 

Hmm. please start from reusing existing routines.
If it's not enough, some enhancement for generic cgroup  will be welcomed
rather than completely new one only for memcg.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
