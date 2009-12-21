Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AB3276B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:04:36 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL74Y3U023763
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:04:34 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CEFE45DE52
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:04:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C49845DE4F
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:04:34 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0862F1DB803C
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:04:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C7CF1DB803F
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:04:33 +0900 (JST)
Date: Mon, 21 Dec 2009 16:01:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 4/8] memcg: move charges of anonymous page
Message-Id: <20091221160128.ad2779f6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221143503.dab0a48a.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143503.dab0a48a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:35:03 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch is the core part of this move-charge-at-task-migration feature.
> It implements functions to move charges of anonymous pages mapped only by
> the target task.
> 
> Implementation:
> - define struct move_charge_struct and a valuable of it(mc) to remember the
>   count of pre-charges and other information.
> - At can_attach(), get anon_rss of the target mm, call __mem_cgroup_try_charge()
>   repeatedly and count up mc.precharge.
> - At attach(), parse the page table, find a target page to be move, and call
>   mem_cgroup_move_account() about the page.
> - Cancel all precharges if mc.precharge > 0 on failure or at the end of
>   task move.
> 
> Changelog: 2009/12/04
> - change the term "recharge" to "move_charge".
> - handle a signal in can_attach() phase.
> - parse the page table in can_attach() phase again(go back to the old behavior),
>   because it doesn't add so big overheads, so it would be better to calculate
>   the precharge count more accurately.
> Changelog: 2009/11/19
> - in can_attach(), instead of parsing the page table, make use of per process
>   mm_counter(anon_rss).
> - loosen the valid check in is_target_pte_for_recharge().
> Changelog: 2009/11/06
> - drop support for file cache, shmem/tmpfs and shared(used by multiple processes)
>   pages(revisit in future).
> Changelog: 2009/10/13
> - change the term "migrate" to "recharge".
> Changelog: 2009/09/24
> - in can_attach(), parse the page table of the task and count only the number
>   of target ptes and call try_charge() repeatedly. No isolation at this phase.
> - in attach(), parse the page table of the task again, and isolate the target
>   page and call move_account() one by one.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
