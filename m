Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id m316et0d133692
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 16:40:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m316WEFR245986
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 17:32:15 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m316SWkW022973
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 16:28:32 +1000
Message-ID: <47F1D4F3.3040207@linux.vnet.ibm.com>
Date: Tue, 01 Apr 2008 11:53:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain> <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com>
In-Reply-To: <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 31, 2008 at 10:43 PM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
>>  -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>  +struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>   {
>>         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>>                                 struct mem_cgroup, css);
>>   }
> 
> This should probably be inlined in the header file if it's needed
> outside this file.

I thought about it, but that also means we need to export struct mem_cgroup into
the header file

>>  +static inline void mm_fork_init_owner(struct task_struct *p)
>>  +{
>>  +}
> 
> I think this is stale.
> 

Yes, it is stale now :)

>>  +
>>  +void mm_update_next_owner(struct mm_struct *mm)
>>  +{
>>  +       struct task_struct *c, *g, *p = current;
>>  +
>>  +       /*
>>  +        * This routine should not be called for init_task
>>  +        */
>>  +       BUG_ON(p == p->parent);
> 
> I think (as you mentioned earlier) that we need an RCU critical
> section in this function, in order for the tasklist traversal to be
> safe.
> 
> Maybe also BUG_ON(p != mm->owner) ?
> 

Yes

>>  +       list_for_each_entry(c, &p->children, sibling) {
>>  +               if (c->mm && (c->mm == mm))
> 
> Since mm != NULL, no need to test for c->mm since if it's NULL then c->mm != mm
> 

OK

>>  +assign_new_owner:
>>  +       BUG_ON(c == p);
>>  +       task_lock(c);
>>  +       if (c->mm != mm) {
>>  +               task_unlock(c);
>>  +               goto retry;
>>  +       }
>>  +       mm->owner = c;
> 
> Here we'll want to call vm_cgroup_update_mm_owner(), to adjust the
> accounting. (Or if in future we end up with more than a couple of
> subsystems that want notification at this time, we'll want to call
> cgroup_update_mm_owner() and have it call any interested subsystems.
> 

I don't think we need to adjust accounting, since only mm->owner is changing and
not the cgroup to which the task/mm belongs. Do we really need to notify? I
don't want to do any notifications under task_lock().

> Paul


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
