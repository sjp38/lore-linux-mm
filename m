Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 964B86B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:02 -0400 (EDT)
Date: Wed, 31 Oct 2012 09:45:38 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/2] mm: refactor reinsert of swap_info in sys_swapoff
Message-ID: <20121031134538.GG27288@phenom.dumpdata.com>
References: <1351372847-13625-1-git-send-email-cesarb@cesarb.net>
 <1351372847-13625-2-git-send-email-cesarb@cesarb.net>
 <20121030140417.988c2437.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121030140417.988c2437.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, dan.magenheimer@oracle.com
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Oct 30, 2012 at 02:04:17PM -0700, Andrew Morton wrote:
> On Sat, 27 Oct 2012 19:20:46 -0200
> Cesar Eduardo Barros <cesarb@cesarb.net> wrote:
> 
> > The block within sys_swapoff which re-inserts the swap_info into the
> > swap_list in case of failure of try_to_unuse() reads a few values outside
> > the swap_lock. While this is safe at that point, it is subtle code.
> > 
> > Simplify the code by moving the reading of these values to a separate
> > function, refactoring it a bit so they are read from within the
> > swap_lock. This is easier to understand, and matches better the way it
> > worked before I unified the insertion of the swap_info from both
> > sys_swapon and sys_swapoff.
> > 
> > This change should make no functional difference. The only real change
> > is moving the read of two or three structure fields to within the lock
> > (frontswap_map_get() is nothing more than a read of p->frontswap_map).
> 
> Your patch doesn't change this, but...  it is very unusual for any
> subsystem's ->init method to be called under a spinlock.  Because it is
> highly likely that such a method will wish to do things such as memory
> allocation.
> 
> It is rare and unlikely for an ->init() method to *need* such external
> locking, because all the objects it is dealing with cannot be looked up
> by other threads because nothing has been registered anywhere yet.

I don't believe it actually needs that locking. Dan, do you recall
the details of this?
> 
> So either frontswap is doing something wrong here or there's some
> subtlety which escapes me.  If the former then we should try to get
> that ->init call to happen outside swap_lock.

Agreed.
> 
> And if we can do that, perhaps we can fix the regrettable GFP_ATOMIC
> in zcache_new_pool().

Ouch. Yes.


FYI, thanks for pulling those two patches - they looked good to me
but I hadn't had a chance to test them so did not want to comment on them
until that happen. Dan beat me to it and he did test them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
