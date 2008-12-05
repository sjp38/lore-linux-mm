Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.1/8.13.1) with ESMTP id mB5D8XRS016144
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:08:33 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB5D8XMY2179298
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:08:33 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB5D8WXM000572
	for <linux-mm@kvack.org>; Fri, 5 Dec 2008 13:08:33 GMT
Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Reply-To: gerald.schaefer@de.ibm.com
In-Reply-To: <1228342567.13111.11.camel@nimitz>
References: <1228339524.6598.11.camel@t60p>
	 <1228342567.13111.11.camel@nimitz>
Content-Type: text/plain
Date: Fri, 05 Dec 2008 14:08:20 +0100
Message-Id: <1228482500.8392.15.camel@t60p>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 2008-12-03 at 14:16 -0800, Dave Hansen wrote:
> I'm a bit confused why this is.  Is this because the LRUs are per-zone
> and we expected !CONFIG_NUMA systems to only have LRUs sitting on the
> same (only) node as the current CPU?
> 
> This doesn't make any sense, though.  The pagevecs that
> drain_cpu_pagevecs() actually empties out are per-cpu.

Right, the pagevecs are per-cpu, independent from any CONFIG_NUMA
settings, and this is exactly why I would expect that lru_add_drain_all()
works on all cpus, as opposed to lru_add_drain() which works only on
the current cpu.

> This doesn't seem right to me.  CONFIG_MEMORY_HOTREMOVE doesn't change
> the layout of the LRUs, unlike NUMA or UNEVICTABLE_LRU.  So, I think
> this bug is more due to the hotremove code mis-expecting behavior out of
> lru_add_drain_all().
> 
> Why does this not affect the other lru_add_drain_all() users?

Good question, there are only a few other users and most of them were
added just recently with the unevictable lru patches. The only exception
is migrate_prep(), but this is only called from sys_move_pages(), which
is not implemented w/o CONFIG_NUMA afaik.

As explained above, the per-cpu pagevec layout should be independent
from NUMA or UNEVICTABLE_LRU, so I guess the right thing to do here
is completely remove the #ifdef as in the patch from Kosaki Motohiro
(or at least replace it with a CONFIG_SMP as suggested by Kamezawa
Hiroyuki).

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
