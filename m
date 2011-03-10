Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEB98D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 01:13:25 -0500 (EST)
Date: Thu, 10 Mar 2011 15:04:28 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v4] memcg: fix leak on wrong LRU with FUSE
Message-Id: <20110310150428.f175758c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110310144752.289483d4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110308135612.e971e1f3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308181832.6386da5f.nishimura@mxp.nes.nec.co.jp>
	<20110309150750.d570798c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309164801.3a4c8d10.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309100020.GD30778@cmpxchg.org>
	<20110310083659.fd8b1c3f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110310144752.289483d4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

On Thu, 10 Mar 2011 14:47:52 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 10 Mar 2011 08:36:59 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > will add. Thank you !
> > 
> 
> Here is v4 based on feedbacks.
> ==
> 
> fs/fuse/dev.c::fuse_try_move_page() does
> 
>    (1) remove a page by ->steal()
>    (2) re-add the page to page cache 
>    (3) link the page to LRU if it was not on LRU at (1)
> 
> This implies the page is _on_ LRU when it's added to radix-tree.
> So, the page is added to  memory cgroup while it's on LRU and
> the pave will remain in the old(wrong) memcg.
> By this bug, force_empty()'s LRU scan cannot find the page and
> rmdir() will never ends.
> 
> This is the same behavior as SwapCache and needs special care as
>  - remove page from LRU before overwrite pc->mem_cgroup.
>  - add page to LRU after overwrite pc->mem_cgroup.
> 
> This will fixes memcg's rmdir() hang issue with FUSE.
> 
> Changelog v3=v4:
>   - moved PageLRU() check into the leaf function.
>   - added comments
> 
> Changelog v2=>v3:
>   - fixed double accounting.
> 
> Changelog v1=>v2:
>   - clean up.
>   - cover !PageLRU() by pagevec case.
> 
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

I hope this can fix the original BZ case.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
