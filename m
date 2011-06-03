Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF486B007B
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 14:13:30 -0400 (EDT)
Date: Fri, 3 Jun 2011 20:13:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG 3.0.0-rc1] ksm: NULL pointer dereference in ksm_do_scan()
Message-ID: <20110603181322.GN2802@random.random>
References: <20110601222032.GA2858@thinkpad>
 <2144269697.363041.1306998593180.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <20110602141927.GA2011@thinkpad>
 <20110602164841.GK23047@sequoia.sous-sol.org>
 <alpine.LSU.2.00.1106021011300.1277@sister.anvils>
 <20110602174305.GH19505@random.random>
 <alpine.LSU.2.00.1106030957090.1901@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106030957090.1901@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chris Wright <chrisw@sous-sol.org>, Andrea Righi <andrea@betterlinux.com>, CAI Qian <caiqian@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jun 03, 2011 at 10:06:14AM -0700, Hugh Dickins wrote:
> On Thu, 2 Jun 2011, Andrea Arcangeli wrote:
> > On Thu, Jun 02, 2011 at 10:29:39AM -0700, Hugh Dickins wrote:
> > > AndreaA, I didn't study the patch you posted half an hour ago,
> > > since by that time I'd worked it out and was preparing patch below.
> > > I think your patch would be for a different bug, hopefully one we
> > > don't have, it looks more complicated than we should need for this.
> > 
> > I didn't expect two different bugs leading to double free.
> 
> There wasn't a double free there, just failure to cope with race
> emptying the list, so accessing head when expecting a full entry.

Yes, we thought it was a double free initially because of two dead
pointers but we couldn't explain why mm was null so consistently.

> You'll see from the "beware" comment in scan_get_next_rmap_item()
> that this case is expected, that it sometimes reaches freeing the
> slots before the exiting task reaches __ksm_exit().
> 
> That race should already be handled.  I believe your patch is unnecessary,
> because get_mm_slot() is a hashlist lookup, and will return NULL once
> either end has done the hlist_del(&mm_slot->link).

Ok so that case is handled by get_mm_slot not succeeding. I see thanks
for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
