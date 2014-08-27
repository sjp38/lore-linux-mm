Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id AEF2E6B0038
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 11:15:04 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so344852qac.30
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 08:15:04 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o96si924156qga.46.2014.08.27.08.15.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 08:15:04 -0700 (PDT)
From: WANG Chao <chaowang@redhat.com>
Subject: [PATCH] mm, slub: do not add duplicate sysfs
Date: Wed, 27 Aug 2014 23:14:48 +0800
Message-Id: <1409152488-21227-1-git-send-email-chaowang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "open list:SLAB ALLOCATOR" <linux-mm@kvack.org>, open list <linux-kernel@vger.kernel.org>

Mergeable slab can be changed to unmergeable after tuning its sysfs
interface, for example echo 1 > trace. But the sysfs kobject with the unique
name will be still there.

When creating a new mergeable slab, the following warning will happen:

(hello.ko is a trivial module to simply create a mergeable slab)

[  408.915029] ------------[ cut here ]------------
[  408.919641] WARNING: CPU: 3 PID: 2766 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x80()
[  408.927449] sysfs: cannot create duplicate filename '/kernel/slab/:t-0000048'
[  408.934563] Modules linked in: hello(O+) ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack xt_CHECKSUM iptable_mangle tun bridge stpi
[  408.980823] CPU: 3 PID: 2766 Comm: modprobe Tainted: G           O 3.17.0-rc1 #22
[  408.988981] Hardware name: Dell Inc. OptiPlex 760 /0M860N, BIOS A12 05/23/2011
[  408.997571]  0000000000000009 ffff8801a053ba40 ffffffff816c560e ffff8801a053ba88
[  409.004994]  ffff8801a053ba78 ffffffff810bbb2d ffff8800b6b6d000 ffff8800b65bc580
[  409.012414]  ffff8801a04260f0 0000000000000000 ffff880035d58b78 ffff8801a053bad8
[  409.019839] Call Trace:
[  409.022290]  [<ffffffff816c560e>] dump_stack+0x45/0x56
[  409.027418]  [<ffffffff810bbb2d>] warn_slowpath_common+0x7d/0xa0
[  409.033415]  [<ffffffff810bbb9c>] warn_slowpath_fmt+0x4c/0x50
[  409.039156]  [<ffffffff81273588>] ? kernfs_path+0x48/0x60
[  409.044546]  [<ffffffff81276bd4>] sysfs_warn_dup+0x64/0x80
[  409.050027]  [<ffffffff81276c7e>] sysfs_create_dir_ns+0x8e/0xa0
[  409.055938]  [<ffffffff81362f2f>] kobject_add_internal+0xbf/0x3f0
[  409.062019]  [<ffffffff81363610>] kobject_init_and_add+0x60/0x80
[  409.068016]  [<ffffffff811f2836>] ? sysfs_slab_add+0x146/0x200
[  409.073845]  [<ffffffff811f2771>] sysfs_slab_add+0x81/0x200
[  409.079409]  [<ffffffff811f518b>] __kmem_cache_create+0x51b/0x860
[  409.085494]  [<ffffffffc0094000>] ? 0xffffffffc0094000
[  409.090627]  [<ffffffff816c22ef>] ? printk+0x67/0x69
[  409.095584]  [<ffffffff811f45d2>] ? kmem_cache_alloc+0x1c2/0x1f0
[  409.101581]  [<ffffffff811bf3bb>] ? do_kmem_cache_create+0x3b/0xf0
[  409.107752]  [<ffffffff811bf42b>] do_kmem_cache_create+0xab/0xf0
[  409.113749]  [<ffffffff811bf622>] kmem_cache_create+0x1b2/0x2a0
[  409.119661]  [<ffffffff8136fa5e>] ? kasprintf+0x3e/0x40
[  409.124881]  [<ffffffffc0094000>] ? 0xffffffffc0094000
[  409.130019]  [<ffffffffc009403a>] init_hello+0x3a/0x1000 [hello]
[  409.136019]  [<ffffffff8100212c>] do_one_initcall+0xbc/0x1f0
[  409.141671]  [<ffffffff811da2c2>] ? __vunmap+0xb2/0x100
[  409.146891]  [<ffffffff8112e12e>] load_module+0x1e4e/0x25e0
[  409.152455]  [<ffffffff81129f40>] ? store_uevent+0x40/0x40
[  409.157934]  [<ffffffff8112aa31>] ? copy_module_from_fd.isra.47+0x121/0x180
[  409.164884]  [<ffffffff8112ea36>] SyS_finit_module+0x86/0xb0
[  409.170539]  [<ffffffff816cbba9>] system_call_fastpath+0x16/0x1b
[  409.176533] ---[ end trace c8eef8076cd27e36 ]---

Now if a unique is taken, we suffix it with an index, for example,
/sys/kernel/slab/:t-0000048 is already there, but not mergeable. We create
another unique name with index suffix, /sys/kernel/slab/:t-0000048-1, if
this one is taken too, we increase the index value each time, :t-0000048-2,
:t-0000048-3 ... until we find one.

Signed-off-by: WANG Chao <chaowang@redhat.com>
---
 mm/slub.c | 34 ++++++++++++++++++++++++++++++++--
 1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 3e8afcc..8b4944e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5099,9 +5099,9 @@ static inline struct kset *cache_kset(struct kmem_cache *s)
 
 /* Create a unique string id for a slab cache:
  *
- * Format	:[flags-]size
+ * Format	:[flags-]size[-index]
  */
-static char *create_unique_id(struct kmem_cache *s)
+static char *__create_unique_id(struct kmem_cache *s, int index)
 {
 	char *name = kmalloc(ID_STR_LENGTH, GFP_KERNEL);
 	char *p = name;
@@ -5127,11 +5127,41 @@ static char *create_unique_id(struct kmem_cache *s)
 	if (p != name + 1)
 		*p++ = '-';
 	p += sprintf(p, "%07d", s->size);
+	if (index)
+		p += sprintf(p, "-%d", index);
 
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
 }
 
+static char *create_unique_id(struct kmem_cache *s)
+{
+	char *name;
+	struct kmem_cache *k;
+	int index, unique;
+
+
+	for (index = 0, unique = 0; !unique; index++) {
+		name = __create_unique_id(s, index);
+		unique = 1;
+
+		/*
+		 * Walk through slab_caches to see if name is taken.
+		 * It happens when mergeables becomes unmergeables.
+		 */
+		list_for_each_entry(k, &slab_caches, list) {
+			if (!k->kobj.name)
+				continue;
+
+			if (!strcmp(k->kobj.name, name)) {
+				unique = 0;
+				break;
+			}
+		}
+	}
+	return name;
+}
+
 static int sysfs_slab_add(struct kmem_cache *s)
 {
 	int err;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
