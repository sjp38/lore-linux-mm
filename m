Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F74A6B03A3
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 12:13:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 28so2924940wrw.13
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:13:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id i15si4334146wra.8.2017.04.19.09.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 09:13:23 -0700 (PDT)
Date: Wed, 19 Apr 2017 12:13:18 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v9 2/3] mm, THP, swap: Check whether THP can be
 split firstly
Message-ID: <20170419161318.GC3376@cmpxchg.org>
References: <20170419070625.19776-1-ying.huang@intel.com>
 <20170419070625.19776-3-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170419070625.19776-3-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 19, 2017 at 03:06:24PM +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> To swap out THP (Transparent Huage Page), before splitting the THP,
> the swap cluster will be allocated and the THP will be added into the
> swap cache.  But it is possible that the THP cannot be split, so that
> we must delete the THP from the swap cache and free the swap cluster.
> To avoid that, in this patch, whether the THP can be split is checked
> firstly.  The check can only be done racy, but it is good enough for
> most cases.
> 
> With the patchset, the swap out throughput improves 3.6% (from about
> 4.16GB/s to about 4.31GB/s) in the vm-scalability swap-w-seq test case
> with 8 processes.  The test is done on a Xeon E5 v3 system.  The swap
> device used is a RAM simulated PMEM (persistent memory) device.  To
> test the sequential swapping out, the test case creates 8 processes,
> which sequentially allocate and write to the anonymous pages until the
> RAM and part of the swap device is used up.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com> [for can_split_huge_page()]

How often does this actually happen in practice? Because all that this
protects us from is trying to allocate a swap cluster - which with the
si->free_clusters list really isn't all that expensive - and return it
again. Unless this happens all the time in practice, this optimization
seems misplaced.

It's especially a little strange because in the other email I asked
about the need for unlikely() annotations, yet this patch is adding
branches and checks for what seems to be an unlikely condition into
the THP hot path.

I'd suggest you drop both these optimization attempts unless there is
real data proving that they have a measurable impact.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
