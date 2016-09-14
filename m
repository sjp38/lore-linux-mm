Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39B846B0038
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:35:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so15338105lfs.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:35:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e23si4605982wmc.77.2016.09.14.07.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 07:35:13 -0700 (PDT)
Date: Wed, 14 Sep 2016 10:31:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [fuse-devel] Kernel panic under load
Message-ID: <20160914143102.GA1445@cmpxchg.org>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
 <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
 <20160909194239.GA16056@cmpxchg.org>
 <CAJfpegv3Hk3WtGG0gQ+TGpyoH0CoTf=um8gUdV8KA-ZneQ8+JA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CAJfpegv3Hk3WtGG0gQ+TGpyoH0CoTf=um8gUdV8KA-ZneQ8+JA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Antonio SJ Musumeci <trapexit@spawn.link>, fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Miklos,

On Tue, Sep 13, 2016 at 10:42:17AM +0200, Miklos Szeredi wrote:
> Fuse allows pages to be spliced into the page cache when reading the
> file.  It does this with replace_page_cache_page(), which is an atomic
> version of delete_from_page_cache()+add_to_page_cache().
>=20
> Fuse is the only user of replace_page_cache_page(), so I imagine bugs
> can more easily escape notice than the more commonly used variants.
>=20
> Could you please take a look at this function.  "git blame" shows that
> it's older than the add/remove variants, but I haven't gone into the
> details.

Indeed, replace_page_cache_page() uses a properly accounted deletion
of the old page followed by a raw, untracked radix_tree_insert(). It
would lead to an underflow that triggers the page counter assertion.

Thanks for the pointer, Miklos. This has been broken for a while.

Antonio, does the following patch resolve the issue for you? It
applies to the head of Linus's tree, let me know if you need it
backported to a different base.

---

=46rom 3a2bb511f5e04019ccc487ef995b94700db172e7 Mon Sep 17 00:00:00 2001
=46rom: Johannes Weiner <hannes@cmpxchg.org>
Date: Wed, 14 Sep 2016 09:50:42 -0400
Subject: [PATCH] mm: workingset: fix shadow node leak in
 replace_page_cache_page()

Antonio reports the following crash when using fuse under memory
pressure:

[25192.515454] kernel BUG at /build/linux-a2WvEb/linux-4.4.0/mm/workingset.=
c:346!
[25192.517521] invalid opcode: 0000 [#1] SMP
[25192.519602] Modules linked in: netconsole ip6t_REJECT nf_reject_ipv6 ipt=
_REJECT nf_reject_ipv4 configfs binfmt_misc veth bridge stp llc nf_conntrac=
k_ipv6 nf_defrag_ipv6 xt_conntrack ip6table_filter ip6_tables xt_multiport =
iptable_filter ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_comment xt_nat ipta=
ble_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt=
_CHECKSUM xt_tcpudp iptable_mangle ip_tables x_tables intel_rapl x86_pkg_te=
mp_thermal intel_powerclamp eeepc_wmi asus_wmi coretemp sparse_keymap kvm_i=
ntel ppdev kvm irqbypass mei_me 8250_fintek input_leds serio_raw parport_pc=
 tpm_infineon mei shpchp mac_hid parport lpc_ich autofs4 drbg ansi_cprng dm=
_crypt algif_skcipher af_alg btrfs raid456 async_raid6_recov async_memcpy a=
sync_pq async_xor async_tx xor raid6_pq libcrc32c raid0 multipath linear ra=
id10 raid1 i915 crct10dif_pclmul crc32_pclmul aesni_intel i2c_algo_bit aes_=
x86_64 drm_kms_helper lrw gf128mul glue_helper ablk_helper syscopyarea cryp=
td sysfillrect sysimgblt fb_sys_fops drm ahci r8169 libahci mii wmi fjes vi=
deo [last unloaded: netconsole]
[25192.540910] CPU: 2 PID: 63 Comm: kswapd0 Not tainted 4.4.0-36-generic #5=
5-Ubuntu
[25192.543411] Hardware name: System manufacturer System Product Name/P8H67=
-M PRO, BIOS 3904 04/27/2013
[25192.545840] task: ffff88040cae6040 ti: ffff880407488000 task.ti: ffff880=
407488000
[25192.548277] RIP: 0010:[<ffffffff811ba501>]  [<ffffffff811ba501>] shadow_=
lru_isolate+0x181/0x190
[25192.550706] RSP: 0018:ffff88040748bbe0  EFLAGS: 00010002
[25192.553127] RAX: 0000000000001c81 RBX: ffff8802f91ee928 RCX: ffff8802f91=
eeb38
[25192.555544] RDX: ffff8802f91ee938 RSI: ffff8802f91ee928 RDI: ffff8804099=
ba2c0
[25192.557914] RBP: ffff88040748bc08 R08: 000000000001a7b6 R09: 00000000000=
0003f
[25192.560237] R10: 000000000001a750 R11: 0000000000000000 R12: ffff8804099=
ba2c0
[25192.562512] R13: ffff8803157e9680 R14: ffff8803157e9668 R15: ffff8804099=
ba2c8
[25192.564724] FS:  0000000000000000(0000) GS:ffff88041f280000(0000) knlGS:=
0000000000000000
[25192.566990] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[25192.569201] CR2: 00007ffabb690000 CR3: 0000000001e0a000 CR4: 00000000000=
406e0
[25192.571419] Stack:
[25192.573550]  ffff8804099ba2c0 ffff88039e4f86f0 ffff8802f91ee928 ffff8804=
099ba2c8
[25192.575695]  ffff88040748bd08 ffff88040748bc58 ffffffff811b99bf 00000000=
00000052
[25192.577814]  0000000000000000 ffffffff811ba380 000000000000008a 00000000=
00000080
[25192.579947] Call Trace:
[25192.582022]  [<ffffffff811b99bf>] __list_lru_walk_one.isra.3+0x8f/0x130
[25192.584137]  [<ffffffff811ba380>] ? memcg_drain_all_list_lrus+0x190/0x190
[25192.586165]  [<ffffffff811b9a83>] list_lru_walk_one+0x23/0x30
[25192.588145]  [<ffffffff811ba544>] scan_shadow_nodes+0x34/0x50
[25192.590074]  [<ffffffff811a0e9d>] shrink_slab.part.40+0x1ed/0x3d0
[25192.591985]  [<ffffffff811a53da>] shrink_zone+0x2ca/0x2e0
[25192.593863]  [<ffffffff811a64ce>] kswapd+0x51e/0x990
[25192.595737]  [<ffffffff811a5fb0>] ? mem_cgroup_shrink_node_zone+0x1c0/0x=
1c0
[25192.597613]  [<ffffffff810a0808>] kthread+0xd8/0xf0
[25192.599495]  [<ffffffff810a0730>] ? kthread_create_on_node+0x1e0/0x1e0
[25192.601335]  [<ffffffff8182e34f>] ret_from_fork+0x3f/0x70
[25192.603193]  [<ffffffff810a0730>] ? kthread_create_on_node+0x1e0/0x1e0
[25192.605083] Code: 8d 7e 08 4c 89 fe e8 4f cc 23 00 84 c0 74 20 4c 89 ef =
c6 07 00 66 66 66 90 bb 01 00 00 00 e9 c5 fe ff ff 0f 0b 0f 0b 0f 0b 0f 0b =
<0f> 0b 0f 0b 0f 0b 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55
[25192.609252] RIP  [<ffffffff811ba501>] shadow_lru_isolate+0x181/0x190
[25192.611304]  RSP <ffff88040748bbe0>

which corresponds to the following sanity check in the shadow node
tracking:

  BUG_ON(node->count & RADIX_TREE_COUNT_MASK);

The workingset code tracks radix tree nodes that exclusively contain
shadow entries of evicted pages in them, and this (somewhat obscure)
checks if there are real pages left that would interfere with reclaim
of the radix tree node under memory pressure.

Discussing ways of how fuse might sneak pages into the radix tree past
the workingset code, Miklos pointed to replace_page_cache_page(), and
indeed there is a problem there: it properly accounts for the old page
being removed (__delete_from_page_cache() does that), but then does a
raw raw radix_tree_insert(), not accounting for the replacement page;
the page counter bits in node->count eventually underflow.

To address this, make sure replace_page_cache_page() uses the tracked
page insertion code, page_cache_tree_insert().

Also, make the sanity checks a bit less obscure by using the helpers
for checking the number of pages and shadows in a radix tree node.

Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
Cc: stable@vger.kernel.org # 3.15+
Reported-by: Antonio SJ Musumeci <trapexit@spawn.link>
Debugged-by: Miklos Szeredi <miklos@szeredi.hu>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/swap.h |   2 +
 mm/filemap.c         | 114 +++++++++++++++++++++++++----------------------=
----
 mm/workingset.c      |  10 ++---
 3 files changed, 63 insertions(+), 63 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b17cc4830fa6..4a529c984a3f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -257,6 +257,7 @@ static inline void workingset_node_pages_inc(struct rad=
ix_tree_node *node)
=20
 static inline void workingset_node_pages_dec(struct radix_tree_node *node)
 {
+	VM_BUG_ON(!workingset_node_pages(node));
 	node->count--;
 }
=20
@@ -272,6 +273,7 @@ static inline void workingset_node_shadows_inc(struct r=
adix_tree_node *node)
=20
 static inline void workingset_node_shadows_dec(struct radix_tree_node *nod=
e)
 {
+	VM_BUG_ON(!workingset_node_shadows(node));
 	node->count -=3D 1U << RADIX_TREE_COUNT_SHIFT;
 }
=20
diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287dfc5372..2d0986a64f1f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -110,6 +110,62 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
=20
+static int page_cache_tree_insert(struct address_space *mapping,
+				  struct page *page, void **shadowp)
+{
+	struct radix_tree_node *node;
+	void **slot;
+	int error;
+
+	error =3D __radix_tree_create(&mapping->page_tree, page->index, 0,
+				    &node, &slot);
+	if (error)
+		return error;
+	if (*slot) {
+		void *p;
+
+		p =3D radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
+		if (!radix_tree_exceptional_entry(p))
+			return -EEXIST;
+
+		mapping->nrexceptional--;
+		if (!dax_mapping(mapping)) {
+			if (shadowp)
+				*shadowp =3D p;
+			if (node)
+				workingset_node_shadows_dec(node);
+		} else {
+			/* DAX can replace empty locked entry with a hole */
+			WARN_ON_ONCE(p !=3D
+				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
+					 RADIX_DAX_ENTRY_LOCK));
+			/* DAX accounts exceptional entries as normal pages */
+			if (node)
+				workingset_node_pages_dec(node);
+			/* Wakeup waiters for exceptional entry lock */
+			dax_wake_mapping_entry_waiter(mapping, page->index,
+						      false);
+		}
+	}
+	radix_tree_replace_slot(slot, page);
+	mapping->nrpages++;
+	if (node) {
+		workingset_node_pages_inc(node);
+		/*
+		 * Don't track node that contains actual pages.
+		 *
+		 * Avoid acquiring the list_lru lock if already
+		 * untracked.  The list_empty() test is safe as
+		 * node->private_list is protected by
+		 * mapping->tree_lock.
+		 */
+		if (!list_empty(&node->private_list))
+			list_lru_del(&workingset_shadow_nodes,
+				     &node->private_list);
+	}
+	return 0;
+}
+
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
@@ -561,7 +617,7 @@ int replace_page_cache_page(struct page *old, struct pa=
ge *new, gfp_t gfp_mask)
=20
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		__delete_from_page_cache(old, NULL);
-		error =3D radix_tree_insert(&mapping->page_tree, offset, new);
+		error =3D page_cache_tree_insert(mapping, new, NULL);
 		BUG_ON(error);
 		mapping->nrpages++;
=20
@@ -584,62 +640,6 @@ int replace_page_cache_page(struct page *old, struct p=
age *new, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
=20
-static int page_cache_tree_insert(struct address_space *mapping,
-				  struct page *page, void **shadowp)
-{
-	struct radix_tree_node *node;
-	void **slot;
-	int error;
-
-	error =3D __radix_tree_create(&mapping->page_tree, page->index, 0,
-				    &node, &slot);
-	if (error)
-		return error;
-	if (*slot) {
-		void *p;
-
-		p =3D radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
-		if (!radix_tree_exceptional_entry(p))
-			return -EEXIST;
-
-		mapping->nrexceptional--;
-		if (!dax_mapping(mapping)) {
-			if (shadowp)
-				*shadowp =3D p;
-			if (node)
-				workingset_node_shadows_dec(node);
-		} else {
-			/* DAX can replace empty locked entry with a hole */
-			WARN_ON_ONCE(p !=3D
-				(void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
-					 RADIX_DAX_ENTRY_LOCK));
-			/* DAX accounts exceptional entries as normal pages */
-			if (node)
-				workingset_node_pages_dec(node);
-			/* Wakeup waiters for exceptional entry lock */
-			dax_wake_mapping_entry_waiter(mapping, page->index,
-						      false);
-		}
-	}
-	radix_tree_replace_slot(slot, page);
-	mapping->nrpages++;
-	if (node) {
-		workingset_node_pages_inc(node);
-		/*
-		 * Don't track node that contains actual pages.
-		 *
-		 * Avoid acquiring the list_lru lock if already
-		 * untracked.  The list_empty() test is safe as
-		 * node->private_list is protected by
-		 * mapping->tree_lock.
-		 */
-		if (!list_empty(&node->private_list))
-			list_lru_del(&workingset_shadow_nodes,
-				     &node->private_list);
-	}
-	return 0;
-}
-
 static int __add_to_page_cache_locked(struct page *page,
 				      struct address_space *mapping,
 				      pgoff_t offset, gfp_t gfp_mask,
diff --git a/mm/workingset.c b/mm/workingset.c
index 69551cfae97b..617475f529f4 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -418,21 +418,19 @@ static enum lru_status shadow_lru_isolate(struct list=
_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-
-	BUG_ON(!node->count);
-	BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
+	BUG_ON(!workingset_node_shadows(node));
+	BUG_ON(workingset_node_pages(node));
=20
 	for (i =3D 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
 			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
 			node->slots[i] =3D NULL;
-			BUG_ON(node->count < (1U << RADIX_TREE_COUNT_SHIFT));
-			node->count -=3D 1U << RADIX_TREE_COUNT_SHIFT;
+			workingset_node_shadows_dec(node);
 			BUG_ON(!mapping->nrexceptional);
 			mapping->nrexceptional--;
 		}
 	}
-	BUG_ON(node->count);
+	BUG_ON(workingset_node_shadows(node));
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
--=20
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
