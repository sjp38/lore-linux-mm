Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B950E6B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 20:06:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2J06MHK028796
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 19 Mar 2009 09:06:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AD05245DD83
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 09:06:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 686DB45DD7B
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 09:06:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44D821DB8041
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 09:06:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E26EF1DB8045
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 09:06:20 +0900 (JST)
Date: Thu, 19 Mar 2009 09:04:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 24/27] Convert gfp_zone() to use a table of
 precalculated values
Message-Id: <20090319090456.fb11e23c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090318194604.GD24462@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
	<1237226020-14057-25-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.1.10.0903161500280.20024@qirst.com>
	<20090318135222.GA4629@csn.ul.ie>
	<alpine.DEB.1.10.0903181011210.7901@qirst.com>
	<20090318153508.GA24462@csn.ul.ie>
	<alpine.DEB.1.10.0903181300540.15570@qirst.com>
	<20090318181717.GC24462@csn.ul.ie>
	<alpine.DEB.1.10.0903181507120.10154@qirst.com>
	<20090318194604.GD24462@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Mar 2009 19:46:04 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Mar 18, 2009 at 03:07:48PM -0400, Christoph Lameter wrote:
> > On Wed, 18 Mar 2009, Mel Gorman wrote:
> > 
> > > Thanks.At a quick glance, it looks ok but I haven't tested it. As the intention
> > > was to get one pass of patches that are not controversial and are "obvious",
> > > I have dropped my version of the gfp_zone patch and the subsequent flag
> > > cleanup and will revisit it after the first lot of patches has been dealt
> > > with. I'm testing again with the remaining patches.
> > 
> > This fixes buggy behavior of gfp_zone so it would deserve a higher
> > priority.
> > 
> 
> It is buggy behaviour in response to a flag combination that makes no sense
> which arguably is a buggy caller. Now that I get to think about it a bit more,
> you can't define a const table in a header. If it's declared extern, then
> the compiler doesn't know what the constant value is so it can't generate
> better code.  At best, you end up with equivalent code to what my patch did
> in the first place except __GFP_DMA32|__GFP_HIGHMEM will return ZONE_NORMAL.
> 

I wonder why you have to make the bad caller work insane way ?
Is this bad ?
==
const int gfp_zone_table[GFP_ZONEMASK] = {
	ZONE_NORMAL,		/* 00 No flags set */
	ZONE_DMA,		/* 01 Only GFP_DMA set */
	ZONE_HIGHMEM,		/* 02 Only GFP_HIGHMEM set */
	BAD_ZONE,		/* 03 GFP_HIGHMEM and GFP_DMA set */
	ZONE_DMA32,		/* 04 Only GFP_DMA32 set */
	BAD_ZONE,		/* 05 GFP_DMA and GFP_DMA32 set */
	BAD_ZONE,		/* 06 GFP_DMA32 and GFP_HIGHMEM set */
	BAD_ZONE,		/* 07 GFP_DMA, GFP_DMA32 and GFP_DMA32 set */
	ZONE_MOVABLE,		/* 08 Only ZONE_MOVABLE set */
	ZONE_DMA,		/* 09 MOVABLE + DMA */
	ZONE_MOVABLE,		/* 0A MOVABLE + HIGHMEM */
	BAD_ZONE,		/* 0B MOVABLE + DMA + HIGHMEM */
	ZONE_DMA32,		/* 0C MOVABLE + DMA32 */
	BAD_ZONE,		/* 0D MOVABLE + DMA + DMA32 */
	BAD_ZONE,		/* 0E MOVABLE + DMA32 + HIGHMEM */
	BAD_ZONE		/* 0F MOVABLE + DMA32 + HIGHMEM + DMA
};
==

Thanks,
-Kame



> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
