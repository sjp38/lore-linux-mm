Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA896B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 13:39:22 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so90653628wic.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 10:39:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id os5si19515563wjc.179.2015.05.26.10.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 10:39:20 -0700 (PDT)
Date: Tue, 26 May 2015 19:38:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526173822.GA31777@redhat.com>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz> <1432641006-8025-4-git-send-email-mhocko@suse.cz> <20150526163646.GA29968@redhat.com> <20150526172234.GK14681@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150526172234.GK14681@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/26, Michal Hocko wrote:
>
> On Tue 26-05-15 18:36:46, Oleg Nesterov wrote:
> >
> > > +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> > > +{
> > > +	if (!p->mm)
> > > +		return NULL;
> > > +	return rcu_dereference(p->mm->memcg);
> > > +}
> >
> > Probably I missed something, but it seems that the callers do not
> > expect it can return NULL.
>
> This hasn't changed by this patch. mem_cgroup_from_task was allowed to
> return NULL even before. I've just made it static because it doesn't
> have any external users anymore.

I see, but it could only return NULL if mem_cgroup_from_css() returns
NULL. Now it returns NULL for sure if the caller is task_in_mem_cgroup(),

	// called when task->mm == NULL

	task_memcg = mem_cgroup_from_task(task);
	css_get(&task_memcg->css);

and this css_get() doesn't look nice if task_memcg == NULL ;)

> I will double check

Yes, please. Perhaps I missed something.

> > And in fact I can't understand what mem_cgroup_from_task() actually
> > means, with or without these changes.
>
> It performs task_struct->mem_cgroup mapping. We cannot use cgroup
> mapping here because the charges are bound to mm_struct rather than
> task.

Sure, this is what I can understand. I meant... OK, lets ignore
"without these changes", because without these changes there are
much more oddities ;) With these changes only ->mm == NULL case
looks unclear.

And btw,

	if (!p->mm)
		return NULL;
	return rcu_dereference(p->mm->memcg);

perhaps this needs a comment. It is not clear what protects ->mm.
But. After this series "p" is always current (if ->mm != NULL), so
this is fine.

Nevermind. Please forget. I feel this needs a bit of cleanup, but
we can always do this later.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
