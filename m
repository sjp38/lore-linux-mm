Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D98E46B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 00:11:32 -0400 (EDT)
Subject: [PATCH] mm: Make it easier to catch NULL cache names
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Tue, 28 Jul 2009 14:11:29 +1000
Message-Id: <1248754289.30993.45.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Right now, if you inadvertently pass NULL to kmem_cache_create() at boot
time, it crashes much later after boot somewhere deep inside sysfs which
makes it very non obvious to figure out what's going on.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Yes, I did hit that :-) Something in ppc land using an array of caches
and got the names array out of sync with changes to the list of indices.

 mm/slub.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..e31fbe6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3292,6 +3292,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 {
 	struct kmem_cache *s;
 
+	if (WARN_ON(!name))
+		return NULL;
+
 	down_write(&slub_lock);
 	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
