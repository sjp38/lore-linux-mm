Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0B46B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 01:15:00 -0400 (EDT)
Date: Mon, 17 Oct 2011 16:14:45 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v2 1/1] hugepages: Fix race between hugetlbfs umount and
 quota update.
Message-ID: <20111017051445.GI4580@truffala.fritz.box>
References: <4E4EB603.8090305@cray.com>
 <20110819145109.dcd5dac6.akpm@linux-foundation.org>
 <20111012044317.GA31436@drongo>
 <20111014135948.a45a8ac1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111014135948.a45a8ac1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Barry <abarry@cray.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Hastings <abh@cray.com>

On Fri, Oct 14, 2011 at 01:59:48PM -0700, Andrew Morton wrote:
> On Wed, 12 Oct 2011 15:43:17 +1100
> Paul Mackerras <paulus@samba.org> wrote:
> 
> > In the meantime we have a user-triggerable kernel crash.  As far as I
> > can see, if we did what you suggest, we would end up with a situation
> > where we could run out of huge pages even though everyone was within
> > quota.  Which is arguably better than a kernel crash, but still less
> > than ideal.  What do you suggest?
> 
> My issue with the patch is that it's rather horrible.  We have a layer
> of separation between core hugetlb pages and hugetlbfs.  That layering
> has already been mucked up in various places and this patch mucks it up
> further, and quite severely.
> 
> So I believe we should rethink the patch.  Either a) get the layering
> correct by not poking into hugetlbfs internals from within hugetlb core
> via one of the usual techniques or

Which usual techniques did you have in mind?

> b) make a deliberate decision to
> just give up on that layering: state that hugetlb and hugetlbfs are now
> part of the same subsystem.  Make the necessaary Kconfig changes,
> remove ifdefs, move code around, etc.

Well, that might have something to be said for it, the distinction has
always been tenuous at best.

> If we go ahead with the proposed patch-n-run bugfix, the bad code will
> be there permanently - nobody will go in and clean this mess up and the
> kernel is permanently worsened.

Hrm, as opposed to leaving the crash bug there until someone has time
to do the requested cleanup.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
