Date: Tue, 30 Sep 2008 10:53:41 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: setup_per_zone_pages_min(): zone->lock vs. zone->lru_lock
In-Reply-To: <20080930094017.5ed2938a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1222723206.6791.2.camel@ubuntu> <20080930094017.5ed2938a.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20080930103748.44A3.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Mon, 29 Sep 2008 23:20:05 +0200
> Gerald Schaefer <gerald.schaefer@de.ibm.com> wrote:
> 
> > On Mon, 2008-09-29 at 18:36 +0100, Andy Whitcroft wrote:
> > > The allocator protects it freelists using zone->lock (as we can see in
> > > rmqueue_bulk), so anything which manipulates those should also be using
> > > that lock.  move_freepages() is scanning the cmap and picking up free
> > > pages directly off the free lists, it is expecting those lists to be
> > > stable; it would appear to need zone->lock.  It does look like
> > > setup_per_zone_pages_min() is holding the wrong thing at first look.
> > 
> > I just noticed that the spin_lock in that function is much older than the
> > call to setup_zone_migrate_reserve(), which then calls move_freepages().
> > So it seems that the zone->lru_lock there does (did?) have another purpose,
> > maybe protecting zone->present_pages/pages_min/etc.
> > 
> Maybe.

The zone->lru_lock() have been used before memory hotplug code was
implemented. But I can't find any reason why it have been used.

> 
> > Looks like the need for a zone->lock (if any) was added later, but I'm not
> > sure if makes sense to take both locks together, or if the lru_lock is still
> > needed at all.
> >
> At first look, replacing zone->lru_lock with zone->lock is enough...
> This function is an only one function which use zone->lru_lock in page_alloc.c
> And zone_watermark_ok() which access zone->pages_min/low/high is not under any
> locks. So, taking zone->lru_lock here doesn't seem to be necessary...

I agree.


Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
