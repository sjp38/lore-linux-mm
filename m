Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 0E4836B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 09:07:58 -0500 (EST)
Date: Mon, 5 Dec 2011 14:07:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: vmalloc: Check for page allocation failure before vmlist
 insertion
Message-ID: <20111205140750.GB5070@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Namhyung Kim <namhyung@gmail.com>, Luciano Chavez <lnx1138@linux.vnet.ibm.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Commit [f5252e00: mm: avoid null pointer access in vm_struct via
/proc/vmallocinfo] adds newly allocated vm_structs to the vmlist
after it is fully initialised. Unfortunately, it did not check that
__vmalloc_area_node() successfully populated the area. In the event
of allocation failure, the vmalloc area is freed but the pointer to
freed memory is inserted into the vmlist leading to a a crash later
in get_vmalloc_info().

This patch adds a check for ____vmalloc_area_node() failure within
__vmalloc_node_range. It does not use "goto fail" as in the previous
error path as a warning was already displayed by __vmalloc_area_node()
before it called vfree in its failure path.

Credit goes to Luciano Chavez for doing all the real work of
identifying exactly where the problem was.

If accepted, this should be considered a -stable candidate.

Reported-and-tested-by: Luciano Chavez <lnx1138@linux.vnet.ibm.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmalloc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3231bf3..1d8b32f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1633,6 +1633,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 		goto fail;
 
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node, caller);
+	if (!addr)
+		return NULL;
 
 	/*
 	 * In this function, newly allocated vm_struct is not added

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
