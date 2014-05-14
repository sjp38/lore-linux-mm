Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id A6D786B0037
	for <linux-mm@kvack.org>; Wed, 14 May 2014 05:45:53 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so1157256eek.15
        for <linux-mm@kvack.org>; Wed, 14 May 2014 02:45:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r44si1234372eeo.274.2014.05.14.02.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 02:45:52 -0700 (PDT)
Date: Wed, 14 May 2014 11:45:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: deprecate memory.force_empty knob
Message-ID: <20140514094550.GB15756@dhcp22.suse.cz>
References: <1399994956-3907-1-git-send-email-mhocko@suse.cz>
 <20140513143953.0b91925ee1e81580a4025a2e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513143953.0b91925ee1e81580a4025a2e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 13-05-14 14:39:53, Andrew Morton wrote:
> On Tue, 13 May 2014 17:29:16 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > force_empty has been introduced primarily to drop memory before it gets
> > reparented on the group removal. This alone doesn't sound fully
> > justified because reparented pages which are not in use can be reclaimed
> > also later when there is a memory pressure on the parent level.
> > 
> > Mark the knob CFTYPE_INSANE which tells the cgroup core that it
> > shouldn't create the knob with the experimental sane_behavior. Other
> > users will get informed about the deprecation and asked to tell us more
> > because I do not expect most users will use sane_behavior cgroups mode
> > very soon.
> > Anyway I expect that most users will be simply cgroup remove handlers
> > which do that since ever without having any good reason for it.
> > 
> > If somebody really cares because reparented pages, which would be
> > dropped otherwise, push out more important ones then we should fix the
> > reparenting code and put pages to the tail.
> > 
> > ...
> >
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4793,6 +4793,10 @@ static int mem_cgroup_force_empty_write(struct cgroup_subsys_state *css,
> >  
> >  	if (mem_cgroup_is_root(memcg))
> >  		return -EINVAL;
> > +	pr_info("%s (%d): memory.force_empty is deprecated and will be removed.",
> > +			current->comm, task_pid_nr(current));
> > +	pr_cont(" Let us know if you know if it needed in your usecase at");
> > +	pr_cont(" linux-mm@kvack.org\n");
> >  	return mem_cgroup_force_empty(memcg);
> >  }
> >  
> 
> Do we really want to spam the poor user each and every time they use
> this?  Using pr_info_once() is kinder and gentler?

We do not catch all potential callers but it is true that some
configurations might have thousands of cgroups and the notify_on_release
handler will spam the log.

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: memcg-deprecate-memoryforce_empty-knob-fix
> 
> - s/pr_info/pr_info_once/
> - fix garbled printk text
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  Documentation/cgroups/memory.txt |    2 +-
>  mm/memcontrol.c                  |    8 ++++----
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff -puN Documentation/cgroups/memory.txt~memcg-deprecate-memoryforce_empty-knob-fix Documentation/cgroups/memory.txt
> --- a/Documentation/cgroups/memory.txt~memcg-deprecate-memoryforce_empty-knob-fix
> +++ a/Documentation/cgroups/memory.txt
> @@ -482,7 +482,7 @@ About use_hierarchy, see Section 6.
>    memory.kmem.usage_in_bytes == memory.usage_in_bytes.
>  
>    Please note that this knob is considered deprecated and will be removed
> -  in future.
> +  in the future.
>  
>    About use_hierarchy, see Section 6.
>  
> diff -puN mm/memcontrol.c~memcg-deprecate-memoryforce_empty-knob-fix mm/memcontrol.c
> --- a/mm/memcontrol.c~memcg-deprecate-memoryforce_empty-knob-fix
> +++ a/mm/memcontrol.c
> @@ -4799,10 +4799,10 @@ static int mem_cgroup_force_empty_write(
>  
>  	if (mem_cgroup_is_root(memcg))
>  		return -EINVAL;
> -	pr_info("%s (%d): memory.force_empty is deprecated and will be removed.",
> -			current->comm, task_pid_nr(current));
> -	pr_cont(" Let us know if you know if it needed in your usecase at");
> -	pr_cont(" linux-mm@kvack.org\n");
> +	pr_info_once("%s (%d): memory.force_empty is deprecated and will be "
> +		     "removed.  Let us know if it is needed in your usecase at "
> +		     "linux-mm@kvack.org\n",
> +		     current->comm, task_pid_nr(current));
>  	return mem_cgroup_force_empty(memcg);
>  }
>  
> _
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
