Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 54E0E6B0071
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:28:13 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c41so2165247eek.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:28:12 -0800 (PST)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v6 6/8] fs: only send IPI to invalidate LRU BH when needed
Date: Sun,  8 Jan 2012 18:27:04 +0200
Message-Id: <1326040026-7285-7-git-send-email-gilad@benyossef.com>
In-Reply-To: <y>
References: <y>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

In several code paths, such as when unmounting a file system (but
not only) we send an IPI to ask each cpu to invalidate its local
LRU BHs.

For multi-cores systems that have many cpus that may not have
any LRU BH because they are idle or because they have no performed
any file system access since last invalidation (e.g. CPU crunching
on high perfomance computing nodes that write results to shared
memory) this can lead to loss of performance each time someone
switches KVM (the virtual keyboard and screen type, not the
hypervisor) that has a USB storage stuck in.

This patch attempts to only send the IPI to cpus that have LRU BH.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: linux-mm@kvack.org
CC: Pekka Enberg <penberg@kernel.org>
CC: Matt Mackall <mpm@selenic.com>
CC: Sasha Levin <levinsasha928@gmail.com>
CC: Rik van Riel <riel@redhat.com>
CC: Andi Kleen <andi@firstfloor.org>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org
CC: Avi Kivity <avi@redhat.com>
CC: Michal Nazarewicz <mina86@mina86.org>
CC: Kosaki Motohiro <kosaki.motohiro@gmail.com>
---
 fs/buffer.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 19d8eb7..b2378d4 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1434,10 +1434,23 @@ static void invalidate_bh_lru(void *arg)
 	}
 	put_cpu_var(bh_lrus);
 }
+
+static int local_bh_lru_avail(int cpu, void *dummy)
+{
+	struct bh_lru *b = per_cpu_ptr(&bh_lrus, cpu);
+	int i;
 	
+	for (i = 0; i < BH_LRU_SIZE; i++) {
+		if (b->bhs[i])
+			return 1;
+	}
+
+	return 0;
+}
+
 void invalidate_bh_lrus(void)
 {
-	on_each_cpu(invalidate_bh_lru, NULL, 1);
+	on_each_cpu_cond(local_bh_lru_avail, invalidate_bh_lru, NULL, 1);
 }
 EXPORT_SYMBOL_GPL(invalidate_bh_lrus);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
