Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 850676B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 10:41:43 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id eu11so4703111pac.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 07:41:43 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id e12si630941pat.5.2015.02.11.07.41.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 07:41:42 -0800 (PST)
Date: Wed, 11 Feb 2015 18:41:28 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm] slub: kmem_cache_shrink: init discard list after
 freeing slabs
Message-ID: <20150211154128.GA26049@esperanza>
References: <1423627463.5968.99.camel@intel.com>
 <1423642582-23553-1-git-send-email-vdavydov@parallels.com>
 <alpine.DEB.2.11.1502110851180.32065@gentwo.org>
 <alpine.DEB.2.11.1502110857410.948@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1502110857410.948@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Pekka
 Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>

On Wed, Feb 11, 2015 at 09:00:39AM -0600, Christoph Lameter wrote:
> Hmmmm... Thinking about this some more. It may be better to initialize the
> list head at the beginning of the loop?
> 
> Also the promote array should also be initialized in the loop right?

I do initialize promote lists in the loop using list_splice_init, but
yeah, initializing them in the beginning of the loop would look more
readable indeed. The updated patch is below. Thanks!
---
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] slub: kmem_cache_shrink: fix crash due to uninitialized
 discard list

Currently, the discard list is only initialized at the beginning of the
function. As a result, if there are > 1 nodes, we can get use-after-free
while processing the second or higher node:

    WARNING: CPU: 60 PID: 1 at lib/list_debug.c:29 __list_add+0x3c/0xa9()
    list_add corruption. next->prev should be prev (ffff881ff0a6bb98), but was ffffea007ff57020. (next=ffffea007fbf7320).
    Modules linked in:
    CPU: 60 PID: 1 Comm: swapper/0 Not tainted 3.19.0-rc7-next-20150203-gb50cadf #2178
    Hardware name: Intel Corporation BRICKLAND/BRICKLAND, BIOS BIVTSDP1.86B.0038.R02.1307231126 07/23/2013
     0000000000000009 ffff881ff0a6ba88 ffffffff81c2e096 ffffffff810e2d03
     ffff881ff0a6bad8 ffff881ff0a6bac8 ffffffff8108b320 ffff881ff0a6bb18
     ffffffff8154bbc7 ffff881ff0a6bb98 ffffea007fbf7320 ffffea00ffc3c220
    Call Trace:
     [<ffffffff81c2e096>] dump_stack+0x4c/0x65
     [<ffffffff810e2d03>] ? console_unlock+0x398/0x3c7
     [<ffffffff8108b320>] warn_slowpath_common+0xa1/0xbb
     [<ffffffff8154bbc7>] ? __list_add+0x3c/0xa9
     [<ffffffff8108b380>] warn_slowpath_fmt+0x46/0x48
     [<ffffffff8154bbc7>] __list_add+0x3c/0xa9
     [<ffffffff811bf5aa>] __kmem_cache_shrink+0x12b/0x24c
     [<ffffffff81190ca9>] kmem_cache_shrink+0x26/0x38
     [<ffffffff815848b4>] acpi_os_purge_cache+0xe/0x12
     [<ffffffff815c6424>] acpi_purge_cached_objects+0x32/0x7a
     [<ffffffff825f70f1>] acpi_initialize_objects+0x17e/0x1ae
     [<ffffffff825f5177>] ? acpi_sleep_proc_init+0x2a/0x2a
     [<ffffffff825f5209>] acpi_init+0x92/0x25e
     [<ffffffff810002bd>] ? do_one_initcall+0x90/0x17f
     [<ffffffff811bdfcd>] ? kfree+0x1fc/0x2d5
     [<ffffffff825f5177>] ? acpi_sleep_proc_init+0x2a/0x2a
     [<ffffffff8100031a>] do_one_initcall+0xed/0x17f
     [<ffffffff825ae0e2>] kernel_init_freeable+0x1f0/0x278
     [<ffffffff81c1f31a>] ? rest_init+0x13e/0x13e
     [<ffffffff81c1f328>] kernel_init+0xe/0xda
     [<ffffffff81c3ca7c>] ret_from_fork+0x7c/0xb0
     [<ffffffff81c1f31a>] ? rest_init+0x13e/0x13e

Fix this by initializing the discard list at each iteration of the
for_each_kmem_cache_node loop. Also, move promote lists initialization
to the beginning of the loop to conform.

fixes: slub-never-fail-to-shrink-cache
Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Reported-by: Huang Ying <ying.huang@intel.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index 0909e13cf708..6832c4eab104 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3437,7 +3437,7 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 	struct kmem_cache_node *n;
 	struct page *page;
 	struct page *t;
-	LIST_HEAD(discard);
+	struct list_head discard;
 	struct list_head promote[SHRINK_PROMOTE_MAX];
 	unsigned long flags;
 	int ret = 0;
@@ -3457,11 +3457,12 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 		kick_all_cpus_sync();
 	}
 
-	for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
-		INIT_LIST_HEAD(promote + i);
-
 	flush_all(s);
 	for_each_kmem_cache_node(s, node, n) {
+		INIT_LIST_HEAD(&discard);
+		for (i = 0; i < SHRINK_PROMOTE_MAX; i++)
+			INIT_LIST_HEAD(promote + i);
+
 		spin_lock_irqsave(&n->list_lock, flags);
 
 		/*
@@ -3491,7 +3492,7 @@ int __kmem_cache_shrink(struct kmem_cache *s, bool deactivate)
 		 * partial list.
 		 */
 		for (i = SHRINK_PROMOTE_MAX - 1; i >= 0; i--)
-			list_splice_init(promote + i, &n->partial);
+			list_splice(promote + i, &n->partial);
 
 		spin_unlock_irqrestore(&n->list_lock, flags);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
