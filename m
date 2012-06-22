Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 4E56B6B0167
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 07:28:12 -0400 (EDT)
Date: Fri, 22 Jun 2012 13:27:51 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Message-ID: <20120622112750.GA6596@breakpoint.cc>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-11-git-send-email-mgorman@suse.de>
 <20120621163029.GB6045@breakpoint.cc>
 <20120622105451.GC8271@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120622105451.GC8271@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Fri, Jun 22, 2012 at 11:54:51AM +0100, Mel Gorman wrote:
> > This is mostly used by nic to refil their RX skb pool. You add the
> > __GFP_MEMALLOC to the allocation to rise the change of a successfull refill
> > for the swap case.
> > A few drivers use build_skb() to create the skb. __netdev_alloc_skb()
> > shouldn't be affected since the allocation happens with GFP_ATOMIC. Looking at
> > TG3 it uses build_skb() and get_pages() / kmalloc(). Shouldn't this be some
> > considered?
> > 
> 
> While TG3 is not exactly as you describe after rebasing build_skb should
> make a similar check to __alloc_skb. As it is always used for RX allocation
> from the skbuff_head_cache cache the following should be suitable. Thanks.

As Eric pointed out you end up in netdev_alloc_frag() which is using
alloc_page(). This is also used by __netdev_alloc_skb().

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
