Message-ID: <480306A4.8080700@cn.fujitsu.com>
Date: Mon, 14 Apr 2008 15:24:20 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix oops in oom handling
References: <4802FF10.6030905@cn.fujitsu.com> <20080414161428.27f3ee59.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080414161428.27f3ee59.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Paul Menage <menage@google.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 14 Apr 2008 14:52:00 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
>> It's reproducable in a x86_64 box, but doesn't happen in x86_32.
>>
>> This is because tsk->sighand is not guarded by RCU, so we have to
>> hold tasklist_lock, just as what out_of_memory() does.
>>
> 
> Good catch! and patch seems good.
> 
> Paul, I have one confirmation. Lock hierarchy of
> 	cgroup_lock()
> 	->	read_lock(&tasklist_lock)
> 
> is ok ? (I think this is ok.)
> 

I think so, because we used to have this in cgroup:

mutex_lock(&cgroup_mutex);
  -> attach_task_by_pid()
       -> read_lock(&tasklist_lock)

But afte some time, some uses of tasklist_lock is replaced by rcu.

> Thanks,
> -Kame
> 
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu>
>> ---
>>  mm/oom_kill.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index f255eda..beb592f 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -423,7 +423,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>>  	struct task_struct *p;
>>  
>>  	cgroup_lock();
>> -	rcu_read_lock();
>> +	read_lock(&tasklist_lock);
>>  retry:
>>  	p = select_bad_process(&points, mem);
>>  	if (PTR_ERR(p) == -1UL)
>> @@ -436,7 +436,7 @@ retry:
>>  				"Memory cgroup out of memory"))
>>  		goto retry;
>>  out:
>> -	rcu_read_unlock();
>> +	read_unlock(&tasklist_lock);
>>  	cgroup_unlock();
>>  }
>>  #endif
>> -- 1.5.4.rc3 
>>
>>
>>
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
