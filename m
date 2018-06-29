Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 083D56B0003
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 17:12:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a10-v6so2675185lff.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:12:58 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h21-v6si4520360ljk.210.2018.06.29.14.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 14:12:56 -0700 (PDT)
Date: Fri, 29 Jun 2018 14:12:05 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
Message-ID: <20180629211201.GA14897@castle.DHCP.thefacebook.com>
References: <20180618091808.4419-6-vbabka@suse.cz>
 <201806201923.mC5ZpigB%fengguang.wu@intel.com>
 <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

On Fri, Jun 29, 2018 at 05:37:02PM +0200, Vlastimil Babka wrote:
> On 06/20/2018 01:23 PM, kbuild test robot wrote:
> > Hi Vlastimil,
> > 
> > Thank you for the patch! Yet something to improve:
> > 
> > [auto build test ERROR on mmotm/master]
> > [also build test ERROR on v4.18-rc1 next-20180619]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/kmalloc-reclaimable-caches/20180618-172912
> > base:   git://git.cmpxchg.org/linux-mmotm.git master
> > config: x86_64-allmodconfig (attached as .config)
> > compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> > reproduce:
> >         # save the attached .config to linux build tree
> >         make ARCH=x86_64 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    drivers/staging//android/ion/ion_page_pool.c: In function 'ion_page_pool_remove':
> >>> drivers/staging//android/ion/ion_page_pool.c:56:40: error: 'NR_INDIRECTLY_RECLAIMABLE_BYTES' undeclared (first use in this function)
> >      mod_node_page_state(page_pgdat(page), NR_INDIRECTLY_RECLAIMABLE_BYTES,
> >                                            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >    drivers/staging//android/ion/ion_page_pool.c:56:40: note: each undeclared identifier is reported only once for each function it appears in
> > 
> > vim +/NR_INDIRECTLY_RECLAIMABLE_BYTES +56 drivers/staging//android/ion/ion_page_pool.c
> 
> Looks like I missed a hunk, updated patch below.
> 
> ----8<----
> From a0053c64c72d7e094252d0d7462de8569d87c543 Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Tue, 22 May 2018 16:10:10 +0200
> Subject: [PATCH v3 5/7] mm: rename and change semantics of
>  nr_indirectly_reclaimable_bytes
> 
> The vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES was introduced by commit
> eb59254608bc ("mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES") with the goal of
> accounting objects that can be reclaimed, but cannot be allocated via a
> SLAB_RECLAIM_ACCOUNT cache. This is now possible via kmalloc() with
> __GFP_RECLAIMABLE flag, and the dcache external names user is converted.
> 
> The counter is however still useful for accounting direct page allocations
> (i.e. not slab) with a shrinker, such as the ION page pool. So keep it, and:

Btw, it looks like I've another example of usefulness of this counter:
dynamic per-cpu data.
