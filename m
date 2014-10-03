Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4446B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 06:07:24 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id r10so2428965pdi.10
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 03:07:24 -0700 (PDT)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id bn6si4084063pdb.215.2014.10.03.03.07.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 03:07:23 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CDAE93EE168
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 19:07:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id DB70BAC0AC7
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 19:07:20 +0900 (JST)
Received: from g01jpfmpwyt02.exch.g01.fujitsu.local (g01jpfmpwyt02.exch.g01.fujitsu.local [10.128.193.56])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 829A51DB8044
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 19:07:20 +0900 (JST)
Message-ID: <542E750B.4000508@jp.fujitsu.com>
Date: Fri, 3 Oct 2014 19:06:03 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] driver/base/node: remove unnecessary kfree of node struct
 from unregister_one_node
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, qiuxishi@huawei.com
Cc: akpm@linux-foundation.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 92d585ef067d ("numa: fix NULL pointer access and memory
leak in unregister_one_node()") added kfree() of node struct in
unregister_one_node(). But node struct is freed by node_device_release()
which is called in  unregister_node(). So by adding the kfree(),
node struct is freed two times.

While hot removing memory, the commit leads the following BUG_ON():

  kernel BUG at mm/slub.c:3346!
  invalid opcode: 0000 [#1] SMP
  [...]
  Call Trace:
   [...] unregister_one_node
   [...] try_offline_node
   [...] remove_memory
   [...] acpi_memory_device_remove
   [...] acpi_bus_trim
   [...] acpi_bus_trim
   [...] acpi_device_hotplug
   [...] acpi_hotplug_work_fn
   [...] process_one_work
   [...] worker_thread
   [...] ? rescuer_thread
   [...] kthread
   [...] ? kthread_create_on_node
   [...] ret_from_fork
   [...] ? kthread_create_on_node

This patch removes unnecessary kfree() from unregister_one_node().

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org # v3.16+
Fixes: 92d585ef067d "numa: fix NULL pointer access and memory leak in unregister_one_node()"
---
 drivers/base/node.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index c6d3ae0..d51c49c 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -603,7 +603,6 @@ void unregister_one_node(int nid)
 		return;

 	unregister_node(node_devices[nid]);
-	kfree(node_devices[nid]);
 	node_devices[nid] = NULL;
 }

-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
