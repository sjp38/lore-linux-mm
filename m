Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97B456B0038
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 04:35:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u83so2053106wmb.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 01:35:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u54si3556695edm.140.2017.11.22.01.35.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 01:35:12 -0800 (PST)
Date: Wed, 22 Nov 2017 10:35:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-ID: <20171122093510.baxsmzvvid7c7yrq@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
 <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <26CA724E-070E-4D06-B75E-F1880B1F2CF9@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Reale <ar@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Wed 22-11-17 04:18:35, Zi Yan wrote:
> On 22 Nov 2017, at 3:54, Michal Hocko wrote:
[...]
> > I would keep the two checks consistent. But that leads to a more
> > interesting question. new_page_nodemask does
> >
> > 	if (thp_migration_supported() && PageTransHuge(page)) {
> > 		order = HPAGE_PMD_ORDER;
> > 		gfp_mask |= GFP_TRANSHUGE;
> > 	}
> >
> > How come it is safe to allocate an order-0 page if
> > !thp_migration_supported() when we are about to migrate THP? This
> > doesn't make any sense to me. Are we working around this somewhere else?
> > Why shouldn't we simply return NULL here?
> 
> If !thp_migration_supported(), we will first split a THP and migrate
> its head page. This process is done in unmap_and_move() after
> get_new_page() (the function pointer to this new_page_nodemask()) is
> called. The situation can be PageTransHuge(page) is true here, but the
> page is split in unmap_and_move(), so we want to return a order-0 page
> here.

This deserves a big fat comment in the code because this is not clear
from the code!

> I think the confusion comes from that there is no guarantee of THP
> allocation when we are doing THP migration. If we can allocate a THP
> during THP migration, we are good. Otherwise, we want to fallback to
> the old way, splitting the original THP and migrating the head page,
> to preserve the original code behavior.

I understand that but that should be done explicitly rather than relying
on two functions doing the right thing because this is just too fragile.

Moreover I am not really sure this is really working properly. Just look
at the split_huge_page. It moves all the tail pages to the LRU list
while migrate_pages has a list of pages to migrate. So we will migrate
the head page and all the rest will get back to the LRU list. What
guarantees that they will get migrated as well.

This all looks like a mess!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
