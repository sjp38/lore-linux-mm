Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 14E0A6B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 06:23:02 -0400 (EDT)
Date: Wed, 7 Apr 2010 11:22:40 +0100
Subject: Re: [PATCH 04/14] Allow CONFIG_MIGRATION to be set without
	CONFIG_NUMA or memory hot-remove
Message-ID: <20100407102240.GN17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-5-git-send-email-mel@csn.ul.ie> <20100406170532.56c71031.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170532.56c71031.akpm@linux-foundation.org>
From: mel@csn.ul.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:05:32PM -0700, Andrew Morton wrote:
> On Fri,  2 Apr 2010 17:02:38 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > CONFIG_MIGRATION currently depends on CONFIG_NUMA or on the architecture
> > being able to hot-remove memory. The main users of page migration such as
> > sys_move_pages(), sys_migrate_pages() and cpuset process migration are
> > only beneficial on NUMA so it makes sense.
> > 
> > As memory compaction will operate within a zone and is useful on both NUMA
> > and non-NUMA systems, this patch allows CONFIG_MIGRATION to be set if the
> > user selects CONFIG_COMPACTION as an option.
> > 
> > ...
> >
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -172,6 +172,16 @@ config SPLIT_PTLOCK_CPUS
> >  	default "4"
> >  
> >  #
> > +# support for memory compaction
> > +config COMPACTION
> > +	bool "Allow for memory compaction"
> > +	def_bool y
> > +	select MIGRATION
> > +	depends on EXPERIMENTAL && HUGETLBFS && MMU
> > +	help
> > +	  Allows the compaction of memory for the allocation of huge pages.
> 
> Seems strange to depend on hugetlbfs.  Perhaps depending on
> HUGETLB_PAGE would be more logical.
> 

Fair point, there is a fix below.

> But hang on.  I wanna use compaction to make my order-4 wireless skb
> allocations work better!  Why do you hate me?
> 

Because I'm a bad person and I hate your hardware. However, because I'm
told being a bad person for the sake of it just isn't the right thing to
do, I'll expand the reasoning :).

For your specific example, the allocation is also depending on GFP_ATOMIC
which migration cannot handle today. Significant plumbing would be needed
there to make it work and I believe at the moment at atomic-safe compaction
would be a subset of full compaction. This is a "future" thing but I'd also
expect you and others to resist it on the grounds that depending on such
high-order atomics for the correct working of the hardware is just a bad plan.

That does not cover other high-order allocs though such as those required for
stacks or the ARM allocation of PGDs. These are below PAGE_ALLOC_COSTLY_ORDER
so compaction will not currently trigger.  Reviews commented that it would
be preferable to limit the orders compaction handles to start with. The
direction I'd like to continue with this in the future is to have something
like __zone_reclaim to handle clean page cache first and moving more towards
integrating lumpy reclaim and compaction. When this is done, the HUGETLB_PAGE
dependency would be removed and the smaller orders will also be compacted.

In the meantime, we continue to discourage high-order allocations and
compaction gets its initial trial run against huge pages.

==== CUT HERE ====
mm,compaction: Have CONFIG_COMPACTION depend on HUGETLB_PAGE instead of HUGETLBFS

There is a strong coupling between HUGETLB_PAGE and HUGETLBFS but in theory
there can be alternative interfaces to huge pages than HUGETLB_PAGE. This
patch makes CONFIG_COMPACTION depend on the right thing.

This is a fix to the patch "Allow CONFIG_MIGRATION to be set without
CONFIG_NUMA or memory hot-remove" and should be merged together.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 4fd75a0..a275a7d 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -177,7 +177,7 @@ config COMPACTION
 	bool "Allow for memory compaction"
 	def_bool y
 	select MIGRATION
-	depends on EXPERIMENTAL && HUGETLBFS && MMU
+	depends on EXPERIMENTAL && HUGETLB_PAGE && MMU
 	help
 	  Allows the compaction of memory for the allocation of huge pages.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
