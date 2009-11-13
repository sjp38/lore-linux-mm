Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1D9B26B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 01:00:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAD606Ff032181
	for <linux-mm@kvack.org> (envelope-from seto.hidetoshi@jp.fujitsu.com);
	Fri, 13 Nov 2009 15:00:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A4E645DE4E
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:00:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7185D45DE50
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:00:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E0361DB8041
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:00:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 00E671DB8037
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:00:05 +0900 (JST)
Message-ID: <4AFCF5D6.70902@jp.fujitsu.com>
Date: Fri, 13 Nov 2009 14:59:50 +0900
From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm/memory_hotplug : fix section mismatch
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With CONFIG_MEMORY_HOTPLUG I got following warning:

WARNING: vmlinux.o(.text+0x1276b0): Section mismatch in reference from
the function hotadd_new_pgdat() to the function
.meminit.text:free_area_init_node()
The function hotadd_new_pgdat() references
the function __meminit free_area_init_node().
This is often because hotadd_new_pgdat lacks a __meminit
annotation or the annotation of free_area_init_node is wrong.

Use __ref to fix this.

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 mm/memory_hotplug.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 821dee5..380aef4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -447,7 +447,8 @@ int online_pages(unsigned long pfn, unsigned long nr_pages)
 }
 #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
 
-static pg_data_t *hotadd_new_pgdat(int nid, u64 start)
+/* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
+static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 {
 	struct pglist_data *pgdat;
 	unsigned long zones_size[MAX_NR_ZONES] = {0};
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
