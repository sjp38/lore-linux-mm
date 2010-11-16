Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD0C8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 15:41:24 -0500 (EST)
Date: Tue, 16 Nov 2010 12:41:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX] memcg: avoid deadlock between move charge and
 try_charge()
Message-Id: <20101116124117.64608b66.akpm@linux-foundation.org>
In-Reply-To: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
References: <20101116191748.d6645376.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, stable@kernel.org
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

I put this in the send-to-Linus-in-about-a-week queue.

> Cc: <stable@kernel.org>

The patch doesn't apply well to 2.6.36 so if we do want it backported
then please prepare a tested backport for the -stable guys?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
