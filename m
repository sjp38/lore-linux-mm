From: Paul Jackson <pj@sgi.com>
Date: Thu, 19 Oct 2006 03:10:50 -0700
Message-Id: <20061019101050.6074.75441.sendpatchset@sam.engr.sgi.com>
Subject: [PATCH 2/2] memory page_alloc zonelist caching reorder structure
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, holt@sgi.com, mbligh@google.com, rientjes@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Rearrange the struct members in the 'struct zonelist_cache'
structure, so as to put the readonly (once initialized)
z_to_n[] array first, where it will come right after the
zones[] array in struct zonelist.

This pretty much eliminates the chance that the two frequently
written elements of 'struct zonelist_cache', the fullzones
bitmap and last_full_zap times, will end up on the same cache
line as the performance sensitive, frequently read, never
(after init) written zones[] array.

Keeping frequently written data off frequently read cache
lines is good for performance.

Thanks to Rohit Seth for the suggestion.

Signed-off-by: Paul Jackson <pj@sgi.com>

---

 include/linux/mmzone.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- 2.6.19-rc2-mm1.orig/include/linux/mmzone.h	2006-10-19 02:46:58.000000000 -0700
+++ 2.6.19-rc2-mm1/include/linux/mmzone.h	2006-10-19 02:49:25.000000000 -0700
@@ -374,8 +374,8 @@ struct zone {
 
 
 struct zonelist_cache {
-	DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);	/* zone full? */
 	unsigned short z_to_n[MAX_ZONES_PER_ZONELIST];		/* zone->nid */
+	DECLARE_BITMAP(fullzones, MAX_ZONES_PER_ZONELIST);	/* zone full? */
 	unsigned long last_full_zap;		/* when last zap'd (jiffies) */
 };
 #else

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
