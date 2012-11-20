Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 55A2F6B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 16:49:34 -0500 (EST)
Date: Tue, 20 Nov 2012 13:49:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled
Message-Id: <20121120134932.055bc192.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 Nov 2012 17:44:34 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> While profiling numa/core v16 with cgroup_disable=memory on the command 
> line, I noticed mem_cgroup_count_vm_event() still showed up as high as 
> 0.60% in perftop.
> 
> This occurs because the function is called extremely often even when memcg 
> is disabled.
> 
> To fix this, inline the check for mem_cgroup_disabled() so we avoid the 
> unnecessary function call if memcg is disabled.
> 
> ...
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -181,7 +181,14 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
>  
> -void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> +void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
> +static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
> +					     enum vm_event_item idx)
> +{
> +	if (mem_cgroup_disabled() || !mm)
> +		return;
> +	__mem_cgroup_count_vm_event(mm, idx);
> +}

Does the !mm case occur frequently enough to justify inlining it, or
should that test remain out-of-line?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
