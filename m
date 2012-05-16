Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DC0516B00EC
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:21:26 -0400 (EDT)
Message-ID: <4FB346E3.5060507@parallels.com>
Date: Wed, 16 May 2012 10:19:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 19/29] skip memcg kmem allocations in specified code
 regions
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-20-git-send-email-glommer@parallels.com> <4FB1C398.1010000@jp.fujitsu.com>
In-Reply-To: <4FB1C398.1010000@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/15/2012 06:46 AM, KAMEZAWA Hiroyuki wrote:
> (2012/05/12 2:44), Glauber Costa wrote:
> 
>> This patch creates a mechanism that skip memcg allocations during
>> certain pieces of our core code. It basically works in the same way
>> as preempt_disable()/preempt_enable(): By marking a region under
>> which all allocations will be accounted to the root memcg.
>>
>> We need this to prevent races in early cache creation, when we
>> allocate data using caches that are not necessarily created already.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Christoph Lameter<cl@linux.com>
>> CC: Pekka Enberg<penberg@cs.helsinki.fi>
>> CC: Michal Hocko<mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner<hannes@cmpxchg.org>
>> CC: Suleiman Souhlal<suleiman@google.com>
> 
> 
> The concept seems okay to me but...
> 
>> ---
>>   include/linux/sched.h |    1 +
>>   mm/memcontrol.c       |   25 +++++++++++++++++++++++++
>>   2 files changed, 26 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index 81a173c..0501114 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -1613,6 +1613,7 @@ struct task_struct {
>>   		unsigned long nr_pages;	/* uncharged usage */
>>   		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
>>   	} memcg_batch;
>> +	atomic_t memcg_kmem_skip_account;
> 
> 
> If only 'current' thread touch this, you don't need to make this atomic counter.
> you can use 'long'.
> 
You're absolutely right, Kame, thanks.
I first used atomic_t because I had it tested against current->mm->owner.

Do you, btw, agree to use current instead of owner here?
You can find the rationale in earlier mails between me and Suleiman.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
