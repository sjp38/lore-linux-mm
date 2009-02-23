Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0AEF76B0093
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 06:40:02 -0500 (EST)
Date: Mon, 23 Feb 2009 11:39:59 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 07/20] Simplify the check on whether cpusets are a
	factor or not
Message-ID: <20090223113959.GC6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-8-git-send-email-mel@csn.ul.ie> <Pine.LNX.4.64.0902230913080.20371@melkki.cs.Helsinki.FI> <1235380072.4645.0.camel@laptop> <1235380403.6216.16.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1235380403.6216.16.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Peter Zijlstra <peterz@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 23, 2009 at 11:13:23AM +0200, Pekka Enberg wrote:
> On Mon, 2009-02-23 at 10:07 +0100, Peter Zijlstra wrote:
> > On Mon, 2009-02-23 at 09:14 +0200, Pekka J Enberg wrote:
> > > On Sun, 22 Feb 2009, Mel Gorman wrote:
> > > > The check whether cpuset contraints need to be checked or not is complex
> > > > and often repeated.  This patch makes the check in advance to the comparison
> > > > is simplier to compute.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > You can do that in a cleaner way by defining ALLOC_CPUSET to be zero when 
> > > CONFIG_CPUSETS is disabled. Something like following untested patch:
> > > 
> > > Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> > > ---
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 5675b30..18b687d 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1135,7 +1135,12 @@ failed:
> > >  #define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
> > >  #define ALLOC_HARDER		0x10 /* try to alloc harder */
> > >  #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
> > > +
> > > +#ifdef CONFIG_CPUSETS
> > >  #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
> > > +#else
> > > +#define ALLOC_CPUSET		0x00
> > > +#endif
> > >  
> > 
> > Mel's patch however even avoids the code when cpusets are configured but
> > not actively used (the most common case for distro kernels).
> 
> Right. Combining both patches is probably the best solution then as we
> get rid of the #ifdef in get_page_from_freelist().
> 

An #ifdef in a function is ugly all right. Here is a slightly different
version based on your suggestion. Note the definition of number_of_cpusets
in the !CONFIG_CPUSETS case. I didn't call cpuset_zone_allowed_softwall()
for the preferred zone in case it wasn't in the cpuset for some reason and
we incorrectly disabled the cpuset check.

=====
Simplify the check on whether cpusets are a factor or not

The check whether cpuset contraints need to be checked or not is complex
and often repeated.  This patch makes the check in advance to the comparison
is simplier to compute.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 90c6074..6051082 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -83,6 +83,8 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
 #else /* !CONFIG_CPUSETS */
 
+#define number_of_cpusets (0)
+
 static inline int cpuset_init_early(void) { return 0; }
 static inline int cpuset_init(void) { return 0; }
 static inline void cpuset_init_smp(void) {}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 503d692..405cd8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1136,7 +1136,11 @@ failed:
 #define ALLOC_WMARK_HIGH	0x08 /* use pages_high watermark */
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
+#ifdef CONFIG_CPUSETS
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
+#else
+#define ALLOC_CPUSET		0x00
+#endif /* CONFIG_CPUSETS */
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
 
@@ -1400,6 +1404,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	int alloc_cpuset = 0;
 
 	(void)first_zones_zonelist(zonelist, high_zoneidx, nodemask,
 							&preferred_zone);
@@ -1410,6 +1415,10 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 
 	VM_BUG_ON(order >= MAX_ORDER);
 
+	/* Determine in advance if the cpuset checks will be needed */
+	if ((alloc_flags & ALLOC_CPUSET) && unlikely(number_of_cpusets > 1))
+		alloc_cpuset = 1;
+
 zonelist_scan:
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
@@ -1420,8 +1429,8 @@ zonelist_scan:
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
-		if ((alloc_flags & ALLOC_CPUSET) &&
-			!cpuset_zone_allowed_softwall(zone, gfp_mask))
+		if (alloc_cpuset)
+			if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
 				goto try_next_zone;
 
 		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
