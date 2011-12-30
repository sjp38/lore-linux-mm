Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D686D6B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 06:27:29 -0500 (EST)
Date: Fri, 30 Dec 2011 11:27:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111230112723.GD15729@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <20111217160822.GA10064@barrios-laptop.redhat.com>
 <20111219132615.GL3487@suse.de>
 <20111220071026.GA19025@barrios-laptop.redhat.com>
 <20111220095544.GP3487@suse.de>
 <alpine.LSU.2.00.1112231039030.17640@eggly.anvils>
 <20111229165951.GA15729@suse.de>
 <4EFCC008.30803@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4EFCC008.30803@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 29, 2011 at 02:31:20PM -0500, Rik van Riel wrote:
> On 12/29/2011 11:59 AM, Mel Gorman wrote:
> 
> >I considered a few ways of fixing this. The obvious one is to add a
> >new page flag but that is difficult to justify as the high-cpu-usage
> >problem should only occur when there is a lot of writeback to slow
> >storage which I believe is a rare case. It is not a suitable use for
> >an extended page flag.
> 
> Actually, don't we already have three LRU related
> bits in the page flags?
> 

Yes - PG_active, PG_unevictable and PG_swapbacked

> We could stop using those as bit flags, and use
> them as a number instead. That way we could encode
> up to 7 or 8 (depending on how we use all-zeroes)
> LRU lists with the number of bits we have now.
> 

I wondered about this and I felt there were two problems.

One was reading and updating them atomically.  To do this safely,
the page would either need to be locked, have the page isolated from
the LRU without any other references or be protected by the zone->lru
lock. For the most part we are accessing these bits under the page lock
and in cases such as rotate_reclaimable_page()[1] or truncation that do
not necessarily hold the page lock, we would depend on the zone->lru to
prevent parallel changes (particularly updating PageActive).  I did not
spot a case where we were not protected by some combination of the page
lock and zone->lru so it should be fine but there might be a corner
case I missed. Can you think of one? If a case is missed, it means
that it is possible to get an invalid LRU index leading to corruption.

The other problem is that certain operations become more expensive. We
can no longer check one bit for PageActive for example. We'd have
to read the LRU index and see if it corresponds to an activated
page or not. This is not insurmountable but there would be a small
hit for any path that currently checks PageSwapBacked, PageActive
or PageUnevictable.

[1] I noticed another bug in the LRU immediate patch. It's possible
to call pagevec_putback_from_immediate on a page isolated for reclaim
because the check for PageLRU is wrong.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
