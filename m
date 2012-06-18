Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6A8366B004D
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 08:46:17 -0400 (EDT)
Message-ID: <4FDF227B.3080601@parallels.com>
Date: Mon, 18 Jun 2012 16:43:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 23/25] memcg: propagate kmem limiting information to
 children
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-24-git-send-email-glommer@parallels.com> <4FDF20ED.4090401@jp.fujitsu.com>
In-Reply-To: <4FDF20ED.4090401@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Cristoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 06/18/2012 04:37 PM, Kamezawa Hiroyuki wrote:
> (2012/06/18 19:28), Glauber Costa wrote:
>> The current memcg slab cache management fails to present satisfatory hierarchical
>> behavior in the following scenario:
>>
>> ->  /cgroups/memory/A/B/C
>>
>> * kmem limit set at A
>> * A and B empty taskwise
>> * bash in C does find /
>>
>> Because kmem_accounted is a boolean that was not set for C, no accounting
>> would be done. This is, however, not what we expect.
>>
> 
> Hmm....do we need this new routines even while we have mem_cgroup_iter() ?
> 
> Doesn't this work ?
> 
> 	struct mem_cgroup {
> 		.....
> 		bool kmem_accounted_this;
> 		atomic_t kmem_accounted;
> 		....
> 	}
> 
> at set limit
> 
> 	....set_limit(memcg) {
> 
> 		if (newly accounted) {
> 			mem_cgroup_iter() {
> 				atomic_inc(&iter->kmem_accounted)
> 			}
> 		} else {
> 			mem_cgroup_iter() {
> 				atomic_dec(&iter->kmem_accounted);
> 			}
> 	}
> 
> 
> hm ? Then, you can see kmem is accounted or not by atomic_read(&memcg->kmem_accounted);
> 

Accounted by itself / parent is still useful, and I see no reason to use
an atomic + bool if we can use a pair of bits.

As for the routine, I guess mem_cgroup_iter will work... It does a lot
more than I need, but for the sake of using what's already in there, I
can switch to it with no problems.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
