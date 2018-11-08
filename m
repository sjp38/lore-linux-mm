Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1E86B0599
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 03:12:34 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o42so9480818edc.13
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 00:12:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20-v6si537540ejj.104.2018.11.08.00.12.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 00:12:32 -0800 (PST)
Date: Thu, 8 Nov 2018 09:12:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/5] mm, memory_hotplug: be more verbose for memory
 offline failures
Message-ID: <20181108081231.GN27423@dhcp22.suse.cz>
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-6-mhocko@kernel.org>
 <b23ebcb3-e4f1-be78-bd5f-84c685979ab7@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b23ebcb3-e4f1-be78-bd5f-84c685979ab7@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 08-11-18 12:46:47, Anshuman Khandual wrote:
> 
> 
> On 11/07/2018 03:48 PM, Michal Hocko wrote:
[...]
> > @@ -1411,8 +1409,14 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> >  		/* Allocate a new page from the nearest neighbor node */
> >  		ret = migrate_pages(&source, new_node_page, NULL, 0,
> >  					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
> > -		if (ret)
> > +		if (ret) {
> > +			list_for_each_entry(page, &source, lru) {
> > +				pr_warn("migrating pfn %lx failed ",
> > +				       page_to_pfn(page), ret);
> 
> Seems like pr_warn() needs to have %d in here to print 'ret'.

Dohh. Rebase hickup. You are right ret:%d got lost on the way.

> Though
> dumping return code from migrate_pages() makes sense, wondering if
> it is required for each and every page which failed to migrate here
> or just one instance is enough.

Does it matter enough to special case one printk?

> > +				dump_page(page, NULL);
> > +			}
> 
> s/NULL/failed to migrate/ for dump_page().

Yes, makes sense.

> 
> >  			putback_movable_pages(&source);
> > +		}
> >  	}
> >  out:
> >  	return ret;
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index a919ba5cb3c8..23267767bf98 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7845,6 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  	return false;
> >  unmovable:
> >  	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
> > +	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
> 
> s/has_unmovable_pages/is unmovable/

OK

> If we eally care about the function name, then dump_page() should be
> followed by dump_stack() like the case in some other instances.
>
> >  	return true;
> 
> This will be dumped from HugeTLB and CMA allocation paths as well through
> alloc_contig_range(). But it should be okay as those occurrences should be
> rare and dumping page state then will also help.

yes

Thanks and here is the incremental fix:

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index bf214beccda3..820397e18e59 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1411,9 +1411,9 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
 					MIGRATE_SYNC, MR_MEMORY_HOTPLUG);
 		if (ret) {
 			list_for_each_entry(page, &source, lru) {
-				pr_warn("migrating pfn %lx failed ",
+				pr_warn("migrating pfn %lx failed ret:%d ",
 				       page_to_pfn(page), ret);
-				dump_page(page, NULL);
+				dump_page(page, "migration failure");
 			}
 			putback_movable_pages(&source);
 		}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 23267767bf98..ec2c7916dc2d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7845,7 +7845,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return false;
 unmovable:
 	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
-	dump_page(pfn_to_page(pfn+iter), "has_unmovable_pages");
+	dump_page(pfn_to_page(pfn+iter), "unmovable page");
 	return true;
 }
 
-- 
Michal Hocko
SUSE Labs
