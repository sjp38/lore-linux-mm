Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 90DFF82F7D
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 18:15:28 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id q3so103079258pav.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:15:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r2si14047033pfr.12.2015.12.22.15.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 15:15:28 -0800 (PST)
Date: Tue, 22 Dec 2015 15:15:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: memcontrol: reign in the CONFIG space madness
Message-Id: <20151222151527.b4fd06da45d5c86d193c773d@linux-foundation.org>
In-Reply-To: <20151222151138.0c35816e53b0f0ad940568bb@linux-foundation.org>
References: <1449863653-6546-1-git-send-email-hannes@cmpxchg.org>
	<1449863653-6546-2-git-send-email-hannes@cmpxchg.org>
	<20151212163332.GC28521@esperanza>
	<20151212172057.GA7997@cmpxchg.org>
	<20151222151138.0c35816e53b0f0ad940568bb@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, 22 Dec 2015 15:11:38 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> What I have is

And after a bit of reject resolution in
mm-memcontrol-clean-up-alloc-online-offline-free-functions.patch we
have


static void mem_cgroup_css_free(struct cgroup_subsys_state *css)
{
	struct mem_cgroup *memcg = mem_cgroup_from_css(css);

	if (cgroup_subsys_on_dfl(memory_cgrp_subsys) && !cgroup_memory_nosocket)
		static_branch_dec(&memcg_sockets_enabled_key);

	vmpressure_cleanup(&memcg->vmpressure);
	cancel_work_sync(&memcg->high_work);
	mem_cgroup_remove_from_trees(memcg);
	memcg_free_kmem(memcg);

	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys) && memcg->tcpmem_active)
		static_branch_dec(&memcg_sockets_enabled_key);

	mem_cgroup_free(memcg);
}

code looks a bit strange.  Can we move the static_branch_dec's together
and run cgroup_subsys_on_dfl just once?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
