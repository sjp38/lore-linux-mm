Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id m8THB2HH012900
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 17:11:05 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8THB1Jo3027030
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 19:11:01 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8THAv1i007919
	for <linux-mm@kvack.org>; Mon, 29 Sep 2008 19:10:58 +0200
Subject: setup_per_zone_pages_min(): zone->lock vs. zone->lru_lock
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Content-Type: text/plain
Date: Mon, 29 Sep 2008 19:10:57 +0200
Message-Id: <1222708257.4723.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

is zone->lru_lock really the right lock to take in setup_per_zone_pages_min()?
All other functions in mm/page_alloc.c take zone->lock instead, for working
with page->lru free-list or PageBuddy().

setup_per_zone_pages_min() eventually calls move_freepages(), which is also
manipulating the page->lru free-list and checking for PageBuddy(). Both
should be protected by zone->lock instead of zone->lru_lock, if I understood
that right, or else there could be a race with the other functions in
mm/page_alloc.c.

We ran into a list corruption bug in free_pages_bulk() once, during memory
hotplug stress test, but cannot reproduce it easily. So I cannot verify if
using zone->lock instead of zone->lru_lock would fix it, but to me it looks
like this may be the problem.

Any thoughts?

BTW, I also wonder if a spin_lock_irq() would be enough, instead of
spin_lock_irqsave(), because this function should never be called from
interrupt context, right?

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
