Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA8B6B0055
	for <linux-mm@kvack.org>; Tue, 12 May 2009 04:02:47 -0400 (EDT)
Date: Tue, 12 May 2009 17:00:07 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 4/3] memcg: call uncharge_swapcache outside of tree_lock
 (Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7)
Message-Id: <20090512170007.ad7f5c7b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090512160901.8a6c5f64.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512140648.0974cb10.nishimura@mxp.nes.nec.co.jp>
	<20090512160901.8a6c5f64.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> I understand the problem, but, wait a bit. NACK to this patch itself.
> 
> 1. I placed _uncharge_ inside tree_lock because __remove_from_page_cache() does.
>    (i.e. using the same logic.)
>    So, plz change both logic at once.(change caller of  mem_cgroup_uncharge_cache_page())
> 
hmm, I see.
cache_charge is outside of tree_lock, so moving uncharge would make sense.
IMHO, we should make the period of spinlock as small as possible,
and charge/uncharge of pagecache/swapcache is protected by page lock, not tree_lock.

> 2. Shouldn't we disable IRQ while __mem_cgroup_uncharge_common() rather than moving
>    function ?
> 
Yes, this is another choise.
But, isn't it better to disable IRQ at all users of lock_page_cgroup..unlock_page_cgroup
to avoid this dead lock ?

Anyway, I'll postpone this fix for a while.
We should fix stale swap swapcache first.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
