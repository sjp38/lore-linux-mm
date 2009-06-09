Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3DC9D6B004D
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 07:26:55 -0400 (EDT)
Date: Tue, 9 Jun 2009 07:02:14 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v4] zone_reclaim is always 0 by default
Message-ID: <20090609120213.GA18753@attica.americas.sgi.com>
References: <20090604192236.9761.A69D9226@jp.fujitsu.com> <20090608115048.GA15070@csn.ul.ie> <20090609095507.GA9851@attica.americas.sgi.com> <20090609103754.GN18380@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090609103754.GN18380@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Robin Holt <holt@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 11:37:55AM +0100, Mel Gorman wrote:
> On Tue, Jun 09, 2009 at 04:55:07AM -0500, Robin Holt wrote:
> > On Mon, Jun 08, 2009 at 12:50:48PM +0100, Mel Gorman wrote:
> > 
> > Let me start by saying I agree completely with everything you wrote and
> > still disagree with this patch, but was willing to compromise and work
> > around this for our upcoming x86_64 machine by putting a "value add"
> > into our packaging of adding a sysctl that turns reclaim back on.
> > 
> 
> To be honest, I'm more leaning towards a NACK than an ACK on this one. I
> don't support enough NUMA machines to feel strongly enough about it but
> unconditionally setting zone_reclaim_mode to 0 on x86-64 just because i7's
> might be there seems ill-advised to me and will have other consequences for
> existing more traditional x86-64 NUMA machines.

I was sort-of planning on coming up with an x86_64 arch specific function
for setting zone_reclaim_mode, but didn't like the direction things
were going.

Something to the effect of...
--- 20090609.orig/mm/page_alloc.c       2009-06-09 06:51:34.000000000 -0500
+++ 20090609/mm/page_alloc.c    2009-06-09 06:55:00.160762069 -0500
@@ -2326,12 +2326,7 @@ static void build_zonelists(pg_data_t *p
        while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
                int distance = node_distance(local_node, node);
 
-               /*
-                * If another node is sufficiently far away then it is better
-                * to reclaim pages in a zone before going off node.
-                */
-               if (distance > RECLAIM_DISTANCE)
-                       zone_reclaim_mode = 1;
+               zone_reclaim_mode = arch_zone_reclaim_mode(distance);
 
                /*
                 * We don't want to pressure a particular node.

And then letting each arch define an arch_zone_reclaim_mode().  If other
values are needed in the determination, we would add parameters to
reflect this.

For ia64, add

static inline ia64_zone_reclaim_mode(int distance)
{
	if (distance > 15)
		return 1;
}

#define	arch_zone_reclaim_mode(_d)	ia64_zone_reclaim_mode(_d)


Then, inside x86_64_zone_reclaim_mode(), I could make it something like
	if (distance > 40 || is_uv_system())
		return 1;

In the end, I didn't think this fight was worth fighting given how ugly
this felt.  Upon second thought, I am beginning to think it is not that
bad, but I also don't think it is that good either.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
