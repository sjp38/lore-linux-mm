Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1708E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:14:02 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z77-v6so18925712wrb.20
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 04:14:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j12-v6sor10113160wrt.26.2018.09.10.04.14.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 04:14:00 -0700 (PDT)
From: Aaron Tomlin <atomlin@redhat.com>
Subject: [PATCH] slub: extend slub debug to handle multiple slabs
Date: Mon, 10 Sep 2018 12:13:58 +0100
Message-Id: <20180910111358.10539-1-atomlin@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, atomlin@redhat.com

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
 Documentation/vm/slub.rst | 12 +++++++++---
 mm/slub.c                 | 34 +++++++++++++++++++++++++++++++---
 2 files changed, 40 insertions(+), 6 deletions(-)

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
index 8da34a8af53d..27281867cbe0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1283,9 +1283,37 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 	/*
 	 * Enable debugging if selected on the kernel commandline.
 	 */
-	if (slub_debug && (!slub_debug_slabs || (name &&
-		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs)))))
-		flags |= slub_debug;
+
+	char *end, *n, *glob;
+	int len = strlen(name);
+
+	/* If slub_debug = 0, it folds into the if conditional. */
+	if (!slub_debug_slabs)
+		return flags | slub_debug;
+
+	n = slub_debug_slabs;
+	while (*n) {
+		int cmplen;
+
+		end = strchr(n, ',');
+		if (!end)
+			end = n + strlen(n);
+
+		glob = strnchr(n, end - n, '*');
+		if (glob)
+			cmplen = glob - n;
+		else
+			cmplen = max(len, end - n);
+
+		if (!strncmp(name, n, cmplen)) {
+			flags |= slub_debug;
+			break;
+		}
+
+		if (!*end)
+			break;
+		n = end + 1;
+	}
 
 	return flags;
 }
-- 
2.14.4
