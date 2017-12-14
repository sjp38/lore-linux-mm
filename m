Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08A486B0033
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 02:40:58 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so3913618pfi.23
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:40:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s15si2502139pgf.602.2017.12.13.23.40.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 23:40:56 -0800 (PST)
Date: Thu, 14 Dec 2017 08:40:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/5] mm, hugetlb: do not rely on overcommit limit
 during migration
Message-ID: <20171214074053.GC16951@dhcp22.suse.cz>
References: <20171204140117.7191-1-mhocko@kernel.org>
 <20171204140117.7191-4-mhocko@kernel.org>
 <ec386202-9bee-e230-1b37-bc05c4cd8f49@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec386202-9bee-e230-1b37-bc05c4cd8f49@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 13-12-17 15:35:33, Mike Kravetz wrote:
> On 12/04/2017 06:01 AM, Michal Hocko wrote:
[...]
> > Before migration
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:1
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:0
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
> > 
> > After
> > 
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/free_hugepages:0
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages:0
> > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/surplus_hugepages:0
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/free_hugepages:0
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages:1
> > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/surplus_hugepages:0
> > 
> > with the previous implementation, both nodes would have nr_hugepages:1
> > until the page is freed.
> 
> With the previous implementation, the migration would have failed unless
> nr_overcommit_hugepages was explicitly set.  Correct?

yes

[...]

> In the previous version of this patch, I asked about handling of 'free' huge
> pages.  I did a little digging and IIUC, we do not attempt migration of
> free huge pages.  The routine isolate_huge_page() has this check:
> 
>         if (!page_huge_active(page) || !get_page_unless_zero(page)) {
>                 ret = false;
>                 goto unlock;
>         }
> 
> I believe one of your motivations for this effort was memory offlining.
> So, this implies that a memory area can not be offlined if it contains
> a free (not in use) huge page?

do_migrate_range will ignore this free huge page and then we will free
it up in dissolve_free_huge_pages

> Just FYI and may be something we want to address later.

Maybe yes. The free pool might be reserved which would make
dissolve_free_huge_pages to fail. Maybe we can be more clever and
allocate a new huge page in that case.
 
> My other issues were addressed.
> 
> Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
