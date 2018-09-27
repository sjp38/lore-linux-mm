Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7812B8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 09:07:13 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b5-v6so5233342wmj.6
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 06:07:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m7-v6sor1438147wrn.51.2018.09.27.06.07.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Sep 2018 06:07:11 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@gmail.com>
Subject: [PATCH] mm: don't warn about large allocations for slab
Date: Thu, 27 Sep 2018 15:07:07 +0200
Message-Id: <20180927130707.151239-1-dvyukov@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, iamjoonsoo.kim@lge.com
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Dmitry Vyukov <dvyukov@google.com>

This warning does not seem to be useful. Most of the time it fires when
allocation size depends on syscall arguments. We could add __GFP_NOWARN
to these allocation sites, but having a warning only to suppress it
does not make lots of sense. Moreover, this warnings never fires for
constant-size allocations and never for slub, because there are
additional checks and fallback to kmalloc_large() for large allocations
and kmalloc_large() does not warn. So the warning only fires for
non-constant allocations and only with slab, which is odd to begin with.
The warning leads to episodic unuseful syzbot reports. Remote it.

While we are here also fix the check. We should check against
KMALLOC_MAX_CACHE_SIZE rather than KMALLOC_MAX_SIZE. It all kinda
worked because for slab the constants are the same, and slub always
checks the size against KMALLOC_MAX_CACHE_SIZE before kmalloc_slab().
But if we get there with size > KMALLOC_MAX_CACHE_SIZE anyhow
bad things will happen.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Reported-by: syzbot+87829a10073277282ad1@syzkaller.appspotmail.com
Reported-by: syzbot+ef4e8fc3a06e9019bb40@syzkaller.appspotmail.com
Reported-by: syzbot+6e438f4036df52cbb863@syzkaller.appspotmail.com
Reported-by: syzbot+8574471d8734457d98aa@syzkaller.appspotmail.com
Reported-by: syzbot+af1504df0807a083dbd9@syzkaller.appspotmail.com
---
 mm/slab_common.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 1f903589980f9..2733bddcfdc0c 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1023,10 +1023,8 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
 {
 	unsigned int index;
 
-	if (unlikely(size > KMALLOC_MAX_SIZE)) {
-		WARN_ON_ONCE(!(flags & __GFP_NOWARN));
+	if (unlikely(size > KMALLOC_MAX_CACHE_SIZE))
 		return NULL;
-	}
 
 	if (size <= 192) {
 		if (!size)
-- 
2.19.0.605.g01d371f741-goog
