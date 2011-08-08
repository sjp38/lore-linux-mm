Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E10236B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 17:30:38 -0400 (EDT)
From: Iliyan Malchev <malchev@google.com>
Subject: [PATCH 1/2] slub: extend slub_debug to handle multiple slabs
Date: Mon,  8 Aug 2011 14:30:19 -0700
Message-Id: <1312839019-17987-1-git-send-email-malchev@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Iliyan Malchev <malchev@google.com>

Extend the slub_debug syntax to "slub_debug=<flags>[,<slub>]*", where <slub>
may contain an asterisk at the end.  For example, the following would poison
all kmalloc slabs:

	slub_debug=P,kmalloc*

and the following would apply the default flags to all kmalloc and all block IO
slabs:

	slub_debug=,bio*,kmalloc*

Signed-off-by: Iliyan Malchev <malchev@google.com>
---
 Documentation/vm/slub.txt |   12 +++++++++---
 mm/slub.c                 |   32 +++++++++++++++++++++++++++++---
 2 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index 07375e7..caa5b4a 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -31,8 +31,9 @@ Parameters may be given to slub_debug. If none is specified then full
 debugging is enabled. Format:
 
 slub_debug=<Debug-Options>       Enable options for all slabs
-slub_debug=<Debug-Options>,<slab name>
-				Enable options only for select slabs
+slub_debug=<Debug-Options>,<slab name1>,<slab name2>,...
+				Enable options only for select slabs (no spaces
+				after a comma)
 
 Possible debug options are
 	F		Sanity checks on (enables SLAB_DEBUG_FREE. Sorry
@@ -55,7 +56,12 @@ Trying to find an issue in the dentry cache? Try
 
 	slub_debug=,dentry
 
-to only enable debugging on the dentry cache.
+to only enable debugging on the dentry cache.  You may use an asterisk at the
+end of the slab name, in order to cover all slabs with the same prefix.  For
+example, here's how you can poison the dentry cache as well as all kmalloc
+slabs:
+
+	slub_debug=P,kmalloc-*,dentry
 
 Red zoning and tracking may realign the slab.  We can just apply sanity checks
 to the dentry cache with
diff --git a/mm/slub.c b/mm/slub.c
index eb5a8f9..8e7a282 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1275,9 +1275,35 @@ static unsigned long kmem_cache_flags(unsigned long objsize,
 	/*
 	 * Enable debugging if selected on the kernel commandline.
 	 */
-	if (slub_debug && (!slub_debug_slabs ||
-		!strncmp(slub_debug_slabs, name, strlen(slub_debug_slabs))))
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
+		n = *end ? end + 1 : end;
+	}
 
 	return flags;
 }
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
