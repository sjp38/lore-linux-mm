Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m8TLKNbt238452
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 21:20:23 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8TLKNvU3387606
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 23:20:23 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8TLKJhX022994
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 23:20:20 +0200
Subject: Re: setup_per_zone_pages_min(): zone->lock vs. zone->lru_lock
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
In-Reply-To: <20080929173607.GC14905@brain>
References: <1222708257.4723.23.camel@localhost.localdomain>
	 <20080929173607.GC14905@brain>
Content-Type: text/plain
Date: Mon, 29 Sep 2008 23:20:05 +0200
Message-Id: <1222723206.6791.2.camel@ubuntu>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-09-29 at 18:36 +0100, Andy Whitcroft wrote:
> The allocator protects it freelists using zone->lock (as we can see in
> rmqueue_bulk), so anything which manipulates those should also be using
> that lock.  move_freepages() is scanning the cmap and picking up free
> pages directly off the free lists, it is expecting those lists to be
> stable; it would appear to need zone->lock.  It does look like
> setup_per_zone_pages_min() is holding the wrong thing at first look.

I just noticed that the spin_lock in that function is much older than the
call to setup_zone_migrate_reserve(), which then calls move_freepages().
So it seems that the zone->lru_lock there does (did?) have another purpose,
maybe protecting zone->present_pages/pages_min/etc.

Looks like the need for a zone->lock (if any) was added later, but I'm not
sure if makes sense to take both locks together, or if the lru_lock is still
needed at all.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
