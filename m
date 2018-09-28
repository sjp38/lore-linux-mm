Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C1CA68E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 07:11:43 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id i8-v6so929025wma.9
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 04:11:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6-v6sor3507878wru.33.2018.09.28.04.11.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 04:11:41 -0700 (PDT)
From: Aaron Tomlin <atomlin@redhat.com>
Subject: [PATCH v3] slub: extend slub debug to handle multiple slabs
Date: Fri, 28 Sep 2018 12:11:39 +0100
Message-Id: <20180928111139.27962-1-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, atomlin@redhat.com, malchev@google.com

Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
may contain an asterisk at the end.  For example, the following would poison
all kmalloc slabs:

	slub_debug=P,kmalloc*

and the following would apply the default flags to all kmalloc and all block IO
slabs:

	slub_debug=,bio*,kmalloc*

Please note that a similar patch was posted by Iliyan Malchev some time ago but
was never merged:

	https://marc.info/?l=linux-mm&m=131283905330474&w=2

Signed-off-by: Aaron Tomlin <atomlin@redhat.com>
---
Changes from v2 [2]:

 - Add a function and kernel-doc comment
 - Refactor code
 - Use the appropriate helper function max_t()

Changes from v1 [1]:

 - Add appropriate cast to address compiler warning

[1]: https://marc.info/?l=linux-kernel&m=153657804506284&w=2
[2]: https://marc.info/?l=linux-kernel&m=153747362316965&w=2
---
 Documentation/vm/slub.rst | 12 +++++++++---
 mm/slub.c                 | 50 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/Documentation/vm/slub.rst b/Documentation/vm/slub.rst
index 3a775fd64e2d..195928808bac 100644
--- a/Documentation/vm/slub.rst
+++ b/Documentation/vm/slub.rst
@@ -36,9 +36,10 @@ debugging is enabled. Format:
 
 slub_debug=<Debug-Options>
 	Enable options for all slabs
-slub_debug=<Debug-Options>,<slab name>
-	Enable options only for select slabs
 
+slub_debug=<Debug-Options>,<slab name1>,<slab name2>,...
+	Enable options only for select slabs (no spaces
+	after a comma)
 
 Possible debug options are::
 
@@ -62,7 +63,12 @@ Trying to find an issue in the dentry cache? Try::
 
 	slub_debug=,dentry
 
-to only enable debugging on the dentry cache.
+to only enable debugging on the dentry cache.  You may use an asterisk at the
+end of the slab name, in order to cover all slabs with the same prefix.  For
+example, here's how you can poison the dentry cache as well as all kmalloc
+slabs:
+
+	slub_debug=P,kmalloc-*,dentry
 
 Red zoning and tracking may realign the slab.  We can just apply sanity checks
 to the dentry cache with::
diff --git a/mm/slub.c b/mm/slub.c
index 8da34a8af53d..7927f971df0d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1276,16 +1276,54 @@ static int __init setup_slub_debug(char *str)
 
 __setup("slub_debug", setup_slub_debug);
 
+/*
+ * kmem_cache_flags - apply debugging options to the cache
+ * @object_size:	the size of an object without meta data
+ * @flags:		flags to set
+ * @name:		name of the cache
+ * @ctor:		constructor function
+ *
+ * Debug option(s) are applied to @flags. In addition to the debug
+ * option(s), if a slab name (or multiple) is specified i.e.
+ * slub_debug=<Debug-Options>,<slab name1>,<slab name2> ...
+ * then only the select slabs will receive the debug option(s).
+ */
 slab_flags_t kmem_cache_flags(unsigned int object_size,
 	slab_flags_t flags, const char *name,
 	void (*ctor)(void *))
 {
-	/*
-	 * Enable debugging if selected on the kernel commandline.
-	 */
-	if (slub_debug && (!slub_debug_slabs || (name &&
-		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)))))
-		flags |= slub_debug;
+	char *iter;
+	size_t len;
+
+	/* If slub_debug = 0, it folds into the if conditional. */
+	if (!slub_debug_slabs)
+		return flags | slub_debug;
+
+	len = strlen(name);
+	iter = slub_debug_slabs;
+	while (*iter) {
+		char *end, *glob;
+		size_t cmplen;
+
+		end = strchr(iter, ',');
+		if (!end)
+			end = iter + strlen(iter);
+
+		glob = strnchr(iter, end - iter, '*');
+		if (glob)
+			cmplen = glob - iter;
+		else
+			cmplen = max_t(size_t, len, (end - iter));
+
+		if (!strncmp(name, iter, cmplen)) {
+			flags |= slub_debug;
+			break;
+		}
+
+		if (!*end)
+			break;
+		iter = end + 1;
+	}
 
 	return flags;
 }
-- 
2.14.4
