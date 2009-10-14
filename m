Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B8256B004F
	for <linux-mm@kvack.org>; Wed, 14 Oct 2009 17:55:30 -0400 (EDT)
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
From: reinette chatre <reinette.chatre@intel.com>
In-Reply-To: <200910142333.29625.elendil@planet.nl>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
	 <20091014165051.GE5027@csn.ul.ie> <1255552911.21134.51.camel@rc-desk>
	 <200910142333.29625.elendil@planet.nl>
Content-Type: text/plain
Date: Wed, 14 Oct 2009 14:55:17 -0700
Message-Id: <1255557317.21134.82.camel@rc-desk>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Abbas, Mohamed" <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-10-14 at 14:33 -0700, Frans Pop wrote:
> On Wednesday 14 October 2009, reinette chatre wrote:
> > We do queue the GFP_KERNEL allocations when there are only a few buffers
> > remaining in the queue (8 right now) ...
> 
> Are you sure of this? I have zero messages in my logs about allocation 
> failures with GFP_KERNEL, but I do have plenty with "Only 0 free buffers 
> remaining" with GFP_ATOMIC.

That does make sense to me. We do not expect allocations with GFP_KERNEL
to fail. Considering how I understand how things work I am considering
the following scenario:

* start with system low on available memory
* now introduce incoming traffic (causing the RX code to run)
* upon receipt of frame we attempt an allocation (to reclaim the buffer)
with GFP_ATOMIC (state: num RX buffer free > watermark)
  * this fails since memory is not available
  * num RX buffer free reduces
  * does _not_ queue replenishment of buffers with GFP_KERNEL
* repeat above until we hit the watermark (currently 8)
* upon receipt of frame we attempt an allocation (to reclaim the buffer)
with GFP_ATOMIC (state: num RX buffer free <= watermark) 
  * this fails (now user sees big warning)
  * queue replenishment of buffers with GFP_KERNEL

Essentially what I suspect could happen is that
we do attempt to replenish the buffers with GFP_KERNEL after several
failures with GFP_ATOMIC, but at that point we have already run out
completely.

One way to test this theory is to queue the GFP_KERNEL allocation
earlier (when we still have a significant number of RX buffers
available), 8 may turn out to be too small.

> Does that indicate a bug or could they fall under the ratelimit somehow?

In your kernel log I do see that the driver's error messages related to
GFP_ATOMIC are rate limited (we see many more "order-2 allocation
failure" messages than the "Failed to allocate" messages). All of these
allocation failures are from the "replenish_now" code though, which is
GFP_ATOMIC. So even though we do not see the "Failed to allocate" errors
(which are rate limited) it seems that all allocation failures are from
that (the GFP_ATOMIC) code.

Reinette


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
