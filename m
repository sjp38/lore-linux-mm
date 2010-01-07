Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 65BA66B00B3
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 00:11:14 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o075BCw1029619
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 14:11:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CED7B45DE52
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:11:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA58045DE58
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:11:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DEE9E38006
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:11:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 695EDE08001
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 14:11:10 +0900 (JST)
Date: Thu, 7 Jan 2010 14:07:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm] build fix for
 memcg-move-charges-of-anonymous-swap.patch
Message-Id: <20100107140758.c2f14802.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107133026.6350bd9d.kamezawa.hiroyu@jp.fujitsu.com>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
	<20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
	<20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107130609.31fe83dc.nishimura@mxp.nes.nec.co.jp>
	<20100107133026.6350bd9d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 13:30:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 7 Jan 2010 13:06:09 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > build fix in !CONFIG_SWAP case.
> > 
> >   CC      mm/memcontrol.o
> > mm/memcontrol.c: In function 'is_target_pte_for_mc':
> > mm/memcontrol.c:3648: error: implicit declaration of function 'mem_cgroup_count_swap_user'
> > make[1]: *** [mm/memcontrol.o] Error 1
> > make: *** [mm] Error 2
> > 
> > Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Hmm, this doesn't seem include fix for CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
> ==
> static int is_target_pte_for_mc(struct vm_area_struct *vma,
>                 unsigned long addr, pte_t ptent, union mc_target *target)
> {
> ....
>                 else if (is_swap_pte(ptent)) {
>                         ent = pte_to_swp_entry(ptent);
>                         if (!move_anon || non_swap_entry(ent))
>                                 return 0;
>                         usage_count = mem_cgroup_count_swap_user(ent, &page);
>                 }
> ==
> At least, !do_swap_account check is necessary, I think.
> I'm sorry if I miss something...
> 

Get follwoing after this patch with !CONFIG_SWAP case.
==
mm/built-in.o: In function `is_target_pte_for_mc':
/home/kamezawa/Kernel/ref-mmotm/mm/memcontrol.c:3985: undefined reference to `mem_cgroup_count_swap_user'


I think !do_swap_count check in is_target_pte_for_mc() should be added.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
