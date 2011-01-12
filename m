Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DE1656B00E7
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:18:00 -0500 (EST)
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0CEHxEE011197
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 12 Jan 2011 09:17:59 -0500
Date: Wed, 12 Jan 2011 09:17:58 -0500
From: Prarit Bhargava <prarit@redhat.com>
Message-Id: <20110112141758.28666.83674.sendpatchset@prarit.bos.redhat.com>
Subject: [PATCH]: mm: notifier_from_errno() cleanup
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: lwoodman@redhat.com, dzickus@redhat.com, riel@redhat.com, Prarit Bhargava <prarit@redhat.com>
List-ID: <linux-mm.kvack.org>

While looking at some other notifier callbacks I noticed this code could
use a simple cleanup.

notifier_from_errno() no longer needs the if (ret)/else conditional.  That
same conditional is now done in notifier_from_errno().

Signed-off-by: Prarit Bhargava <prarit@redhat.com>

diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 5bffada..59a3cd4 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -243,12 +243,7 @@ static int __meminit page_cgroup_callback(struct notifier_block *self,
 		break;
 	}
 
-	if (ret)
-		ret = notifier_from_errno(ret);
-	else
-		ret = NOTIFY_OK;
-
-	return ret;
+	return notifier_from_errno(ret);
 }
 
 #endif
diff --git a/mm/slab.c b/mm/slab.c
index 2640374..0164aa4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1387,7 +1387,7 @@ static int __meminit slab_memory_callback(struct notifier_block *self,
 		break;
 	}
 out:
-	return ret ? notifier_from_errno(ret) : NOTIFY_OK;
+	return notifier_from_errno(ret);
 }
 #endif /* CONFIG_NUMA && CONFIG_MEMORY_HOTPLUG */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
