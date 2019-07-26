Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DBB9C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:20:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FEEE229F9
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 10:20:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FEEE229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E7046B0003; Fri, 26 Jul 2019 06:20:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 872A66B0005; Fri, 26 Jul 2019 06:20:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7136B8E0002; Fri, 26 Jul 2019 06:20:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3646D6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 06:20:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k20so32707958pgg.15
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:20:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=sjUX4bETfzwcBLKRwAE+p0hTj1238gzoCvsdlTQUumY=;
        b=CJ8K1qvytH13hmwFf35PeVl018aRUoBOGJaSozJQG7Q9/mvp2++peh6FhV4XwBPBdG
         PHoZQAFkYAi+rW6RZ55pU0OQZCFa6qVR7cqNyBH4oE+nHHpUlhps7ys1P906npmtoadB
         tChNICGa/MEyxFQxOo6UtlpKEqaLDDRPEE3XF4QZBEblOWUGIv7tS8kRHem7tpWI6Hao
         fHgfQX9XmvZi1vY8Y8XzoK7dFXPHTP1KsIq/lJmKyvjkmPLxkVwiLY3BnbY9XaBBlzzS
         l9Ozm6j+Lc2rVLsJ3Opf4/MgsDip5+AD/oDe6NLyGvDeD8NEhd/z4D+vbc1dXz8PNq9G
         SlJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-Gm-Message-State: APjAAAWFFHkCqK6gY5DQ3JmLeoulEsDyH0j4f9BiQeVBLp3Q6E76YLwq
	katwMzD4b42V6ZcCd9LhOq+qt9GTF5IGIOzvrzxNHpbZ3I/+CJImdQ9cYok9ifUTjxX5bmjJ2a7
	UeGYOYh+jalGYdAjAe5qF180x6uZO/nMZuDzBBBPBHVbNWOJG4jinXls1DBPna9xK6Q==
X-Received: by 2002:a62:2582:: with SMTP id l124mr21336462pfl.43.1564136429789;
        Fri, 26 Jul 2019 03:20:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWA+/oQjMlFA5qW7vw2gYYHzlkCQiL6jMhxpF0z7a783ak3FLy2gHws3QR7simpDwUWhi+
X-Received: by 2002:a62:2582:: with SMTP id l124mr21336405pfl.43.1564136428861;
        Fri, 26 Jul 2019 03:20:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564136428; cv=none;
        d=google.com; s=arc-20160816;
        b=eQsvhgFYG5s/5dLg20v3BrKcwU74GYoAxwmEYn9+zeLywRY9hoDV1NZzBqIluZ7mnp
         XAbxaZflHWq7rj9dbEO/FoQTbm1rdZTVuy8uX3yLnHMSGOw/EM/HwAAtamW1njNHhCXi
         36LcyFNjAt3c5HGC58H2npg/Pecx/z4sPUqzTLMMuVoTwmslDK5cj2rtFX7tcuTAVIkF
         xBXIXpmFpuhBR6XseieIh/ow6N2PY3g4gurbCAwxsI6oiIdJ6Vv3SRlJ0FM+F+yTqEr1
         iN5mb1u2QyMB7Kr+NMW2JMCY4PHSVMSZ8sOBgiSR68Kl3kSApr6lAEGDYdxYiD2JWiPA
         cyOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=sjUX4bETfzwcBLKRwAE+p0hTj1238gzoCvsdlTQUumY=;
        b=Vp85gvpA/V7XXchKos8YTkbzvMjOEIdwNm064nxvFy1ImhQSFydiz7Kgtb7QwAGhFx
         yUVxBhI+eW+iFDDohm+fzfe3M7vJmrrwRy6noC0pjzN1ZhBMgUQHscMeuSpGOb5v6jw+
         fBJlSWw4o1NV7DBiE24kdi7FHDIQpzBmaPxs4PfD00wNnDmx6xwuAMsmjKDAqasevqXW
         AbPakxIC4aQj405walXmgk3z0sU0qiSgD7RRDpsA7QxZhVCHXir85aK0KJ4lB0U88k9q
         W0GOZ9pBMjSJYZGUI19wYAj7MJxJ0mnx4LMCQIHeJd+OeBfll5Rq1ULtvG/2wl2z5Pnu
         uCaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTP id n2si455954pga.426.2019.07.26.03.20.28
        for <linux-mm@kvack.org>;
        Fri, 26 Jul 2019 03:20:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mediatek.com
X-UUID: ff942d5feab1455fb029b5ee5719ae32-20190726
X-UUID: ff942d5feab1455fb029b5ee5719ae32-20190726
Received: from mtkexhb01.mediatek.inc [(172.21.101.102)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(Cellopoint E-mail Firewall v4.1.10 Build 0707 with TLS)
	with ESMTP id 1360154933; Fri, 26 Jul 2019 18:20:21 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs07n2.mediatek.inc (172.21.101.141) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 26 Jul 2019 18:20:23 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 26 Jul 2019 18:20:23 +0800
Message-ID: <1564136423.15330.4.camel@mtkswgap22>
Subject: Re: [PATCH v2] mm: memcontrol: fix use after free in
 mem_cgroup_iter()
From: Miles Chen <miles.chen@mediatek.com>
To: Johannes Weiner <hannes@cmpxchg.org>
CC: Michal Hocko <mhocko@kernel.org>, Vladimir Davydov
	<vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-mediatek@lists.infradead.org>,
	<wsd_upstream@mediatek.com>
Date: Fri, 26 Jul 2019 18:20:23 +0800
In-Reply-To: <20190726021247.16162-1-miles.chen@mediatek.com>
References: <20190726021247.16162-1-miles.chen@mediatek.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

I post patch v2 with proper comment you mentioned.
(I am not sure if I can copy your acked-by to patch v2 directly)

Miles

On Fri, 2019-07-26 at 10:12 +0800, Miles Chen wrote:
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
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Miles Chen <miles.chen@mediatek.com>
> ---
>  mm/memcontrol.c | 38 ++++++++++++++++++++++++++++----------
>  1 file changed, 28 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdbb7a84cb6e..09f2191f113b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1130,26 +1130,44 @@ void mem_cgroup_iter_break(struct mem_cgroup *root,
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
> +/*
> + * When cgruop1 non-hierarchy mode is used, parent_mem_cgroup() does
> + * not walk all the way up to the cgroup root (root_mem_cgroup). So
> + * we have to handle dead_memcg from cgroup root separately.
> + */
> +static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> +{
> +	struct mem_cgroup *memcg = dead_memcg;
> +	int invalidate_root = 0;
> +
> +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> +		__invalidate_reclaim_iterators(memcg, dead_memcg);
> +		if (memcg == root_mem_cgroup)
> +			invalidate_root = 1;
> +	}
> +
> +	if (!invalidate_root)
> +		__invalidate_reclaim_iterators(root_mem_cgroup, dead_memcg);
> +}
> +
>  /**
>   * mem_cgroup_scan_tasks - iterate over tasks of a memory cgroup hierarchy
>   * @memcg: hierarchy root


