Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A27576B00F1
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:14:43 -0400 (EDT)
Date: Wed, 22 Apr 2009 18:14:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 18/22] Use allocation flags as an index to the zone
	watermark
Message-ID: <20090422171451.GG15367@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <1240420313.10627.85.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1240420313.10627.85.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 10:11:53AM -0700, Dave Hansen wrote:
> On Wed, 2009-04-22 at 14:53 +0100, Mel Gorman wrote:
> >  struct zone {
> >         /* Fields commonly accessed by the page allocator */
> > -       unsigned long           pages_min, pages_low, pages_high;
> > +       union {
> > +               struct {
> > +                       unsigned long   pages_min, pages_low, pages_high;
> > +               };
> > +               unsigned long pages_mark[3];
> > +       };
> 
> Why the union?  It's a bit obfuscated for me.  Why not just have a
> couple of these:
> 
> static inline unsigned long zone_pages_min(struct zone *zone)
> {
> 	return zone->pages_mark[ALLOC_WMARK_MIN];
> }
> 
> and s/zone->pages_min/zone_pages_min(zone)/
> 
> ?
> 

Preference of taste really. When I started a conversion to accessors, it
changed something recognised to something new that looked uglier to me.
Only one place cares about the union enough to access is via an array so
why spread it everywhere.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
