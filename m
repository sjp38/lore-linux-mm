Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A11276B0082
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 21:35:10 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <13c63325-9e2d-4efc-a910-688304dad6ce@default>
Date: Fri, 19 Jun 2009 18:36:05 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC PATCH 3/4] tmem: preswap implementation (layered on tmem)
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: dan.magenheimer@oracle.com, linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- linux-2.6.30/mm/page_io.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/page_io.c=092009-06-19 09:33:59.000000000 -0600
@@ -102,6 +102,12 @@
 =09=09unlock_page(page);
 =09=09goto out;
 =09}
+=09if (preswap_put(page) =3D=3D 1) {
+=09=09set_page_writeback(page);
+=09=09unlock_page(page);
+=09=09end_page_writeback(page);
+=09=09goto out;
+=09}
 =09bio =3D get_swap_bio(GFP_NOIO, page_private(page), page,
 =09=09=09=09end_swap_bio_write);
 =09if (bio =3D=3D NULL) {
@@ -134,6 +140,12 @@
 =09=09ret =3D -ENOMEM;
 =09=09goto out;
 =09}
+=09if (preswap_get(page) =3D=3D 1) {
+=09=09SetPageUptodate(page);
+=09=09unlock_page(page);
+=09=09bio_put(bio);
+=09=09goto out;
+=09}
 =09count_vm_event(PSWPIN);
 =09submit_bio(READ, bio);
 out:
--- linux-2.6.30/mm/swapfile.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/mm/swapfile.c=092009-06-19 16:20:14.000000000 -0600
@@ -35,7 +35,7 @@
 #include <linux/swapops.h>
 #include <linux/page_cgroup.h>
=20
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -47,7 +47,7 @@
 static const char Bad_offset[] =3D "Bad swap offset entry ";
 static const char Unused_offset[] =3D "Unused swap offset entry ";
=20
-static struct swap_list_t swap_list =3D {-1, -1};
+struct swap_list_t swap_list =3D {-1, -1};
=20
 static struct swap_info_struct swap_info[MAX_SWAPFILES];
=20
@@ -488,6 +488,7 @@
 =09=09=09=09swap_list.next =3D p - swap_info;
 =09=09=09nr_swap_pages++;
 =09=09=09p->inuse_pages--;
+=09=09=09preswap_flush(p - swap_info, offset);
 =09=09=09mem_cgroup_uncharge_swap(ent);
 =09=09}
 =09}
@@ -864,7 +865,7 @@
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-=09=09=09=09=09unsigned int prev)
+=09=09=09=09unsigned int prev, unsigned int preswap)
 {
 =09unsigned int max =3D si->max;
 =09unsigned int i =3D prev;
@@ -890,6 +891,12 @@
 =09=09=09prev =3D 0;
 =09=09=09i =3D 1;
 =09=09}
+=09=09if (preswap) {
+=09=09=09if (preswap_test(si, i))
+=09=09=09=09break;
+=09=09=09else
+=09=09=09=09continue;
+=09=09}
 =09=09count =3D si->swap_map[i];
 =09=09if (count && count !=3D SWAP_MAP_BAD)
 =09=09=09break;
@@ -901,8 +908,12 @@
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
+ *
+ * if the boolean preswap is true, only unuse pages_to_unuse pages;
+ * pages_to_unuse=3D=3D0 means all pages
  */
-static int try_to_unuse(unsigned int type)
+int try_to_unuse(unsigned int type, unsigned int preswap,
+=09=09unsigned long pages_to_unuse)
 {
 =09struct swap_info_struct * si =3D &swap_info[type];
 =09struct mm_struct *start_mm;
@@ -938,7 +949,7 @@
 =09 * one pass through swap_map is enough, but not necessarily:
 =09 * there are races when an instance of an entry might be missed.
 =09 */
-=09while ((i =3D find_next_to_unuse(si, i)) !=3D 0) {
+=09while ((i =3D find_next_to_unuse(si, i, preswap)) !=3D 0) {
 =09=09if (signal_pending(current)) {
 =09=09=09retval =3D -EINTR;
 =09=09=09break;
@@ -1124,6 +1135,8 @@
 =09=09 * interactive performance.
 =09=09 */
 =09=09cond_resched();
+=09=09if (preswap && pages_to_unuse && !--pages_to_unuse)
+=09=09=09break;
 =09}
=20
 =09mmput(start_mm);
@@ -1448,7 +1461,7 @@
 =09spin_unlock(&swap_lock);
=20
 =09current->flags |=3D PF_SWAPOFF;
-=09err =3D try_to_unuse(type);
+=09err =3D try_to_unuse(type, 0, 0);
 =09current->flags &=3D ~PF_SWAPOFF;
=20
 =09if (err) {
@@ -1497,9 +1510,14 @@
 =09swap_map =3D p->swap_map;
 =09p->swap_map =3D NULL;
 =09p->flags =3D 0;
+=09preswap_flush_area(p - swap_info);
 =09spin_unlock(&swap_lock);
 =09mutex_unlock(&swapon_mutex);
 =09vfree(swap_map);
+#ifdef CONFIG_PRESWAP
+=09if (p->preswap_map)
+=09=09vfree(p->preswap_map);
+#endif
 =09/* Destroy swap account informatin */
 =09swap_cgroup_swapoff(type);
=20
@@ -1812,6 +1830,11 @@
 =09}
=20
 =09memset(swap_map, 0, maxpages * sizeof(short));
+#ifdef CONFIG_PRESWAP
+=09p->preswap_map =3D vmalloc(maxpages / sizeof(long));
+=09if (p->preswap_map)
+=09=09memset(p->preswap_map, 0, maxpages / sizeof(long));
+#endif
 =09for (i =3D 0; i < swap_header->info.nr_badpages; i++) {
 =09=09int page_nr =3D swap_header->info.badpages[i];
 =09=09if (page_nr <=3D 0 || page_nr >=3D swap_header->info.last_page) {
@@ -1886,6 +1909,7 @@
 =09} else {
 =09=09swap_info[prev].next =3D p - swap_info;
 =09}
+=09preswap_init(p - swap_info);
 =09spin_unlock(&swap_lock);
 =09mutex_unlock(&swapon_mutex);
 =09error =3D 0;
@@ -2002,6 +2026,8 @@
=20
 =09si =3D &swap_info[swp_type(entry)];
 =09target =3D swp_offset(entry);
+=09if (preswap_test(si, target))
+=09=09return 0;
 =09base =3D (target >> our_page_cluster) << our_page_cluster;
 =09end =3D base + (1 << our_page_cluster);
 =09if (!base)=09=09/* first page is swap header */
@@ -2018,6 +2044,9 @@
 =09=09=09break;
 =09=09if (si->swap_map[toff] =3D=3D SWAP_MAP_BAD)
 =09=09=09break;
+=09=09/* Don't read in preswap pages */
+=09=09if (preswap_test(si, toff))
+=09=09=09break;
 =09}
 =09/* Count contiguous allocated slots below our target */
 =09for (toff =3D target; --toff >=3D base; nr_pages++) {
--- linux-2.6.30/include/linux/swap.h=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/include/linux/swap.h=092009-06-19 12:51:55.000000000 =
-0600
@@ -8,6 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
+#include <linux/vmalloc.h>
=20
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -154,8 +155,62 @@
 =09unsigned int max;
 =09unsigned int inuse_pages;
 =09unsigned int old_block_size;
+#ifdef CONFIG_PRESWAP
+=09unsigned long *preswap_map;
+=09unsigned int preswap_pages;
+#endif
 };
=20
+#ifdef CONFIG_PRESWAP
+
+#include <linux/sysctl.h>
+extern int preswap_sysctl_handler(struct ctl_table *, int, struct file *,
+=09void __user *, size_t *, loff_t *);
+extern const unsigned long preswap_zero, preswap_infinity;
+
+extern void preswap_shrink(unsigned long);
+extern int preswap_test(struct swap_info_struct *, unsigned long);
+extern void preswap_init(unsigned);
+extern int preswap_put(struct page *);
+extern int preswap_get(struct page *);
+extern void preswap_flush(unsigned, unsigned long);
+extern void preswap_flush_area(unsigned);
+/* in swapfile.c */
+extern int try_to_unuse(unsigned int, unsigned int, unsigned long);
+#else
+static inline void preswap_shrink(unsigned long target_pages)
+{
+}
+
+static inline int preswap_test(struct swap_info_struct *sis,
+=09unsigned long offset)
+{
+=09return 0;
+}
+
+static inline void preswap_init(unsigned type)
+{
+}
+
+static inline int preswap_put(struct page *page)
+{
+=09return 0;
+}
+
+static inline int preswap_get(struct page *page)
+{
+=09return 0;
+}
+
+static inline void preswap_flush(unsigned type, unsigned long offset)
+{
+}
+
+static inline void preswap_flush_area(unsigned type)
+{
+}
+#endif /* CONFIG_PRESWAP */
+
 struct swap_list_t {
 =09int head;=09/* head of priority-ordered swapfile list */
 =09int next;=09/* swapfile to be used next */
@@ -312,6 +367,8 @@
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
+extern struct swap_list_t swap_list;
+extern spinlock_t swap_lock;
=20
 /* linux/mm/thrash.c */
 extern struct mm_struct * swap_token_mm;
--- linux-2.6.30/mm/preswap.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.30-tmem/mm/preswap.c=092009-06-19 14:55:16.000000000 -0600
@@ -0,0 +1,274 @@
+/*
+ * linux/mm/preswap.c
+ *
+ * Implements a fast "preswap" on top of the transcendent memory ("tmem") =
API.
+ * When a swapdisk is enabled (with swapon), a "private persistent tmem po=
ol"
+ * is created along with a bit-per-page preswap_map.  When swapping occurs
+ * and a page is about to be written to disk, a "put" into the pool may fi=
rst
+ * be attempted by passing the pageframe to be swapped, along with a "hand=
le"
+ * consisting of a pool_id, an object id, and an index.  Since the pool is=
 of
+ * indeterminate size, the "put" may be rejected, in which case the page
+ * is swapped to disk as normal.  If the "put" is successful, the page is
+ * copied to tmem and the preswap_map records the success.  Later, when
+ * the page needs to be swapped in, the preswap_map is checked and, if set=
,
+ * the page may be obtained with a "get" operation.  Note that the swap
+ * subsystem is responsible for: maintaining coherency between the swapcac=
he,
+ * preswap, and the swapdisk; for evicting stale pages from preswap; and f=
or
+ * emptying preswap when swapoff is performed. The "flush page" and "flush
+ * object" actions are provided for this.
+ *
+ * Note that if a "duplicate put" is performed to overwrite a page and
+ * the "put" operation fails, the page (and old data) is flushed and lost.
+ * Also note that multiple accesses to a tmem pool may be concurrent and
+ * any ordering must be guaranteed by the caller.
+ *
+ * Copyright (C) 2008,2009 Dan Magenheimer, Oracle Corp.
+ */
+
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/sysctl.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/proc_fs.h>
+#include <linux/security.h>
+#include <linux/capability.h>
+#include <linux/uaccess.h>
+#include <linux/tmem.h>
+
+static u32 preswap_poolid =3D -1; /* if negative, preswap will never call =
tmem */
+
+const unsigned long preswap_zero =3D 0, preswap_infinity =3D ~0UL; /* for =
sysctl */
+
+/*
+ * Swizzling increases objects per swaptype, increasing tmem concurrency
+ * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
+ */
+#define SWIZ_BITS=09=094
+#define SWIZ_MASK=09=09((1 << SWIZ_BITS) - 1)
+#define oswiz(_type, _ind)=09((_type << SWIZ_BITS) | (_ind & SWIZ_MASK))
+#define iswiz(_ind)=09=09(_ind >> SWIZ_BITS)
+
+/*
+ * preswap_map test/set/clear operations (must be atomic)
+ */
+
+int preswap_test(struct swap_info_struct *sis, unsigned long offset)
+{
+=09if (!sis->preswap_map)
+=09=09return 0;
+=09return test_bit(offset % BITS_PER_LONG,
+=09=09&sis->preswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void preswap_set(struct swap_info_struct *sis,
+=09=09=09=09unsigned long offset)
+{
+=09if (!sis->preswap_map)
+=09=09return;
+=09set_bit(offset % BITS_PER_LONG,
+=09=09&sis->preswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void preswap_clear(struct swap_info_struct *sis,
+=09=09=09=09unsigned long offset)
+{
+=09if (!sis->preswap_map)
+=09=09return;
+=09clear_bit(offset % BITS_PER_LONG,
+=09=09&sis->preswap_map[offset/BITS_PER_LONG]);
+}
+
+/*
+ * preswap tmem operations
+ */
+
+/* returns 1 if the page was successfully put into preswap, 0 if the page
+ * was declined, and -ERRNO for a specific error */
+int preswap_put(struct page *page)
+{
+=09swp_entry_t entry =3D { .val =3D page_private(page), };
+=09unsigned type =3D swp_type(entry);
+=09pgoff_t offset =3D swp_offset(entry);
+=09u64 ind64 =3D (u64)offset;
+=09u32 ind =3D (u32)offset;
+=09unsigned long pfn =3D page_to_pfn(page);
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int dup =3D 0, ret;
+
+=09if ((s32)preswap_poolid < 0)
+=09=09return 0;
+=09if (ind64 !=3D ind)
+=09=09return 0;
+=09if (preswap_test(sis, offset))
+=09=09dup =3D 1;
+=09mb(); /* ensure page is quiescent; tmem may address it with an alias */
+=09ret =3D (*tmem_ops->put_page)(preswap_poolid, oswiz(type, ind),
+=09=09iswiz(ind), pfn);
+=09if (ret =3D=3D 1) {
+=09=09preswap_set(sis, offset);
+=09=09if (!dup)
+=09=09=09sis->preswap_pages++;
+=09} else if (dup) {
+=09=09/* failed dup put always results in an automatic flush of
+=09=09 * the (older) page from preswap */
+=09=09preswap_clear(sis, offset);
+=09=09sis->preswap_pages--;
+=09}
+=09return ret;
+}
+
+/* returns 1 if the page was successfully gotten from preswap, 0 if the pa=
ge
+ * was not present (should never happen!), and -ERRNO for a specific error=
 */
+int preswap_get(struct page *page)
+{
+=09swp_entry_t entry =3D { .val =3D page_private(page), };
+=09unsigned type =3D swp_type(entry);
+=09pgoff_t offset =3D swp_offset(entry);
+=09u64 ind64 =3D (u64)offset;
+=09u32 ind =3D (u32)offset;
+=09unsigned long pfn =3D page_to_pfn(page);
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int ret;
+
+=09if ((s32)preswap_poolid < 0)
+=09=09return 0;
+=09if (ind64 !=3D ind)
+=09=09return 0;
+=09if (!preswap_test(sis, offset))
+=09=09return 0;
+=09ret =3D (*tmem_ops->get_page)(preswap_poolid, oswiz(type, ind),
+=09=09iswiz(ind), pfn);
+=09return ret;
+}
+
+/* flush a single page from preswap */
+void preswap_flush(unsigned type, unsigned long offset)
+{
+=09u64 ind64 =3D (u64)offset;
+=09u32 ind =3D (u32)offset;
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int ret =3D 1;
+
+=09if ((s32)preswap_poolid < 0)
+=09=09return;
+=09if (ind64 !=3D ind)
+=09=09return;
+=09if (preswap_test(sis, offset)) {
+=09=09ret =3D (*tmem_ops->flush_page)(preswap_poolid,
+=09=09=09=09=09oswiz(type, ind), iswiz(ind));
+=09=09sis->preswap_pages--;
+=09=09preswap_clear(sis, offset);
+=09}
+}
+
+/* flush all pages from the passed swaptype */
+void preswap_flush_area(unsigned type)
+{
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int ind;
+
+=09if ((s32)preswap_poolid < 0)
+=09=09return;
+=09for (ind =3D SWIZ_MASK; ind >=3D 0; ind--)
+=09=09(void)(*tmem_ops->flush_object)(preswap_poolid,
+=09=09=09oswiz(type, ind));
+=09sis->preswap_pages =3D 0;
+}
+
+void preswap_init(unsigned type)
+{
+=09/* only need one tmem pool for all swap types */
+=09if ((s32)preswap_poolid >=3D 0)
+=09=09return;
+=09if (tmem_ops =3D=3D NULL)
+=09=09return;
+=09preswap_poolid =3D (*tmem_ops->new_pool)(0, 0, TMEM_POOL_PERSIST);
+}
+
+/*
+ * preswap infrastructure functions
+ */
+
+/* code structure leveraged from sys_swapoff */
+void preswap_shrink(unsigned long target_pages)
+{
+=09struct swap_info_struct *si =3D NULL;
+=09unsigned long total_pages =3D 0, total_pages_to_unuse;
+=09unsigned long pages =3D 0, unuse_pages =3D 0;
+=09int type;
+=09int wrapped =3D 0;
+
+=09do {
+=09=09/*
+=09=09 * we don't want to hold swap_lock while doing a very
+=09=09 * lengthy try_to_unuse, but swap_list may change
+=09=09 * so restart scan from swap_list.head each time
+=09=09 */
+=09=09spin_lock(&swap_lock);
+=09=09total_pages =3D 0;
+=09=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
+=09=09=09si =3D get_swap_info_struct(type);
+=09=09=09total_pages +=3D si->preswap_pages;
+=09=09}
+=09=09if (total_pages <=3D target_pages) {
+=09=09=09spin_unlock(&swap_lock);
+=09=09=09return;
+=09=09}
+=09=09total_pages_to_unuse =3D total_pages - target_pages;
+=09=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
+=09=09=09si =3D get_swap_info_struct(type);
+=09=09=09if (total_pages_to_unuse < si->preswap_pages)
+=09=09=09=09pages =3D unuse_pages =3D total_pages_to_unuse;
+=09=09=09else {
+=09=09=09=09pages =3D si->preswap_pages;
+=09=09=09=09unuse_pages =3D 0; /* unuse all */
+=09=09=09}
+=09=09=09if (security_vm_enough_memory(pages))
+=09=09=09=09continue;
+=09=09=09vm_unacct_memory(pages);
+=09=09=09break;
+=09=09}
+=09=09spin_unlock(&swap_lock);
+=09=09if (type < 0)
+=09=09=09return;
+=09=09current->flags |=3D PF_SWAPOFF;
+=09=09(void)try_to_unuse(type, 1, unuse_pages);
+=09=09current->flags &=3D ~PF_SWAPOFF;
+=09=09wrapped++;
+=09} while (wrapped <=3D 3);
+}
+
+
+#ifdef CONFIG_SYSCTL
+/* cat /sys/proc/vm/preswap provides total number of pages in preswap
+ * across all swaptypes.  echo N > /sys/proc/vm/preswap attempts to shrink
+ * preswap page usage to N (usually 0) */
+int preswap_sysctl_handler(ctl_table *table, int write,
+=09struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
+{
+=09unsigned long npages;
+=09int type;
+=09unsigned long totalpages =3D 0;
+=09struct swap_info_struct *si =3D NULL;
+
+=09/* modeled after hugetlb_sysctl_handler in mm/hugetlb.c */
+=09if (!write) {
+=09=09spin_lock(&swap_lock);
+=09=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
+=09=09=09si =3D get_swap_info_struct(type);
+=09=09=09totalpages +=3D si->preswap_pages;
+=09=09}
+=09=09spin_unlock(&swap_lock);
+=09=09npages =3D totalpages;
+=09}
+=09table->data =3D &npages;
+=09table->maxlen =3D sizeof(unsigned long);
+=09proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
+
+=09if (write)
+=09=09preswap_shrink(npages);
+
+=09return 0;
+}
+#endif
--- linux-2.6.30/include/linux/sysctl.h=092009-06-09 21:05:27.000000000 -06=
00
+++ linux-2.6.30-tmem/include/linux/sysctl.h=092009-06-19 09:33:59.00000000=
0 -0600
@@ -205,6 +205,7 @@
 =09VM_PANIC_ON_OOM=3D33,=09/* panic at out-of-memory */
 =09VM_VDSO_ENABLED=3D34,=09/* map VDSO into new processes? */
 =09VM_MIN_SLAB=3D35,=09=09 /* Percent pages ignored by zone reclaim */
+=09VM_PRESWAP_PAGES=3D36,=09/* pages/target_pages in preswap */
 };
=20
=20
--- linux-2.6.30/kernel/sysctl.c=092009-06-09 21:05:27.000000000 -0600
+++ linux-2.6.30-tmem/kernel/sysctl.c=092009-06-19 09:33:59.000000000 -0600
@@ -1282,6 +1282,18 @@
 =09=09.proc_handler=09=3D &scan_unevictable_handler,
 =09},
 #endif
+#ifdef CONFIG_PRESWAP
+=09{
+=09=09.ctl_name=09=3D VM_PRESWAP_PAGES,
+=09=09.procname=09=3D "preswap",
+=09=09.data=09=09=3D NULL,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D &preswap_sysctl_handler,
+=09=09.extra1=09=09=3D (void *)&preswap_zero,
+=09=09.extra2=09=09=3D (void *)&preswap_infinity,
+=09},
+#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
