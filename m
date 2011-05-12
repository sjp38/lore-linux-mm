Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EBA09900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 14:00:32 -0400 (EDT)
Date: Thu, 12 May 2011 20:00:18 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512180018.GN11579@random.random>
References: <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
 <alpine.DEB.2.00.1105121232110.28493@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105121232110.28493@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 12:38:34PM -0500, Christoph Lameter wrote:
> I dont think that will change much since huge pages are at MAX_ORDER size.
> Either you can get them or not. The challenge with the small order
> allocations is that they require contiguous memory. Compaction is likely
> not as effective as the prior mechanism that did opportunistic reclaim of
> neighboring pages.

THP requires contiguous pages too, the issue is similar, and worse
with THP, but THP enables compaction by default, likely this only
happens with compaction off. We've really to differentiate between
compaction on and off, it makes world of difference (a THP enabled
kernel with compaction off, also runs into swap storms and temporary
hangs all the time, it's probably the same issue of SLUB=y
COMPACTION=n). At least THP didn't activate kswapd, kswapd running
lumpy too makes things worse as it'll probably keep running in the
background after the direct reclaim fails.

The original reports talks about kerenls with SLUB=y and
COMPACTION=n. Not sure if anybody is having trouble with SLUB=y
COMPACTION=y...

Compaction is more effective than the prior mechanism too (prior
mechanism is lumpy reclaim) and it doesn't cause VM disruptions that
ignore all referenced information and takes down anything it finds in
the way.

I think when COMPACTION=n, lumpy either should go away, or only be
activated by __GFP_REPEAT so that only hugetlbfs makes use of
it. Increasing nr_hugepages is ok to halt the system for a while but
when all allocations are doing that, system becomes unusable, kind of
livelocked.

BTW, it comes to mind in patch 2, SLUB should clear __GFP_REPEAT too
(not only __GFP_NOFAIL). Clearing __GFP_WAIT may be worth it or not
with COMPACTION=y, definitely good idea to clear __GFP_WAIT unless
lumpy is restricted to __GFP_REPEAT|__GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
