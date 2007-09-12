Subject: [PATCH] Re: Kernel Panic - 2.6.23-rc4-mm1 ia64 - was Re: Update:
	[Automatic] NUMA replicated pagecache ...
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070912154130.GS4835@shadowen.org>
References: <20070727084252.GA9347@wotan.suse.de>
	 <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost>
	 <20070813074351.GA15609@wotan.suse.de> <1189543962.5036.97.camel@localhost>
	 <46E74679.9020805@linux.vnet.ibm.com> <1189604927.5004.12.camel@localhost>
	 <46E7F2D8.3080003@linux.vnet.ibm.com> <1189609787.5004.33.camel@localhost>
	 <20070912154130.GS4835@shadowen.org>
Content-Type: text/plain
Date: Wed, 12 Sep 2007 15:46:14 -0400
Message-Id: <1189626374.5004.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>, balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-12 at 16:41 +0100, Andy Whitcroft wrote:
> On Wed, Sep 12, 2007 at 11:09:47AM -0400, Lee Schermerhorn wrote:
> 
> > > Interesting, I don't see a memory controller function in the stack
> > > trace, but I'll double check to see if I can find some silly race
> > > condition in there.
> > 
> > right.  I noticed that after I sent the mail.  
> > 
> > Also, config available at:
> > http://free.linux.hp.com/~lts/Temp/config-2.6.23-rc4-mm1-gwydyr-nomemcont
> 
> Be interested to know the outcome of any bisect you do.  Given its
> tripping in reclaim.

Problem isolated to memory controller patches.  This patch seems to fix
this particular problem.  I've only run the test for a few minutes with
and without memory controller configured, but I did observe reclaim
kicking in several times.  W/o this patch, system would panic as soon as
I entered direct/zone reclaim--less than a minute.

Lee
--------------------------------

PATCH 2.6.23-rc4-mm1 Memory Controller:  initialize all scan_controls'
	isolate_pages member.

We need to initialize all scan_controls' isolate_pages member.
Otherwise, shrink_active_list() attempts to execute at undefined
location.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/vmscan.c |    2 ++
 1 file changed, 2 insertions(+)

Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-10 13:22:21.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-12 15:30:27.000000000 -0400
@@ -1758,6 +1758,7 @@ unsigned long shrink_all_memory(unsigned
 		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
 		.swappiness = vm_swappiness,
+		.isolate_pages = isolate_pages_global,
 	};
 
 	current->reclaim_state = &reclaim_state;
@@ -1941,6 +1942,7 @@ static int __zone_reclaim(struct zone *z
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.swappiness = vm_swappiness,
+		.isolate_pages = isolate_pages_global,
 	};
 	unsigned long slab_reclaimable;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
