Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 547226B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 22:47:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H2lE7Y030835
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 11:47:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D5FE45DE51
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:47:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F1B945DE4F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:47:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D6281DB8043
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:56:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D6281DB8038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 11:56:25 +0900 (JST)
Date: Thu, 17 Sep 2009 11:45:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3][mmotm] updateing size of kcore
Message-Id: <20090917114509.a9eb9f2c.kamezawa.hiroyu@jp.fujitsu.com>
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


After memory hotplug (or other events in future), kcore size
can be modified.

To update inode->i_size, we have to know inode/dentry but we
can't get it from inside /proc directly.
But considerinyg memory hotplug, kcore image is updated only when
it's opened. Then, updating inode->i_size at open() is enough.

Cc: WANG Cong <xiyou.wangcong@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 fs/proc/kcore.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: mmotm-2.6.31-Sep14/fs/proc/kcore.c
===================================================================
--- mmotm-2.6.31-Sep14.orig/fs/proc/kcore.c
+++ mmotm-2.6.31-Sep14/fs/proc/kcore.c
@@ -546,6 +546,11 @@ static int open_kcore(struct inode *inod
 		return -EPERM;
 	if (kcore_need_update)
 		kcore_update_ram();
+	if (i_size_read(inode) != proc_root_kcore->size) {
+		mutex_lock(&inode->i_mutex);
+		i_size_write(inode, proc_root_kcore->size);
+		mutex_unlock(&inode->i_mutex);
+	}
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
