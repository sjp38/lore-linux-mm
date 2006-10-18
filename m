From: Paul Jackson <pj@sgi.com>
Date: Wed, 18 Oct 2006 01:14:40 -0700
Message-Id: <20061018081440.18477.10664.sendpatchset@sam.engr.sgi.com>
Subject: [PATCH] memory page_alloc zonelist caching speedup aligncache
Sender: owner-linux-mm@kvack.org
From: Paul Jackson <pj@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: nickpiggin@yahoo.com.au, ak@suse.de, linux-mm@kvack.org, holt@sgi.com, mbligh@google.com, rientjes@google.com, rohitseth@google.com, menage@google.com, Paul Jackson <pj@sgi.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Avoid frequent writes to the zonelist zones[] array, which are
read-only after initial setup, by putting the zonelist_cache on
a separate cacheline.

Signed-off-by: Paul Jackson <pj@sgi.com>

---

 include/linux/mmzone.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

--- 2.6.19-rc2-mm1.orig/include/linux/mmzone.h	2006-10-17 17:19:22.000000000 -0700
+++ 2.6.19-rc2-mm1/include/linux/mmzone.h	2006-10-17 17:31:31.000000000 -0700
@@ -396,7 +396,8 @@ struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
 	struct zone *zones[MAX_ZONES_PER_ZONELIST + 1];      // NULL delimited
 #ifdef CONFIG_NUMA
-	struct zonelist_cache zlcache;			     // optional ...
+	/* Keep written zonelist_cache off read-only zones[] cache lines */
+	struct zonelist_cache zlcache ____cacheline_aligned; // optional ...
 #endif
 };
 

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
