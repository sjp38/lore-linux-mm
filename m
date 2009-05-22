Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 536C46B005A
	for <linux-mm@kvack.org>; Fri, 22 May 2009 01:07:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M57S5x010260
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 14:07:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA6C645DE5D
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:07:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FA3B45DE57
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:07:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 738A91DB8040
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:07:27 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13D231DB803A
	for <linux-mm@kvack.org>; Fri, 22 May 2009 14:07:27 +0900 (JST)
Date: Fri, 22 May 2009 14:05:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] synchrouns swap freeing at zapping vmas
Message-Id: <20090522140555.384470ea.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090522133906.66fea0fe.nishimura@mxp.nes.nec.co.jp>
References: <20090521164100.5f6a0b75.kamezawa.hiroyu@jp.fujitsu.com>
	<20090522133906.66fea0fe.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Fri, 22 May 2009 13:39:06 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Thu, 21 May 2009 16:41:00 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> - Using shmem caused a BUG.
> 
>         BUG: sleeping function called from invalid context at include/linux/pagemap.h:327
>         in_atomic(): 1, irqs_disabled(): 0, pid: 1113, name: shmem_test_02
>         no locks held by shmem_test_02/1113.
>         Pid: 1113, comm: shmem_test_02 Not tainted 2.6.30-rc5-69e923d8 #2
>         Call Trace:
>          [<ffffffff802ad004>] ? free_swap_batch+0x40/0x7f
>          [<ffffffff80299b58>] ? shmem_free_swp+0xac/0xca
>          [<ffffffff8029a0f1>] ? shmem_truncate_range+0x57b/0x7af
>          [<ffffffff80378393>] ? __percpu_counter_add+0x3e/0x5c
>          [<ffffffff8029c458>] ? shmem_delete_inode+0x77/0xd3
>          [<ffffffff8029c3e1>] ? shmem_delete_inode+0x0/0xd3
>          [<ffffffff802d3ab7>] ? generic_delete_inode+0xe0/0x178
>          [<ffffffff802d0dda>] ? d_kill+0x24/0x46
>          [<ffffffff802d2212>] ? dput+0x134/0x141
>          [<ffffffff802c3504>] ? __fput+0x189/0x1ba
>          [<ffffffff802a50e4>] ? remove_vma+0x4e/0x83
>          [<ffffffff802a5224>] ? exit_mmap+0x10b/0x129
>          [<ffffffff80238fbd>] ? mmput+0x41/0x9f
>          [<ffffffff8023cf37>] ? exit_mm+0x101/0x10c
>          [<ffffffff8023e439>] ? do_exit+0x1a0/0x61a
>          [<ffffffff80259253>] ? trace_hardirqs_on_caller+0x113/0x13e
>          [<ffffffff8023e926>] ? do_group_exit+0x73/0xa5
>          [<ffffffff8023e96a>] ? sys_exit_group+0x12/0x16
>          [<ffffffff8020b96b>] ? system_call_fastpath+0x16/0x1b
> 
> (include/linux/pagemap.h)
>     325 static inline void lock_page(struct page *page)
>     326 {
>     327         might_sleep();
>     328         if (!trylock_page(page))
>     329                 __lock_page(page);
>     330 }
>     331
> 
> 
> I hope they would be some help for you.
> 
Thanks, I have to drop this patch ;)
Now, I found a very clean new way....I think (modify memcg's logic).
Thank you for your contribution and patience.

Thanks,
-Kame


> Thanks,
> Daisuke Nishimura.
> 
> > Any comments are welcome. 
> > 
> > Thanks,
> > -Kame
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
