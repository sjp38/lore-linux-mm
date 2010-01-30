From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/4] hwpoison: avoid "still referenced by -1 users" warning
Date: Sat, 30 Jan 2010 17:25:13 +0800
Message-ID: <20100130093704.146687888@intel.com>
References: <20100130092509.793222613@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Ov8CL-0003He-DN
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Sep 2010 14:31:49 +0200
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3A9C16B010D
	for <linux-mm@kvack.org>; Mon, 13 Sep 2010 08:31:35 -0400 (EDT)
Content-Disposition: inline; filename=hwpoison-no-warn-unknown.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Get rid of the amusing last line, emitted for slab/reserved kernel pages:

[  328.396842] MCE 0x1ff00: Unknown page state
[  328.399058] MCE 0x1ff00: dirty unknown page state page recovery: Failed
[  328.402465] MCE 0x1ff00: unknown page state page still referenced by -1 users

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-mm.orig/mm/memory-failure.c	2010-01-22 11:20:28.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2010-01-30 17:23:40.000000000 +0800
@@ -803,7 +803,7 @@ static int page_action(struct page_state
 	count = page_count(p) - 1;
 	if (ps->action == me_swapcache_dirty && result == DELAYED)
 		count--;
-	if (count != 0) {
+	if (count > 0) {
 		printk(KERN_ERR
 		       "MCE %#lx: %s page still referenced by %d users\n",
 		       pfn, ps->msg, count);


--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
