Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E57E46B0069
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 08:32:50 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so997242wmc.3
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 05:32:50 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h38si865357ede.369.2017.12.01.05.32.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 05:32:49 -0800 (PST)
Date: Fri, 1 Dec 2017 13:32:15 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm, oom: simplify alloc_pages_before_oomkill handling
Message-ID: <20171201133214.GB7741@castle.DHCP.thefacebook.com>
References: <20171130152824.1591-1-guro@fb.com>
 <20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171201091425.ekrpxsmkwcusozua@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@vger.kernel.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi, Michal!

I totally agree that out_of_memory() function deserves some refactoring.

But I think there is an issue with your patch (see below):

On Fri, Dec 01, 2017 at 10:14:25AM +0100, Michal Hocko wrote:
> Recently added alloc_pages_before_oomkill gained new caller with this
> patchset and I think it just grown to deserve a simpler code flow.
> What do you think about this on top of the series?
> 
> ---
> From f1f6035ea0df65e7619860b013f2fabdda65233e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 1 Dec 2017 10:05:25 +0100
> Subject: [PATCH] mm, oom: simplify alloc_pages_before_oomkill handling
> 
> alloc_pages_before_oomkill is the last attempt to allocate memory before
> we go and try to kill a process or a memcg. It's success path always has
> to properly clean up the oc state (namely victim reference count). Let's
> pull this into alloc_pages_before_oomkill directly rather than risk
> somebody will forget to do it in future. Also document that we _know_
> alloc_pages_before_oomkill violates proper layering and that is a
> pragmatic decision.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/oom.h |  2 +-
>  mm/oom_kill.c       | 21 +++------------------
>  mm/page_alloc.c     | 24 ++++++++++++++++++++++--
>  3 files changed, 26 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 10f495c8454d..7052e0a20e13 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -121,7 +121,7 @@ extern void oom_killer_enable(void);
>  
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
> -extern struct page *alloc_pages_before_oomkill(const struct oom_control *oc);
> +extern bool alloc_pages_before_oomkill(struct oom_control *oc);
>  
>  extern int oom_evaluate_task(struct task_struct *task, void *arg);
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4678468bae17..5c2cd299757b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -1102,8 +1102,7 @@ bool out_of_memory(struct oom_control *oc)
>  	if (!is_memcg_oom(oc) && sysctl_oom_kill_allocating_task &&
>  	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> -		oc->page = alloc_pages_before_oomkill(oc);
> -		if (oc->page)
> +		if (alloc_pages_before_oomkill(oc))
>  			return true;
>  		get_task_struct(current);
>  		oc->chosen_task = current;
> @@ -1112,13 +1111,8 @@ bool out_of_memory(struct oom_control *oc)
>  	}
>  
>  	if (mem_cgroup_select_oom_victim(oc)) {
> -		oc->page = alloc_pages_before_oomkill(oc);
> -		if (oc->page) {
> -			if (oc->chosen_memcg &&
> -			    oc->chosen_memcg != INFLIGHT_VICTIM)
> -				mem_cgroup_put(oc->chosen_memcg);

You're removing chosen_memcg releasing here, but I don't see where you
do this instead. And I'm not sure that putting mem_cgroup_put() into
alloc_pages_before_oomkill() is a way towards simpler code.

I was thinking about a bit larger refactoring: splitting out_of_memory()
into the following parts (defined as separate functions): victim selection
(per-process, memcg-aware or just allocating task), last allocation attempt,
OOM action (kill process, kill memcg, panic). Hopefully it can simplify the things,
but I don't have code yet.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
