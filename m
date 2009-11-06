Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 991FD6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 01:48:22 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA66mJoD019458
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 15:48:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 994F745DE62
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:48:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72BF845DE57
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:48:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F32F1DB8046
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:48:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 022831DB803B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 15:48:16 +0900 (JST)
Date: Fri, 6 Nov 2009 15:45:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-Id: <20091106154542.5ca9bb61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 14:10:11 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Hi.
> 
> In current memcg, charges associated with a task aren't moved to the new cgroup
> at task move. These patches are for this feature, that is, for recharging to
> the new cgroup and, of course, uncharging from old cgroup at task move.
> 
> Current virsion supports only recharge of non-shared(mapcount == 1) anonymous pages
> and swaps of those pages. I think it's enough as a first step.
> 
> [1/8] cgroup: introduce cancel_attach()
> [2/8] memcg: move memcg_tasklist mutex
> [3/8] memcg: add mem_cgroup_cancel_charge()
> [4/8] memcg: cleanup mem_cgroup_move_parent()
> [5/8] memcg: add interface to recharge at task move
> [6/8] memcg: recharge charges of anonymous page
> [7/8] memcg: avoid oom during recharge at task move
> [8/8] memcg: recharge charges of anonymous swap
> 
> 2 is dependent on 1 and 4 is dependent on 3.
> 3 and 4 are just for cleanups.
> 5-8 are the body of this feature.
> 
> Major Changes from Oct13:
> - removed "[RFC]".
> - rebased on mmotm-2009-11-01-10-01.
> - dropped support for file cache and shmem/tmpfs(revisit in future).
> - Updated Documentation/cgroup/memory.txt.
> 

Seems much nicer but I have some nitpicks as already commented.

For [8/8], mm->swap_usage counter may be a help for making it faster.
Concern is how it's shared but will not be very big error.

> TODO:
> - add support for file cache, shmem/tmpfs, and shared(mapcount > 1) pages.
> - implement madvise(2) to let users decide the target vma for recharge.
> 

About this, I think "force_move_shared_account" flag is enough, I think.
But we have to clarify "mmap()ed but not on page table" entries are not
moved....

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
