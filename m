Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mADBSZID001524
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 20:28:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CCA7445DD7C
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:28:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAB9845DD7A
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:28:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F6CC1DB803E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:28:35 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 439E31DB803B
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 20:28:35 +0900 (JST)
Date: Thu, 13 Nov 2008 20:27:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memory hotplug: fix notiier chain return value (Was
 Re: 2.6.28-rc4 mem_cgroup_charge_common panic)
Message-Id: <20081113202758.2f12915a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1226353408.8805.12.camel@badari-desktop>
References: <1226353408.8805.12.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Badari, I think you used SLUB. If so, page_cgroup's notifier callback was not
called and newly allocated page's page_cgroup wasn't allocated.
This is a fix. (notifier saw STOP_HERE flag added by slub's notifier.)

I'm now testing modified kernel, which does alloc/free page_cgroup by notifier.
(Usually, all page_cgroups are from bootmem and not freed.
 so, modified a bit for test)

And I cannot reproduce panic. I think you do "real" memory hotplug other than
online/offline and saw panic caused by this. 

Is this slub's behavior intentional ? page_cgroup's notifier has lower priority
than slub, now.

Thanks,
-Kame
==
notifier callback's notifier_from_errno() just works well in error
route. (It adds mask for "stop here")

Hanlder should return NOTIFY_OK in explict way.

Signed-off-by:KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/page_cgroup.c |    5 ++++-
 mm/slub.c        |    6 ++++--
 2 files changed, 8 insertions(+), 3 deletions(-)

Index: mmotm-2.6.28-Nov10/mm/slub.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/slub.c
+++ mmotm-2.6.28-Nov10/mm/slub.c
@@ -3220,8 +3220,10 @@ static int slab_memory_callback(struct n
 	case MEM_CANCEL_OFFLINE:
 		break;
 	}
-
-	ret = notifier_from_errno(ret);
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
 	return ret;
 }
 
Index: mmotm-2.6.28-Nov10/mm/page_cgroup.c
===================================================================
--- mmotm-2.6.28-Nov10.orig/mm/page_cgroup.c
+++ mmotm-2.6.28-Nov10/mm/page_cgroup.c
@@ -216,7 +216,10 @@ static int page_cgroup_callback(struct n
 		break;
 	}
 
-	ret = notifier_from_errno(ret);
+	if (ret)
+		ret = notifier_from_errno(ret);
+	else
+		ret = NOTIFY_OK;
 
 	return ret;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
