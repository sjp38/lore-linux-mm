Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5CEF66B00D3
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 19:58:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3RNxQdp013182
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Apr 2009 08:59:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CBED45DE4F
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:59:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D9E2B45DD72
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:59:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C7597E18004
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:59:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D9A6E18002
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 08:59:25 +0900 (JST)
Date: Tue, 28 Apr 2009 08:57:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix leak of swap accounting as stale swap cache under
 memcg
Message-Id: <20090428085753.a91b6007.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <661de9470904271217t7ef9e300x1e40bbf0362ca14f@mail.gmail.com>
References: <20090427181259.6efec90b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090427101323.GK4454@balbir.in.ibm.com>
	<20090427203535.4e3f970b.d-nishimura@mtf.biglobe.ne.jp>
	<661de9470904271217t7ef9e300x1e40bbf0362ca14f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 00:47:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Thanks for the detailed explanation of the possible race conditions. I
> am beginning to wonder why we don't have any hooks in add_to_swap.*.
> for charging a page. If the page is already charged and if it is a
> context issue (charging it to the right cgroup) that is already
> handled from what I see. Won't that help us solve the !PageCgroupUsed
> issue?
> 

For adding hook to add_to_swap_cache, we need to know which cgroup the swap cache
should be charged. Then, we have to remove CONFIG_CGROUP_MEM_RES_CTRL_SWAP_EXT
and enable memsw control always.

When using swap_cgroup, we'll know which cgroup the new swap cache should be charged.
Then, the new page readed in will be charged to recorded cgroup in swap_cgroup.
One bad thing of this method is a cgroup which swap_cgroup point to is different from
a cgroup which the task calls do_swap_fault(). This means that a page-fault by a
task can cause memory-reclaim under another cgroup and moreover, OOM.
I don't think it's sane behavior. So, current design of swap accounting waits until the
page is mapped.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
