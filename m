Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED7C86B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 04:24:57 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G9OtHF009492
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 18:24:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8981945DE4F
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:24:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C01045DD72
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:24:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 514481DB803A
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:24:55 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 100F41DB8037
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 18:24:55 +0900 (JST)
Date: Fri, 16 Jan 2009 18:23:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX] [PATCH] memcg: fix refcnt handling at swapoff
Message-Id: <20090116182351.42c3ff7e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116181235.320d372b.kamezawa.hiroyu@jp.fujitsu.com>
References: <497025E8.8050207@cn.fujitsu.com>
	<20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
	<20090116172651.3e11fb0c.nishimura@mxp.nes.nec.co.jp>
	<20090116181235.320d372b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 18:12:35 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> How-to-reproduce.
> 
> In shell-A
>   #mount -t cgroup none /opt/cgroup
>   #mkdir /opt/cgroup/xxx/
>   #echo 0 > /opt/cgroup/xxx/tasks
>   #Run malloc 100M on this and sleep. ---(*)
> 
> In shell-B.
>   #echo 40M > /opt/cgroup/xxx/memory.limit_in_bytes.
>   Then, you'll see 60M of swap.
>   #/sbin/swapoff -a 
>   Then, you'll see OOM-Kill against (*)
>   #echo shell-A > /opt/cgroup/tasks
>   make /opt/cgroup/xxx/ empty
>   #rmdir /opt/cgroup/xxx
> 
> => panics.
> 
I'll update how-to-test text under Documentation/ later.
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, at swapoff, even while try_charge() fails, commit is executed.
This is bug and make refcnt of cgroup_subsys_state minus, finally.

Reported-by: Li Zefan <lizf@cn.fujitsu.com>
Tested-by: Li Zefan <lizf@cn.fujitsu.com>
Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/swapfile.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Jan14/mm/swapfile.c
===================================================================
--- mmotm-2.6.29-Jan14.orig/mm/swapfile.c
+++ mmotm-2.6.29-Jan14/mm/swapfile.c
@@ -698,8 +698,10 @@ static int unuse_pte(struct vm_area_stru
 	pte_t *pte;
 	int ret = 1;
 
-	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr))
+	if (mem_cgroup_try_charge_swapin(vma->vm_mm, page, GFP_KERNEL, &ptr)) {
 		ret = -ENOMEM;
+		goto out_nolock;
+	}
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
@@ -723,6 +725,7 @@ static int unuse_pte(struct vm_area_stru
 	activate_page(page);
 out:
 	pte_unmap_unlock(pte, ptl);
+out_nolock:
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
