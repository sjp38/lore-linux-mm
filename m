Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E45746B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:37:08 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3RGQAoZ032402
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:26:10 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3RGavVs089468
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:36:57 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3RGabQT013057
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:36:38 -0600
Subject: Re: [PATCH] convert parisc to sparsemem (was Re: [PATCH v3] mm:
 make expand_downwards symmetrical to expand_upwards)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1303583657.4116.11.camel@mulgrave.site>
References: <1303337718.2587.51.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>
	 <20110421221712.9184.A69D9226@jp.fujitsu.com>
	 <1303403847.4025.11.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211328000.5741@router.home>
	 <1303411537.9048.3583.camel@nimitz>
	 <1303507985.2590.47.camel@mulgrave.site>
	 <1303583657.4116.11.camel@mulgrave.site>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 27 Apr 2011 09:36:29 -0700
Message-ID: <1303922189.9516.33.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Christoph Lameter <cl@linux.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>

On Sat, 2011-04-23 at 13:34 -0500, James Bottomley wrote: 
> This is the preliminary conversion.  It's very nasty on parisc because
> the memory allocation isn't symmetric anymore: under DISCONTIGMEM, we
> push all memory into bootmem and then let free_all_bootmem() do the
> magic for us;

Urg, that's unfortunate.  I bet we could fairly easily teach the bootmem
allocator to allow a couple of bootmem_data's to hang off of an
individual pgdat.  Put each pmem_ranges in one of those instead of a
pgdat.  That would at least help with the bitmap size explosion and
extra loops.

> now we have to do separate initialisations for ranges
> because SPARSEMEM can't do multi-range boot memory. It's also got the
> horrible hack that I only use the first found range for bootmem.  I'm
> not sure if this is correct (it won't be if the first found range can be
> under about 50MB because we'll run out of bootmem during boot) ... we
> might have to sort the ranges and use the larges, but that will involve
> us in even more hackery around the bootmem reservations code.
> 
> The boot sequence got a few seconds slower because now all of the loops
> over our pfn ranges actually have to skip through the holes (which takes
> time for 64GB).

Which iterations were these, btw?  All of the ones I saw the patch touch
seemed to be running over just a single pmem_range.

> All in all, I've not been very impressed with SPARSEMEM over
> DISCONTIGMEM.  It seems to have a lot of rough edges (necessitating
> exception code) which DISCONTIGMEM just copes with.

We definitely need to look at extending it to cover bootmem-time a bit.
Is that even worth it these days with the no-bootmem bits around?

-- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
