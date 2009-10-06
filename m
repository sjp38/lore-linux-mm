Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B62CB6B0055
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 05:22:57 -0400 (EDT)
Date: Tue, 6 Oct 2009 10:22:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091006092257.GB18185@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910050851.02056.elendil@planet.nl> <20091005085739.GB5452@csn.ul.ie> <200910052334.23833.elendil@planet.nl> <alpine.DEB.1.00.0910051700440.31688@chino.kir.corp.google.com> <20091006085345.GA18185@csn.ul.ie> <alpine.DEB.1.00.0910060210320.24787@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0910060210320.24787@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Frans Pop <elendil@planet.nl>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 06, 2009 at 02:14:26AM -0700, David Rientjes wrote:
> On Tue, 6 Oct 2009, Mel Gorman wrote:
> 
> > > > And the winner is:
> > > > 2ff05b2b4eac2e63d345fc731ea151a060247f53 is first bad commit
> > > > commit 2ff05b2b4eac2e63d345fc731ea151a060247f53
> > > > Author: David Rientjes <rientjes@google.com>
> > > > Date:   Tue Jun 16 15:32:56 2009 -0700
> > > > 
> > > >     oom: move oom_adj value from task_struct to mm_struct
> > > > 
> > > > I'm confident that the bisection is good. The test case was very reliable 
> > > > while zooming in on the merge from akpm.
> > > > 
> > > 
> > > I doubt it for two reasons: (i) this commit was reverted in 0753ba0 since 
> > > 2.6.31-rc7 and is no longer in the kernel, and (ii) these are GFP_ATOMIC 
> > > allocations which would be unaffected by oom killer scores.
> > > 
> > 
> > However, the problem was reported to start showing up in 2.6.31-rc1 so
> > while it might not be *the* patch, it might be making the type of change
> > that caused more fragmentation. This patch adjusted the size of
> > mm_struct and maybe it was enough to change the "order" required for the
> > slab. Maybe there are other slabs that have changed size as well in that
> > timeframe.
> > 
> > Frans, what is the size of mm_struct before and after this patch was
> > applied? Find it with either
> > 
> > grep mm_struct /proc/slabinfo
> > 
> > and if the information is not available there, try
> > 
> > cat /sys/kernel/slab/mm_struct/slab_size and
> > /sys/kernel/slab/mm_struct/order
> > 
> 
> If that's the case and the problem still persists in 2.6.31-rc7 as 
> reported, then you'd need to compare the current slab order for both 
> mm_struct and signal_struct to the previously known working kernel 
> since the latter is where oom_adj was moved.  (You'd still have to check 
> the former to see if there were any mm_struct additions between rc1 and 
> rc7 between the commit and revert, though.)
> 

Best to just grab all of slabinfo for a poke around. I know task_struct
has increases in size since 2.6.29 but not enough on the machines I've
changed to make a difference to the order of pages requested. It might
be different on the problem machines.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
