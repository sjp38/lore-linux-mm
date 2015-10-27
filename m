Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id DD09582F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 12:23:54 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so167399355wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 09:23:54 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z19si31010840wij.114.2015.10.27.09.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 09:23:53 -0700 (PDT)
Date: Tue, 27 Oct 2015 09:23:31 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Fix thresholds for 32b architectures.
Message-ID: <20151027162331.GA7749@cmpxchg.org>
References: <1445942234-11175-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445942234-11175-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fb.com>, Ben Hutchings <ben@decadent.org.uk>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org

On Tue, Oct 27, 2015 at 11:37:14AM +0100, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 424cdc141380 ("memcg: convert threshold to bytes") has fixed a
> regression introduced by 3e32cb2e0a12 ("mm: memcontrol: lockless page
> counters") where thresholds were silently converted to use page units
> rather than bytes when interpreting the user input.
> 
> The fix is not complete, though, as properly pointed out by Ben
> Hutchings during stable backport review. The page count is converted
> to bytes but unsigned long is used to hold the value which would
> be obviously not sufficient for 32b systems with more than 4G
> thresholds. The same applies to usage as taken from mem_cgroup_usage
> which might overflow.
> 
> Let's remove this bytes vs. pages internal tracking differences and
> handle thresholds in page units internally. Chage mem_cgroup_usage()
> to return the value in page units and revert 424cdc141380 because this
> should be sufficient for the consistent handling.
> mem_cgroup_read_u64 as the only users of mem_cgroup_usage outside of
> the threshold handling code is converted to give the proper in bytes
> result. It is doing that already for page_counter output so this is
> more consistent as well.
> 
> The value presented to the userspace is still in bytes units.
> 
> Fixes: 424cdc141380 ("memcg: convert threshold to bytes")
> Fixes: 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
> CC: stable@vger.kernel.org
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> +++ b/mm/memcontrol.c
> @@ -2802,7 +2802,7 @@ static unsigned long tree_stat(struct mem_cgroup *memcg,
>  	return val;
>  }
>  
> -static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
> +static inline unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  {
>  	u64 val;

Minor nit, but this should probably be unsigned long now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
