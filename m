Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 650AF6B0003
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 12:05:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m21-v6so9051689pgl.16
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:05:07 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id f65-v6si28362447pff.276.2018.10.31.09.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 09:05:05 -0700 (PDT)
Message-ID: <a7c1bc0ed1e68cbc32c4dd6753fa9f8ff7f1421f.camel@linux.intel.com>
Subject: Re: [mm PATCH v4 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Wed, 31 Oct 2018 09:05:04 -0700
In-Reply-To: <5b937f29-a6e1-6622-b035-246229021d3e@microsoft.com>
References: <20181017235043.17213.92459.stgit@localhost.localdomain>
	 <20181017235419.17213.68425.stgit@localhost.localdomain>
	 <5b937f29-a6e1-6622-b035-246229021d3e@microsoft.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, "davem@davemloft.net" <davem@davemloft.net>, "yi.z.zhang@linux.intel.com" <yi.z.zhang@linux.intel.com>, "khalid.aziz@oracle.com" <khalid.aziz@oracle.com>, "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mingo@kernel.org" <mingo@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

On Wed, 2018-10-31 at 15:40 +0000, Pasha Tatashin wrote:
> 
> On 10/17/18 7:54 PM, Alexander Duyck wrote:
> > This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.
> > 
> > This iterator will take care of making sure a given memory range provided
> > is in fact contained within a zone. It takes are of all the bounds checking
> > we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
> > it should help to speed up the search a bit by iterating until the end of a
> > range is greater than the start of the zone pfn range, and will exit
> > completely if the start is beyond the end of the zone.
> > 
> > This patch adds yet another iterator called
> > for_each_free_mem_range_in_zone_from and then uses it to support
> > initializing and freeing pages in groups no larger than MAX_ORDER_NR_PAGES.
> > By doing this we can greatly improve the cache locality of the pages while
> > we do several loops over them in the init and freeing process.
> > 
> > We are able to tighten the loops as a result since we only really need the
> > checks for first_init_pfn in our first iteration and after that we can
> > assume that all future values will be greater than this. So I have added a
> > function called deferred_init_mem_pfn_range_in_zone that primes the
> > iterators and if it fails we can just exit.
> > 
> > On my x86_64 test system with 384GB of memory per node I saw a reduction in
> > initialization time from 1.85s to 1.38s as a result of this patch.
> > 
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Hi Alex,
> 
> Could you please split this patch into two parts:
> 
> 1. Add deferred_init_maxorder()
> 2. Add memblock iterator?
> 
> This would allow a better bisecting in case of problems. Chaning two
> loops into deferred_init_maxorder() while a good idea, is still
> non-trivial and might lead to bugs.
> 
> Thank you,
> Pavel

I can do that, but I will need to flip the order. I will add the new
iterator first and then deferred_init_maxorder. Otherwise the
intermediate step ends up being too much throw-away code.

- Alex
