Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 83DB06B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:22:37 -0400 (EDT)
Received: by wgme6 with SMTP id e6so34939159wgm.2
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:22:37 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id ce7si24960277wjc.102.2015.05.26.10.22.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:22:36 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so103505903wgb.3
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:22:35 -0700 (PDT)
Date: Tue, 26 May 2015 19:22:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526172234.GK14681@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526163646.GA29968@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526163646.GA29968@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 26-05-15 18:36:46, Oleg Nesterov wrote:
> On 05/26, Michal Hocko wrote:
> >
> > @@ -426,17 +426,7 @@ struct mm_struct {
> >  	struct kioctx_table __rcu	*ioctx_table;
> >  #endif
> >  #ifdef CONFIG_MEMCG
> > -	/*
> > -	 * "owner" points to a task that is regarded as the canonical
> > -	 * user/owner of this mm. All of the following must be true in
> > -	 * order for it to be changed:
> > -	 *
> > -	 * current == mm->owner
> > -	 * current->mm != mm
> > -	 * new_owner->mm == mm
> > -	 * new_owner->alloc_lock is held
> > -	 */
> > -	struct task_struct __rcu *owner;
> > +	struct mem_cgroup __rcu *memcg;
> 
> Yes, thanks, this is what I tried to suggest ;)
> 
> But I can't review this series. Simply because I know nothing about
> memcs. I don't even know how to use it.
> 
> Just one question,
> 
> > +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> > +{
> > +	if (!p->mm)
> > +		return NULL;
> > +	return rcu_dereference(p->mm->memcg);
> > +}
> 
> Probably I missed something, but it seems that the callers do not
> expect it can return NULL.

This hasn't changed by this patch. mem_cgroup_from_task was allowed to
return NULL even before. I've just made it static because it doesn't
have any external users anymore. I will double check whether we can ever
get NULL there in the real life. We have this code like that for quite
some time. Maybe this is just a heritage from the past...

> Perhaps sock_update_memcg() is fine, but
> task_in_mem_cgroup() calls it when find_lock_task_mm() fails, and in
> this case ->mm is NULL.
> 
> And in fact I can't understand what mem_cgroup_from_task() actually
> means, with or without these changes.

It performs task_struct->mem_cgroup mapping. We cannot use cgroup
mapping here because the charges are bound to mm_struct rather than
task.

> And another question. I can't understand what happens when a task
> execs... IOW, could you confirm that exec_mmap() does not need
> mm_set_memcg(mm, oldmm->memcg) ?

Right you are! Fixed thanks!
---
diff --git a/fs/exec.c b/fs/exec.c
index 2cd4def4b1d6..ea00d5a47aad 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -867,6 +867,7 @@ static int exec_mmap(struct mm_struct *mm)
 		up_read(&old_mm->mmap_sem);
 		BUG_ON(active_mm != old_mm);
 		setmax_mm_hiwater_rss(&tsk->signal->maxrss, old_mm);
+		mm_set_memcg(mm, old_mm->memcg);
 		mmput(old_mm);
 		return 0;
 	}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
