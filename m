Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 73A366B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 08:28:53 -0400 (EDT)
Message-ID: <4FC611F4.7010202@parallels.com>
Date: Wed, 30 May 2012 16:26:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 16/28] memcg: kmem controller charge/uncharge infrastructure
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-17-git-send-email-glommer@parallels.com> <20120530121706.GB25094@somewhere.redhat.com>
In-Reply-To: <20120530121706.GB25094@somewhere.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/30/2012 04:17 PM, Frederic Weisbecker wrote:
> On Fri, May 25, 2012 at 05:03:36PM +0400, Glauber Costa wrote:
>>   #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>> +static __always_inline struct kmem_cache *
>> +mem_cgroup_get_kmem_cache(struct kmem_cache *cachep, gfp_t gfp)
>> +{
>> +	if (!mem_cgroup_kmem_on)
>> +		return cachep;
>> +	if (!current->mm)
>> +		return cachep;
>> +	if (in_interrupt())
>> +		return cachep;
>
> Does that mean interrupts are kept out of accounting?

Well, since interrupts have no process context, if you are in an 
interrupt I can't think of any sane thing to do than relay it to the 
root memcg. That's what happen when I return cachep: I return the 
original parent cache, and we allocate from that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
