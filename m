Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D794C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 598622087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 07:27:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 598622087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D97D28E0005; Tue, 30 Jul 2019 03:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D49D98E0002; Tue, 30 Jul 2019 03:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C11958E0005; Tue, 30 Jul 2019 03:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA9E8E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 03:27:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so39781836edt.4
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 00:27:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nrBxUHmgl8x1VGgMHHpPsiWYj4tSkoM26u6CTSy92ZI=;
        b=I3CjNDUtj0Pd8Fnelqph/VgBw4EJGFr4knZGE4X/g9ywDXWzaZLlp+0z6OGMHRNqfW
         i7z02g0oOElAzBTW6rIKjuPxu55bHP0u7ZpA5dVCmp61Q3Yebfy56c1cA9LOBTZF56Qw
         6ltF0y1imkaCx2T9XqewysdFnFwOhEeaBKQXLrTl+JTtYzTqHAp5S4sxfErgR0UXS0el
         NCqgEQkplMUlKzw93gzNu17p+cYxlb2fJL6EKd3ps9Xkp/fbo3W0zaCCAoW60Cp3HTdV
         d9um93yBj1KKCqFZZEW8/qgyHz9pVObKtLNjLwieSP0Er/JLMojm6f/RIGX9To9etQDH
         ILwA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX2FbWblN+dS5wdaOgjoIBm1hSgVTUcIp03ext+PLxebcWhVkuU
	XQnHTbPAfBY40/qBaNiGfC6zGEXKeRsONvtNve8WIs3es5xdpql6T8aWw2aW8hXkqUtS6JRdoHr
	zpexQuIPa4hTlvC8uIgqnzWrmYL3kZHVHzsKWQaU7JZsYMQPYHjAIiGR39b9ZyF4=
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr28431148eju.299.1564471646999;
        Tue, 30 Jul 2019 00:27:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhInbaUoAHDZ38T52zJDTPzEpgfJL/KVqVcAx8vbcNFVbEwKZKaMHjfGu1khFjUx6I3sEO
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr28431102eju.299.1564471646045;
        Tue, 30 Jul 2019 00:27:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564471646; cv=none;
        d=google.com; s=arc-20160816;
        b=DAvlZVFU0mnrD8a4XfuQLc+XXIxueekkcgdiTi5Q+fkt19h89zvV2Zdrs/j+c2JhXf
         N3DYCL/0oTSvR4ai29zBweqsXHDKMrpt9euy4iTu98Npo1SeJ1FrA81QTI30wdtvzsYh
         FPVFgLffz17fwx/orkkDraRgk7OI3xHwrdUVWW3Nv64DjPMBuY22dfkwSCcHEW1PQaL7
         RVPJuZzCe7hhQRo+cClKxNEtCky0gkUgciLWY4jtMRmck2fxAA3KRdM6ouMYNFeKQOlF
         vtwHu8mf6E0779TxwwnRqPBUGavgRG2mtFUpV/qY2Pq4TmPdwdqgP8M8ptcp41JKAcUc
         OlYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nrBxUHmgl8x1VGgMHHpPsiWYj4tSkoM26u6CTSy92ZI=;
        b=DCMviCv+mkIYsgOom3KGsviV4cYIVVuPx8Yd9vJfH/Txnkln0WfM7P9C7nzNEoPcgz
         37jUNLxUA3L5+A1KKlAAU67Sr5D11OWihofSmCYto2PqBFHZGf/Ht4PPoBD6B8b4y2lN
         S8dAvYiqg3d12McsplhVr/oi2YyTuK+eE3Omd4+g9ZVj6vVofkN6TifVp07Xh6C9ERAL
         xhMgUbw2lD7BM/GIUqjsSYlmWnrkV1eyrTwld6NLlg4lwLz0vDI+AwBgTnaBQW7j7gb6
         H8SABtQ7njXgk6WO3/chOYiV9JMaryG/qbPTzb5APHNXWu59Sche/xaanpJQm8cFHDw7
         FsBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e24si18425353ede.59.2019.07.30.00.27.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 00:27:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A31BAFBB;
	Tue, 30 Jul 2019 07:27:25 +0000 (UTC)
Date: Tue, 30 Jul 2019 09:27:24 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: memcontrol: fix use after free in
 mem_cgroup_iter()
Message-ID: <20190730072724.GM9330@dhcp22.suse.cz>
References: <20190730015729.4406-1-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730015729.4406-1-miles.chen@mediatek.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Andrew to pick up the patch]

On Tue 30-07-19 09:57:29, Miles Chen wrote:
> This patch is sent to report an use after free in mem_cgroup_iter()
> after merging commit: be2657752e9e "mm: memcg: fix use after free in
> mem_cgroup_iter()".
> 
> I work with android kernel tree (4.9 & 4.14), and the commit:
> be2657752e9e "mm: memcg: fix use after free in mem_cgroup_iter()" has
> been merged to the trees. However, I can still observe use after free
> issues addressed in the commit be2657752e9e.
> (on low-end devices, a few times this month)
> 
> backtrace:
> 	css_tryget <- crash here
> 	mem_cgroup_iter
> 	shrink_node
> 	shrink_zones
> 	do_try_to_free_pages
> 	try_to_free_pages
> 	__perform_reclaim
> 	__alloc_pages_direct_reclaim
> 	__alloc_pages_slowpath
> 	__alloc_pages_nodemask
> 
> To debug, I poisoned mem_cgroup before freeing it:
> 
> static void __mem_cgroup_free(struct mem_cgroup *memcg)
> 	for_each_node(node)
> 	free_mem_cgroup_per_node_info(memcg, node);
> 	free_percpu(memcg->stat);
> +       /* poison memcg before freeing it */
> +       memset(memcg, 0x78, sizeof(struct mem_cgroup));
> 	kfree(memcg);
> }
> 
> The coredump shows the position=0xdbbc2a00 is freed.
> 
> (gdb) p/x ((struct mem_cgroup_per_node *)0xe5009e00)->iter[8]
> $13 = {position = 0xdbbc2a00, generation = 0x2efd}
> 
> 0xdbbc2a00:     0xdbbc2e00      0x00000000      0xdbbc2800      0x00000100
> 0xdbbc2a10:     0x00000200      0x78787878      0x00026218      0x00000000
> 0xdbbc2a20:     0xdcad6000      0x00000001      0x78787800      0x00000000
> 0xdbbc2a30:     0x78780000      0x00000000      0x0068fb84      0x78787878
> 0xdbbc2a40:     0x78787878      0x78787878      0x78787878      0xe3fa5cc0
> 0xdbbc2a50:     0x78787878      0x78787878      0x00000000      0x00000000
> 0xdbbc2a60:     0x00000000      0x00000000      0x00000000      0x00000000
> 0xdbbc2a70:     0x00000000      0x00000000      0x00000000      0x00000000
> 0xdbbc2a80:     0x00000000      0x00000000      0x00000000      0x00000000
> 0xdbbc2a90:     0x00000001      0x00000000      0x00000000      0x00100000
> 0xdbbc2aa0:     0x00000001      0xdbbc2ac8      0x00000000      0x00000000
> 0xdbbc2ab0:     0x00000000      0x00000000      0x00000000      0x00000000
> 0xdbbc2ac0:     0x00000000      0x00000000      0xe5b02618      0x00001000
> 0xdbbc2ad0:     0x00000000      0x78787878      0x78787878      0x78787878
> 0xdbbc2ae0:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2af0:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b00:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b10:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b20:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b30:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b40:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b50:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b60:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b70:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2b80:     0x78787878      0x78787878      0x00000000      0x78787878
> 0xdbbc2b90:     0x78787878      0x78787878      0x78787878      0x78787878
> 0xdbbc2ba0:     0x78787878      0x78787878      0x78787878      0x78787878
> 
> In the reclaim path, try_to_free_pages() does not setup
> sc.target_mem_cgroup and sc is passed to do_try_to_free_pages(), ...,
> shrink_node().
> 
> In mem_cgroup_iter(), root is set to root_mem_cgroup because
> sc->target_mem_cgroup is NULL.
> It is possible to assign a memcg to root_mem_cgroup.nodeinfo.iter in
> mem_cgroup_iter().
> 
> 	try_to_free_pages
> 		struct scan_control sc = {...}, target_mem_cgroup is 0x0;
> 	do_try_to_free_pages
> 	shrink_zones
> 	shrink_node
> 		 mem_cgroup *root = sc->target_mem_cgroup;
> 		 memcg = mem_cgroup_iter(root, NULL, &reclaim);
> 	mem_cgroup_iter()
> 		if (!root)
> 			root = root_mem_cgroup;
> 		...
> 
> 		css = css_next_descendant_pre(css, &root->css);
> 		memcg = mem_cgroup_from_css(css);
> 		cmpxchg(&iter->position, pos, memcg);
> 
> My device uses memcg non-hierarchical mode.
> When we release a memcg: invalidate_reclaim_iterators() reaches only
> dead_memcg and its parents. If non-hierarchical mode is used,
> invalidate_reclaim_iterators() never reaches root_mem_cgroup.
> 
> static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> {
> 	struct mem_cgroup *memcg = dead_memcg;
> 
> 	for (; memcg; memcg = parent_mem_cgroup(memcg)
> 	...
> }
> 
> So the use after free scenario looks like:
> 
> CPU1						CPU2
> 
> try_to_free_pages
> do_try_to_free_pages
> shrink_zones
> shrink_node
> mem_cgroup_iter()
>     if (!root)
>     	root = root_mem_cgroup;
>     ...
>     css = css_next_descendant_pre(css, &root->css);
>     memcg = mem_cgroup_from_css(css);
>     cmpxchg(&iter->position, pos, memcg);
> 
> 					invalidate_reclaim_iterators(memcg);
> 					...
> 					__mem_cgroup_free()
> 						kfree(memcg);
> 
> try_to_free_pages
> do_try_to_free_pages
> shrink_zones
> shrink_node
> mem_cgroup_iter()
>     if (!root)
>     	root = root_mem_cgroup;
>     ...
>     mz = mem_cgroup_nodeinfo(root, reclaim->pgdat->node_id);
>     iter = &mz->iter[reclaim->priority];
>     pos = READ_ONCE(iter->position);
>     css_tryget(&pos->css) <- use after free
> 
> To avoid this, we should also invalidate root_mem_cgroup.nodeinfo.iter in
> invalidate_reclaim_iterators().
> 
> Change since v1:
> Add a comment to explain why we need to handle root_mem_cgroup separately.
> Rename invalid_root to invalidate_root.
> 
> Change since v2:
> Add fix tag
> 
> Change since v3:
> Remove confusing 'invalidate_root', make the code easier to read
> 
> Fixes: 5ac8fb31ad2e ("mm: memcontrol: convert reclaim iterator to simple css refcounting")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: Miles Chen <miles.chen@mediatek.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 39 +++++++++++++++++++++++++++++----------
>  1 file changed, 29 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdbb7a84cb6e..8a2a2d5cfc26 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1130,26 +1130,45 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
>  		css_put(&prev->css);
>  }
>  
> -static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> +static void __invalidate_reclaim_iterators(struct mem_cgroup *from,
> +					struct mem_cgroup *dead_memcg)
>  {
> -	struct mem_cgroup *memcg = dead_memcg;
>  	struct mem_cgroup_reclaim_iter *iter;
>  	struct mem_cgroup_per_node *mz;
>  	int nid;
>  	int i;
>  
> -	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> -		for_each_node(nid) {
> -			mz = mem_cgroup_nodeinfo(memcg, nid);
> -			for (i = 0; i <= DEF_PRIORITY; i++) {
> -				iter = &mz->iter[i];
> -				cmpxchg(&iter->position,
> -					dead_memcg, NULL);
> -			}
> +	for_each_node(nid) {
> +		mz = mem_cgroup_nodeinfo(from, nid);
> +		for (i = 0; i <= DEF_PRIORITY; i++) {
> +			iter = &mz->iter[i];
> +			cmpxchg(&iter->position,
> +				dead_memcg, NULL);
>  		}
>  	}
>  }
>  
> +static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> +{
> +	struct mem_cgroup *memcg = dead_memcg;
> +	struct mem_cgroup *last;
> +
> +	do {
> +		__invalidate_reclaim_iterators(memcg, dead_memcg);
> +		last = memcg;
> +	} while (memcg = parent_mem_cgroup(memcg));
> +
> +	/*
> +	 * When cgruop1 non-hierarchy mode is used,
> +	 * parent_mem_cgroup() does not walk all the way up to the
> +	 * cgroup root (root_mem_cgroup). So we have to handle
> +	 * dead_memcg from cgroup root separately.
> +	 */
> +	if (last != root_mem_cgroup)
> +		__invalidate_reclaim_iterators(root_mem_cgroup,
> +						dead_memcg);
> +}
> +
>  /**
>   * mem_cgroup_scan_tasks - iterate over tasks of a memory cgroup hierarchy
>   * @memcg: hierarchy root
> -- 
> 2.18.0

-- 
Michal Hocko
SUSE Labs

