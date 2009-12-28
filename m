Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 41A5760021B
	for <linux-mm@kvack.org>; Sun, 27 Dec 2009 21:46:44 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBS2kei8016120
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 28 Dec 2009 11:46:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BB9C45DE70
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:40 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC8BE45DE60
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF79E1DB803E
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 766AEE18002
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 11:46:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [cleanup][PATCH 2/2] mlock_vma_pages_range() only return success or failure
In-Reply-To: <20091228114519.A678.A69D9226@jp.fujitsu.com>
References: <20091228114519.A678.A69D9226@jp.fujitsu.com>
Message-Id: <20091228114611.A67B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 28 Dec 2009 11:46:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently, mlock_vma_pages_range() only return len or 0. then
current error handling of mmap_region() is meaningless complex.

this patch makes simplify and makes consist with brk() code.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/mmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 826b0ec..0f10176 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1247,8 +1247,8 @@ out:
 	mm->total_vm += len >> PAGE_SHIFT;
 	vm_stat_account(mm, vm_flags, file, len >> PAGE_SHIFT);
 	if (vm_flags & VM_LOCKED) {
-		long nr_pages = mlock_vma_pages_range(vma, addr, addr + len);
-		mm->locked_vm += (len >> PAGE_SHIFT) - nr_pages;
+		if (!mlock_vma_pages_range(vma, addr, addr + len))
+			mm->locked_vm += (len >> PAGE_SHIFT);
 	} else if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
 		make_pages_present(addr, addr + len);
 	return addr;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
