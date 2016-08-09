Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71CA56B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 12:11:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4so27549605wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:11:18 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id eo1si35531939wjb.236.2016.08.09.09.11.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 09:11:17 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id i5so4120164wmg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 09:11:17 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v3] mm/slub: Run free_partial() outside of the kmem_cache_node->list_lock
Date: Tue,  9 Aug 2016 17:11:10 +0100
Message-Id: <1470759070-18743-1-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
References: <1470756466-12493-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <dsafonov@virtuozzo.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Dave Gordon <david.s.gordon@intel.com>, linux-mm@kvack.org

With debugobjects enabled and using SLAB_DESTROY_BY_RCU, when a
kmem_cache_node is destroyed the call_rcu() may trigger a slab
allocation to fill the debug object pool (__debug_object_init:fill_pool).
Everywhere but during kmem_cache_destroy(), discard_slab() is performed
outside of the kmem_cache_node->list_lock and avoids a lockdep warning
about potential recursion:

[  138.850350] =============================================
[  138.850352] [ INFO: possible recursive locking detected ]
[  138.850355] 4.8.0-rc1-gfxbench+ #1 Tainted: G     U
[  138.850357] ---------------------------------------------
[  138.850359] rmmod/8895 is trying to acquire lock:
[  138.850360]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff811c80d7>] get_partial_node.isra.63+0x47/0x430
[  138.850368]
               but task is already holding lock:
[  138.850371]  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff811cbda4>] __kmem_cache_shutdown+0x54/0x320
[  138.850376]
               other info that might help us debug this:
[  138.850378]  Possible unsafe locking scenario:

[  138.850380]        CPU0
[  138.850381]        ----
[  138.850382]   lock(&(&n->list_lock)->rlock);
[  138.850385]   lock(&(&n->list_lock)->rlock);
[  138.850387]
                *** DEADLOCK ***

[  138.850391]  May be due to missing lock nesting notation

[  138.850395] 5 locks held by rmmod/8895:
[  138.850397]  #0:  (&dev->mutex){......}, at: [<ffffffff8156ce32>] driver_detach+0x42/0xc0
[  138.850404]  #1:  (&dev->mutex){......}, at: [<ffffffff8156ce40>] driver_detach+0x50/0xc0
[  138.850410]  #2:  (cpu_hotplug.dep_map){++++++}, at: [<ffffffff8107d65d>] get_online_cpus+0x2d/0x80
[  138.850418]  #3:  (slab_mutex){+.+.+.}, at: [<ffffffff811964ec>] kmem_cache_destroy+0x3c/0x220
[  138.850424]  #4:  (&(&n->list_lock)->rlock){-.-...}, at: [<ffffffff811cbda4>] __kmem_cache_shutdown+0x54/0x320
[  138.850431]
               stack backtrace:
[  138.850435] CPU: 6 PID: 8895 Comm: rmmod Tainted: G     U          4.8.0-rc1-gfxbench+ #1
[  138.850439] Hardware name: Gigabyte Technology Co., Ltd. H87M-D3H/H87M-D3H, BIOS F11 08/18/2015
[  138.850443]  0000000000000000 ffff880179b93800 ffffffff814221f5 ffff8801d1e5ce40
[  138.850449]  ffffffff827c6dd0 ffff880179b938c0 ffffffff810d48a6 00ffffff00000000
[  138.850454]  ffff88017990d900 ffff880179b93930 ffffffff0000d445 a70e0e46e14b0709
[  138.850459] Call Trace:
[  138.850463]  [<ffffffff814221f5>] dump_stack+0x67/0x92
[  138.850467]  [<ffffffff810d48a6>] __lock_acquire+0x1646/0x1ad0
[  138.850492]  [<ffffffffa00e6a7b>] ? i915_exit+0x1a/0x1e2 [i915]
[  138.850509]  [<ffffffff810d5172>] lock_acquire+0xb2/0x200
[  138.850512]  [<ffffffff811c80d7>] ? get_partial_node.isra.63+0x47/0x430
[  138.850516]  [<ffffffff8180b8d6>] _raw_spin_lock+0x36/0x50
[  138.850519]  [<ffffffff811c80d7>] ? get_partial_node.isra.63+0x47/0x430
[  138.850522]  [<ffffffff811c80d7>] get_partial_node.isra.63+0x47/0x430
[  138.850543]  [<ffffffff8110e757>] ? __module_address+0x27/0xf0
[  138.850558]  [<ffffffffa00e6a7b>] ? i915_exit+0x1a/0x1e2 [i915]
[  138.850561]  [<ffffffff8110e82d>] ? __module_text_address+0xd/0x60
[  138.850565]  [<ffffffff811124ca>] ? is_module_text_address+0x2a/0x50
[  138.850568]  [<ffffffff8109ec51>] ? __kernel_text_address+0x31/0x80
[  138.850572]  [<ffffffff8101edd9>] ? print_context_stack+0x79/0xd0
[  138.850575]  [<ffffffff8101e584>] ? dump_trace+0x124/0x300
[  138.850579]  [<ffffffff811c9137>] ___slab_alloc.constprop.67+0x1a7/0x3b0
[  138.850582]  [<ffffffff8144109e>] ? __debug_object_init+0x2de/0x400
[  138.850586]  [<ffffffff810d0f07>] ? add_lock_to_list.isra.22.constprop.41+0x77/0xc0
[  138.850590]  [<ffffffff810d460e>] ? __lock_acquire+0x13ae/0x1ad0
[  138.850594]  [<ffffffff8144109e>] ? __debug_object_init+0x2de/0x400
[  138.850597]  [<ffffffff811c9383>] __slab_alloc.isra.64.constprop.66+0x43/0x80
[  138.850601]  [<ffffffff811c95f6>] kmem_cache_alloc+0x236/0x2d0
[  138.850604]  [<ffffffff8144109e>] ? __debug_object_init+0x2de/0x400
[  138.850607]  [<ffffffff8144109e>] __debug_object_init+0x2de/0x400
[  138.850611]  [<ffffffff81441309>] debug_object_activate+0x109/0x1e0
[  138.850614]  [<ffffffff811c8d60>] ? slab_cpuup_callback+0x100/0x100
[  138.850618]  [<ffffffff810ed242>] __call_rcu.constprop.63+0x32/0x2f0
[  138.850621]  [<ffffffff810ed512>] call_rcu+0x12/0x20
[  138.850624]  [<ffffffff811c7c8d>] discard_slab+0x3d/0x40
[  138.850627]  [<ffffffff811cbe2b>] __kmem_cache_shutdown+0xdb/0x320
[  138.850631]  [<ffffffff811964ec>] ? kmem_cache_destroy+0x3c/0x220
[  138.850634]  [<ffffffff81195a89>] shutdown_cache+0x19/0x60
[  138.850638]  [<ffffffff8119665e>] kmem_cache_destroy+0x1ae/0x220
[  138.850650]  [<ffffffffa0060e74>] i915_gem_load_cleanup+0x14/0x40 [i915]
[  138.850660]  [<ffffffffa001ffd1>] i915_driver_unload+0x151/0x180 [i915]
[  138.850670]  [<ffffffffa002a1c4>] i915_pci_remove+0x14/0x20 [i915]
[  138.850673]  [<ffffffff8146ef54>] pci_device_remove+0x34/0xb0
[  138.850677]  [<ffffffff8156cd05>] __device_release_driver+0x95/0x140
[  138.850680]  [<ffffffff8156cea6>] driver_detach+0xb6/0xc0
[  138.850683]  [<ffffffff8156bd53>] bus_remove_driver+0x53/0xd0
[  138.850687]  [<ffffffff8156d987>] driver_unregister+0x27/0x50
[  138.850689]  [<ffffffff8146dfb5>] pci_unregister_driver+0x25/0x70
[  138.850704]  [<ffffffffa00e6a7b>] i915_exit+0x1a/0x1e2 [i915]
[  138.850707]  [<ffffffff8110f3d3>] SyS_delete_module+0x193/0x1f0
[  138.850711]  [<ffffffff8180c429>] entry_SYSCALL_64_fastpath+0x1c/0xac

v2: Keep remove_partial() under the lock, just move discard_slab()
outside the lock.
v3: Rename discard list.

Fixes: 52b4b950b507 ("mm: slab: free kmem_cache_node after destroy sysfs file")
Reported-by: Dave Gordon <david.s.gordon@intel.com>
Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Dave Gordon <david.s.gordon@intel.com>
Cc: linux-mm@kvack.org
---
 mm/slub.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 825ff45..7a6d268 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3479,6 +3479,7 @@ static void list_slab_objects(struct kmem_cache *s, struct page *page,
  */
 static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 {
+	LIST_HEAD(discard);
 	struct page *page, *h;
 
 	BUG_ON(irqs_disabled());
@@ -3486,13 +3487,16 @@ static void free_partial(struct kmem_cache *s, struct kmem_cache_node *n)
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
 		if (!page->inuse) {
 			remove_partial(n, page);
-			discard_slab(s, page);
+			list_add(&page->lru, &discard);
 		} else {
 			list_slab_objects(s, page,
 			"Objects remaining in %s on __kmem_cache_shutdown()");
 		}
 	}
 	spin_unlock_irq(&n->list_lock);
+
+	list_for_each_entry_safe(page, h, &discard, lru)
+		discard_slab(s, page);
 }
 
 /*
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
