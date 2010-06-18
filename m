Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 917A16B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 22:13:07 -0400 (EDT)
Date: Fri, 18 Jun 2010 10:57:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH -mm] fix bad call of memcg_oom_recover at cancel
 move.
Message-Id: <20100618105741.4e596ea7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100617092442.GJ4306@balbir.in.ibm.com>
References: <20100617172034.00ea8835.kamezawa.hiroyu@jp.fujitsu.com>
	<20100617092442.GJ4306@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jun 2010 14:54:42 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-17 17:20:34]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > When cgroup_cancel_attach() is called via cgroup_attach_task(),
> > mem_cgroup_clear_mc() can be called even when any migration
> > was done. In such case, mc.to and mc.from is NULL.
> > 
> > But, memcg-clean-up-waiting-move-acct-v2.patch
> > doesn't handle this correctly and pass NULL to memcg_oom_recover.
> > fix it.
> > 
> > BUG: unable to handle kernel paging request at 000000000000114c
> > IP: [<ffffffff81153bb9>] memcg_oom_recover+0x9/0x30
> > PGD 61ce4b067 PUD 613ea0067 PMD 0
> > Oops: 0000 [#1] SMP
> > <snip>
> > Call Trace:
> >  [<ffffffff81155359>] mem_cgroup_clear_mc+0x119/0x1c0
> >  [<ffffffff811554de>] mem_cgroup_cancel_attach+0xe/0x10
> >  [<ffffffff810b619c>] cgroup_attach_task+0x26c/0x2c0
> >  [<ffffffff810b6257>] cgroup_tasks_write+0x67/0x1c0
> >  [<ffffffff81121555>] ? might_fault+0xa5/0xb0
> >  [<ffffffff8112150c>] ? might_fault+0x5c/0xb0
> >  [<ffffffff810b40a2>] cgroup_file_write+0x2d2/0x330
> >  [<ffffffff81093aa2>] ? print_lock_contention_bug+0x22/0xf0
> >  [<ffffffff81259fef>] ? security_file_permission+0x1f/0x80
> >  [<ffffffff8115d998>] vfs_write+0xc8/0x190
> >  [<ffffffff8115e3a1>] sys_write+0x51/0x90
> >  [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b
> > Code: 20 48 39 43 20 41 bc f0 ff ff ff 75 c7 45 88 ae 48 11 00 00 45 31 e4 eb bb 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 44 00 00 <8b> 87 4c 11 00 00 85 c0 75 05 c9 c3 0f 1f 00 48 89 f9 31 d2 be
> > RIP  [<ffffffff81153bb9>] memcg_oom_recover+0x9/0x30
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > Index: mmotm-2.6.35-0611/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.35-0611.orig/mm/memcontrol.c
> > +++ mmotm-2.6.35-0611/mm/memcontrol.c
> > @@ -4485,8 +4485,10 @@ static void mem_cgroup_clear_mc(void)
> >  	mc.to = NULL;
> >  	mc.moving_task = NULL;
> >  	spin_unlock(&mc.lock);
> > -	memcg_oom_recover(from);
> > -	memcg_oom_recover(to);
> > +	if (from)
> > +		memcg_oom_recover(from);
> > +	if (to)
> > +		memcg_oom_recover(to);
> >  	wake_up_all(&mc.waitq);
> 
> May I recommend the following change instead
> 
> 
> Don't crash on a null memcg being passed, check if memcg
> is NULL and handle the condition gracefully
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c6ece0a..d71c488 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1370,7 +1370,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
>  
>  static void memcg_oom_recover(struct mem_cgroup *mem)
>  {
> -	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> +	if (mem && mem->oom_kill_disable && atomic_read(&mem->oom_lock))
>  		memcg_wakeup_oom(mem);
>  }
>  
I agree to this fix.

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
