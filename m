Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4BE546B00A2
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 20:38:11 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1D1c977024510
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 13 Feb 2009 10:38:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D279445DE50
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 10:38:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B75245DE4F
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 10:38:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 477F71DB8041
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 10:38:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B1E1DB8037
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 10:38:07 +0900 (JST)
Date: Fri, 13 Feb 2009 10:36:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] fix vmaccnt at fork (Was Re: "heuristic overcommit" and
 fork())
Message-Id: <20090213103655.3a0ea204.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <ED3886372DB5491AAA799709DBA78F6F@david>
References: <ED3886372DB5491AAA799709DBA78F6F@david>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: linux-kernel@vger.kernel.org, David CHAMPELOVIER <david@champelovier.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 20:26:32 +0100
"David CHAMPELOVIER" <david@champelovier.com> wrote:

> Hi,
> 
> Recently, I was unable to fork() a 38 GB process on a system with 64 GB RAM
> and no swap.
> Having a look at the kernel source, I surprisingly found that in "heuristic
> overcommit" mode, fork() always checks that there is enough memory to
> duplicate process memory.
> 
> As far as I know, overcommit was introduced in the kernel for several
> reasons, and fork() was one of them, since applications often exec() just
> after fork(). I know fork() is not the most judicious choice in this case,
> but well, this is the way many applications are written.
> 
> Moreover, I can read in the proc man page that in "heuristic overcommit
> mode", "obvious overcommits of address space are refused". I do not think
> fork() is an obvious overcommit, that's why I would expect fork() to be
> always accepted in this mode.
> 
> So, is there a reason why fork() checks for available memory in "heuristic
> mode" ?
> 

fork() is used for duplicate process and it means to duplicate memory space.
Because of Copy-On-Write, the page will not be used acutally. But, it's not
different from mmap() case. In that case, overcommit_guess compares
requested size and size of free memory for all that we use demand paging.
So, the behavior is not surprizing.  For notifing the kernel can assume
exec-is-called-after-fork, we may need some flags or paramater.

But, hmm.., there is something strange, following. Mel, how do you think ?
==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Vm accounting at fork() should use the same logic as mmap().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm.h |    2 ++
 kernel/fork.c      |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: mmotm-2.6.29-Feb11/kernel/fork.c
===================================================================
--- mmotm-2.6.29-Feb11.orig/kernel/fork.c
+++ mmotm-2.6.29-Feb11/kernel/fork.c
@@ -301,7 +301,8 @@ static int dup_mmap(struct mm_struct *mm
 			continue;
 		}
 		charge = 0;
-		if (mpnt->vm_flags & VM_ACCOUNT) {
+		if (accountable_mapping(mpnt->vm_file, mpnt->vm_flags) &&
+			mpnt->vm_flags & VM_ACCOUNT) {
 			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			if (security_vm_enough_memory(len))
 				goto fail_nomem;
Index: mmotm-2.6.29-Feb11/include/linux/mm.h
===================================================================
--- mmotm-2.6.29-Feb11.orig/include/linux/mm.h
+++ mmotm-2.6.29-Feb11/include/linux/mm.h
@@ -1047,6 +1047,8 @@ extern void free_bootmem_with_active_reg
 typedef int (*work_fn_t)(unsigned long, unsigned long, void *);
 extern void work_with_active_regions(int nid, work_fn_t work_fn, void *data);
 extern void sparse_memory_present_with_active_regions(int nid);
+extern int accountable_mapping(struct file *file, unsigned int vmflags);
+
 #endif /* CONFIG_ARCH_POPULATES_NODE_MAP */
 
 #if !defined(CONFIG_ARCH_POPULATES_NODE_MAP) && \



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
