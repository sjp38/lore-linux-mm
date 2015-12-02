Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6966B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 03:18:46 -0500 (EST)
Received: by wmec201 with SMTP id c201so46880511wme.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 00:18:46 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id fa15si2754262wjc.132.2015.12.02.00.18.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 00:18:45 -0800 (PST)
Received: by wmec201 with SMTP id c201so241074768wme.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 00:18:45 -0800 (PST)
Date: Wed, 2 Dec 2015 09:18:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151202081842.GA25284@dhcp22.suse.cz>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
 <20151201154353.87e2200b5cd1a99289ce6653@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201154353.87e2200b5cd1a99289ce6653@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aristeu Rozanski <arozansk@redhat.com>, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 01-12-15 15:43:53, Andrew Morton wrote:
[...]
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 1ecc0bc..bdbf83b 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -42,6 +42,7 @@
> >  int sysctl_panic_on_oom;
> >  int sysctl_oom_kill_allocating_task;
> >  int sysctl_oom_dump_tasks = 1;
> > +int sysctl_oom_dump_stack = 1;
> >  
> >  DEFINE_MUTEX(oom_lock);
> >  
> > @@ -384,7 +385,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p,
> >  		current->signal->oom_score_adj);
> >  	cpuset_print_task_mems_allowed(current);
> >  	task_unlock(current);
> > -	dump_stack();
> > +	if (sysctl_oom_dump_stack)
> > +		dump_stack();
> >  	if (memcg)
> >  		mem_cgroup_print_oom_info(memcg, p);
> >  	else
> 
> The patch seems reasonable to me, but it's missing the required update
> to Documentation/sysctl/vm.txt.

I thought we have agreed to go via KERN_DEBUG log level for the
backtrace. Aristeu has posted a patch for that already.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
