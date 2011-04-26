Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A781B900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:26:29 -0400 (EDT)
Received: by pvc12 with SMTP id 12so325431pvc.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 23:26:27 -0700 (PDT)
Date: Tue, 26 Apr 2011 13:31:50 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 2/2] use oom_killer_disabled in page fault oom path
Message-ID: <20110426053150.GA11949@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com

Currently oom_killer_disabled is only used in __alloc_pages_slowpath,
For page fault oom case it is not considered. One use case is
virtio balloon driver, when memory pressure is high, virtio ballooning
will cause oom killing due to such as page fault oom.

Thus add oom_killer_disabled checking in pagefault_out_of_memory.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 mm/oom_kill.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-2.6.orig/mm/oom_kill.c	2011-04-26 11:32:21.446452686 +0800
+++ linux-2.6/mm/oom_kill.c	2011-04-26 11:33:05.426452586 +0800
@@ -747,6 +747,9 @@ out:
  */
 void pagefault_out_of_memory(void)
 {
+	if (oom_killer_disabled)
+		return;
+
 	if (try_set_system_oom()) {
 		out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
