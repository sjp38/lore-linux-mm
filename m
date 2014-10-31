Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6AFF8280031
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 04:07:05 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lf10so7241824pab.33
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 01:07:05 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id rq6si3481241pbc.17.2014.10.31.01.07.03
        for <linux-mm@kvack.org>;
        Fri, 31 Oct 2014 01:07:04 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH for v3.18] mm/slab: fix unalignment problem on Malta with EVA due to slab merge
Date: Fri, 31 Oct 2014 17:08:32 +0900
Message-Id: <1414742912-14852-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Markos Chandras <Markos.Chandras@imgtec.com>, linux-mips@linux-mips.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Unlike the SLUB, sometimes, object isn't started at the beginning of
the slab in the SLAB. This causes the unalignment problem after
slab merging is supported by commit 12220dea07f1 ("mm/slab:
support slab merge"). Following is the report from Markos that fail
to boot on Malta with EVA.

Calibrating delay loop... 19.86 BogoMIPS (lpj=99328)
pid_max: default: 32768 minimum: 301
Mount-cache hash table entries: 4096 (order: 0, 16384 bytes)
Mountpoint-cache hash table entries: 4096 (order: 0, 16384 bytes)
Kernel bug detected[#1]:
CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0-05639-g12220dea07f1 #1631
task: 1f04f5d8 ti: 1f050000 task.ti: 1f050000
$ 0   : 00000000 806c0000 00000080 00000000
$ 4   : 1f048080 00000001 00000001 00000000
$ 8   : 1f04f5d8 00000001 fffffffc 00000000
$12   : 00000000 ffffffff fffef7b7 00000000
$16   : 1f048080 1f00ec00 1f048180 806ba998
$20   : 1f00ec00 80660000 1f03b780 806ad380
$24   : 00000000 80154d70
$28   : 1f050000 1f053d48 806ba8ec 80141184
Hi    : 00000000
Lo    : 0b532b80
epc   : 80141190 alloc_unbound_pwq+0x234/0x304
    Not tainted
ra    : 80141184 alloc_unbound_pwq+0x228/0x304
Status: 1000dc03        KERNEL EXL IE
Cause : 00800034
PrId  : 0001a82d (MIPS P5600)
Modules linked in:
Process swapper/0 (pid: 1, threadinfo=1f050000, task=1f04f5d8, tls=00000000)
Stack : 1f03b880 00000002 1f03b800 80140d90 1f048180 1f03b880 00000002
1f03b800
          1f03bb80 801417a4 1f0481e0 0000000e 1f048180 00000200 1f048180
1f048190
          00000002 1f048188 80660000 80660000 8065af94 80141dc0 0110d710
00000100
          8065af94 806ad380 8065b200 8013ea70 1f048280 1f053e0c 8065af98
1f0481e0
          00000000 00000004 80660000 80660000 80660000 80660000 80660000
80660000
          ...
Call Trace:
[<80141190>] alloc_unbound_pwq+0x234/0x304
[<801417a4>] apply_workqueue_attrs+0x11c/0x294
[<80141dc0>] __alloc_workqueue_key+0x23c/0x470
[<80683de4>] init_workqueues+0x320/0x400
[<8010058c>] do_one_initcall+0xe8/0x23c
[<8067cbec>] kernel_init_freeable+0x9c/0x224
[<80565fd8>] kernel_init+0x10/0x100
[<80104e38>] ret_from_kernel_thread+0x14/0x1c

Code: 10400032  00408021  320200ff <00020336> 00002821  02002021
0c0defb0  24060100  26020074
---[ end trace cb88537fdc8fa200 ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

---[ end Kernel panic - not syncing: Attempted to kill init!
exitcode=0x0000000b

alloc_unbound_pwq() allocates slab object from pool_workqueue. This
kmem_cache requires 256 bytes alignment, but, current merging code
doesn't honor that, and merge it with kmalloc-256. kmalloc-256 requires
only cacheline size alignment so that above failure occurs. However,
in x86, kmalloc-256 is luckily aligned in 256 bytes, so the problem
didn't happen on it.

To fix this problem, this patch introduces alignment mismatch check
in find_mergeable(). This will fix the problem.

Reported-by: Markos Chandras <Markos.Chandras@imgtec.com>
Tested-by: Markos Chandras <Markos.Chandras@imgtec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab_common.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3a6e0cf..2657084 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -269,6 +269,10 @@ struct kmem_cache *find_mergeable(size_t size, size_t align,
 		if (s->size - size >= sizeof(void *))
 			continue;
 
+		if (IS_ENABLED(CONFIG_SLAB) && align &&
+			(align > s->align || s->align % align))
+			continue;
+
 		return s;
 	}
 	return NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
