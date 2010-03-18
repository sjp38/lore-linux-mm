Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1BEA6B009C
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 17:22:18 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [10.3.21.3])
	by smtp-out.google.com with ESMTP id o2ILMBN1030585
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 14:22:12 -0700
Received: from fg-out-1718.google.com (fgg16.prod.google.com [10.86.7.16])
	by hpaq3.eem.corp.google.com with ESMTP id o2ILLpfv000354
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 22:22:10 +0100
Received: by fg-out-1718.google.com with SMTP id 16so113660fgg.3
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 14:22:09 -0700 (PDT)
Date: Thu, 18 Mar 2010 21:21:58 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 3/5] tmpfs: handle MPOL_LOCAL mount option properly
In-Reply-To: <1268877338.4773.151.camel@useless.americas.hpqcorp.net>
Message-ID: <alpine.LSU.2.00.1003182112010.11097@sister.anvils>
References: <20100316145022.4C4E.A69D9226@jp.fujitsu.com>  <alpine.LSU.2.00.1003171619410.29003@sister.anvils>  <20100318084915.8723.A69D9226@jp.fujitsu.com> <1268877338.4773.151.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, kiran@scalex86.org, cl@linux-foundation.org, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010, Lee Schermerhorn wrote:
> On Thu, 2010-03-18 at 08:52 +0900, KOSAKI Motohiro wrote:
> > > On Tue, 16 Mar 2010, KOSAKI Motohiro wrote:
> > > 
> > > > commit 71fe804b6d5 (mempolicy: use struct mempolicy pointer in
> > > > shmem_sb_info) added mpol=local mount option. but its feature is
> > > > broken since it was born. because such code always return 1 (i.e.
> > > > mount failure).
> > > > 
> > > > This patch fixes it.
> > > > 
> > > > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > > Cc: Ravikiran Thirumalai <kiran@scalex86.org>
> > > 
> > > Thank you both for finding and fixing these mpol embarrassments.
> > > 
> > > But if this "mpol=local" feature was never documented (not even in the
> > > commit log),

Sorry, I was absolutely wrong to say that: I seem to have been looking at
the wrong commit, but 3f226aa1 does document mpol=local, and does explain
why mpol=default differed; and KOSAKI-san's 5/5 corrects the mpol=default
description in tmpfs.txt, as well as adding mpol=local description.


> > > has been broken since birth 20 months ago, and nobody has
> > > noticed: wouldn't it be better to save a little bloat and just rip it out?
> > 
> > I have no objection if lee agreed, lee?
> > Of cource, if we agree it, we can make the new patch soon :)
> > 
> 
> Well, given the other issues with mpol_parse_str(), I suspect the entire
> tmpfs mpol option is not used all that often in the mainline kernel.  I
> recall that this feature was introduced by SGI for some of their
> customers who may depend on it.  There have been cases where I could
> have used it were it supported for the SYSV shm and MAP_ANON_MAP_SHARED
> internal tmpfs mount.  Further, note that the addition of "mpol=local"
> occurred between when the major "enterprise distributions" selected a
> new mainline kernel.  Production users of those distros, who are the
> likely users of this feature, tend not to live on the bleeding edge.
> So, maybe we shouldn't read too much into it not being discovered until
> now.

True.

> 
> That being said, I suppose I wouldn't be all that opposed to deprecating
> the entire tmpfs mpol option, and see who yells.   If the mpol mount
> options stays, I'd like to see the 'local' option stay.  It's a
> legitimate behavior that one can specify via the system calls and see
> via numa_maps, so I think the mpol mount option, if it exists, should
> support a way to specify it.  
> 
> As for bloat, the additional code on the mount option side to support it
> is:
> 
>         case MPOL_LOCAL:
>                 /*
>                  * Don't allow a nodelist;  mpol_new() checks flags
>                  */
>                 if (nodelist)
>                         goto out;
>                 mode = MPOL_PREFERRED;
>                 break;

Shocking :)

Yes, I withdraw my objection.  I'd been puzzled by why you would have
added an option which nobody was interested in, including yourself;
but as I see it now, you'd noticed a bug in mpol=default, and felt
that the right way to provide the missing functionality was to add
mpol=local: fair enough, let's keep it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
