Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A7076900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 21:13:16 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5N1D9aR013275
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:09 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz37.hot.corp.google.com with ESMTP id p5N1Bk0K031727
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:07 -0700
Received: by pwi4 with SMTP id 4so999103pwi.29
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 18:13:05 -0700 (PDT)
Date: Wed, 22 Jun 2011 18:13:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/2] mm, hotplug: protect zonelist building with
 zonelists_mutex
In-Reply-To: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1106221811500.23120@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1106221810130.23120@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

959ecc48fc75 ("mm/memory_hotplug.c: fix building of node hotplug 
zonelist") does not protect the build_all_zonelists() call with 
zonelists_mutex as needed.  This can lead to races in constructing 
zonelist ordering if a concurrent build is underway.  Protecting this with 
lock_memory_hotplug() is insufficient since zonelists can be rebuild 
though sysfs as well.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memory_hotplug.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -498,7 +498,9 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
 	 * The node we allocated has no zone fallback lists. For avoiding
 	 * to access not-initialized zonelist, build here.
 	 */
+	mutex_lock(&zonelists_mutex);
 	build_all_zonelists(NULL);
+	mutex_unlock(&zonelists_mutex);
 
 	return pgdat;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
