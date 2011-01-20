Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 59D516B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 20:56:52 -0500 (EST)
Date: Thu, 20 Jan 2011 10:52:51 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [patch rfc] memcg: correctly order reading PCG_USED and
 pc->mem_cgroup
Message-Id: <20110120105251.f0384f8d.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110119120319.GA2232@cmpxchg.org>
References: <20110119120319.GA2232@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011 13:03:19 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> The placement of the read-side barrier is confused: the writer first
> sets pc->mem_cgroup, then PCG_USED.  The read-side barrier has to be
> between testing PCG_USED and reading pc->mem_cgroup.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c |   27 +++++++++------------------
>  1 files changed, 9 insertions(+), 18 deletions(-)
> 
> I am a bit dumbfounded as to why this has never had any impact.  I see
> two scenarios where charging can race with LRU operations:
> 
> One is shmem pages on swapoff.  They are on the LRU when charged as
> page cache, which could race with isolation/putback.  This seems
> sufficiently rare.
> 
> The other case is a swap cache page being charged while somebody else
> had it isolated.  mem_cgroup_lru_del_before_commit_swapcache() would
> see the page isolated and skip it.  The commit then has to race with
> putback, which could see PCG_USED but not pc->mem_cgroup, and crash
> with a NULL pointer dereference.  This does sound a bit more likely.
> 
> Any idea?  Am I missing something?
> 
pc->mem_cgroup is not cleared even when the page is freed, so NULL pointer
dereference can happen only when it's the first time the page is used.
But yes, even if it's not the first time, this means pc->mem_cgroup may be wrong.

Anyway, I welcome this patch.

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
