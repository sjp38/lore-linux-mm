Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3528D6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:15:37 -0500 (EST)
Received: by mail-la0-f51.google.com with SMTP id ge10so1484556lab.10
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:15:36 -0800 (PST)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id i8si22087932lam.48.2015.01.22.05.15.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 05:15:35 -0800 (PST)
Received: by mail-la0-f52.google.com with SMTP id hs14so1484374lab.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:15:34 -0800 (PST)
From: Andrey Skvortsov <andrej.skvortzov@gmail.com>
Subject: [PATCH] mm/slub: suppress BUG messages for kmem_cache_alloc/kmem_cache_free
Date: Thu, 22 Jan 2015 16:15:19 +0300
Message-Id: <1421932519-21036-1-git-send-email-Andrej.Skvortzov@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, linux-kernel@vger.kernel.org, Andrey Skvortsov <Andrej.Skvortzov@gmail.com>

After commit d2dc80750ee "mm/slub: optimize alloc/free fastpath by removing
preemption on/off" and if CONFIG_DEBUG_PREEMPT is set, then huge amount of BUG
messages like these happen:

BUG: using smp_processor_id() in preemptible [00000000] code: kjournald/171
caller is kmem_cache_alloc+0x41/0x132

and

BUG: using smp_processor_id() in preemptible [00000000] code: kdevtmpfs/12
caller is kmem_cache_free+0x5d/0x109

They are caused by this_cpu_ptr() that checks state of preemption.
Because preemption checks are not necessary anymore in this code, then
they are replaced with a raw_cpu_ptr() that does not check state of
preemption.

Signed-off-by: Andrey Skvortsov <Andrej.Skvortzov@gmail.com>
---

These "BUGs" appear for the first time in next-20150119.

[    0.947906] BUG: using smp_processor_id() in preemptible [00000000] code: kdevtmpfs/12
[    0.952925] caller is kmem_cache_free+0x5d/0x109
[    0.952931] CPU: 0 PID: 12 Comm: kdevtmpfs Tainted: G            E   3.19.0-rc5-next-20150121-150119- #1
[    0.952933] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.952936]  0000000000000000 ffff88000f8de1a0 ffffffff813d08ca 0000000000000000
[    0.952940]  ffffffff812036d7 0000000000000071 ffff88000c252000 ffff88000f801600
[    0.952944]  ffffea0000309400 ffffffff8113cf97 ffffffff811248e8 0000000000000000
[    0.952948] Call Trace:
[    0.952958]  [<ffffffff813d08ca>] ? dump_stack+0x4a/0x74
[    0.952963]  [<ffffffff812036d7>] ? check_preemption_disabled+0xd3/0xe4
[    0.952968]  [<ffffffff8113cf97>] ? do_path_lookup+0x47/0x52
[    0.952971]  [<ffffffff811248e8>] ? kmem_cache_free+0x5d/0x109
[    0.952974]  [<ffffffff8113cf97>] ? do_path_lookup+0x47/0x52
[    0.952977]  [<ffffffff8113cfca>] ? kern_path_create+0x28/0x117
[    0.952983]  [<ffffffff8105d38a>] ? preempt_count_sub+0xab/0xca
[    0.952987]  [<ffffffff81061e5a>] ? __dequeue_entity+0x1e/0x32
[    0.952993]  [<ffffffff812d0422>] ? handle_create.isra.2+0x37/0x1b9
[    0.952999]  [<ffffffff810c8831>] ? trace_preempt_on+0xe/0x2f
[    0.953003]  [<ffffffff8105d38a>] ? preempt_count_sub+0xab/0xca
[    0.953007]  [<ffffffff813d1e8f>] ? __schedule+0x467/0x550
[    0.953011]  [<ffffffff810c8831>] ? trace_preempt_on+0xe/0x2f
[    0.953014]  [<ffffffff812d05a4>] ? handle_create.isra.2+0x1b9/0x1b9
[    0.953017]  [<ffffffff812d068a>] ? devtmpfsd+0xe6/0x13b
[    0.953021]  [<ffffffff81055ba1>] ? kthread+0x9e/0xa6
[    0.953025]  [<ffffffff81055b03>] ? __kthread_parkme+0x5c/0x5c
[    0.953030]  [<ffffffff813d4c6c>] ? ret_from_fork+0x7c/0xb0
[    0.953033]  [<ffffffff81055b03>] ? __kthread_parkme+0x5c/0x5c

and

[    0.942593] BUG: using smp_processor_id() in preemptible [00000000] code: kdevtmpfs/12
[    0.945143] caller is kmem_cache_alloc+0x41/0x132
[    0.945149] CPU: 0 PID: 12 Comm: kdevtmpfs Tainted: G            E   3.19.0-rc5-next-20150121-150119- #1
[    0.945151] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.945153]  0000000000000000 ffff88000f8de1a0 ffffffff813d08ca 0000000000000000
[    0.945158]  ffffffff812036d7 ffffffffffffffef 0000000000015f40 0000000000000010
[    0.945162]  00000000000000d0 ffff88000f801600 ffffffff81124b43 ffffffff8114508f
[    0.945166] Call Trace:
[    0.945178]  [<ffffffff813d08ca>] ? dump_stack+0x4a/0x74
[    0.945184]  [<ffffffff812036d7>] ? check_preemption_disabled+0xd3/0xe4
[    0.945187]  [<ffffffff81124b43>] ? kmem_cache_alloc+0x41/0x132
[    0.945206]  [<ffffffff8114508f>] ? inode_init_always+0xfc/0x19c
[    0.945211]  [<ffffffff8113ce4c>] ? getname_kernel+0x29/0xe9
[    0.945215]  [<ffffffff8113ce4c>] ? getname_kernel+0x29/0xe9
[    0.945219]  [<ffffffff8113cf6d>] ? do_path_lookup+0x1d/0x52
[    0.945223]  [<ffffffff8113cfca>] ? kern_path_create+0x28/0x117
[    0.945233]  [<ffffffff810c8831>] ? trace_preempt_on+0xe/0x2f
[    0.945239]  [<ffffffff8105d38a>] ? preempt_count_sub+0xab/0xca
[    0.945244]  [<ffffffff81061e5a>] ? __dequeue_entity+0x1e/0x32
[    0.945250]  [<ffffffff812d0422>] ? handle_create.isra.2+0x37/0x1b9
[    0.945254]  [<ffffffff810c8831>] ? trace_preempt_on+0xe/0x2f
[    0.945257]  [<ffffffff8105d38a>] ? preempt_count_sub+0xab/0xca
[    0.945262]  [<ffffffff813d1e8f>] ? __schedule+0x467/0x550
[    0.945266]  [<ffffffff810c8831>] ? trace_preempt_on+0xe/0x2f
[    0.945269]  [<ffffffff812d05a4>] ? handle_create.isra.2+0x1b9/0x1b9
[    0.945273]  [<ffffffff812d068a>] ? devtmpfsd+0xe6/0x13b
[    0.945278]  [<ffffffff81055ba1>] ? kthread+0x9e/0xa6
[    0.945282]  [<ffffffff81055b03>] ? __kthread_parkme+0x5c/0x5c
[    0.945286]  [<ffffffff813d4c6c>] ? ret_from_fork+0x7c/0xb0
[    0.945290]  [<ffffffff81055b03>] ? __kthread_parkme+0x5c/0x5c



 mm/slub.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ceee1d7..6bcd031 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2404,7 +2404,7 @@ redo:
 	 */
 	do {
 		tid = this_cpu_read(s->cpu_slab->tid);
-		c = this_cpu_ptr(s->cpu_slab);
+		c = raw_cpu_ptr(s->cpu_slab);
 	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
 
 	/*
@@ -2670,7 +2670,7 @@ redo:
 	 */
 	do {
 		tid = this_cpu_read(s->cpu_slab->tid);
-		c = this_cpu_ptr(s->cpu_slab);
+		c = raw_cpu_ptr(s->cpu_slab);
 	} while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
 
 	/* Same with comment on barrier() in slab_alloc_node() */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
