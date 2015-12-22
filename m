Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id A195D82F7D
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 18:38:34 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p187so126263536wmp.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:38:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v191si46693433wmd.52.2015.12.22.15.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 15:38:33 -0800 (PST)
Date: Tue, 22 Dec 2015 18:38:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Message-ID: <20151222233823.GA28111@cmpxchg.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
 <1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
 <20151212163332.GC28521@esperanza>
 <20151212172057.GA7997@cmpxchg.org>
 <20151222151138.0c35816e53b0f0ad940568bb@linux-foundation.org>
 <20151222151527.b4fd06da45d5c86d193c773d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151222151527.b4fd06da45d5c86d193c773d@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Dec 22, 2015 at 03:15:27PM -0800, Andrew Morton wrote:
> On Tue, 22 Dec 2015 15:11:38 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > What I have is
> 
> And after a bit of reject resolution in
> mm-memcontrol-clean-up-alloc-online-offline-free-functions.patch we
> have
> 
> 
> static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
> {
> 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> 
> 	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
> 		static_branch_dec(&memcg_sockets_enabled_key);
> 
> 	vmpressure_cleanup(&memcg->vmpressure);
> 	cancel_work_sync(&memcg->high_work);
> 	mem_cgroup_remove_from_trees(memcg);
> 	memcg_free_kmem(memcg);
> 
> 	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
> 		static_branch_dec(&memcg_sockets_enabled_key);
> 
> 	mem_cgroup_free(memcg);
> }
> 
> code looks a bit strange.  Can we move the static_branch_dec's together
> and run cgroup_subsys_on_dfl just once?

Thanks for fixing it up. I think we can at least put the branches next
to each other. Here is what I have in my local tree:

static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
{
	struct mem_cgroup *memcg = mem_cgroup_from_css(css);

	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
		static_branch_dec(&memcg_sockets_enabled_key);

	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
		static_branch_dec(&memcg_sockets_enabled_key);

	vmpressure_cleanup(&memcg->vmpressure);
	cancel_work_sync(&memcg->high_work);
	mem_cgroup_remove_from_trees(memcg);
	memcg_free_kmem(memcg);
	mem_cgroup_free(memcg);
}

However, I don't think turning it into this would be an improvement:

	if (cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
		if (!cgroup_memory_nosocket)
			static_branch_dec(&memcg_sockets_enabled_key);
	} else if (memcg->tcpmem_active) {
		static_branch_dec(&memcg_sockets_enabled_key);
	}

Plus, I'm a little worried that conflating cgroup and cgroup2 blocks
will get us into trouble. Yeah, that code looks a little unusual, but
I can't help but think it's easier to follow the code flow for one
particular mode when the jump labels are always explicit. Then the
brain can easily pattern-match and ignore blocks of the other mode.
It doesn't work the same when we hide keywords in implicit else ifs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
