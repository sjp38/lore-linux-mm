Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5DFF96B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 19:36:26 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB40aNiY002895
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Dec 2009 09:36:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6229145DE4C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:36:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 30F0F45DE5C
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:36:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D1DF51DB803A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:36:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EADDE38002
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:36:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC] high system time & lock contention running large mixed workload
In-Reply-To: <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
References: <4B15CEE0.2030503@redhat.com> <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
Message-Id: <20091204092445.587D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri,  4 Dec 2009 09:36:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 2009-12-01 at 21:20 -0500, Rik van Riel wrote:
> 
> > This is reasonable, except for the fact that pages that are moved
> > to the inactive list without having the referenced bit cleared are
> > guaranteed to be moved back to the active list.
> > 
> > You'll be better off without that excess list movement, by simply
> > moving pages directly back onto the active list if the trylock
> > fails.
> > 
> 
> 
> The attached patch addresses this issue by changing page_check_address()
> to return -1 if the spin_trylock() fails and page_referenced_one() to
> return 1 in that path so the page gets moved back to the active list.
> 
> Also, BTW, check this out: an 8-CPU/16GB system running AIM 7 Compute
> has 196491 isolated_anon pages.  This means that ~6140 processes are
> somewhere down in try_to_free_pages() since we only isolate 32 pages at
> a time, this is out of 9000 processes...
> 
> 
> ---------------------------------------------------------------------
> active_anon:2140361 inactive_anon:453356 isolated_anon:196491
>  active_file:3438 inactive_file:1100 isolated_file:0
>  unevictable:2802 dirty:153 writeback:0 unstable:0
>  free:578920 slab_reclaimable:49214 slab_unreclaimable:93268
>  mapped:1105 shmem:0 pagetables:139100 bounce:0
> 
> Node 0 Normal free:1647892kB min:12500kB low:15624kB high:18748kB 
> active_anon:7835452kB inactive_anon:785764kB active_file:13672kB 
> inactive_file:4352kB unevictable:11208kB isolated(anon):785964kB 
> isolated(file):0kB present:12410880kB mlocked:11208kB dirty:604kB 
> writeback:0kB mapped:4344kB shmem:0kB slab_reclaimable:177792kB 
> slab_unreclaimable:368676kB kernel_stack:73256kB pagetables:489972kB 
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> 
> 202895 total pagecache pages
> 197629 pages in swap cache
> Swap cache stats: add 6954838, delete 6757209, find 1251447/2095005
> Free swap  = 65881196kB
> Total swap = 67354616kB
> 3997696 pages RAM
> 207046 pages reserved
> 1688629 pages shared
> 3016248 pages non-shared

This seems we have to improve reclaim bale out logic. the system already
have 1.5GB free pages. IOW, the system don't need swap-out anymore.



> @@ -352,9 +359,11 @@ static int page_referenced_one(struct page *page,
>  	if (address == -EFAULT)
>  		goto out;
>  
> -	pte = page_check_address(page, mm, address, &ptl, 0);
> +	pte = page_check_address(page, mm, address, &ptl, 0, trylock);
>  	if (!pte)
>  		goto out;
> +	else if (pte == (pte_t *)-1)
> +		return 1;
>  
>  	/*
>  	 * Don't want to elevate referenced for mlocked page that gets this far,

Sorry, NAK.
I have to say the same thing of Rik's previous mention. shrink_active_list()
ignore the return value of page_referenced(). then above 'return 1' is meaningless.

Umm, ok, I'll make the patch myself.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
