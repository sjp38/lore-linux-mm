Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 611DA6B00ED
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 04:47:46 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8D8WRIV031117
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 04:32:27 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8D8lhQU109036
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 04:47:43 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8D8lh9i021602
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 05:47:43 -0300
Date: Mon, 13 Sep 2010 14:17:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix race in file_mapped accouting flag
 management
Message-ID: <20100913084741.GD17950@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100913160822.0c2cd732.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, gthelen@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-13 16:08:22]:

> 
> I think this small race is not very critical but it's bug.
> We have this race since 2.6.34. 
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now. memory cgroup accounts file-mapped by counter and flag.
> counter is working in the same way with zone_stat but FileMapped flag only
> exists in memcg (for helping move_account).
> 
> This flag can be updated wrongly in a case. Assume CPU0 and CPU1
> and a thread mapping a page on CPU0, another thread unmapping it on CPU1.
> 
>     CPU0                   		CPU1
> 				rmv rmap (mapcount 1->0)
>    add rmap (mapcount 0->1) 
>    lock_page_cgroup()
>    memcg counter+1		(some delay)
>    set MAPPED FLAG.
>    unlock_page_cgroup()
> 				lock_page_cgroup()
> 				memcg counter-1
> 				clear MAPPED flag
> 
> In above sequence, counter is properly updated but FLAG is not.
> This means that representing a state by a flag which is maintained by
> counter needs some specail care.

In the situation above who has the PTE lock? Are we not synchronized
via the PTE lock such that add rmap and rm rmap, will not happen
simultaneously?

> 
> To handle this, at claering a flag, this patch check mapcount directly and
                     ^^^^ (clearing)
> clear the flag only when mapcount == 0. (if mapcount >0, someone will make
> it to zero later and flag will be cleared.)
> 
> Reverse case, dec-after-inc cannot be a problem because page_table_lock()
> works well for it. (IOW, to make above sequence, 2 processes should touch
> the same page at once with map/unmap.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
