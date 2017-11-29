Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA7FE6B0033
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 19:38:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e69so939003pgc.15
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 16:38:12 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 9si349110pfq.5.2017.11.28.16.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 16:38:11 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] mm, memcg: fix mem_cgroup_swapout() for THPs
References: <20171128161941.20931-1-shakeelb@google.com>
Date: Wed, 29 Nov 2017 08:38:08 +0800
In-Reply-To: <20171128161941.20931-1-shakeelb@google.com> (Shakeel Butt's
	message of "Tue, 28 Nov 2017 08:19:41 -0800")
Message-ID: <87o9nlc427.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Huang Ying <ying.huang@intel.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, stable@vger.kernel.org

Shakeel Butt <shakeelb@google.com> writes:

> The commit d6810d730022 ("memcg, THP, swap: make mem_cgroup_swapout()
> support THP") changed mem_cgroup_swapout() to support transparent huge
> page (THP). However the patch missed one location which should be
> changed for correctly handling THPs. The resulting bug will cause the
> memory cgroups whose THPs were swapped out to become zombies on
> deletion.

Good catch!  Thanks a lot for fixing!

Best Regards,
Huang, Ying

> Fixes: d6810d730022 ("memcg, THP, swap: make mem_cgroup_swapout() support THP")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: stable@vger.kernel.org
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 50e6906314f8..ac2ffd5e02b9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6044,7 +6044,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
>  	memcg_check_events(memcg, page);
>  
>  	if (!mem_cgroup_is_root(memcg))
> -		css_put(&memcg->css);
> +		css_put_many(&memcg->css, nr_entries);
>  }
>  
>  /**

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
