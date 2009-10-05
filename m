Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D505B6B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 17:34:29 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Mon, 5 Oct 2009 23:34:16 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910050851.02056.elendil@planet.nl> <20091005085739.GB5452@csn.ul.ie>
In-Reply-To: <20091005085739.GB5452@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910052334.23833.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Monday 05 October 2009, Mel Gorman wrote:
> On Mon, Oct 05, 2009 at 08:50:58AM +0200, Frans Pop wrote:
> > On Monday 05 October 2009, Frans Pop wrote:
> > > I'll dig into this a bit more as it looks like this should be
> > > reproducible, probably even without the kernel build. Next step is
> > > to see how .30 behaves in the same situation.
> >
> > This looks conclusive. I tested .30 and .32-rc3 from clean reboots and
> > only starting gitk. I only started music playing in the background
> > (amarok) from an NFS share to ensure network activity.
> >
> > With .32-rc3 I got 4 SKB allocation errors while starting the *second*
> > gitk instance. And the system was completely frozen with music stopped
> > until gitk finished loading.
> >
> > With .30 I was able to start *three* gitk's (which meant 2 of them got
> > (partially) swapped out) without any allocation errors. And with the
> > system remaining relatively responsive. There was a short break in the
> > music while I started the 2nd instance, but it just continued playing
> > afterwards. There was also some mild latency in the mouse cursor, but
> > nothing like the full desktop freeze I get with .32-rc3.
> >
> > One thing I should mention: my swap is an LVM volume that's in a VG
> > that's on a LUKS encrypted partition.
> >
> > Does this give you enough info to go on, or should I try a bisection?
>
> I'll be trying to reproduce it, but it's unlikely I'll manage to
> reproduce it reliably as there may be a specific combination of hardware
> necessary as well. What I'm going to try is writing a module that
> allocates order-5 every second GFP_ATOMIC and see can I reproduce using
> scenarios similar to yours but it'll take some time with no guarantee of
> success. If you could bisect it, it would be fantastic.

And the winner is:
2ff05b2b4eac2e63d345fc731ea151a060247f53 is first bad commit
commit 2ff05b2b4eac2e63d345fc731ea151a060247f53
Author: David Rientjes <rientjes@google.com>
Date:   Tue Jun 16 15:32:56 2009 -0700

    oom: move oom_adj value from task_struct to mm_struct

I'm confident that the bisection is good. The test case was very reliable 
while zooming in on the merge from akpm.

Cheers,
FJP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
