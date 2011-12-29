Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 090A16B005A
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 11:59:58 -0500 (EST)
Date: Thu, 29 Dec 2011 16:59:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/11] mm: Isolate pages for immediate reclaim on their
 own LRU
Message-ID: <20111229165951.GA15729@suse.de>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-12-git-send-email-mgorman@suse.de>
 <20111217160822.GA10064@barrios-laptop.redhat.com>
 <20111219132615.GL3487@suse.de>
 <20111220071026.GA19025@barrios-laptop.redhat.com>
 <20111220095544.GP3487@suse.de>
 <alpine.LSU.2.00.1112231039030.17640@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1112231039030.17640@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

I was offline for several days for the holidays and I'm not back
online properly until Jan 4th, hence the delay in responding.

On Fri, Dec 23, 2011 at 11:08:19AM -0800, Hugh Dickins wrote:
> Sorry, Mel, I've had to revert this patch (and its two little children)
> from my 3.2.0-rc6-next-20111222 testing: you really do need a page flag
> (or substitute) for your "immediate" lru.
> 

Don't be sorry at all. I prefer that this was caught before merging
to mainline and thanks for catching this.

> How else can a del_page_from_lru[_list]() know whether to decrement
> the count of the immediate or the inactive list? 

You are right, it cannot and because pages are removed from the
LRU list in contexts such as invalidating a mapping, we cannot be
sure whether a page is on the immediate LRU or inactive_file in all
cases. It is further complicated by the fact that PageReclaim and
PageReadhead use the same page flag.

> page_lru() says to
> decrement the count of the inactive list, so in due course that wraps
> to a gigantic number, and then page reclaim livelocks trying to wring
> pages out of an empty list.  It's the memcg case I've been hitting,
> but presumably the same happens with global counts.
> 

I've verified that the accounting can break. I did not see it wrap
negative because in my testing it was rare the problem occurred but it
would happen eventually.

I considered a few ways of fixing this. The obvious one is to add a
new page flag but that is difficult to justify as the high-cpu-usage
problem should only occur when there is a lot of writeback to slow
storage which I believe is a rare case. It is not a suitable use for
an extended page flag.

The second was to keep these PageReclaim pages off the LRU but this
leads to complications of its own.

The third was to use a combination of flags to mark pages that
are on the immediate LRU such as how PG_compound and PG_reclaim in
combination mark tail pages. This would not be free of races and would
eventually cause corruption. There is also the problem that we cannot
atomically set multiple bits so setting the bits in contexts such as
set_page_dirty() may be problematic.

Andrew, as there is not an easy uncontroversial fix can you remove
the following patches from mmotm please?

mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch
mm-isolate-pages-for-immediate-reclaim-on-their-own-lru-fix.patch
mm-isolate-pages-for-immediate-reclaim-on-their-own-lru-fix-2.patch

The impact is that users writing to slow stage may see higher CPU usage
as the pages under writeback have to be skipped by scanning once the
dirty pages move to the end of the LRU list. I'm assuming once they
are removed from mmotm that they also get removed from linux-next.

> There is another such accounting bug in -next, been there longer and
> not so easy to hit: I'm fairly sure it will turn out to be memcg
> misaccounting a THPage somewhere, I'll have a look around shortly.
> 
> p.s. Immediate?  Isn't that an odd name for a list of pages which are
> not immediately freeable?  Maybe Rik's launder/laundry name would be
> better: pages which are currently being cleaned.

That is potentially very misleading as not all pages being laundered are
on that list. reclaim_writeback might be a better name.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
