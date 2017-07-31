Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E60FE6B05C3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 02:47:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q50so45423329wrb.14
        for <linux-mm@kvack.org>; Sun, 30 Jul 2017 23:47:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si16436352wrp.7.2017.07.30.23.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 30 Jul 2017 23:47:43 -0700 (PDT)
Date: Mon, 31 Jul 2017 08:47:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: gigantic hugepages vs. movable zones
Message-ID: <20170731064741.GC13036@dhcp22.suse.cz>
References: <20170726105004.GI2981@dhcp22.suse.cz>
 <6dd3171d-7d61-5476-5465-ab7c06b56e0b@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6dd3171d-7d61-5476-5465-ab7c06b56e0b@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 28-07-17 13:48:28, Mike Kravetz wrote:
> On 07/26/2017 03:50 AM, Michal Hocko wrote:
> > Hi,
> > I've just noticed that alloc_gigantic_page ignores movability of the
> > gigantic page and it uses any existing zone. Considering that
> > hugepage_migration_supported only supports 2MB and pgd level hugepages
> > then 1GB pages are not migratable and as such allocating them from a
> > movable zone will break the basic expectation of this zone. Standard
> > hugetlb allocations try to avoid that by using htlb_alloc_mask and I
> > believe we should do the same for gigantic pages as well.
> > 
> > I suspect this behavior is not intentional. What do you think about the
> > following untested patch?
> > ---
> > From 542d32c1eca7dcf38afca1a91bca4a472f6e8651 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 26 Jul 2017 12:43:43 +0200
> > Subject: [PATCH] mm, hugetlb: do not allocate non-migrateable gigantic pages
> >  from movable zones
> > 
> > alloc_gigantic_page doesn't consider movability of the gigantic hugetlb
> > when scanning eligible ranges for the allocation. As 1GB hugetlb pages
> > are not movable currently this can break the movable zone assumption
> > that all allocations are migrateable and as such break memory hotplug.
> > 
> > Reorganize the code and use the standard zonelist allocations scheme
> > that we use for standard hugetbl pages. htlb_alloc_mask will ensure that
> > only migratable hugetlb pages will ever see a movable zone.
> > 
> > Fixes: 944d9fec8d7a ("hugetlb: add support for gigantic page allocation at runtime")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> This seems reasonable to me, and I like the fact that the code is more
> like the default huge page case.  I don't see any issues with the code.
> I did some simple smoke testing of allocating 1G pages with the new code
> and ensuring they ended up as expected.
>
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks a lot Mike! I will play with this some more today and tomorrow
and send the final patch later this week.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
