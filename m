Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m316GKw9028849
	for <linux-mm@kvack.org>; Tue, 1 Apr 2008 07:16:21 +0100
Received: from py-out-1112.google.com (pybu77.prod.google.com [10.34.97.77])
	by zps78.corp.google.com with ESMTP id m316GJpf020108
	for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:16:20 -0700
Received: by py-out-1112.google.com with SMTP id u77so2030551pyb.16
        for <linux-mm@kvack.org>; Mon, 31 Mar 2008 23:16:19 -0700 (PDT)
Message-ID: <6599ad830803312316m17f9e6f1mf7f068c0314a789e@mail.gmail.com>
Date: Mon, 31 Mar 2008 23:16:19 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v3)
In-Reply-To: <20080401054324.829.4517.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080401054324.829.4517.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 31, 2008 at 10:43 PM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>  -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  +struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>   {
>         return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>                                 struct mem_cgroup, css);
>   }

This should probably be inlined in the header file if it's needed
outside this file.
>  +static inline void mm_fork_init_owner(struct task_struct *p)
>  +{
>  +}

I think this is stale.

>  +
>  +void mm_update_next_owner(struct mm_struct *mm)
>  +{
>  +       struct task_struct *c, *g, *p = current;
>  +
>  +       /*
>  +        * This routine should not be called for init_task
>  +        */
>  +       BUG_ON(p == p->parent);

I think (as you mentioned earlier) that we need an RCU critical
section in this function, in order for the tasklist traversal to be
safe.

Maybe also BUG_ON(p != mm->owner) ?

>  +       list_for_each_entry(c, &p->children, sibling) {
>  +               if (c->mm && (c->mm == mm))

Since mm != NULL, no need to test for c->mm since if it's NULL then c->mm != mm

>  +assign_new_owner:
>  +       BUG_ON(c == p);
>  +       task_lock(c);
>  +       if (c->mm != mm) {
>  +               task_unlock(c);
>  +               goto retry;
>  +       }
>  +       mm->owner = c;

Here we'll want to call vm_cgroup_update_mm_owner(), to adjust the
accounting. (Or if in future we end up with more than a couple of
subsystems that want notification at this time, we'll want to call
cgroup_update_mm_owner() and have it call any interested subsystems.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
