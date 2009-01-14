Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 182576B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 02:23:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0E7NpTL015683
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 14 Jan 2009 16:23:51 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 48EAA45DD7A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:23:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 079ED45DD77
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:23:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B52B1DB8047
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:23:50 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1CDF1DB803F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:23:49 +0900 (JST)
Date: Wed, 14 Jan 2009 16:22:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] don't show pgoff of vma if vma is pure ANON (was Re:
 mmotm 2009-01-12-16-53 uploaded)
Message-Id: <20090114162245.923c4caf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <496CC9D8.6040909@google.com>
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
	<20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
	<496CC9D8.6040909@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jan 2009 09:05:28 -0800
Mike Waychison <mikew@google.com> wrote:


> > ===================================================================
> > --- mmotm-2.6.29-Jan12.orig/fs/exec.c
> > +++ mmotm-2.6.29-Jan12/fs/exec.c
> > @@ -509,7 +509,7 @@ static int shift_arg_pages(struct vm_are
> >  	unsigned long length = old_end - old_start;
> >  	unsigned long new_start = old_start - shift;
> >  	unsigned long new_end = old_end - shift;
> > -	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
> > +	unsigned long new_pgoff = vma->vm_pgoff;
> >  	struct mmu_gather *tlb;
> >  
> >  	BUG_ON(new_start > new_end);
> > 
> 
> This patch is just reverting the behaviour back to having a 64bit pgoff. 
>   Best just reverting the patch for the time being.
> 
Hmm, is this brutal ?

==
Recently, it's argued that what proc/pid/maps shows is ugly when a
32bit binary runs on 64bit host.

/proc/pid/maps outputs vma's pgoff member but vma->pgoff is of no use
information is the vma is for ANON.
By this patch, /proc/pid/maps shows just 0 if no file backing store.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.29-Jan13/fs/proc/task_mmu.c
===================================================================
--- mmotm-2.6.29-Jan13.orig/fs/proc/task_mmu.c
+++ mmotm-2.6.29-Jan13/fs/proc/task_mmu.c
@@ -220,7 +220,8 @@ static void show_map_vma(struct seq_file
 			flags & VM_WRITE ? 'w' : '-',
 			flags & VM_EXEC ? 'x' : '-',
 			flags & VM_MAYSHARE ? 's' : 'p',
-			((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
+			(!vma->vm_file)? 0 :
+				((loff_t)vma->vm_pgoff) << PAGE_SHIFT,
 			MAJOR(dev), MINOR(dev), ino, &len);
 
 	/*
Index: mmotm-2.6.29-Jan13/fs/proc/task_nommu.c
===================================================================
--- mmotm-2.6.29-Jan13.orig/fs/proc/task_nommu.c
+++ mmotm-2.6.29-Jan13/fs/proc/task_nommu.c
@@ -143,7 +143,8 @@ static int nommu_vma_show(struct seq_fil
 		   flags & VM_WRITE ? 'w' : '-',
 		   flags & VM_EXEC ? 'x' : '-',
 		   flags & VM_MAYSHARE ? flags & VM_SHARED ? 'S' : 's' : 'p',
-		   (unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
+		   (!vma->vm_file) ? 0 :
+			(unsigned long long) vma->vm_pgoff << PAGE_SHIFT,
 		   MAJOR(dev), MINOR(dev), ino, &len);
 
 	if (file) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
