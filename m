Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 70CB86B0007
	for <linux-mm@kvack.org>; Wed,  6 Jun 2018 05:32:21 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id k13-v6so2056769pgr.11
        for <linux-mm@kvack.org>; Wed, 06 Jun 2018 02:32:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b83-v6si25522944pfk.342.2018.06.06.02.32.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Jun 2018 02:32:20 -0700 (PDT)
Date: Wed, 6 Jun 2018 11:32:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] mm: add find_alloc_contig_pages() interface
Message-ID: <20180606093214.GE32433@dhcp22.suse.cz>
References: <20180417020915.11786-1-mike.kravetz@oracle.com>
 <20180417020915.11786-3-mike.kravetz@oracle.com>
 <deb9dd1d-84bf-75c7-2880-a7bcec880d47@suse.cz>
 <af56d281-fea1-2bd7-aff1-108fa1d9f3be@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af56d281-fea1-2bd7-aff1-108fa1d9f3be@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Reinette Chatre <reinette.chatre@intel.com>, Christopher Lameter <cl@linux.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed 02-05-18 14:13:32, Mike Kravetz wrote:
> On 04/21/2018 09:16 AM, Vlastimil Babka wrote:
> > On 04/17/2018 04:09 AM, Mike Kravetz wrote:
> >> find_alloc_contig_pages() is a new interface that attempts to locate
> >> and allocate a contiguous range of pages.  It is provided as a more
> >> convenient interface than alloc_contig_range() which is currently
> >> used by CMA and gigantic huge pages.
> >>
> >> When attempting to allocate a range of pages, migration is employed
> >> if possible.  There is no guarantee that the routine will succeed.
> >> So, the user must be prepared for failure and have a fall back plan.
> >>
> >> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> > 
> > Hi, just two quick observations, maybe discussion pointers for the
> > LSF/MM session:
> > - it's weird that find_alloc_contig_pages() takes an order, and
> > free_contig_pages() takes a nr_pages. I suspect the interface would be
> > more future-proof with both using nr_pages? Perhaps also minimum
> > alignment for the allocation side? Order is fine for hugetlb, but what
> > about other potential users?
> 
> Agreed, and I am changing this to nr_pages and adding alignment.
> 
> > - contig_alloc_migratetype_ok() says that MIGRATE_CMA blocks are OK to
> > allocate from. This silently assumes that everything allocated by this
> > will be migratable itself, or it might eat CMA reserves. Is it the case?
> > Also you then call alloc_contig_range() with MIGRATE_MOVABLE, so it will
> > skip/fail on MIGRATE_CMA anyway IIRC.
> 
> When looking closer at the code, alloc_contig_range currently has comments
> saying migratetype must be MIGRATE_MOVABLE or MIGRATE_CMA.  However, this
> is not checked/enforced anywhere in the code (that I can see).  The
> migratetype passed to alloc_contig_range() will be used to set the migrate
> type of all pageblocks in the range.  If there is an error, one side effect
> is that some pageblocks may have their migrate type changed to migratetype.
> Depending on how far we got before hitting the error, the number of pageblocks
> changed is unknown.  This actually can happen at the lower level routine
> start_isolate_page_range().
> 
> My first thought was to make start_isolate_page_range/set_migratetype_isolate
> check that the migrate type of a pageblock was migratetype before isolating.
> This would work for CMA, and I could make it work for the new allocator.
> However, offline_pages also calls start_isolate_page_range and I believe we
> do not want to enforce such a rule (all pageblocks must be of the same migrate
> type) for memory hotplug/offline?
> 
> Should we be concerned at all about this potential changing of migrate type
> on error?  The only way I can think to avoid this is to save the original
> migrate type before isolation.

This is more a question to Vlastimil, Joonsoo. But my understanding is
that it doesn't matter. MIGRATE_MOVABLE will not block other
allocations. So we seem to need it only for MIGRATE_CMA. The later
should die sooner or later hopefully so this awful kludge should just
die with it.
-- 
Michal Hocko
SUSE Labs
