Date: Tue, 26 Feb 2008 10:43:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 13/15] memcg: fix mem_cgroup_move_lists locking
Message-Id: <20080226104303.5db0df8e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0802252347160.27067@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252347160.27067@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:49:04 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Ever since the VM_BUG_ON(page_get_page_cgroup(page)) (now Bad page state)
> went into page freeing, I've hit it from time to time in testing on some
> machines, sometimes only after many days.  Recently found a machine which
> could usually produce it within a few hours, which got me there at last.
> 
> The culprit is mem_cgroup_move_lists, whose locking is inadequate; and
> the arrangement of structures was such that you got page_cgroups from
> the lru list neatly put on to SLUB's freelist.  Kamezawa-san identified
> the same hole independently.
> 
> The main problem was that it was missing the lock_page_cgroup it needs
> to safely page_get_page_cgroup; but it's tricky to go beyond that too,
> and I couldn't do it with SLAB_DESTROY_BY_RCU as I'd expected.
> See the code for comments on the constraints.
> 
> This patch immediately gets replaced by a simpler one from Hirokazu-san;
> but is it just foolish pride that tells me to put this one on record,
> in case we need to come back to it later?
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
yes, we need this patch.

BTW, what is "a simpler one from Hirokazu-san" ? 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
