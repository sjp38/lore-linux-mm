Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 23AC66B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:22:44 -0500 (EST)
Received: by mail-wi0-f181.google.com with SMTP id hi5so3954575wib.14
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:22:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gu8si8374716wib.0.2014.02.11.02.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 02:22:41 -0800 (PST)
Date: Tue, 11 Feb 2014 11:22:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: change oom_info_lock to mutex
Message-ID: <20140211102238.GB11946@dhcp22.suse.cz>
References: <1392040082-14303-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.02.1402101339580.15624@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402101339580.15624@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon 10-02-14 13:40:55, David Rientjes wrote:
> On Mon, 10 Feb 2014, Michal Hocko wrote:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 19d5d4274e22..55e6731ebcd5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1687,7 +1687,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  	 * protects memcg_name and makes sure that parallel ooms do not
> >  	 * interleave
> >  	 */
> > -	static DEFINE_SPINLOCK(oom_info_lock);
> > +	static DEFINE_MUTEX(oom_info_lock);
> >  	struct cgroup *task_cgrp;
> >  	struct cgroup *mem_cgrp;
> >  	static char memcg_name[PATH_MAX];
> > @@ -1698,7 +1698,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> >  	if (!p)
> >  		return;
> >  
> > -	spin_lock(&oom_info_lock);
> > +	mutex_lock(&oom_info_lock);
> >  	rcu_read_lock();
> >  
> >  	mem_cgrp = memcg->css.cgroup;
> > @@ -1767,7 +1767,7 @@ done:
> >  
> >  		pr_cont("\n");
> >  	}
> > -	spin_unlock(&oom_info_lock);
> > +	mutex_unlock(&oom_info_lock);
> >  }
> >  
> >  /*
> 
> Can we change oom_info_lock() to only protecting memcg_name and forget 
> about interleaving the hierarchical memcg stats instead?

Why? Is mutex or holding it for the whole mem_cgroup_print_oom_info a
big deal? I think that having clear oom report is really worth it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
