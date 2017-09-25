Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 268EE6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 02:30:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r83so11941058pfj.5
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 23:30:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 186si3107494pfa.91.2017.09.24.23.30.29
        for <linux-mm@kvack.org>;
        Sun, 24 Sep 2017 23:30:30 -0700 (PDT)
Date: Mon, 25 Sep 2017 15:30:28 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, swap: Make VMA based swap readahead configurable
Message-ID: <20170925063028.GA27727@bbox>
References: <20170921013310.31348-1-ying.huang@intel.com>
 <20170925054133.GB27410@bbox>
 <87bmlze319.fsf@yhuang-dev.intel.com>
 <20170925061734.GA27678@bbox>
 <87377be1n5.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87377be1n5.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

On Mon, Sep 25, 2017 at 02:24:46PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Mon, Sep 25, 2017 at 01:54:42PM +0800, Huang, Ying wrote:
> >> Hi, Minchan,
> >> 
> >> Minchan Kim <minchan@kernel.org> writes:
> >> 
> >> > Hi Huang,
> >> >
> >> > On Thu, Sep 21, 2017 at 09:33:10AM +0800, Huang, Ying wrote:
> >> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> [snip]
> >> 
> >> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> >> index 9c4bdddd80c2..e62c8e2e34ef 100644
> >> >> --- a/mm/Kconfig
> >> >> +++ b/mm/Kconfig
> >> >> @@ -434,6 +434,26 @@ config THP_SWAP
> >> >>  
> >> >>  	  For selection by architectures with reasonable THP sizes.
> >> >>  
> >> >> +config VMA_SWAP_READAHEAD
> >> >> +	bool "VMA based swap readahead"
> >> >> +	depends on SWAP
> >> >> +	default y
> >> >> +	help
> >> >> +	  VMA based swap readahead detects page accessing pattern in a
> >> >> +	  VMA and adjust the swap readahead window for pages in the
> >> >> +	  VMA accordingly.  It works better for more complex workload
> >> >> +	  compared with the original physical swap readahead.
> >> >> +
> >> >> +	  It can be controlled via the following sysfs interface,
> >> >> +
> >> >> +	    /sys/kernel/mm/swap/vma_ra_enabled
> >> >> +	    /sys/kernel/mm/swap/vma_ra_max_order
> >> >
> >> > It might be better to discuss in other thread but if you mention new
> >> > interface here again, I will discuss it here.
> >> >
> >> > We are creating new ABI in here so I want to ask question in here.
> >> >
> >> > Did you consier to use /sys/block/xxx/queue/read_ahead_kb for the
> >> > swap readahead knob? Reusing such common/consistent knob would be better
> >> > than adding new separate konb.
> >> 
> >> The problem is that the configuration of VMA based swap readahead is
> >> global instead of block device specific.  And because it works in
> >> virtual way, that is, the swap blocks on the different block devices may
> >> be readahead together.  It's a little hard to use the block device
> >> specific configuration.
> >
> > Fair enough. page-cluster from the beginning should have been like that
> > instead of vma_ra_max_order.
> >
> > One more questions: Do we need separate vma_ra_enable?
> >
> > Can't we disable it via echo 0 > /sys/kernel/mm/swap/vma_ra_max_order
> > like page-cluster?
> 
> The difference is,
> 
> vma_ra_eanble: 0
>   => use original physical swap readahead
> 
> vma_ra_enable: 1 && vma_ra_max_order: 0
>   => use VMA based swap readahead and disable the readahead.

I understand now. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
