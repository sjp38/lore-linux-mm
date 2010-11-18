Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C9B746B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 21:54:50 -0500 (EST)
From: <b32542@freescale.com>
Subject: [PATCH] slub: operate cache name memory same to slab and slob
Date: Thu, 18 Nov 2010 11:00:59 +0800
Message-ID: <1290049259-20108-1-git-send-email-b32542@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, tytso@mit.edu, linux-kernel@vger.kernel.org, Zeng Zhaoming <zengzm.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Zeng Zhaoming <zengzm.kernel@gmail.com>

Get a memory leak complaint about ext4:
  comm "mount", pid 1159, jiffies 4294904647 (age 6077.804s)
  hex dump (first 32 bytes):
    65 78 74 34 5f 67 72 6f 75 70 69 6e 66 6f 5f 31  ext4_groupinfo_1
    30 00 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  0.kkkkkkkkkkkkk.
  backtrace:
    [<c068ade3>] kmemleak_alloc+0x93/0xd0
    [<c024e54c>] __kmalloc_track_caller+0x30c/0x380
    [<c02269d3>] kstrdup+0x33/0x60
    [<c0318a70>] ext4_mb_init+0x4e0/0x550
    [<c0304e0e>] ext4_fill_super+0x1e6e/0x2f60
    [<c0261140>] mount_bdev+0x1c0/0x1f0
    [<c02fc00f>] ext4_mount+0x1f/0x30
    [<c02603d8>] vfs_kern_mount+0x78/0x250
    [<c026060e>] do_kern_mount+0x3e/0x100
    [<c027b4c2>] do_mount+0x2e2/0x780
    [<c027ba04>] sys_mount+0xa4/0xd0
    [<c010429f>] sysenter_do_call+0x12/0x38
    [<ffffffff>] 0xffffffff

It is cause by slub manage the cache name different from slab and slob.
In slab and slob, only reference to name, alloc and reclaim the memory
is the duty of the code that invoked kmem_cache_create().

In slub, cache name duplicated when create. This ambiguity will cause
some memory leaks and double free if kmem_cache_create() pass a
dynamic malloc cache name.

Signed-off-by: Zeng Zhaoming <zengzm.kernel@gmail.com>
---
 mm/slub.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)
 mode change 100644 => 100755 mm/slub.c

diff --git a/mm/slub.c b/mm/slub.c
old mode 100644
new mode 100755
index 981fb73..a223e08
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -209,7 +209,6 @@ static inline int sysfs_slab_alias(struct kmem_cache *s, const char *p)
 							{ return 0; }
 static inline void sysfs_slab_remove(struct kmem_cache *s)
 {
-	kfree(s->name);
 	kfree(s);
 }
 
@@ -3228,7 +3227,6 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		size_t align, unsigned long flags, void (*ctor)(void *))
 {
 	struct kmem_cache *s;
-	char *n;
 
 	if (WARN_ON(!name))
 		return NULL;
@@ -3252,25 +3250,19 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 		return s;
 	}
 
-	n = kstrdup(name, GFP_KERNEL);
-	if (!n)
-		goto err;
-
 	s = kmalloc(kmem_size, GFP_KERNEL);
 	if (s) {
-		if (kmem_cache_open(s, n,
+		if (kmem_cache_open(s, name,
 				size, align, flags, ctor)) {
 			list_add(&s->list, &slab_caches);
 			if (sysfs_slab_add(s)) {
 				list_del(&s->list);
-				kfree(n);
 				kfree(s);
 				goto err;
 			}
 			up_write(&slub_lock);
 			return s;
 		}
-		kfree(n);
 		kfree(s);
 	}
 err:
@@ -4421,7 +4413,6 @@ static void kmem_cache_release(struct kobject *kobj)
 {
 	struct kmem_cache *s = to_slab(kobj);
 
-	kfree(s->name);
 	kfree(s);
 }
 
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
