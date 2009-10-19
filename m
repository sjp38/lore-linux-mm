Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AEADD6B004F
	for <linux-mm@kvack.org>; Sun, 18 Oct 2009 22:44:58 -0400 (EDT)
From: Frans Pop <elendil@planet.nl>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Date: Mon, 19 Oct 2009 04:44:52 +0200
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop>
In-Reply-To: <1255912562.6824.9.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200910190444.55867.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Monday 19 October 2009, Pekka Enberg wrote:
> On Wednesday 14 October 2009, Frans Pop wrote:
> > On Thursday 15 October 2009, Mel Gorman wrote:
> > > Outside the range of commits suspected of causing problems was the
> > > following. It's extremely low probability
> > >
> > > Commit 8aa7e84 Fix congestion_wait() sync/async vs read/write
> > > confusion This patch alters the call to congestion_wait() in the
> > > page allocator. Frankly, I don't get the change but it might worth
> > > checking if replacing BLK_RW_ASYNC with WRITE on top of 2.6.31 makes
> > > any difference
> >
> > This is the real culprit. Mel: thanks very much for looking beyond the
> > area I identified. Your overview of mm changes was exactly what I
> > needed and really helped a lot during my later tests.
> >
> > This commit definitely causes most of the problems; confirmed by
> > reverting it on top of 2.6.31 (also requires reverting 373c0a7e, which
> > is a later build fix).
>
> Mel/Jens, any ideas why commit 8aa7e84 makes us run out of high order
> pages? Should we be using BLK_RW_SYNC in mm/page_alloc.c instead of
> BLK_RW_ASYNC?

I'm starting to think that this commit may not be directly related to high 
order allocation failures. The fact that I'm seeing SKB allocation 
failures earlier because of this commit could be just a side effect.
It could be that instead the main impact of this commit is on encrypted 
file system and/or encrypted swap (kcryptd).

Besides mm the commit also touches dm-crypt (and nfs/write.c, but as I'm 
only reading from NFS that's unlikely).

Reason for thinking this is that reverting it makes no difference for Karol 
[1]. It will be interesting to see if it does make a difference for Sven 
Geggus [2].

/me wonders if we'll ever get to the bottom of this...

[1] http://lkml.org/lkml/2009/10/18/138
[2] http://lkml.org/lkml/2009/10/17/113

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
