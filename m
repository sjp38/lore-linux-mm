Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 831ED6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:19:40 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7Jcp8013541
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:19:38 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E5BD45DE6E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:19:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2755A45DE4D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:19:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 054011DB8037
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:19:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 92459E18001
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:19:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 4/7] nandsim: Don't use PF_MEMALLOC
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-Id: <20091117161843.3DE0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:19:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Woodhouse <David.Woodhouse@intel.com>, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, linux-mtd@lists.infradead.org
List-ID: <linux-mm.kvack.org>


Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

Cc: David Woodhouse <David.Woodhouse@intel.com>
Cc: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Cc: linux-mtd@lists.infradead.org
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/mtd/nand/nandsim.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
index cd0711b..97a8bbb 100644
--- a/drivers/mtd/nand/nandsim.c
+++ b/drivers/mtd/nand/nandsim.c
@@ -1322,34 +1322,18 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
 	return 0;
 }
 
-static int set_memalloc(void)
-{
-	if (current->flags & PF_MEMALLOC)
-		return 0;
-	current->flags |= PF_MEMALLOC;
-	return 1;
-}
-
-static void clear_memalloc(int memalloc)
-{
-	if (memalloc)
-		current->flags &= ~PF_MEMALLOC;
-}
-
 static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t *pos)
 {
 	mm_segment_t old_fs;
 	ssize_t tx;
-	int err, memalloc;
+	int err;
 
 	err = get_pages(ns, file, count, *pos);
 	if (err)
 		return err;
 	old_fs = get_fs();
 	set_fs(get_ds());
-	memalloc = set_memalloc();
 	tx = vfs_read(file, (char __user *)buf, count, pos);
-	clear_memalloc(memalloc);
 	set_fs(old_fs);
 	put_pages(ns);
 	return tx;
@@ -1359,16 +1343,14 @@ static ssize_t write_file(struct nandsim *ns, struct file *file, void *buf, size
 {
 	mm_segment_t old_fs;
 	ssize_t tx;
-	int err, memalloc;
+	int err;
 
 	err = get_pages(ns, file, count, *pos);
 	if (err)
 		return err;
 	old_fs = get_fs();
 	set_fs(get_ds());
-	memalloc = set_memalloc();
 	tx = vfs_write(file, (char __user *)buf, count, pos);
-	clear_memalloc(memalloc);
 	set_fs(old_fs);
 	put_pages(ns);
 	return tx;
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
