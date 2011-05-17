Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 417526B0011
	for <linux-mm@kvack.org>; Tue, 17 May 2011 14:24:49 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4HIOl7i026463
	for <linux-mm@kvack.org>; Tue, 17 May 2011 11:24:47 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by wpaz24.hot.corp.google.com with ESMTP id p4HIOf34021970
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 May 2011 11:24:46 -0700
Received: by pvg13 with SMTP id 13so406911pvg.26
        for <linux-mm@kvack.org>; Tue, 17 May 2011 11:24:41 -0700 (PDT)
Date: Tue, 17 May 2011 11:24:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH mmotm] add the pagefault count into memcg stats: shmem fix
Message-ID: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
target mm, not for current mm (but of course they're usually the same).

We don't know the target mm in shmem_getpage(), so do it at the outer
level in shmem_fault(); and it's easier to follow if we move the
count_vm_event(PGMAJFAULT) there too.

Hah, it was using __count_vm_event() before, sneaking that update into
the unpreemptible section under info->lock: well, it comes to the same
on x86 at least, and I still think it's best to keep these together.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

--- mmotm/mm/shmem.c	2011-05-13 14:57:45.367884578 -0700
+++ linux/mm/shmem.c	2011-05-17 10:27:19.901934756 -0700
@@ -1293,14 +1293,10 @@ repeat:
 		swappage = lookup_swap_cache(swap);
 		if (!swappage) {
 			shmem_swp_unmap(entry);
+			spin_unlock(&info->lock);
 			/* here we actually do the io */
-			if (type && !(*type & VM_FAULT_MAJOR)) {
-				__count_vm_event(PGMAJFAULT);
-				mem_cgroup_count_vm_event(current->mm,
-							  PGMAJFAULT);
+			if (type)
 				*type |= VM_FAULT_MAJOR;
-			}
-			spin_unlock(&info->lock);
 			swappage = shmem_swapin(swap, gfp, info, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
@@ -1539,7 +1535,10 @@ static int shmem_fault(struct vm_area_st
 	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
-
+	if (ret & VM_FAULT_MAJOR) {
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+	}
 	return ret | VM_FAULT_LOCKED;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
