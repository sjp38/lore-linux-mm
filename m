Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 292386B0269
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 05:11:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x10-v6so16323736edx.9
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:11:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y37-v6si11609405edd.10.2018.10.17.02.11.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 02:11:55 -0700 (PDT)
Date: Wed, 17 Oct 2018 11:11:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v3 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
Message-ID: <20181017091154.GK18839@dhcp22.suse.cz>
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202709.2171.75580.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015202709.2171.75580.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On Mon 15-10-18 13:27:09, Alexander Duyck wrote:
> This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.
> 
> This iterator will take care of making sure a given memory range provided
> is in fact contained within a zone. It takes are of all the bounds checking
> we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
> it should help to speed up the search a bit by iterating until the end of a
> range is greater than the start of the zone pfn range, and will exit
> completely if the start is beyond the end of the zone.
> 
> This patch adds yet another iterator called
> for_each_free_mem_range_in_zone_from and then uses it to support
> initializing and freeing pages in groups no larger than MAX_ORDER_NR_PAGES.
> By doing this we can greatly improve the cache locality of the pages while
> we do several loops over them in the init and freeing process.
> 
> We are able to tighten the loops as a result since we only really need the
> checks for first_init_pfn in our first iteration and after that we can
> assume that all future values will be greater than this. So I have added a
> function called deferred_init_mem_pfn_range_in_zone that primes the
> iterators and if it fails we can just exit.

Numbers please.

Besides that, this adds a lot of code and I am not convinced the result
is so much better to justify that. 

> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  include/linux/memblock.h |   58 +++++++++++++++
>  mm/memblock.c            |   63 ++++++++++++++++
>  mm/page_alloc.c          |  176 ++++++++++++++++++++++++++++++++--------------
>  3 files changed, 242 insertions(+), 55 deletions(-)
-- 
Michal Hocko
SUSE Labs
