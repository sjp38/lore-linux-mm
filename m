Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C980E6B0253
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:12:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so465387wmb.8
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:12:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r30sor14065956edr.0.2017.11.28.06.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 06:12:17 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: hugetlb page migration vs. overcommit
Date: Tue, 28 Nov 2017 15:12:09 +0100
Message-Id: <20171128141211.11117-1-mhocko@kernel.org>
In-Reply-To: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
References: <20171128101907.jtjthykeuefxu7gl@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 28-11-17 11:19:07, Michal Hocko wrote:
> On Wed 22-11-17 16:28:32, Michal Hocko wrote:
> > Hi,
> > is there any reason why we enforce the overcommit limit during hugetlb
> > pages migration? It's in alloc_huge_page_node->__alloc_buddy_huge_page
> > path. I am wondering whether this is really an intentional behavior.
> > The page migration allocates a page just temporarily so we should be
> > able to go over the overcommit limit for the migration duration. The
> > reason I am asking is that hugetlb pages tend to be utilized usually
> > (otherwise the memory would be just wasted and pool shrunk) but then
> > the migration simply fails which breaks memory hotplug and other
> > migration dependent functionality which is quite suboptimal. You can
> > workaround that by increasing the overcommit limit.
> > 
> > Why don't we simply migrate as long as we are able to allocate the
> > target hugetlb page? I have a half baked patch to remove this
> > restriction, would there be an opposition to do something like that?
> 
> So I finally got to think about this some more and looked at how we
> actually account things more thoroughly. And it is, you both of you
> expected, quite subtle and not easy to get around. Per NUMA pools make
> things quite complicated. Why? Migration can really increase the overall
> pool size. Say we are migrating from Node1 to Node2. Node2 doesn't have
> any pre-allocated pages but assume that the overcommit allows us to move
> on. All good. Except that the original page will return to the pool
> because free_huge_page will see Node1 without any surplus pages and
> therefore moves back the page to the pool. Node2 will release the
> surplus page only after it is freed which can be an unbound amount of
> time. 
> 
> While we are still effectively under the overcommit limit the semantic
> is kind of strange and I am not sure the behavior is really intended.
> I see why per node surplus counter is used here. We simply want to
> maintain per node counts after regular page free. So I was thinking
> to add a temporary/migrate state to the huge page for migration pages
> (start with new page, state transfered to the old page on success) and
> free such a page to the allocator regardless of the surplus counters.
> 
> This would mean that the page migration might change inter node pool
> sizes but I guess that should be acceptable. What do you guys think?
> I can send a draft patch if that helps you to understand the idea.

This is what I have currently and it seems to work (or at least it
doesn't it doesn't blow up immediately). The first patch is a cleanup
and patch2 implements the temporary page idea.

Does this make any sense to you at all?
-- 
Michal Hocko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
