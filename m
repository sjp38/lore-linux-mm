Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A337A6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 04:14:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0D9ELH6016927
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jan 2009 18:14:21 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7620D45DD76
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:14:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3401845DD7A
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:14:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 955251DB8043
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:14:20 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A81C1DB803A
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:14:20 +0900 (JST)
Date: Tue, 13 Jan 2009 18:13:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2009-01-12-16-53 uploaded
Message-Id: <20090113181317.48e910af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
References: <200901130053.n0D0rhev023334@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghan@google.com, mikew@google.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Mon, 12 Jan 2009 16:53:43 -0800
akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2009-01-12-16-53 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> and will soon be available at
> 
>    git://git.zen-sources.org/zen/mmotm.git
> 

After rtc compile fix, the kernel boots.

But with CONFIG_DEBUG_VM, I saw BUG_ON() at 

fork() -> ...
	-> copy_page_range() ...
		-> copy_one_pte()
			->page_dup_rmap()
				-> __page_check_anon_rmap().

BUG_ON(page->index != linear_page_index(vma, address)); 
fires. (from above, the page is ANON.)

It seems page->index == 0x7FFFFFFE here and the page seems to be
the highest address of stack.

This is caused by
 fs-execc-fix-value-of-vma-vm_pgoff-for-the-stack-vma-of-32-bit-processes.patch 


This is a fix.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

pgoff is *not* vma->vm_start >> PAGE_SHIFT.
And no adjustment is necessary (when it maps the same start
before/after adjust vma.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
Index: mmotm-2.6.29-Jan12/fs/exec.c
===================================================================
--- mmotm-2.6.29-Jan12.orig/fs/exec.c
+++ mmotm-2.6.29-Jan12/fs/exec.c
@@ -509,7 +509,7 @@ static int shift_arg_pages(struct vm_are
 	unsigned long length = old_end - old_start;
 	unsigned long new_start = old_start - shift;
 	unsigned long new_end = old_end - shift;
-	unsigned long new_pgoff = new_start >> PAGE_SHIFT;
+	unsigned long new_pgoff = vma->vm_pgoff;
 	struct mmu_gather *tlb;
 
 	BUG_ON(new_start > new_end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
