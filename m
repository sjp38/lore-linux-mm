Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D8FB76B004A
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 04:38:20 -0400 (EDT)
Date: Thu, 30 Sep 2010 10:38:14 +0200
From: Bron Gondwana <brong@fastmail.fm>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Message-ID: <20100930083814.GA4618@brong.net>
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
 <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 07:01:32PM +0900, KOSAKI Motohiro wrote:
> Cc to linux-mm and hpc guys. and intetionally full quote.
> 
> 
> > So over the last couple of weeks, I've noticed that our shiny new IMAP
> > servers (Dual Xeon E5520 + Intel S5520UR MB) with 48G of RAM haven't
> > been performing as well as expected, and there were some big oddities.
> > Namely two things stuck out:
> > 
> > 1. There was free memory. There's 20T of data on these machines. The
> >    kernel should have used lots of memory for caching, but for some
> >    reason, it wasn't. cache ~ 2G, buffers ~ 25G, unused ~ 5G
> > 2. The machine has an SSD for very hot data. In total, there's about 16G
> >    of data on the SSD. Almost all of that 16G of data should end up
> >    being cached, so there should be little reading from the SSDs at all.
> >    Instead we saw at peak times 2k+ blocks read/s from the SSDs. Again a
> >    sign that caching wasn't working.
> > 
> > After a bunch of googling, I found this thread.
> > 
> > http://lkml.org/lkml/2009/5/12/586
> > 
> > It appears that patch never went anywhere, and zone_reclaim_mode is
> > still defaulting to 1 on our pretty standard file/email/web server type
> > machine with a NUMA kernel.
> > 
> > By changing it to 0, we saw an immediate massive change in caching
> > behaviour. Now cache ~ 27G, buffers ~ 7G and unused ~ 0.2G, and IO reads
> > from the SSD dropped to 100/s instead of 2000/s.

Apropos to all this, look what's showed up:

http://jcole.us/blog/archives/2010/09/28/mysql-swap-insanity-and-the-numa-architecture/

More fun with NUMA.  Though in the Mysql case I can see that there's no easy
answer because there really is one big process chewing most of the RAM.

The question in our case is: why isn't the kernel balancing the multiple
separate Cyrus instances across all the nodes?  And why, as one of the
comments there says, isn't swap to NUMA being considered cheaper than
swap to disk!  That's the real problem here - that Linux is considering
accessing remote RAM to be more expensive than accessing disk!

Bron.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
