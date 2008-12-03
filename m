Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB3MFUSl019988
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 15:15:30 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB3MGCuV191442
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 15:16:12 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB3MGBD0009256
	for <linux-mm@kvack.org>; Wed, 3 Dec 2008 15:16:12 -0700
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1228339524.6598.11.camel@t60p>
References: <1228339524.6598.11.camel@t60p>
Content-Type: text/plain
Date: Wed, 03 Dec 2008 14:16:07 -0800
Message-Id: <1228342567.13111.11.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-03 at 22:25 +0100, Gerald Schaefer wrote:
> offline_pages() calls lru_add_drain_all() followed by drain_all_pages().
> While drain_all_pages() works on each cpu, lru_add_drain_all() only runs
> on the current cpu for architectures w/o CONFIG_NUMA.

I'm a bit confused why this is.  Is this because the LRUs are per-zone
and we expected !CONFIG_NUMA systems to only have LRUs sitting on the
same (only) node as the current CPU?

This doesn't make any sense, though.  The pagevecs that
drain_cpu_pagevecs() actually empties out are per-cpu.

> This let us run
> into the BUG_ON(!PageBuddy(page)) in __offline_isolated_pages() during
> memory hotplug stress test on s390. The page in question was still on the
> pcp list, because of a race with lru_add_drain_all() and drain_all_pages()
> on different cpus.
> 
> This is fixed with this patch by adding CONFIG_MEMORY_HOTREMOVE to the
> lru_add_drain_all() #ifdef, to let it run on each cpu.

This doesn't seem right to me.  CONFIG_MEMORY_HOTREMOVE doesn't change
the layout of the LRUs, unlike NUMA or UNEVICTABLE_LRU.  So, I think
this bug is more due to the hotremove code mis-expecting behavior out of
lru_add_drain_all().

Why does this not affect the other lru_add_drain_all() users?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
