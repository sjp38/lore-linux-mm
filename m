Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1274B6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 10:13:25 -0400 (EDT)
Received: by wgck11 with SMTP id k11so224988653wgc.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:13:24 -0700 (PDT)
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id b12si9670281wjb.139.2015.07.09.07.13.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 07:13:23 -0700 (PDT)
Received: by wgov12 with SMTP id v12so40171447wgo.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 07:13:23 -0700 (PDT)
Date: Thu, 9 Jul 2015 16:13:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 8/8] memcg: get rid of mem_cgroup_from_task
Message-ID: <20150709141320.GH13872@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-9-git-send-email-mhocko@kernel.org>
 <20150708174331.GH2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150708174331.GH2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 08-07-15 20:43:31, Vladimir Davydov wrote:
> On Wed, Jul 08, 2015 at 02:27:52PM +0200, Michal Hocko wrote:
[...]
> > @@ -1091,12 +1079,14 @@ bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
> >  		task_unlock(p);
> >  	} else {
> >  		/*
> > -		 * All threads may have already detached their mm's, but the oom
> > -		 * killer still needs to detect if they have already been oom
> > -		 * killed to prevent needlessly killing additional tasks.
> > +		 * All threads have already detached their mm's but we should
> > +		 * still be able to at least guess the original memcg from the
> > +		 * task_css. These two will match most of the time but there are
> > +		 * corner cases where task->mm and task_css refer to a different
> > +		 * cgroups.
> >  		 */
> >  		rcu_read_lock();
> > -		task_memcg = mem_cgroup_from_task(task);
> > +		task_memcg = mem_cgroup_from_css(task_css(task, memory_cgrp_id));
> >  		css_get(&task_memcg->css);
> 
> I wonder why it's safe to call css_get here.

What do you mean by safe? Memcg cannot go away because we are under rcu
lock.

> 
> The patch itself looks good though,
> 
> Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
