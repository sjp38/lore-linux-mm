Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6A049600309
	for <linux-mm@kvack.org>; Sun, 29 Nov 2009 19:16:11 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAU0G8HX025338
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 30 Nov 2009 09:16:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A84345DE53
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:16:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1901A45DE52
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:16:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E4E0E1DB8037
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:16:07 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DB551DB803E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:16:07 +0900 (JST)
Date: Mon, 30 Nov 2009 09:13:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/9] ksm: mem cgroup charge swapin copy
Message-Id: <20091130091316.b804a75c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0911241648520.25288@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
	<Pine.LNX.4.64.0911241648520.25288@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009 16:51:13 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> But ksm swapping does require one small change in mem cgroup handling.
> When do_swap_page()'s call to ksm_might_need_to_copy() does indeed
> substitute a duplicate page to accommodate a different anon_vma (or a
> different index), that page escaped mem cgroup accounting, because of
> the !PageSwapCache check in mem_cgroup_try_charge_swapin().
> 
> That was returning success without charging, on the assumption that
> pte_same() would fail after, which is not the case here.  Originally I
> proposed that success, so that an unshrinkable mem cgroup at its limit
> would not fail unnecessarily; but that's a minor point, and there are
> plenty of other places where we may fail an overallocation which might
> later prove unnecessary.  So just go ahead and do what all the other
> exceptions do: proceed to charge current mm.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Ok. Maybe commit_charge will work enough. (I hope so.)

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

BTW, I'm happy if you adds "How to test" documenation to
Documentation/vm/ksm.txt or to share some test programs.

1. Map anonymous pages + madvise(MADV_MERGEABLE)
2. "echo 1 > /sys/kernel/mm/ksm/run"

is enough ?

Thanks,
-Kame

> ---
> 
>  mm/memcontrol.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> --- ksm5/mm/memcontrol.c	2009-11-14 10:17:02.000000000 +0000
> +++ ksm6/mm/memcontrol.c	2009-11-22 20:40:37.000000000 +0000
> @@ -1862,11 +1862,12 @@ int mem_cgroup_try_charge_swapin(struct
>  		goto charge_cur_mm;
>  	/*
>  	 * A racing thread's fault, or swapoff, may have already updated
> -	 * the pte, and even removed page from swap cache: return success
> -	 * to go on to do_swap_page()'s pte_same() test, which should fail.
> +	 * the pte, and even removed page from swap cache: in those cases
> +	 * do_swap_page()'s pte_same() test will fail; but there's also a
> +	 * KSM case which does need to charge the page.
>  	 */
>  	if (!PageSwapCache(page))
> -		return 0;
> +		goto charge_cur_mm;
>  	mem = try_get_mem_cgroup_from_swapcache(page);
>  	if (!mem)
>  		goto charge_cur_mm;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
