Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7F86B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 12:58:26 -0500 (EST)
Received: by wesu56 with SMTP id u56so34952171wes.10
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:58:25 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id jo3si23470006wjc.166.2015.03.02.09.58.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 09:58:24 -0800 (PST)
Received: by wghl18 with SMTP id l18so35056732wgh.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 09:58:24 -0800 (PST)
Date: Mon, 2 Mar 2015 18:58:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] memcg: disable hierarchy support if bound to the legacy
 cgroup hierarchy
Message-ID: <20150302175821.GA18345@dhcp22.suse.cz>
References: <1425317939-13305-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425317939-13305-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 02-03-15 12:38:59, Johannes Weiner wrote:
> From: Vladimir Davydov <vdavydov@parallels.com>
> 
> If the memory cgroup controller is initially mounted in the scope of the
> default cgroup hierarchy and then remounted to a legacy hierarchy, it
> will still have hierarchy support enabled, which is incorrect. We should
> disable hierarchy support if bound to the legacy cgroup hierarchy.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

I had this one on the radar but I wasn't sure about the first cgroup
part so I haven't acked it. Once Tejun picked it up this one is good as
well.

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> Andrew, could you please pick this up for 4.0?  I don't think it's
> urgent enough for -stable, though.  Thanks!
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0c86945bcc9a..68d4890fc4bd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5238,7 +5238,9 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
>  	 * on for the root memcg is enough.
>  	 */
>  	if (cgroup_on_dfl(root_css->cgroup))
> -		mem_cgroup_from_css(root_css)->use_hierarchy = true;
> +		root_mem_cgroup->use_hierarchy = true;
> +	else
> +		root_mem_cgroup->use_hierarchy = false;
>  }
>  
>  static u64 memory_current_read(struct cgroup_subsys_state *css,
> -- 
> 2.3.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
