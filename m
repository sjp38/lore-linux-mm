Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 88DEB6B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 23:53:35 -0400 (EDT)
Date: Tue, 31 Aug 2010 12:51:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 4/5] memcg: lockless update of file stat with
 move-account safe method
Message-Id: <20100831125118.fa01f0c2.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100825171050.1574ba7c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100825170435.15f8eb73.kamezawa.hiroyu@jp.fujitsu.com>
	<20100825171050.1574ba7c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 17:10:50 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> At accounting file events per memory cgroup, we need to find memory cgroup
> via page_cgroup->mem_cgroup. Now, we use lock_page_cgroup().
> 
> But, considering the context which page-cgroup for files are accessed,
> we can use alternative light-weight mutual execusion in the most case.
> At handling file-caches, the only race we have to take care of is "moving"
> account, IOW, overwriting page_cgroup->mem_cgroup. Because file status
> update is done while the page-cache is in stable state, we don't have to
> take care of race with charge/uncharge.
> 
> Unlike charge/uncharge, "move" happens not so frequently. It happens only when
> rmdir() and task-moving (with a special settings.)
> This patch adds a race-checker for file-cache-status accounting v.s. account
> moving. The new per-cpu-per-memcg counter MEM_CGROUP_ON_MOVE is added.
> The routine for account move 
>   1. Increment it before start moving
>   2. Call synchronize_rcu()
>   3. Decrement it after the end of moving.
> By this, file-status-counting routine can check it needs to call
> lock_page_cgroup(). In most case, I doesn't need to call it.
> 
> Changelog: 20100825
>  - added a comment about mc.lock
>  - fixed bad lock.
> Changelog: 20100804
>  - added a comment for possible optimization hint.
> Changelog: 20100730
>  - some cleanup.
> Changelog: 20100729
>  - replaced __this_cpu_xxx() with this_cpu_xxx
>    (because we don't call spinlock)
>  - added VM_BUG_ON().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

(snip)

> @@ -1505,29 +1551,36 @@ void mem_cgroup_update_file_mapped(struc
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	bool need_lock = false;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
> -
> -	lock_page_cgroup(pc);
> +	rcu_read_lock();
>  	mem = id_to_memcg(pc->mem_cgroup, true);
It doesn't cause any problem, but I think it would be better to change this to
"id_to_memcg(..., false)". It's just under rcu_read_lock(), not under page_cgroup
lock anymore.

Otherwise, it looks good to me.

Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
