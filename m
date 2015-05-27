Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 419B06B00AC
	for <linux-mm@kvack.org>; Wed, 27 May 2015 05:43:57 -0400 (EDT)
Received: by wgez8 with SMTP id z8so4436787wge.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 02:43:56 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si3084668wic.59.2015.05.27.02.43.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 May 2015 02:43:55 -0700 (PDT)
Date: Wed, 27 May 2015 11:43:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150527094352.GB27348@dhcp22.suse.cz>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz>
 <1432641006-8025-4-git-send-email-mhocko@suse.cz>
 <20150526163646.GA29968@redhat.com>
 <20150526172234.GK14681@dhcp22.suse.cz>
 <20150526173822.GA31777@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526173822.GA31777@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 26-05-15 19:38:22, Oleg Nesterov wrote:
> On 05/26, Michal Hocko wrote:
> >
> > On Tue 26-05-15 18:36:46, Oleg Nesterov wrote:
> > >
> > > > +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> > > > +{
> > > > +	if (!p->mm)
> > > > +		return NULL;
> > > > +	return rcu_dereference(p->mm->memcg);
> > > > +}
> > >
> > > Probably I missed something, but it seems that the callers do not
> > > expect it can return NULL.
> >
> > This hasn't changed by this patch. mem_cgroup_from_task was allowed to
> > return NULL even before. I've just made it static because it doesn't
> > have any external users anymore.
> 
> I see, but it could only return NULL if mem_cgroup_from_css() returns
> NULL. Now it returns NULL for sure if the caller is task_in_mem_cgroup(),
> 
> 	// called when task->mm == NULL
> 
> 	task_memcg = mem_cgroup_from_task(task);
> 	css_get(&task_memcg->css);
> 
> and this css_get() doesn't look nice if task_memcg == NULL ;)

You are right of course. mem_cgroup_from_task is indeed weird. I will
add the diff below to the original patch and try to get rid of this
weird interface in a follow up patch.

> > I will double check
> 
> Yes, please. Perhaps I missed something.
> 
> > > And in fact I can't understand what mem_cgroup_from_task() actually
> > > means, with or without these changes.
> >
> > It performs task_struct->mem_cgroup mapping. We cannot use cgroup
> > mapping here because the charges are bound to mm_struct rather than
> > task.
> 
> Sure, this is what I can understand. I meant... OK, lets ignore
> "without these changes", because without these changes there are
> much more oddities ;) With these changes only ->mm == NULL case
> looks unclear.
> 
> And btw,
> 
> 	if (!p->mm)
> 		return NULL;
> 	return rcu_dereference(p->mm->memcg);
> 
> perhaps this needs a comment. It is not clear what protects ->mm.
> But. After this series "p" is always current (if ->mm != NULL), so
> this is fine.
> 
> Nevermind. Please forget. I feel this needs a bit of cleanup, but
> we can always do this later.

Yes I will rather do that in a separate patch. Thanks!

This will go into to patch because I have indeed change the semantic of
this function and I haven't realized the subtle difference.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aa85d5dfbe0e..ab00b6ae84e2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -471,9 +471,14 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
 
 static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
-	if (!p->mm)
-		return NULL;
-	return rcu_dereference(p->mm->memcg);
+	if (p->mm)
+		return rcu_dereference(p->mm->memcg);
+
+	/*
+	 * If the process doesn't have mm struct anymore we have to fallback
+	 * to the task_css.
+	 */
+	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
 }
 
 void mm_set_memcg(struct mm_struct *mm, struct mem_cgroup *memcg)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
