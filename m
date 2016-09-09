Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 400F76B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 11:59:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so192946993pfv.1
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 08:59:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y80si4414217pfi.205.2016.09.09.08.53.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 08:53:42 -0700 (PDT)
Message-ID: <1473436422.3916.3.camel@linux.intel.com>
Subject: Re: [PATCH -v3 00/10] THP swap: Delay splitting THP during swapping
 out
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Fri, 09 Sep 2016 08:53:42 -0700
In-Reply-To: <20160909054336.GA2114@bbox>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
	 <20160909054336.GA2114@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Fri, 2016-09-09 at 14:43 +0900, Minchan Kim wrote:
> Hi Huang,
> 
> On Wed, Sep 07, 2016 at 09:45:59AM -0700, Huang, Ying wrote:
> > 
> > From: Huang Ying <ying.huang@intel.com>
> > 
> > This patchset is to optimize the performance of Transparent Huge Page
> > (THP) swap.
> > 
> > Hi, Andrew, could you help me to check whether the overall design is
> > reasonable?
> > 
> > Hi, Hugh, Shaohua, Minchan and Rik, could you help me to review the
> > swap part of the patchset?A A Especially [01/10], [04/10], [05/10],
> > [06/10], [07/10], [10/10].
> > 
> > Hi, Andrea and Kirill, could you help me to review the THP part of the
> > patchset?A A Especially [02/10], [03/10], [09/10] and [10/10].
> > 
> > Hi, Johannes, Michal and Vladimir, I am not very confident about the
> > memory cgroup part, especially [02/10] and [03/10].A A Could you help me
> > to review it?
> > 
> > And for all, Any comment is welcome!
> > 
> > 
> > Recently, the performance of the storage devices improved so fast that
> > we cannot saturate the disk bandwidth when do page swap out even on a
> > high-end server machine.A A Because the performance of the storage
> > device improved faster than that of CPU.A A And it seems that the trend
> > will not change in the near future.A A On the other hand, the THP
> > becomes more and more popular because of increased memory size.A A So it
> > becomes necessary to optimize THP swap performance.
> > 
> > The advantages of the THP swap support include:
> > 
> > - Batch the swap operations for the THP to reduce lock
> > A  acquiring/releasing, including allocating/freeing the swap space,
> > A  adding/deleting to/from the swap cache, and writing/reading the swap
> > A  space, etc.A A This will help improve the performance of the THP swap.
> > 
> > - The THP swap space read/write will be 2M sequential IO.A A It is
> > A  particularly helpful for the swap read, which usually are 4k random
> > A  IO.A A This will improve the performance of the THP swap too.
> > 
> > - It will help the memory fragmentation, especially when the THP is
> > A  heavily used by the applications.A A The 2M continuous pages will be
> > A  free up after THP swapping out.
> I just read patchset right now and still doubt why the all changes
> should be coupled with THP tightly. Many parts(e.g., you introduced
> or modifying existing functions for making them THP specific) could
> just take page_list and the number of pages then would handle them
> without THP awareness.
> 
> For example, if the nr_pages is larger than SWAPFILE_CLUSTER, we
> can try to allocate new cluster. With that, we could allocate new
> clusters to meet nr_pages requested or bail out if we fail to allocate
> and fallback to 0-order page swapout. With that, swap layer could
> support multiple order-0 pages by batch.
> 
> IMO, I really want to land Tim Chen's batching swapout work first.
> With Tim Chen's work, I expect we can make better refactoring
> for batching swap before adding more confuse to the swap layer.
> (I expect it would share several pieces of code for or would be base
> for batching allocation of swapcache, swapslot)

Minchan,

Ying and I do plan to send out a new patch series on batching swapout
and swapin plus a few other optimization on the swapping ofA 
regular sized pages.

Hopefully we'll be able to do that soon after we fixed up a few
things and retest.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
