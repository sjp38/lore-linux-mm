Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 279866B009A
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 21:25:07 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o072P4hJ032564
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 11:25:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B04F2AEA8D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:25:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18B321EF083
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:25:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D6DEB1DB803F
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:25:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 814091DB803E
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 11:25:03 +0900 (JST)
Date: Thu, 7 Jan 2010 11:21:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2010-01-06-14-34 uploaded (mm/memcontrol)
Message-Id: <20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
References: <201001062259.o06MxQrp023236@imap1.linux-foundation.org>
	<20100106171058.f1d6f393.randy.dunlap@oracle.com>
	<20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 11:13:19 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> Thank you for your report.
 
> > config attached.
> > 
> I'm sorry I missed the !CONFIG_SWAP or !CONFIG_CGROUP_MEM_RES_CTLR_SWAP case.
> 
> I'll prepare fixes.
> 
Nishimura-san, could you double check this ?

Andrew, this is a fix onto Nishimura-san's memcg move account patch series.
Maybe this -> patches/memcg-move-charges-of-anonymous-swap.patch

Thanks,
-Kame
==

Build fix to following build error when CONFIG_CGROUP_MEM_RES_CTLR_SWAP is off.

mm/memcontrol.c: In function 'is_target_pte_for_mc':
mm/memcontrol.c:3985: error: implicit declaration of function 'mem_cgroup_count_swap_user'
mm/memcontrol.c: In function 'mem_cgroup_move_charge_pte_range':
mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'
mm/memcontrol.c:4220: error: too many arguments to function 'mem_cgroup_move_swap_account'

CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: ref-mmotm/mm/memcontrol.c
===================================================================
--- ref-mmotm.orig/mm/memcontrol.c
+++ ref-mmotm/mm/memcontrol.c
@@ -2369,7 +2369,7 @@ static int mem_cgroup_move_swap_account(
 }
 #else
 static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
-				struct mem_cgroup *from, struct mem_cgroup *to)
+		struct mem_cgroup *from, struct mem_cgroup *to, bool need_fixup)
 {
 	return -EINVAL;
 }
@@ -3976,7 +3976,7 @@ static int is_target_pte_for_mc(struct v
 
 	if (!pte_present(ptent)) {
 		/* TODO: handle swap of shmes/tmpfs */
-		if (pte_none(ptent) || pte_file(ptent))
+		if (pte_none(ptent) || pte_file(ptent) || !do_swap_account)
 			return 0;
 		else if (is_swap_pte(ptent)) {
 			ent = pte_to_swp_entry(ptent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
