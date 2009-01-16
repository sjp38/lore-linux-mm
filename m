Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C6FB06B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 03:08:32 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G88UTa021911
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 17:08:30 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D586745DD72
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:08:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A700D45DD70
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:08:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 920E41DB803E
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:08:29 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4587D1DB803A
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 17:08:29 +0900 (JST)
Date: Fri, 16 Jan 2009 17:07:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116170724.d2ad8344.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <497025E8.8050207@cn.fujitsu.com>
References: <497025E8.8050207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 14:15:04 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Found this when testing memory resource controller, can be triggered
> with:
> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
> 

Li-san, could you try this ? I myself can't reproduce the bug yet...
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, at swapoff, even while try_charge() fails, commit is executed.
This is bug and make refcnt of cgroup_subsys_state minus, finally.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
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
