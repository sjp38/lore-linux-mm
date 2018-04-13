Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4ECC6B0009
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 04:55:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t123so893224wmt.8
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 01:55:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r29si1180374edi.39.2018.04.13.01.55.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 01:55:55 -0700 (PDT)
Date: Fri, 13 Apr 2018 10:55:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180413085553.GF17484@dhcp22.suse.cz>
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 12-04-18 17:52:04, Kirill Tkhai wrote:
[...]
> @@ -4471,6 +4477,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>  
>  	return &memcg->css;
>  fail:
> +	mem_cgroup_id_remove(memcg);
>  	mem_cgroup_free(memcg);
>  	return ERR_PTR(-ENOMEM);
>  }

The only path which jumps to fail: here (in the current mmotm tree) is 
	error = memcg_online_kmem(memcg);
	if (error)
		goto fail;

AFAICS and the only failure path in memcg_online_kmem
	memcg_id = memcg_alloc_cache_id();
	if (memcg_id < 0)
		return memcg_id;

I am not entirely clear on memcg_alloc_cache_id but it seems we do clean
up properly. Or am I missing something?
-- 
Michal Hocko
SUSE Labs
