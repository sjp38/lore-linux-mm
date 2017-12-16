Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE696B0271
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 14:30:10 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id m3so2992091lfe.3
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 11:30:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x88sor377040lfi.105.2017.12.16.11.30.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Dec 2017 11:30:08 -0800 (PST)
From: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Subject: [PATCH] mm: vmscan: make unregister_shrinker() safer
Date: Sat, 16 Dec 2017 22:29:37 +0300
Message-Id: <20171216192937.13549-1-akaraliou.dev@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>, linux-mm@kvack.org

unregister_shrinker() does not have any sanitizing inside so
calling it twice will oops because of double free attempt or so.
This patch makes unregister_shrinker() safer and allows calling
it on resource freeing path without explicit knowledge of whether
shrinker was successfully registered or not.

Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>
---
 mm/vmscan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 65c4fa26abfa..7cb56db5e9ca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -281,10 +281,14 @@ EXPORT_SYMBOL(register_shrinker);
  */
 void unregister_shrinker(struct shrinker *shrinker)
 {
+	if (!shrinker->nr_deferred)
+		return;
+
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
 	kfree(shrinker->nr_deferred);
+	shrinker->nr_deferred = NULL;
 }
 EXPORT_SYMBOL(unregister_shrinker);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
