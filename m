Date: Tue, 7 Aug 2007 17:55:47 +0100
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Message-ID: <20070807165546.GA7603@skynet.ie>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070806121558.e1977ba5.akpm@linux-foundation.org> <200708062231.49247.ak@suse.de> <20070806215541.GC6142@skynet.ie> <20070806221252.aa1e9048.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070806221252.aa1e9048.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (06/08/07 22:12), Andrew Morton didst pronounce:
> On Mon, 6 Aug 2007 22:55:41 +0100 mel@skynet.ie (Mel Gorman) wrote:
> 
> > On (06/08/07 22:31), Andi Kleen didst pronounce:
> > > 
> > > > If correct, I would suggest merging the horrible hack for .23 then taking
> > > > it out when we merge "grouping pages by mobility".  But what if we don't do
> > > > that merge?
> > > 
> > > Or disable ZONE_MOVABLE until it is usable?
> > 
> > It's usable now. The issue with policies only occurs if the user specifies
> > kernelcore= or movablecore= on the command-line. Your language suggests
> > that you believe policies are not applied when ZONE_MOVABLE is configured
> > at build-time.
> 
> So..  the problem which we're fixing here is only present when someone
> use kernelcore=.  This is in fact an argument for _not_ merging the
> horrible-hack.
> 

It's even more constrained than that. It only applies to the MPOL_BIND
policy when kernelcore= is specified. The other policies work the same
as they ever did.

> How commonly do we expect people to specify kernelcore=?  If "not much" then
> it isn't worth adding the __alloc_pages() overhead?
> 

For 2.6.23 at least, it'll be "not much". While I'm not keen on leaving
MPOL_BIND as it is for 2.6.23, we can postpone the final decision until
we've bashed the one-zonelist-per-node patches a bit and see do we want to
do that instead.

> (It's a pretty darn small overhead, I must say)

And it's simplier than the one-zone-list-per-node patches. The
current draft of the patch I'm working on looks something like;

 arch/parisc/mm/init.c     |   10 ++-
 drivers/char/sysrq.c      |    2 
 fs/buffer.c               |    2 
 include/linux/gfp.h       |    3 -
 include/linux/mempolicy.h |    2 
 include/linux/mmzone.h    |   42 +++++++++++++++
 include/linux/swap.h      |    2 
 mm/mempolicy.c            |    6 +-
 mm/mmzone.c               |   28 ++++++++++
 mm/oom_kill.c             |    8 +--
 mm/page_alloc.c           |  122 +++++++++++++++++++++-------------------------
 mm/slab.c                 |   11 ++--
 mm/slub.c                 |   11 ++--
 mm/vmscan.c               |   16 +++---
 14 files changed, 164 insertions(+), 101 deletions(-)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
