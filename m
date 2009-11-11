Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A338B6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 20:52:17 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAB1qBPM019224
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Nov 2009 10:52:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D05B45DE51
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:52:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3ACF645DE4F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:52:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2489BE1800C
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:52:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C07E6E1800A
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 10:52:10 +0900 (JST)
Date: Wed, 11 Nov 2009 10:49:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: remove memcg_tasklist
Message-Id: <20091111104934.eee96fc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
	<20091111103906.5c3563bb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Nov 2009 10:39:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> memcg_tasklist was introduced at commit 7f4d454d(memcg: avoid deadlock caused
> by race between oom and cpuset_attach) instead of cgroup_mutex to fix a deadlock
> problem.  The cgroup_mutex, which was removed by the commit, in
> mem_cgroup_out_of_memory() was originally introduced at commit c7ba5c9e
> (Memory controller: OOM handling).
> 
> IIUC, the intention of this cgroup_mutex was to prevent task move during
> select_bad_process() so that situations like below can be avoided.
> 
>   Assume cgroup "foo" has exceeded its limit and is about to trigger oom.
>   1. Process A, which has been in cgroup "baa" and uses large memory, is just
>      moved to cgroup "foo". Process A can be the candidates for being killed.
>   2. Process B, which has been in cgroup "foo" and uses large memory, is just
>      moved from cgroup "foo". Process B can be excluded from the candidates for
>      being killed.
> 
> But these race window exists anyway even if we hold a lock, because
> __mem_cgroup_try_charge() decides wether it should trigger oom or not outside
> of the lock. So the original cgroup_mutex in mem_cgroup_out_of_memory and thus
> current memcg_tasklist has no use. And IMHO, those races are not so critical
> for users.
> 
> This patch removes it and make codes simpler.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
