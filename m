Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B72016B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 14:01:15 -0500 (EST)
Date: Mon, 9 Nov 2009 19:00:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091109190059.GH6657@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910262206.13146.elendil@planet.nl> <200911052114.36718.elendil@planet.nl> <200911061051.40443.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200911061051.40443.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Chris Mason <chris.mason@oracle.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 06, 2009 at 10:51:37AM +0100, Frans Pop wrote:
> On Thursday 05 November 2009, Frans Pop wrote:
> > On Monday 26 October 2009, Frans Pop wrote:
> > > On Tuesday 20 October 2009, Mel Gorman wrote:
> > > > I've attached a patch below that should allow us to cheat. When it's
> > > > applied, it outputs who called congestion_wait(), how long the
> > > > timeout was and how long it waited for. By comparing before and
> > > > after sleep times, we should be able to see which of the callers has
> > > > significantly changed and if it's something easily addressable.
> > >
> > > The results from this look fairly interesting (although I may be a bad
> > > judge as I don't really know what I'm looking at ;-).
> > >
> > > I've tested with two kernels:
> > > 1) 2.6.31.1: 1 test run
> > > 2) 2.6.31.1 + congestion_wait() reverts: 2 test runs
> >
> > I've taken another look at the data from this debug patch, resulting in
> > these graphs: http://people.debian.org/~fjp/tmp/kernel/congestion.pdf
> >
> > I think the graph may show the reason for the congestion_wait()
> > regression. Horizontal axis shows time, vertical axis shows number of
> > logged congestion_wait calls per type.
> 
> I'm sorry. My initial version had a skewed time axis (showed occurrences 
> instead of actual time). I've now uploaded a corrected version:
> http://people.debian.org/~fjp/tmp/kernel/congestion.pdf
> 
> I've also uploaded a second version that shows cumulative delay per type, 
> which probably gives a better insight:
> http://people.debian.org/~fjp/tmp/kernel/congestion2.pdf
> 
> For both the top chart is without the revert, the bottom one after the 
> revert.
> 

I'm looking into this at the moment. There are some definite
differences not only in the length congestion_wait() is waiting but in
what the callers are doing. I've more or less reproduced your results
locally and am slowly plodding through each caller to see what has
changed of significance. No patches yet though.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
