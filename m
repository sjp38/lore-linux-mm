Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CB69C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E2FB2238C
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:49:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E2FB2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4C526B0008; Fri, 26 Jul 2019 08:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FDB08E0003; Fri, 26 Jul 2019 08:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EBBE8E0002; Fri, 26 Jul 2019 08:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFE56B0008
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:49:36 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e9so22922098edv.18
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:49:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nNpcOEVyV3SN4a/zaMP4AC+VHbE0/ocGXO9iuI9yTyk=;
        b=a/RxqiK309XjmHb0kMhQc3irhKNySTQ2+azKq/OcRnwNSjR0Mr6X7sCbExbbEfqG2p
         BHlflXg91Wyh/ZE81ooLS0s78afOzbrFTJV63jkwWtVj5gvnOPvaDZKwXpBLI79nuYR3
         FDnS7DUZGDY79OosOb/IOXkE6rgryRbUpACNLQ44VOUd6LdkNQrwLZeK4lzq1IRElOln
         oHi+Obcy60A3g9pPIjiyC+NzT74RyVMcxblJYOmQ2MRYPfRag+pssxyC1qzv/19hRG6e
         4XiCj1E/wfIoTtY6QVXC9Lp+TdbN6VMdjX2JceEfevd3Gr8EOmB3xyTtEpuI51zXVfVe
         hRdg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXY+KqZkfk2itWiV1eNnWoJWPyfnAhY2HUpZLu+8OM7sWwKF+sb
	wmL8nF8Vb4trhAntPfgMemM90rZFuLQQeRisib0y7G8J4aPHXpo3+ycBmhw99J03YH2ImOSc3re
	AVb6jcLH+UhDwdvrf5E8fJMX4GboF3FH6zcbr5WUs+Flsv+LJL7oSX31oNsonfFA=
X-Received: by 2002:a17:906:3f91:: with SMTP id b17mr46108361ejj.74.1564145375786;
        Fri, 26 Jul 2019 05:49:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz73fpaVXRt5HAwBAVog4CJ53x4tH/KPT885wAzf7j/W3Gn4SSniYsAYF9SDausUELTvUu7
X-Received: by 2002:a17:906:3f91:: with SMTP id b17mr46108318ejj.74.1564145374930;
        Fri, 26 Jul 2019 05:49:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564145374; cv=none;
        d=google.com; s=arc-20160816;
        b=NlFpYcR1A7eDmZ/SqtZR+Rxvh7VXJ7304uesC+GP/BLYkgUaML1NTWtKTm4cYk+hPK
         vsAlsKj+hEoOGRNpT4panNqcQh4rMjJCKtZwKQ/KUaDizEnIZ51joSQyYcweT9fE2Nw2
         e5FKOEpxA0hrwsSsg+OpMZ67MhsRxxi+wsLKQAu2kNWlTe6lc+/ITZvegxSa7zVCegt1
         1o2SDt1S9YRemLGGMvsAyvt6gUEllchErN8hRzHNxrAaCKOSz9V09W8m/oi5XbXdAhx2
         kLX83slAbBt8ELp9JGCVh2ADJwtPkp9+8ESZBeFqYrRv63S7Mka8FyDD/pZd/DwPScrt
         HrYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nNpcOEVyV3SN4a/zaMP4AC+VHbE0/ocGXO9iuI9yTyk=;
        b=QXpo0wRlanMjYklofkTu5q7YfSm1PJK52sVoCmSibS0GZkllG5YcKt0PNBVRXn6L9c
         2u4nca3+hJMdXEs0asljIvOGL21TRUhyDzzvKt3RJcCH6Mwc4r9wNR8IPNlkK6MwdCxS
         HNbswk7pSOpqOOI6FtaP0ivzjgHKWOz5181QuVBE9MmdTi2MVCEzAhVvcW9PrRznILFZ
         ssJbdvz4avc7EY4uOUg81c4q/JDyDS/tgysGZ1FRzms+ej/mfnFNNGHOhyWmvkaIu9rQ
         6CeJO09PP7VfWvyftwtaEmSXh5KG3l0JKJXPL3JJxkyOHSzoyvnx0cMl8Za4UxLM73EV
         Mf5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p16si11681659ejr.358.2019.07.26.05.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 05:49:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3C11AAFE4;
	Fri, 26 Jul 2019 12:49:34 +0000 (UTC)
Date: Fri, 26 Jul 2019 14:49:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
Subject: Re: [PATCH v2] mm: memcontrol: fix use after free in
 mem_cgroup_iter()
Message-ID: <20190726124933.GN6142@dhcp22.suse.cz>
References: <20190726021247.16162-1-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726021247.16162-1-miles.chen@mediatek.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 10:12:47, Miles Chen wrote:
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

Thanks for the write up. This is really useful.

> To avoid this, we should also invalidate root_mem_cgroup.nodeinfo.iter in
> invalidate_reclaim_iterators().

I am sorry, I didn't get to comment an earlier version but I am
wondering whether it makes more sense to do and explicit invalidation.

[...]
> +static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> +{
> +	struct mem_cgroup *memcg = dead_memcg;
> +	int invalidate_root = 0;
> +
> +	for (; memcg; memcg = parent_mem_cgroup(memcg))
> +		__invalidate_reclaim_iterators(memcg, dead_memcg);

	/* here goes your comment */
	if (!dead_memcg->use_hierarchy)
		__invalidate_reclaim_iterators(root_mem_cgroup,	dead_memcg);
> +
> +}

Other than that the patch looks good to me.

Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs

