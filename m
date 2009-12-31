Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7EA5F60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 19:33:53 -0500 (EST)
Date: Thu, 31 Dec 2009 00:33:49 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] mm: don't discard unused swap slots by default
In-Reply-To: <Pine.LNX.4.64.0911301752070.10043@sister.anvils>
Message-ID: <alpine.LSU.2.00.0912302338210.8471@sister.anvils>
References: <20091030065102.GA2896@lst.de> <Pine.LNX.4.64.0910301629030.4106@sister.anvils> <20091118171232.GB25541@lst.de> <20091130172243.GA30779@lst.de> <Pine.LNX.4.64.0911301752070.10043@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, "Martin K. Petersen" <martin.petersen@oracle.com>, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009, Hugh Dickins wrote:
> On Mon, 30 Nov 2009, Christoph Hellwig wrote:
> 
> > Current TRIM/UNMAP/etc implementation are slow enough that discarding
> > small chunk during run time is a bad idea.  So only discard the whole
> > swap space on swapon by default, but require the admin to enable it
> > for run-time discards using the new vm.discard_swapspace sysctl.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Thanks: you having suggested it, I guess it's no coincidence that
> this looks a little like what I'm currently experimenting with, on
> 2.6.32-rc8-mm1 which contains your mods, on Vertex with 1.4 firmware.

I continued those experiments, on the OCZ Vertex, and then on
the Intel SSDSA2M080G2 which appeared at my door a few weeks ago.

> 
> There's several variables (not the least my own idiocy), and too soon
> for me to say anything definite; but the impression I'm getting from
> numbers so far is that (on that SSD anyway) the dubious discards from
> SWP_DISCARDABLE are actually beneficial - more so than the initial
> discard of the whole partition.

That initial impression was borne out by further testing on the Vertex,
which continued to benefit significantly (but not dramatically) from
SWP_DISCARDABLE discards, more so than from swapon's initial discard.

The Intel showed altogether less benefit from any swap discards, but
more benefit from swapon's initial discard (odd since I'd expect its
effects soon to get wiped out) than from ongoing SWP_DISCARDABLEs.

I didn't observe strong reason to tune out the SWP_DISCARDABLEs;
though it may well be that I'd have done better to invest some time
in looking for other swap speedups, than bother with discard in the
first place.

Martin mentioned "We have pretty good vendor guarantees that discards
are going to be essentially free on SCSI-class hardware": can anyone
suggest other ATA SSDs implementing discard that I could check?

I was surprised by what came through most strongly from this testing,
not an effect of initial or ongoing discards at all.

I mentioned earlier that I intended to remove how SWP_SOLIDSTATE
rotates around the swap area (whereas rotationals anchor to the start
of the area).  I put that in for low-end flash, on which wear-levelling
might be very localized; but I'd come to see that it would be a bad
idea on discard-capable SSDs, since they would tend to appear never
less than 1MB away from full (after the first pass around the area).

So while experimenting with tuning out the initial or ongoing discards,
I also experimented with tuning out the initial randomization and the
continued rotation.

But on both the Vertex and the Intel, the randomization and rotation
actually came through as much more consistently beneficial than the
discards: definitely behaviour to be retained, even though I'm
clueless why.

> 
> Each SWP_DISCARDABLE discard is of a 1MB range (if 4kB pagesize, and
> if swap partition - if swapping to fragmented regular file, they would
> often be of less, so indeed less efficient).
> 
> Please could you send me, on or offlist, the tests you have which show
> them to be worth suppressing?

You didn't respond, so perhaps the problem was a worry rather than
a demonstrated issue.  I can see that discarding filesystems appear
liable to be calling discard even on inappropriately small extents,
which swap avoids doing (unless swapping to a regular file which is
too fragmented to be sensible anyway).

> I do prefer to avoid tunables if we can;
> and although this sysctl you suggested is the easiest way, it doesn't
> seem the correct way.
> 
> Something in /sys/block/<device>/queue/ would be more correct: but
> perhaps more trouble than it's worth; and so very specific to swap
> (and whatever mm/swapfile.c happens to be doing in any release)
> that it wouldn't belong very well there either.
> 
> You mentioned an "-o discard" mount option before: so I think what
> we ought to be doing is an option to swapon.  But you can imagine
> that I'd prefer to avoid that too, if we can work this out without it.
> 
> If I could see how bad these SWP_DISCARDABLE discards are for
> myself, I might for the moment prefer just to cut out that code,
> until we can be more intelligent about it (instead of fixing visible
> sysctl/sysfs/swapon options which limit to the current implementation).

Yes, I still have these reservations, so haven't pushed forward
your patch, nor any such alternative.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
