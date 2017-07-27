Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8E76B02B4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 03:29:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p43so29789061wrb.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 00:29:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m25si18657193wrm.92.2017.07.27.00.29.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 00:29:01 -0700 (PDT)
Date: Thu, 27 Jul 2017 09:28:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: gigantic hugepages vs. movable zones
Message-ID: <20170727072857.GI20970@dhcp22.suse.cz>
References: <20170726105004.GI2981@dhcp22.suse.cz>
 <87inie1uwf.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87inie1uwf.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 27-07-17 07:52:08, Aneesh Kumar K.V wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
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
> 
> 
> I also noticed an unrelated issue with the usage of
> start_isolate_page_range. On error we set the migrate type to
> MIGRATE_MOVABLE.

Why that should be a problem? I think it is perfectly OK to have
MIGRATE_MOVABLE pageblocks inside kernel zones.

> That may conflict with CMA pages ?

How?

> Wondering whether we should check for page's pageblock migrate type in
> pfn_range_valid_gigantic() ?

I do not think so. Migrate type is just too lowlevel for
pfn_range_valid_gigantic. If something like that is really needed then
it should go down the CMA/alloc_contig_range path.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
