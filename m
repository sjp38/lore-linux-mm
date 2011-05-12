Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8F759900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:46:52 -0400 (EDT)
Date: Thu, 12 May 2011 19:46:41 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512174641.GL11579@random.random>
References: <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105120942050.24560@router.home>
 <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121144320.27324@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105121144320.27324@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 11:48:19AM -0500, Christoph Lameter wrote:
> Try order = 1 which gives you SLAB like interaction with the page
> allocator. Then we at least know that it is the order 2 and 3 allocs that
> are the problem and not something else.

order 1 should work better, because it's less likely we end up here
(which leaves RECLAIM_MODE_LUMPYRECLAIM on and then see what happens
at the top of page_check_references())

   else if (sc->order && priority < DEF_PRIORITY - 2)
   	sc->reclaim_mode |= syncmode;

with order 1 more likely we end up here as enough pages are freed for
order 1 and we're safe:

     else
	sc->reclaim_mode = RECLAIM_MODE_SINGLE | RECLAIM_MODE_ASYNC;

None of these issue should materialize with COMPACTION=n. Even
__GFP_WAIT can be left enabled to run compaction without expecting
adverse behavior, but running compaction may still not be worth it for
small systems where the benefit of having order 1/2/3 allocation may
not outweight the cost of compaction itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
