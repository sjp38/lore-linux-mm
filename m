Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 790D26B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 12:04:49 -0400 (EDT)
Date: Tue, 27 Oct 2009 12:03:32 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091027160332.GA7776@think>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera>
 <20091019161815.GA11487@think>
 <20091020104839.GC11778@csn.ul.ie>
 <200910262206.13146.elendil@planet.nl>
 <20091027145435.GG8900@csn.ul.ie>
 <20091027155223.GL8900@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091027155223.GL8900@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 03:52:24PM +0000, Mel Gorman wrote:
> 
> > So, after the move to async/sync, a lot more pages are getting queued
> > for writeback - more than three times the number of pages are queued for
> > writeback with the vanilla kernel. This amount of congestion might be why
> > direct reclaimers and kswapd's timings have changed so much.
> > 
> 
> Or more accurately, the vanilla kernel has queued up a lot more pages for
> IO than when the patch is reverted. I'm not seeing yet why this is.

[ sympathies over confusion about congestion...lots of variables here ]

If wb_kupdate has been able to queue more writes it is because the
congestion logic isn't stopping it.  We have congestion_wait(), but
before calling that in the writeback paths it says: are you congested?
and then backs off if the answer is yes.

Ideally, direct reclaim will never do writeback.  We want it to be able
to find clean pages that kupdate and friends have already processed.

Waiting for congestion is a funny thing, it only tells us the device has
managed to finish some IO or that a timeout has passed.  Neither event has
any relation to figuring out if the IO for reclaimable pages has
finished.

One option is to have the VM remember the hashed waitqueue for one of
the pages it direct reclaims and then wait on it.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
