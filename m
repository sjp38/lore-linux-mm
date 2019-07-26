Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 009DDC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:55:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A875521871
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:55:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A875521871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F11A6B0005; Fri, 26 Jul 2019 08:55:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A1888E0003; Fri, 26 Jul 2019 08:55:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B7E48E0002; Fri, 26 Jul 2019 08:55:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E19956B0005
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:55:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20so34082872edr.15
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:55:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=h911+WRuILe0IZojgwiXEDQs/EpQSYjObJAEx5dM7zE=;
        b=X3e7AQNT/pcBrB66sZByhU4PxKncSIsY5W1h7FQ/F0FIU4Lq37lWBdfsbfS9ixiLqp
         7MakzsunGZCzLmkTABYJZlX8oU5L+hCSaQcZY1pjwhhnAh+MWG1dKayW9Q3/mBQwEMq6
         SE8HRsB8fFfd8rvNd3Fo0Dk9uBW/UQhRmuvt6syrsBrgUSZl5wsXFuGPGXEwMajvhDdV
         iD7zjUih7J+GmalLMGSC++MKzfxW2otppATAat8ClOf9e7/XPlxUDVJONnqXv8p+Iczh
         wkDAgAA8vhjT7sjW91w4ivz1lI1yCUQUWoCI6p6kt7aJGY4y2mmpUFwtCKS4ZS0mMFb6
         CWTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXvW2RSH7kPtXH5HU+/lpKw2LfYJ4zoOYKKNs9IkvckBs8mpLcq
	RfIyIaGXqymHTkEqnlsFii2DiDzKoQ/47SZ6CQCoqF079w/Hp9CwVcOrB6bHCrPKS6ju15Yo9y3
	knPkhewz1hOfEEh4MVfhrMl9FPaVJ/t+xog8D3aWyDc4gz+Cc7kWpsIbQBZ/O+N0=
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr71624224ejb.265.1564145735458;
        Fri, 26 Jul 2019 05:55:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDB19i3owTA3n3EZnpJIZ3Q2IkQhhrZnYOClytbbMNS8ecw/N8yoMjTRx/DbxVmuTNEQhU
X-Received: by 2002:a17:906:e241:: with SMTP id gq1mr71624178ejb.265.1564145734631;
        Fri, 26 Jul 2019 05:55:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564145734; cv=none;
        d=google.com; s=arc-20160816;
        b=VQSXMVI1O9RgHZE+d0WqGKavMWTG3gIiNEFL8hDSdzsXH5ElfyBbNByoFekfnBb1d6
         qUJ05mfyzHulxtpS2Ed6RSErx5LnAOyWkAnBPAhD9rSasPLUkLLRMs0CaWvqkGs6OrqN
         qnixw4Y0utprp0EbhWFAtoIZO+vmdJpVvexOBNvD3+TgZNzIQM4xqjpG/kdLd/N3nsf+
         neiXOiCzMtgmoJ3n45VOLVN1ngy4yTl3L4qwYrOWPUWQ8JJYI8tMRVeIvuxQsj8Ml4he
         w1kYqT9LoPC109keQxCdKMRocCdrb3Q06OVDTSYkkntpCbtLeRAzEgEFgfUJ4FKCSCv0
         Rf1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=h911+WRuILe0IZojgwiXEDQs/EpQSYjObJAEx5dM7zE=;
        b=bC95YjCwLm/myhHOkzasinoCjOK1ZNYo9/7jlkaOevSpu6wbh35IfPqMvUNsNMWlAv
         ugSA9BmlqWree6IFhJiAYPJ/b/1LC9xnBSV5pzBPgMIaG4dTX7lZb6fXYuBm8NQJHPqC
         124fLSC/ZZBmvOFBLJfyrO5hrq3rx5CmGIKKr1d+xoPKIHfk3JMuOD15pe1p865XQFoF
         bUiyv9I8i+G8UsVF3VZFFAfzQ7xmkWJhJClLG3fBxHFOpnEyoaOr/ZJerJ6K505EUAWv
         vJ3RktjaYtHnMprSy7Z1jbgwrqg/+qb+RrnhdHvaMwOQb31NDePPNXGT5BoWPlPE3P+k
         xByA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c14si12620808ejb.99.2019.07.26.05.55.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 05:55:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id BA2EFABB2;
	Fri, 26 Jul 2019 12:55:33 +0000 (UTC)
Date: Fri, 26 Jul 2019 14:55:33 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com
Subject: Re: [PATCH v2] mm: memcontrol: fix use after free in
 mem_cgroup_iter()
Message-ID: <20190726125533.GO6142@dhcp22.suse.cz>
References: <20190726021247.16162-1-miles.chen@mediatek.com>
 <20190726124933.GN6142@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190726124933.GN6142@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-07-19 14:49:33, Michal Hocko wrote:
> On Fri 26-07-19 10:12:47, Miles Chen wrote:
> > This patch is sent to report an use after free in mem_cgroup_iter()
> > after merging commit: be2657752e9e "mm: memcg: fix use after free in
> > mem_cgroup_iter()".
> > 
> > I work with android kernel tree (4.9 & 4.14), and the commit:
> > be2657752e9e "mm: memcg: fix use after free in mem_cgroup_iter()" has
> > been merged to the trees. However, I can still observe use after free
> > issues addressed in the commit be2657752e9e.
> > (on low-end devices, a few times this month)
> > 
> > backtrace:
> > 	css_tryget <- crash here
> > 	mem_cgroup_iter
> > 	shrink_node
> > 	shrink_zones
> > 	do_try_to_free_pages
> > 	try_to_free_pages
> > 	__perform_reclaim
> > 	__alloc_pages_direct_reclaim
> > 	__alloc_pages_slowpath
> > 	__alloc_pages_nodemask
> > 
> > To debug, I poisoned mem_cgroup before freeing it:
> > 
> > static void __mem_cgroup_free(struct mem_cgroup *memcg)
> > 	for_each_node(node)
> > 	free_mem_cgroup_per_node_info(memcg, node);
> > 	free_percpu(memcg->stat);
> > +       /* poison memcg before freeing it */
> > +       memset(memcg, 0x78, sizeof(struct mem_cgroup));
> > 	kfree(memcg);
> > }
> > 
> > The coredump shows the position=0xdbbc2a00 is freed.
> > 
> > (gdb) p/x ((struct mem_cgroup_per_node *)0xe5009e00)->iter[8]
> > $13 = {position = 0xdbbc2a00, generation = 0x2efd}
> > 
> > 0xdbbc2a00:     0xdbbc2e00      0x00000000      0xdbbc2800      0x00000100
> > 0xdbbc2a10:     0x00000200      0x78787878      0x00026218      0x00000000
> > 0xdbbc2a20:     0xdcad6000      0x00000001      0x78787800      0x00000000
> > 0xdbbc2a30:     0x78780000      0x00000000      0x0068fb84      0x78787878
> > 0xdbbc2a40:     0x78787878      0x78787878      0x78787878      0xe3fa5cc0
> > 0xdbbc2a50:     0x78787878      0x78787878      0x00000000      0x00000000
> > 0xdbbc2a60:     0x00000000      0x00000000      0x00000000      0x00000000
> > 0xdbbc2a70:     0x00000000      0x00000000      0x00000000      0x00000000
> > 0xdbbc2a80:     0x00000000      0x00000000      0x00000000      0x00000000
> > 0xdbbc2a90:     0x00000001      0x00000000      0x00000000      0x00100000
> > 0xdbbc2aa0:     0x00000001      0xdbbc2ac8      0x00000000      0x00000000
> > 0xdbbc2ab0:     0x00000000      0x00000000      0x00000000      0x00000000
> > 0xdbbc2ac0:     0x00000000      0x00000000      0xe5b02618      0x00001000
> > 0xdbbc2ad0:     0x00000000      0x78787878      0x78787878      0x78787878
> > 0xdbbc2ae0:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2af0:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b00:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b10:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b20:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b30:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b40:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b50:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b60:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b70:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2b80:     0x78787878      0x78787878      0x00000000      0x78787878
> > 0xdbbc2b90:     0x78787878      0x78787878      0x78787878      0x78787878
> > 0xdbbc2ba0:     0x78787878      0x78787878      0x78787878      0x78787878
> > 
> > In the reclaim path, try_to_free_pages() does not setup
> > sc.target_mem_cgroup and sc is passed to do_try_to_free_pages(), ...,
> > shrink_node().
> > 
> > In mem_cgroup_iter(), root is set to root_mem_cgroup because
> > sc->target_mem_cgroup is NULL.
> > It is possible to assign a memcg to root_mem_cgroup.nodeinfo.iter in
> > mem_cgroup_iter().
> > 
> > 	try_to_free_pages
> > 		struct scan_control sc = {...}, target_mem_cgroup is 0x0;
> > 	do_try_to_free_pages
> > 	shrink_zones
> > 	shrink_node
> > 		 mem_cgroup *root = sc->target_mem_cgroup;
> > 		 memcg = mem_cgroup_iter(root, NULL, &reclaim);
> > 	mem_cgroup_iter()
> > 		if (!root)
> > 			root = root_mem_cgroup;
> > 		...
> > 
> > 		css = css_next_descendant_pre(css, &root->css);
> > 		memcg = mem_cgroup_from_css(css);
> > 		cmpxchg(&iter->position, pos, memcg);
> > 
> > My device uses memcg non-hierarchical mode.
> > When we release a memcg: invalidate_reclaim_iterators() reaches only
> > dead_memcg and its parents. If non-hierarchical mode is used,
> > invalidate_reclaim_iterators() never reaches root_mem_cgroup.
> > 
> > static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> > {
> > 	struct mem_cgroup *memcg = dead_memcg;
> > 
> > 	for (; memcg; memcg = parent_mem_cgroup(memcg)
> > 	...
> > }
> > 
> > So the use after free scenario looks like:
> > 
> > CPU1						CPU2
> > 
> > try_to_free_pages
> > do_try_to_free_pages
> > shrink_zones
> > shrink_node
> > mem_cgroup_iter()
> >     if (!root)
> >     	root = root_mem_cgroup;
> >     ...
> >     css = css_next_descendant_pre(css, &root->css);
> >     memcg = mem_cgroup_from_css(css);
> >     cmpxchg(&iter->position, pos, memcg);
> > 
> > 					invalidate_reclaim_iterators(memcg);
> > 					...
> > 					__mem_cgroup_free()
> > 						kfree(memcg);
> > 
> > try_to_free_pages
> > do_try_to_free_pages
> > shrink_zones
> > shrink_node
> > mem_cgroup_iter()
> >     if (!root)
> >     	root = root_mem_cgroup;
> >     ...
> >     mz = mem_cgroup_nodeinfo(root, reclaim->pgdat->node_id);
> >     iter = &mz->iter[reclaim->priority];
> >     pos = READ_ONCE(iter->position);
> >     css_tryget(&pos->css) <- use after free
> 
> Thanks for the write up. This is really useful.
> 
> > To avoid this, we should also invalidate root_mem_cgroup.nodeinfo.iter in
> > invalidate_reclaim_iterators().
> 
> I am sorry, I didn't get to comment an earlier version but I am
> wondering whether it makes more sense to do and explicit invalidation.
> 
> [...]
> > +static void invalidate_reclaim_iterators(struct mem_cgroup *dead_memcg)
> > +{
> > +	struct mem_cgroup *memcg = dead_memcg;
> > +	int invalidate_root = 0;
> > +
> > +	for (; memcg; memcg = parent_mem_cgroup(memcg))
> > +		__invalidate_reclaim_iterators(memcg, dead_memcg);
> 
> 	/* here goes your comment */
> 	if (!dead_memcg->use_hierarchy)
> 		__invalidate_reclaim_iterators(root_mem_cgroup,	dead_memcg);
> > +
> > +}
> 
> Other than that the patch looks good to me.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Btw. I believe we want to push this to stable trees as well. I think it
goes all the way down to 5ac8fb31ad2e ("mm: memcontrol: convert reclaim
iterator to simple css refcounting"). Unless I am missing something a
Fixes: tag would be really helpful.
-- 
Michal Hocko
SUSE Labs

