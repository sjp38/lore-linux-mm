Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8D47280753
	for <linux-mm@kvack.org>; Sat, 20 May 2017 06:52:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b84so17313545wmh.0
        for <linux-mm@kvack.org>; Sat, 20 May 2017 03:52:07 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p21si16722820wmf.44.2017.05.20.03.52.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 20 May 2017 03:52:06 -0700 (PDT)
Date: Sat, 20 May 2017 12:52:03 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH] slub/memcg: Cure the brainless abuse of sysfs attributes
Message-ID: <alpine.DEB.2.20.1705201244540.2255@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>

memcg_propagate_slab_attrs() abuses the sysfs attribute file functions to
propagate settings from the root kmem_cache to a newly created
kmem_cache. It does that with:

     attr->show(root, buf);
     attr->store(new, buf, strlen(bug);

Aside of being a lazy and absurd hackery this is broken because it does not
check the return value of the show() function.

Some of the show() functions return 0 w/o touching the buffer. That means in
such a case the store function is called with the stale content of the
previous show(). That causes nonsense like invoking kmem_cache_shrink() on
a newly created kmem_cache. In the worst case it would cause handing in an
uninitialized buffer.

This should be rewritten proper by adding a propagate() callback to those
slub_attributes which must be propagated and avoid that insane conversion
to and from ASCII, but that's too large for a hot fix.

Check at least the return value of the show() function, so calling store()
with stale content is prevented.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: stable@vger.kernel.org

---
 mm/slub.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5512,6 +5512,7 @@ static void memcg_propagate_slab_attrs(s
 		char mbuf[64];
 		char *buf;
 		struct slab_attribute *attr = to_slab_attr(slab_attrs[i]);
+		ssize_t len;
 
 		if (!attr || !attr->store || !attr->show)
 			continue;
@@ -5536,8 +5537,9 @@ static void memcg_propagate_slab_attrs(s
 			buf = buffer;
 		}
 
-		attr->show(root_cache, buf);
-		attr->store(s, buf, strlen(buf));
+		len = attr->show(root_cache, buf);
+		if (len > 0)
+			attr->store(s, buf, len);
 	}
 
 	if (buffer)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
