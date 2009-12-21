Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0B06C6B0044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 02:05:32 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBL75UNE024207
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 21 Dec 2009 16:05:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AE8F45DE51
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:05:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 704B445DE4F
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:05:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 551611DB8044
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:05:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B58A1DB8041
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 16:05:30 +0900 (JST)
Date: Mon, 21 Dec 2009 16:02:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 5/8] memcg: improve performance in moving charge
Message-Id: <20091221160224.af4e4023.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091221143620.4830a54c.nishimura@mxp.nes.nec.co.jp>
References: <20091221143106.6ff3ca15.nishimura@mxp.nes.nec.co.jp>
	<20091221143620.4830a54c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 21 Dec 2009 14:36:20 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch tries to reduce overheads in moving charge by:
> 
> - Instead of calling res_counter_uncharge() against the old cgroup in
>   __mem_cgroup_move_account() everytime, call res_counter_uncharge() at the end
>   of task migration once.
> - removed css_get(&to->css) from __mem_cgroup_move_account() because callers
>   should have already called css_get(). And removed css_put(&to->css) too,
>   which was called by callers of move_account on success of move_account.
> - Instead of calling __mem_cgroup_try_charge(), i.e. res_counter_charge(),
>   repeatedly, call res_counter_charge(PAGE_SIZE * count) in can_attach() if
>   possible.
> - Instead of calling css_get()/css_put() repeatedly, make use of coalesce
>   __css_get()/__css_put() if possible.
> 
> These changes reduces the overhead from 1.7sec to 0.6sec to move charges of 1G
> anonymous memory in my test environment.
> 
> Changelog: 2009/12/14
> - move cgroup part to another patch.
> - fix some bugs.
> 
> Changelog: 2009/12/04
> - new patch
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
