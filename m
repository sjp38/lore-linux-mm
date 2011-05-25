Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E62D6B0012
	for <linux-mm@kvack.org>; Wed, 25 May 2011 03:09:00 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0F5AF3EE0BD
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:08:57 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBF9C45DF50
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:08:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BEE7B45DF4A
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:08:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADCDAE08002
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:08:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B4FC1DB803B
	for <linux-mm@kvack.org>; Wed, 25 May 2011 16:08:56 +0900 (JST)
Message-ID: <4DDCAB01.8080700@jp.fujitsu.com>
Date: Wed, 25 May 2011 16:08:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/4] pagewalk: Fix walk_page_range() don't check find_vma()
 result properly
References: <4DDCAAC0.20102@jp.fujitsu.com>
In-Reply-To: <4DDCAAC0.20102@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, kamezawa.hiroyu@jp.fujitsu.com

The doc of find_vma() says,

    /* Look up the first VMA which satisfies  addr < vm_end,  NULL if none. */
    struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
    {
     (snip)

Thus, caller should confirm whether the returned vma matches a desired one.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/pagewalk.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index c3450d5..606bbb4 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -176,7 +176,7 @@ int walk_page_range(unsigned long addr, unsigned long end,
 		 * we can't handled it in the same manner as non-huge pages.
 		 */
 		vma = find_vma(walk->mm, addr);
-		if (vma && is_vm_hugetlb_page(vma)) {
+		if (vma && vma->vm_start <= addr && is_vm_hugetlb_page(vma)) {
 			if (vma->vm_end < next)
 				next = vma->vm_end;
 			/*
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
