Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCF0C6B03FD
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 04:49:28 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n78so6660742lfi.4
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:49:28 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id r191si615264lff.286.2017.04.06.01.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 01:49:27 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id r36so3072722lfi.0
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:49:26 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:49:24 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 2/4] mm: memcontrol: re-use global VM event enum
Message-ID: <20170406084923.GB2268@esperanza>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
 <20170404220148.28338-2-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170404220148.28338-2-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Apr 04, 2017 at 06:01:46PM -0400, Johannes Weiner wrote:
> The current duplication is a high-maintenance mess, and it's painful
> to add new items.
> 
> This increases the size of the event array, but we'll eventually want
> most of the VM events tracked on a per-cgroup basis anyway.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Although the increase in the mem_cgroup struct introduced by this patch
looks scary, I agree this is a reasonable step toward unification of
vmstat, as most vm_even_item entries do make sense to be accounted per
cgroup as well.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

> @@ -608,9 +601,9 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>  
>  	/* pagein of a big page is an event. So, ignore page size */
>  	if (nr_pages > 0)
> -		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
> +		__this_cpu_inc(memcg->stat->events[PGPGIN]);
>  	else {
> -		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
> +		__this_cpu_inc(memcg->stat->events[PGPGOUT]);
>  		nr_pages = -nr_pages; /* for event */
>  	}

AFAIR this doesn't exactly match system-wide PGPGIN/PGPGOUT: they are
supposed to account only paging events involving IO while currently they
include faulting in zero pages and zapping a process address space.
Probably, this should be revised before rolling out to cgroup v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
