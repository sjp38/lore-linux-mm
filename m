Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3728A6B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 16:41:54 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <20091014165051.GE5027@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <20091012134328.GB8200@csn.ul.ie> <200910121932.14607.elendil@planet.nl>
	 <200910132238.40867.elendil@planet.nl> <20091014103002.GA5027@csn.ul.ie>
	 <1255537680.21134.14.camel@rc-desk>  <20091014165051.GE5027@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 14 Oct 2009 13:41:51 -0700
Message-Id: <1255552911.21134.51.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-14 at 09:50 -0700, Mel Gorman wrote:

> What is your take on GFP_ATOMIC-direct deleting the pool before the tasklet
> can refill it with GFP_KERNEL?

I am not sure I understand your question. We attempt to reclaim a
received buffer on every receive, and with a queue size of 256 + 64 we
assume to have a pretty big buffer to deal with cases when allocations
fail. So, technically, for us to get into this situation where we start
seeing these allocation failures there would have been more than 200
times in which GFP_ATOMIC allocations failed that we did _not_ see since
we only see those warnings when there are less than 8 free buffers
remaining. More on this below ...

>  Should direct allocation be falling back to
> calling with GFP_KERNEL when the pool has been depleted instead of failing?

This is the intention of the current implementation. In the tasklet we
run iwl_rx_replenish_now(), which attempts the GFP_ATOMIC allocations
first by calling iwl_rx_allocate() with the GFP_ATOMIC flag. No
particular action is taken when this fails (apart from the error
message), but if the buffers are running low then iwl_rx_queue_restock()
(which is also called from iwl_rx_replenish_now()) will queue work that
will do the allocation with GFP_KERNEL.

We do queue the GFP_KERNEL allocations when there are only a few buffers
remaining in the queue (8 right now) ... maybe we can make this higher?

I am not sure if this will help in what you are trying to figure out
here, but would it help to play with the numbers here? That is, in
iwl_rx_queue_restock() we have:

if (rxq->free_count <= RX_LOW_WATERMARK)
	queue_work(priv->workqueue, &priv->rx_replenish);

Would it help here to make that value higher? Maybe queue the GFP_KERNEL
allocation when there are, for example, 50 or 100 free buffers
remaining? 

Reinette


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
