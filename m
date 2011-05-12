Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C9EB4900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:18:41 -0400 (EDT)
Date: Thu, 12 May 2011 20:18:31 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512181831.GQ11579@random.random>
References: <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121144320.27324@router.home>
 <20110512174641.GL11579@random.random>
 <alpine.DEB.2.00.1105121255060.28493@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105121255060.28493@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 01:00:10PM -0500, Christoph Lameter wrote:
> On Thu, 12 May 2011, Andrea Arcangeli wrote:
> 
> > order 1 should work better, because it's less likely we end up here
> > (which leaves RECLAIM_MODE_LUMPYRECLAIM on and then see what happens
> > at the top of page_check_references())
> >
> >    else if (sc->order && priority < DEF_PRIORITY - 2)
> 
> Why is this DEF_PRIORITY - 2? Shouldnt it be DEF_PRIORITY? An accomodation
> for SLAB order 1 allocs?

That's to allow a few loops of the shrinker (i.e. not take down
everything in the way regardless of any aging information in pte/page
if there's no memory pressure). This "- 2" is independent of the
allocation order. If it was < DEF_PRIORITY it'd trigger lumpy already
at the second loop (in do_try_to_free_pages). So it'd make things
worse. Like it'd make things worse decreasing the
PAGE_ALLOC_COSTLY_ORDER define to 2 and keeping slub at 3.

> May I assume that the case of order 2 and 3 allocs in that case was not
> very well tested after the changes to introduce compaction since people
> were focusing on RHEL testing?

Not really, I had to eliminate lumpy before compaction was
developed. RHEL6 has zero lumpy code (not even at compile time) and
compaction enabled by default, so even if we enabled SLUB=y it should
work ok (not sure why James still crashes with patch 2 applied that
clears __GFP_WAIT, that crash likely has nothing to do with compaction
or lumpy as both are off with __GFP_WAIT not set).

Lumpy is also eliminated upstream now (but only at runtime when
COMPACTION=y), unless __GFP_REPEAT is set, in which case I think lumpy
will still work upstream too but few unfrequent things like increasing
nr_hugepages uses that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
