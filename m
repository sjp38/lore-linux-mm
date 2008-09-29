Date: Mon, 29 Sep 2008 18:36:14 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: setup_per_zone_pages_min(): zone->lock vs. zone->lru_lock
Message-ID: <20080929173607.GC14905@brain>
References: <1222708257.4723.23.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222708257.4723.23.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 29, 2008 at 07:10:57PM +0200, Gerald Schaefer wrote:
> Hi,
> 
> is zone->lru_lock really the right lock to take in setup_per_zone_pages_min()?
> All other functions in mm/page_alloc.c take zone->lock instead, for working
> with page->lru free-list or PageBuddy().
> 
> setup_per_zone_pages_min() eventually calls move_freepages(), which is also
> manipulating the page->lru free-list and checking for PageBuddy(). Both
> should be protected by zone->lock instead of zone->lru_lock, if I understood
> that right, or else there could be a race with the other functions in
> mm/page_alloc.c.
> 
> We ran into a list corruption bug in free_pages_bulk() once, during memory
> hotplug stress test, but cannot reproduce it easily. So I cannot verify if
> using zone->lock instead of zone->lru_lock would fix it, but to me it looks
> like this may be the problem.
> 
> Any thoughts?
> 
> BTW, I also wonder if a spin_lock_irq() would be enough, instead of
> spin_lock_irqsave(), because this function should never be called from
> interrupt context, right?

The allocator protects it freelists using zone->lock (as we can see in
rmqueue_bulk), so anything which manipulates those should also be using
that lock.  move_freepages() is scanning the cmap and picking up free
pages directly off the free lists, it is expecting those lists to be
stable; it would appear to need zone->lock.  It does look like
setup_per_zone_pages_min() is holding the wrong thing at first look.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
