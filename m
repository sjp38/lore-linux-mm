Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 49DE86B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 03:00:43 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so6847714pac.3
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 00:00:42 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id db10si1764234pdb.238.2014.08.08.00.00.41
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 00:00:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH for v3.17-rc1] Revert "slab: remove BAD_ALIEN_MAGIC"
Date: Fri,  8 Aug 2014 16:00:39 +0900
Message-Id: <1407481239-7572-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This reverts commit a640616822b2 ("slab: remove BAD_ALIEN_MAGIC").

commit a640616822b2 ("slab: remove BAD_ALIEN_MAGIC") assumes that the
system with !CONFIG_NUMA has only one memory node. But, it turns out to
be false by the report from Geert. His system, m68k, has many memory nodes
and is configured in !CONFIG_NUMA. So it couldn't boot with above change.

Here goes his failure report.

  With latest mainline, I'm getting a crash during bootup on m68k/ARAnyM:

  enable_cpucache failed for radix_tree_node, error 12.
  kernel BUG at /scratch/geert/linux/linux-m68k/mm/slab.c:1522!
  *** TRAP #7 ***   FORMAT=0
  Current process id is 0
  BAD KERNEL TRAP: 00000000
  Modules linked in:
  PC: [<0039c92c>] kmem_cache_init_late+0x70/0x8c
  SR: 2200  SP: 00345f90  a2: 0034c2e8
  d0: 0000003d    d1: 00000000    d2: 00000000    d3: 003ac942
  d4: 00000000    d5: 00000000    a0: 0034f686    a1: 0034f682
  Process swapper (pid: 0, task=0034c2e8)
  Frame format=0
  Stack from 00345fc4:
          002f69ef 002ff7e5 000005f2 000360fa 0017d806 003921d4 00000000
          00000000 00000000 00000000 00000000 00000000 003ac942 00000000
          003912d6
  Call Trace: [<000360fa>] parse_args+0x0/0x2ca
   [<0017d806>] strlen+0x0/0x1a
   [<003921d4>] start_kernel+0x23c/0x428
   [<003912d6>] _sinittext+0x2d6/0x95e

  Code: f7e5 4879 002f 69ef 61ff ffca 462a 4e47 <4879> 0035 4b1c 61ff
  fff0 0cc4 7005 23c0 0037 fd20 588f 265f 285f 4e75 48e7 301c
  Disabling lock debugging due to kernel taint
  Kernel panic - not syncing: Attempted to kill the idle task!
  ---[ end Kernel panic - not syncing: Attempted to kill the idle task!

Although there is a alternative way to fix this issue such as disabling
use of alien cache on !CONFIG_NUMA, but, reverting issued commit is better
to me in this time.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index c727a16..0376429 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -470,6 +470,8 @@ static struct kmem_cache kmem_cache_boot = {
 	.name = "kmem_cache",
 };
 
+#define BAD_ALIEN_MAGIC 0x01020304ul
+
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -836,7 +838,7 @@ static int transfer_objects(struct array_cache *to,
 static inline struct alien_cache **alloc_alien_cache(int node,
 						int limit, gfp_t gfp)
 {
-	return NULL;
+	return (struct alien_cache **)BAD_ALIEN_MAGIC;
 }
 
 static inline void free_alien_cache(struct alien_cache **ac_ptr)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
