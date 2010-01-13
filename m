Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6D1736B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 00:39:21 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0D5dIAY026116
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 Jan 2010 14:39:18 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 09A6A45DE57
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 14:39:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B26845DE53
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 14:39:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FDF2E18002
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 14:39:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 37B93E18003
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 14:39:14 +0900 (JST)
Date: Wed, 13 Jan 2010 14:35:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: ensure list is empty at rmdir
Message-Id: <20100113143555.df2cb1cc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100113142707.1c857d1d.nishimura@mxp.nes.nec.co.jp>
References: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
	<20100113103006.8cf3b23c.nishimura@mxp.nes.nec.co.jp>
	<20100113122754.d390d0a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100113142707.1c857d1d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jan 2010 14:27:07 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> For example:
> - Pages can be uncharged by its owner process while they are on LRU.
> - race between mem_cgroup_add_lru_list() and __mem_cgroup_uncharge_common().
> 
> So there can be a case in which the usage is zero but some of the LRUs are not empty.
> 
> OTOH, mem_cgroup_del_lru_list(), which can be called asynchronously with rmdir,
> accesses the mem_cgroup, so this access can cause a problem if it races with
> rmdir because the mem_cgroup might have been freed by rmdir.
> 
 
> The problem here is pages on LRU may contain pointer to stale memcg.
> To make res->usage to be 0, all pages on memcg must be uncharged or moved to
> another(parent) memcg. Moved page_cgroup have already removed from original LRU,
> but uncharged page_cgroup contains pointer to memcg withou PCG_USED bit. (This
> asynchronous LRU work is for improving performance.) If PCG_USED bit is not set,
> page_cgroup will never be added to memcg's LRU. So, about pages not on LRU, they
> never access stale pointer. Then, what we have to take care of is page_cgroup
> _on_ LRU list. This patch fixes this problem by making mem_cgroup_force_empty()
> visit all LRUs before exiting its loop and guarantee there are no pages on its LRU.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: stable@kernel.org

Thank you. very nice.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
