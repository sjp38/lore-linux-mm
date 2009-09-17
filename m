Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C56546B0055
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 22:44:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H2j0Ff029666
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 11:45:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6466D45DE55
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:45:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4089C45DE62
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:45:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C9D91DB803C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:45:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C265E1DB8042
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:44:59 +0900 (JST)
Date: Thu, 17 Sep 2009 11:42:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/3][mmotm] kcore: more fixes for init
Message-Id: <20090917114256.1f3971d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	<1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	<20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Am?rico_Wang <xiyou.wangcong@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

proc_kcore_init() doesn't check NULL case.
fix it and remove unnecessary comments.

Cc: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/kcore.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
===================================================================
--- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
+++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
@@ -606,6 +606,10 @@ static int __init proc_kcore_init(void)
 {
 	proc_root_kcore = proc_create("kcore", S_IRUSR, NULL,
 				      &proc_kcore_operations);
+	if (!proc_root_kcore) {
+		printk(KERN_ERR "couldn't create /proc/kcore\n");
+		return 0; /* Always returns 0. */
+	}
 	/* Store text area if it's special */
 	proc_kcore_text_init();
 	/* Store vmalloc area */
@@ -615,7 +619,6 @@ static int __init proc_kcore_init(void)
 	/* Store direct-map area from physical memory map */
 	kcore_update_ram();
 	hotplug_memory_notifier(kcore_callback, 0);
-	/* Other special area, area-for-module etc is arch specific. */
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
