Received: by ti-out-0910.google.com with SMTP id j3so27673tid.8
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 10:46:52 -0700 (PDT)
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: [PATCH 2/5] kmemtrace: Better alternative to "kmemtrace: fix printk format warnings".
Date: Tue, 19 Aug 2008 20:43:24 +0300
Message-Id: <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: penberg@cs.helsinki.fi
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Fix the problem "kmemtrace: fix printk format warnings" attempted to fix,
but resulted in marker-probe format mismatch warnings. Instead of carrying
size_t into probes, we get rid of it by casting to unsigned long, just as
we did with gfp_t.

This way, we don't need to change marker format strings and we don't have
to rely on other format specifiers like "%zu", making for consistent use
of more generic data types (since there are no format specifiers for
gfp_t, for example).

Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/linux/kmemtrace.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/kmemtrace.h b/include/linux/kmemtrace.h
index 2c33201..5bea8ea 100644
--- a/include/linux/kmemtrace.h
+++ b/include/linux/kmemtrace.h
@@ -33,7 +33,8 @@ static inline void kmemtrace_mark_alloc_node(enum kmemtrace_type_id type_id,
 	trace_mark(kmemtrace_alloc, "type_id %d call_site %lu ptr %lu "
 		   "bytes_req %lu bytes_alloc %lu gfp_flags %lu node %d",
 		   type_id, call_site, (unsigned long) ptr,
-		   bytes_req, bytes_alloc, (unsigned long) gfp_flags, node);
+		   (unsigned long) bytes_req, (unsigned long) bytes_alloc,
+		   (unsigned long) gfp_flags, node);
 }
 
 static inline void kmemtrace_mark_free(enum kmemtrace_type_id type_id,
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
