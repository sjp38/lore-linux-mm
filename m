Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD53D6B0327
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 03:56:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so19468784pfh.3
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 00:56:52 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n23si713890pll.384.2017.09.12.00.56.50
        for <linux-mm@kvack.org>;
        Tue, 12 Sep 2017 00:56:51 -0700 (PDT)
Date: Tue, 12 Sep 2017 16:56:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm:swap: respect page_cluster for readahead
Message-ID: <20170912075645.GA2837@bbox>
References: <1505183833-4739-1-git-send-email-minchan@kernel.org>
 <1505183833-4739-4-git-send-email-minchan@kernel.org>
 <87vakopk22.fsf@yhuang-dev.intel.com>
 <20170912062524.GA1950@bbox>
 <874ls8pga3.fsf@yhuang-dev.intel.com>
 <20170912065244.GC2068@bbox>
 <87r2vcnzme.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r2vcnzme.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team <kernel-team@lge.com>, Ilya Dryomov <idryomov@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Tue, Sep 12, 2017 at 03:29:45PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Tue, Sep 12, 2017 at 02:44:36PM +0800, Huang, Ying wrote:
> >> Minchan Kim <minchan@kernel.org> writes:
> >> 
> >> > On Tue, Sep 12, 2017 at 01:23:01PM +0800, Huang, Ying wrote:
> >> >> Minchan Kim <minchan@kernel.org> writes:
> >> >> 
> >> >> > page_cluster 0 means "we don't want readahead" so in the case,
> >> >> > let's skip the readahead detection logic.
> >> >> >
> >> >> > Cc: "Huang, Ying" <ying.huang@intel.com>
> >> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> >> > ---
> >> >> >  include/linux/swap.h | 3 ++-
> >> >> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >> >> >
> >> >> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> >> >> > index 0f54b491e118..739d94397c47 100644
> >> >> > --- a/include/linux/swap.h
> >> >> > +++ b/include/linux/swap.h
> >> >> > @@ -427,7 +427,8 @@ extern bool has_usable_swap(void);
> >> >> >  
> >> >> >  static inline bool swap_use_vma_readahead(void)
> >> >> >  {
> >> >> > -	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
> >> >> > +	return page_cluster > 0 && READ_ONCE(swap_vma_readahead)
> >> >> > +				&& !atomic_read(&nr_rotate_swap);
> >> >> >  }
> >> >> >  
> >> >> >  /* Swap 50% full? Release swapcache more aggressively.. */
> >> >> 
> >> >> Now the readahead window size of the VMA based swap readahead is
> >> >> controlled by /sys/kernel/mm/swap/vma_ra_max_order, while that of the
> >> >> original swap readahead is controlled by sysctl page_cluster.  It is
> >> >> possible for anonymous memory to use VMA based swap readahead and tmpfs
> >> >> to use original swap readahead algorithm at the same time.  So that, I
> >> >> think it is necessary to use different control knob to control these two
> >> >> algorithm.  So if we want to disable readahead for tmpfs, but keep it
> >> >> for VMA based readahead, we can set 0 to page_cluster but non-zero to
> >> >> /sys/kernel/mm/swap/vma_ra_max_order.  With your change, this will be
> >> >> impossible.
> >> >
> >> > For a long time, page-cluster have been used as controlling swap readahead.
> >> > One of example, zram users have been disabled readahead via 0 page-cluster.
> >> > However, with your change, it would be regressed if it doesn't disable
> >> > vma_ra_max_order.
> >> >
> >> > As well, all of swap users should be aware of vma_ra_max_order as well as
> >> > page-cluster to control swap readahead but I didn't see any document about
> >> > that. Acutaully, I don't like it but want to unify it with page-cluster.
> >> 
> >> The document is in
> >> 
> >> Documentation/ABI/testing/sysfs-kernel-mm-swap
> >> 
> >> The concern of unifying it with page-cluster is as following.
> >> 
> >> Original swap readahead on tmpfs may not work well because the combined
> >> workload is running, so we want to disable or constrain it.  But at the
> >> same time, the VMA based swap readahead may work better.  So I think it
> >> may be necessary to control them separately.
> >
> > My concern is users have been disabled swap readahead by page-cluster would
> > be regressed. Please take care of them.
> 
> How about disable VMA based swap readahead if zram used as swap?  Like
> we have done for hard disk?

It could be with SWP_SYNCHRONOUS_IO flag which indicates super-fast,
no seek cost swap devices if this patchset is merged so VM automatically
disables readahead. It is in my TODO but it's orthogonal work.

The problem I raised is "Why shouldn't we obey user's decision?",
not zram sepcific issue.

A user has used SSD as swap devices decided to disable swap readahead
by some reason(e.g., small memory system). Anyway, it has worked
via page-cluster for a several years but with vma-based swap devices,
it doesn't work any more.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
