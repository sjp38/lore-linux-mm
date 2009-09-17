Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0A79C6B005A
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:20:07 -0400 (EDT)
Date: Thu, 17 Sep 2009 15:17:38 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 7/8] memcg: migrate charge of swap
Message-Id: <20090917151738.503de68c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917142558.58f3e8ef.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112817.b3829458.nishimura@mxp.nes.nec.co.jp>
	<20090917142558.58f3e8ef.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 14:25:58 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 17 Sep 2009 11:28:17 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch is another core part of this charge migration feature.
> > It enables charge migration of swap.
> > 
> > Unlike mapped page, swaps of anonymous pages have its entry stored in the pte.
> > So this patch calls read_swap_cache_async() and do the same thing about the swap-in'ed
> > page as anonymous pages in migrate_charge_prepare_pte_range(), and handles !PageCgroupUsed
> > case in mem_cgroup_migrate_charge().
> 
> Hmmm.....do we really need to do swap-in ? I think no.
> 
I do agree with you.
I did swap-in just to remember the target pages(I cannot find a good way to remember all of
target swap entries).

If we go parse-pagetable-twice direction as mentioned in another mail,
list would be unnecessary anyway.

> > 
> > To exchange swap_cgroup's record safely, this patch changes swap_cgroup_record()
> > to use xchg, and define new function to cmpxchg swap_cgroup's record.
> > 
> I think this is enough.
> 
Agreed.

> BTW, it's not very bad to do this exchange under swap_lock. (if charge is done.)
> Then, the whole logic can be simple.
> 
Current memcg in mmotm calls swap_cgroup_record() under swap_lock except
__mem_cgroup_commit_charge_swapin().
Instead of doing all of it under swap_lock, I choose lockless(cmpxchg) implementation.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
