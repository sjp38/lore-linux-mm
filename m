Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BFBD26B006A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:08:54 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG38pHt028257
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:08:51 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E6B4E45DE5D
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:08:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C3D945DE56
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:08:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8322AE18035
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:08:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CD034E1803E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:08:23 +0900 (JST)
Date: Wed, 16 Dec 2009 12:05:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 5/11] mm accessor for tomoyo
Message-Id: <20091216120519.b65addb7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Replace mmap_sem with mm_accessor().
for security layer.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 security/tomoyo/common.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: mmotm-mm-accessor/security/tomoyo/common.c
===================================================================
--- mmotm-mm-accessor.orig/security/tomoyo/common.c
+++ mmotm-mm-accessor/security/tomoyo/common.c
@@ -759,14 +759,14 @@ static const char *tomoyo_get_exe(void)
 
 	if (!mm)
 		return NULL;
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
 			cp = tomoyo_realpath_from_path(&vma->vm_file->f_path);
 			break;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return cp;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
