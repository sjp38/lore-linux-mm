Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3497E900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 21:13:11 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p5N1D5YQ002977
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:07 -0700
Received: from pzd13 (pzd13.prod.google.com [10.243.17.205])
	by hpaq3.eem.corp.google.com with ESMTP id p5N1CY5I009752
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:04 -0700
Received: by pzd13 with SMTP id 13so1132300pzd.11
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:03 -0700 (PDT)
Date: Wed, 22 Jun 2011 18:13:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, hotplug: fix error handling in mem_online_node()
Message-ID: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The error handling in mem_online_node() is incorrect: hotadd_new_pgdat() 
returns NULL if the new pgdat could not have been allocated and a pointer 
to it otherwise.

mem_online_node() should fail if hotadd_new_pgdat() fails, not the 
inverse.  This fixes an issue when memoryless nodes are not onlined and 
their sysfs interface is not registered when their first cpu is brought 
up.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memory_hotplug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -521,7 +521,7 @@ int mem_online_node(int nid)
 
 	lock_memory_hotplug();
 	pgdat = hotadd_new_pgdat(nid, 0);
-	if (pgdat) {
+	if (!pgdat) {
 		ret = -ENOMEM;
 		goto out;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
