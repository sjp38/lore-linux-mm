From: Paul Jackson <pj@sgi.com>
Date: Tue, 10 Oct 2006 01:13:57 -0700
Message-Id: <20061010081357.15156.55404.sendpatchset@jackhammer.engr.sgi.com>
Subject: [PATCH] memory page_alloc revert empty zonelist check
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Andi Kleen <ak@suse.de>, mbligh@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Backout one item from a previous "memory page_alloc minor
cleanups" patch.  Until and unless we are certain that no one
can ever pass an empty zonelist to __alloc_pages(), this check
for an empty zonelist (or some BUG equivalent) is essential.
The code in get_page_from_freelist() blow ups if passed an
empty zonelist.

Signed-off-by: Paul Jackson

---

Andrew - applies on top of my "memory page_alloc minor cleanups"
patch.  -pj

 mm/page_alloc.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- 2.6.18-mm3.orig/mm/page_alloc.c	2006-10-10 00:25:31.751908557 -0700
+++ 2.6.18-mm3/mm/page_alloc.c	2006-10-10 00:25:32.567919262 -0700
@@ -1057,6 +1057,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 	might_sleep_if(wait);
 
 restart:
+	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
+
+	if (unlikely(*z == NULL)) {
+		/* Should this ever happen?? */
+		return NULL;
+	}
+
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
 				zonelist, ALLOC_WMARK_LOW|ALLOC_CPUSET);
 	if (page)

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
