Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A21856B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 12:33:39 -0400 (EDT)
Received: by wiclp1 with SMTP id lp1so114151555wic.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 09:33:38 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id kf4si10067564wic.48.2015.07.09.09.33.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 09:33:37 -0700 (PDT)
Received: by wicmv11 with SMTP id mv11so5725911wic.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 09:33:37 -0700 (PDT)
Date: Thu, 9 Jul 2015 18:33:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] memcg: get rid of mem_cgroup_from_task
Message-ID: <20150709163334.GI13872@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-9-git-send-email-mhocko@kernel.org>
 <20150708174331.GH2436@esperanza>
 <20150709141320.GH13872@dhcp22.suse.cz>
 <20150709143246.GL2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150709143246.GL2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-07-15 17:32:47, Vladimir Davydov wrote:
> On Thu, Jul 09, 2015 at 04:13:21PM +0200, Michal Hocko wrote:
> > On Wed 08-07-15 20:43:31, Vladimir Davydov wrote:
> > > On Wed, Jul 08, 2015 at 02:27:52PM +0200, Michal Hocko wrote:
> > [...]
> > > > @@ -1091,12 +1079,14 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
> > > >  		task_unlock(p);
> > > >  	} else {
> > > >  		/*
> > > > -		 * All threads may have already detached their mm's, but the oom
> > > > -		 * killer still needs to detect if they have already been oom
> > > > -		 * killed to prevent needlessly killing additional tasks.
> > > > +		 * All threads have already detached their mm's but we should
> > > > +		 * still be able to at least guess the original memcg from the
> > > > +		 * task_css. These two will match most of the time but there are
> > > > +		 * corner cases where task->mm and task_css refer to a different
> > > > +		 * cgroups.
> > > >  		 */
> > > >  		rcu_read_lock();
> > > > -		task_memcg = mem_cgroup_from_task(task);
> > > > +		task_memcg = mem_cgroup_from_css(task_css(task, memory_cgrp_id));
> > > >  		css_get(&task_memcg->css);
> > > 
> > > I wonder why it's safe to call css_get here.
> > 
> > What do you mean by safe? Memcg cannot go away because we are under rcu
> > lock.
> 
> No, it can't, but css->refcnt can reach zero while we are here, can't
> it? If it happens, css->refcnt.release will be called twice, which will
> have very bad consequences. I think it's OK to call css_tryget{_online}
> from an RCU read-side section, but not css_get. Am I missing something?

OK, now I see what you mean. This is a good question indeed. This code has been
like that for quite a while and I took it for granted. I have to think
about it some more. Anyway the patch doesn't change the behavior here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
