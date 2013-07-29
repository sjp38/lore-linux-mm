Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 7D8AF6B003C
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:47:18 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id ht10so2406627vcb.24
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 12:47:17 -0700 (PDT)
Message-ID: <51F6C6E5.9020200@gmail.com>
Date: Mon, 29 Jul 2013 15:47:49 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 5/6] mm: memcg: enable memcg OOM killer only for user
 faults
References: <1374791138-15665-1-git-send-email-hannes@cmpxchg.org> <1374791138-15665-6-git-send-email-hannes@cmpxchg.org> <51F6C00C.5050702@gmail.com> <20130729194452.GA4793@cmpxchg.org>
In-Reply-To: <20130729194452.GA4793@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

(7/29/13 3:44 PM), Johannes Weiner wrote:
> On Mon, Jul 29, 2013 at 03:18:36PM -0400, KOSAKI Motohiro wrote:
>> (7/25/13 6:25 PM), Johannes Weiner wrote:
>>> System calls and kernel faults (uaccess, gup) can handle an out of
>>> memory situation gracefully and just return -ENOMEM.
>>>
>>> Enable the memcg OOM killer only for user faults, where it's really
>>> the only option available.
>>>
>>> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>>> ---
>>>    include/linux/memcontrol.h | 23 +++++++++++++++++++++++
>>>    include/linux/sched.h      |  3 +++
>>>    mm/filemap.c               | 11 ++++++++++-
>>>    mm/memcontrol.c            |  2 +-
>>>    mm/memory.c                | 40 ++++++++++++++++++++++++++++++----------
>>>    5 files changed, 67 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>>> index 7b4d9d7..9bb5eeb 100644
>>> --- a/include/linux/memcontrol.h
>>> +++ b/include/linux/memcontrol.h
>>> @@ -125,6 +125,24 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>>>    extern void mem_cgroup_replace_page_cache(struct page *oldpage,
>>>    					struct page *newpage);
>>>
>>> +/**
>>> + * mem_cgroup_xchg_may_oom - toggle the memcg OOM killer for a task
>>> + * @p: task
>>> + * @new: true to enable, false to disable
>>> + *
>>> + * Toggle whether a failed memcg charge should invoke the OOM killer
>>> + * or just return -ENOMEM.  Returns the previous toggle state.
>>> + */
>>> +static inline bool mem_cgroup_xchg_may_oom(struct task_struct *p, bool new)
>>> +{
>>> +	bool old;
>>> +
>>> +	old = p->memcg_oom.may_oom;
>>> +	p->memcg_oom.may_oom = new;
>>> +
>>> +	return old;
>>> +}
>>
>> The name of xchg strongly suggest the function use compare-swap op. So, it seems
>> misleading name. I suggest just use "set_*" or something else. In linux kernel,
>> many setter functions already return old value. Don't mind.
>
> I renamed it to bool mem_cgroup_toggle_oom(bool onoff) when I
> incorporated Michal's feedback, would you be okay with that?

Yes, thank you.

>
>>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>>> index fc09d21..4b3effc 100644
>>> --- a/include/linux/sched.h
>>> +++ b/include/linux/sched.h
>>> @@ -1398,6 +1398,9 @@ struct task_struct {
>>>    		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
>>>    	} memcg_batch;
>>>    	unsigned int memcg_kmem_skip_account;
>>> +	struct memcg_oom_info {
>>> +		unsigned int may_oom:1;
>>> +	} memcg_oom;
>>
>> This ":1" makes slower but doesn't diet any memory space, right? I suggest
>> to use bool. If anybody need to diet in future, he may change it to bit field.
>> That's ok, let's stop too early and questionable micro optimization.
>
> It should sit in the same word as the memcg_kmem_skip_account, plus
> I'm adding another bit in the next patch (in_memcg_oom), so we save
> space.  It's also the OOM path, so anything but performance critical.

Oh, if you added another bit too, it's ok, of course.

>>> diff --git a/mm/filemap.c b/mm/filemap.c
>>> index a6981fe..2932810 100644
>>> --- a/mm/filemap.c
>>> +++ b/mm/filemap.c
>>> @@ -1617,6 +1617,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
>>>    	struct file_ra_state *ra = &file->f_ra;
>>>    	struct inode *inode = mapping->host;
>>>    	pgoff_t offset = vmf->pgoff;
>>> +	unsigned int may_oom;
>>
>> Why don't you use bool? your mem_cgroup_xchg_may_oom() uses bool and it seems cleaner more.
>
> Yup, forgot to convert it with the interface, I changed it to bool.

thx.


>>> +	/*
>>> +	 * Enable the memcg OOM handling for faults triggered in user
>>> +	 * space.  Kernel faults are handled more gracefully.
>>> +	 */
>>> +	if (flags & FAULT_FLAG_USER)
>>> +		WARN_ON(mem_cgroup_xchg_may_oom(current, true) == true);
>>
>> Please don't assume WARN_ON never erase any code. I'm not surprised if embedded
>> guys replace WARN_ON with nop in future.
>
> That would be really messed up.
>
> But at the same time, the WARN_ON() obfuscates what's going on a
> little bit, so putting it separately should make the code more
> readable.  I'll change it.
>
> Thanks for your input!

No problem. :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
