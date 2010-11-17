Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CBBD46B00A1
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:17:08 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAH0H5bH031816
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Nov 2010 09:17:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D53F45DE51
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:17:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A3845DE4F
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:17:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 13B84E08003
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:17:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9C8E38003
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 09:17:04 +0900 (JST)
Date: Wed, 17 Nov 2010 09:11:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX] memcg: avoid deadlock between move charge and
 try_charge()
Message-Id: <20101117091135.1d811e89.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
References: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 19:17:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> __mem_cgroup_try_charge() can be called under down_write(&mmap_sem)(e.g.
> mlock does it). This means it can cause deadlock if it races with move charge:
> 
> Ex.1)
>                 move charge             |        try charge
>   --------------------------------------+------------------------------
>     mem_cgroup_can_attach()             |  down_write(&mmap_sem)
>       mc.moving_task = current          |    ..
>       mem_cgroup_precharge_mc()         |  __mem_cgroup_try_charge()
>         mem_cgroup_count_precharge()    |    prepare_to_wait()
>           down_read(&mmap_sem)          |    if (mc.moving_task)
>           -> cannot aquire the lock     |    -> true
>                                         |      schedule()
> 
> Ex.2)
>                 move charge             |        try charge
>   --------------------------------------+------------------------------
>     mem_cgroup_can_attach()             |
>       mc.moving_task = current          |
>       mem_cgroup_precharge_mc()         |
>         mem_cgroup_count_precharge()    |
>           down_read(&mmap_sem)          |
>           ..                            |
>           up_read(&mmap_sem)            |
>                                         |  down_write(&mmap_sem)
>     mem_cgroup_move_task()              |    ..
>       mem_cgroup_move_charge()          |  __mem_cgroup_try_charge()
>         down_read(&mmap_sem)            |    prepare_to_wait()
>         -> cannot aquire the lock       |    if (mc.moving_task)
>                                         |    -> true
>                                         |      schedule()
> 
> To avoid this deadlock, we do all the move charge works (both can_attach() and
> attach()) under one mmap_sem section.
> And after this patch, we set/clear mc.moving_task outside mc.lock, because we
> use the lock only to check mc.from/to.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: <stable@kernel.org>

Thanks,
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
