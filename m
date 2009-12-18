Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 708E46B006A
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 19:38:42 -0500 (EST)
MIME-Version: 1.0
Message-ID: <db7e960e-d87c-4a35-ac27-cd75ec67d8b1@default>
Date: Thu, 17 Dec 2009 16:38:13 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Tmem [PATCH 3/5] (Take 3): Implement frontswap on top of tmem layer
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: dan.magenheimer@oracle.com, npiggin@suse.de, akpm@osdl.org, jeremy@goop.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, dave.mccracken@oracle.com, linux-mm@kvack.org, Rusty@rcsinet15.oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, chris.mason@oracle.com, Pavel Machek <pavel@ucw.cz>
List-ID: <linux-mm.kvack.org>

Tmem [PATCH 3/5] (Take 3): Implement frontswap on top of tmem layer.

Hooks added to existing page swap routines and data structures to:
1) create a tmem pool when any swap "type" is created (one pool
   covers all open swap types)
2) attempt to "put" pages to frontswap prior to writing to a swap disk
   and fallback to writing to swap disk if put fails
3) track successfully put pages with a new bit-per-page frontswap_map
   array
4) "get" pages from frontswap if frontswap_map indicates
5) destroy the tmem pool when no more swap types are in use
6) implement "shrinking" to repatriate pages from frontswap into
   the swap cache (or purge entirely if no longer needed)
7) Provide a sysctl interface to support both userland shrinking
   and determine number of pages currently in frontswap

The term "frontswap" is coined because it is the opposite
of a "backing store" for swap disks.  The previous term
("preswap") was deemed too generic and overloaded.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>


 include/linux/swap.h                     |   51 +++
 include/linux/sysctl.h                   |    1=20
 kernel/sysctl.c                          |   11=20
 mm/frontswap.c                           |  319 +++++++++++++++++++++
 mm/page_io.c                             |   12=20
 mm/swapfile.c                            |   43 ++
 6 files changed, 430 insertions(+), 7 deletions(-)

--- linux-2.6.32/mm/page_io.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/page_io.c=092009-12-17 13:59:06.000000000 -0700
@@ -102,6 +102,12 @@ int swap_writepage(struct page *page, st
 =09=09unlock_page(page);
 =09=09goto out;
 =09}
+=09if (frontswap_put(page) =3D=3D 1) {
+=09=09set_page_writeback(page);
+=09=09unlock_page(page);
+=09=09end_page_writeback(page);
+=09=09goto out;
+=09}
 =09bio =3D get_swap_bio(GFP_NOIO, page_private(page), page,
 =09=09=09=09end_swap_bio_write);
 =09if (bio =3D=3D NULL) {
@@ -134,6 +140,12 @@ int swap_readpage(struct page *page)
 =09=09ret =3D -ENOMEM;
 =09=09goto out;
 =09}
+=09if (frontswap_get(page) =3D=3D 1) {
+=09=09SetPageUptodate(page);
+=09=09unlock_page(page);
+=09=09bio_put(bio);
+=09=09goto out;
+=09}
 =09count_vm_event(PSWPIN);
 =09submit_bio(READ, bio);
 out:
--- linux-2.6.32/mm/swapfile.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/mm/swapfile.c=092009-12-17 14:00:05.000000000 -0700
@@ -35,7 +35,7 @@
 #include <linux/swapops.h>
 #include <linux/page_cgroup.h>
=20
-static DEFINE_SPINLOCK(swap_lock);
+DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
@@ -47,7 +47,7 @@ static const char Unused_file[] =3D "Unuse
 static const char Bad_offset[] =3D "Bad swap offset entry ";
 static const char Unused_offset[] =3D "Unused swap offset entry ";
=20
-static struct swap_list_t swap_list =3D {-1, -1};
+struct swap_list_t swap_list =3D {-1, -1};
=20
 static struct swap_info_struct swap_info[MAX_SWAPFILES];
=20
@@ -585,6 +585,7 @@ static int swap_entry_free(struct swap_i
 =09=09=09swap_list.next =3D p - swap_info;
 =09=09nr_swap_pages++;
 =09=09p->inuse_pages--;
+=09=09frontswap_flush(p - swap_info, offset);
 =09}
 =09if (!swap_count(count))
 =09=09mem_cgroup_uncharge_swap(ent);
@@ -984,7 +985,7 @@ static int unuse_mm(struct mm_struct *mm
  * Recycle to start on reaching the end, returning 0 when empty.
  */
 static unsigned int find_next_to_unuse(struct swap_info_struct *si,
-=09=09=09=09=09unsigned int prev)
+=09=09=09=09unsigned int prev, unsigned int frontswap)
 {
 =09unsigned int max =3D si->max;
 =09unsigned int i =3D prev;
@@ -1010,6 +1011,12 @@ static unsigned int find_next_to_unuse(s
 =09=09=09prev =3D 0;
 =09=09=09i =3D 1;
 =09=09}
+=09=09if (frontswap) {
+=09=09=09if (frontswap_test(si, i))
+=09=09=09=09break;
+=09=09=09else
+=09=09=09=09continue;
+=09=09}
 =09=09count =3D si->swap_map[i];
 =09=09if (count && swap_count(count) !=3D SWAP_MAP_BAD)
 =09=09=09break;
@@ -1021,8 +1028,12 @@ static unsigned int find_next_to_unuse(s
  * We completely avoid races by reading each swap page in advance,
  * and then search for the process using it.  All the necessary
  * page table adjustments can then be made atomically.
+ *
+ * if the boolean frontswap is true, only unuse pages_to_unuse pages;
+ * pages_to_unuse=3D=3D0 means all pages
  */
-static int try_to_unuse(unsigned int type)
+int try_to_unuse(unsigned int type, unsigned int frontswap,
+=09=09unsigned long pages_to_unuse)
 {
 =09struct swap_info_struct * si =3D &swap_info[type];
 =09struct mm_struct *start_mm;
@@ -1058,7 +1069,7 @@ static int try_to_unuse(unsigned int typ
 =09 * one pass through swap_map is enough, but not necessarily:
 =09 * there are races when an instance of an entry might be missed.
 =09 */
-=09while ((i =3D find_next_to_unuse(si, i)) !=3D 0) {
+=09while ((i =3D find_next_to_unuse(si, i, frontswap)) !=3D 0) {
 =09=09if (signal_pending(current)) {
 =09=09=09retval =3D -EINTR;
 =09=09=09break;
@@ -1251,6 +1262,8 @@ retry:
 =09=09 * interactive performance.
 =09=09 */
 =09=09cond_resched();
+=09=09if (frontswap && pages_to_unuse && !--pages_to_unuse)
+=09=09=09break;
 =09}
=20
 =09mmput(start_mm);
@@ -1575,7 +1588,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 =09spin_unlock(&swap_lock);
=20
 =09current->flags |=3D PF_OOM_ORIGIN;
-=09err =3D try_to_unuse(type);
+=09err =3D try_to_unuse(type, 0, 0);
 =09current->flags &=3D ~PF_OOM_ORIGIN;
=20
 =09if (err) {
@@ -1624,6 +1637,11 @@ SYSCALL_DEFINE1(swapoff, const char __us
 =09swap_map =3D p->swap_map;
 =09p->swap_map =3D NULL;
 =09p->flags =3D 0;
+=09frontswap_flush_area(p - swap_info);
+#ifdef CONFIG_FRONTSWAP
+=09if (p->frontswap_map)
+=09=09vfree(p->frontswap_map);
+#endif
 =09spin_unlock(&swap_lock);
 =09mutex_unlock(&swapon_mutex);
 =09vfree(swap_map);
@@ -2015,6 +2033,12 @@ SYSCALL_DEFINE2(swapon, const char __use
 =09} else {
 =09=09swap_info[prev].next =3D p - swap_info;
 =09}
+#ifdef CONFIG_FRONTSWAP
+=09p->frontswap_map =3D vmalloc(maxpages / sizeof(long));
+=09if (p->frontswap_map)
+=09=09memset(p->frontswap_map, 0, maxpages / sizeof(long));
+#endif
+=09frontswap_init(p - swap_info);
 =09spin_unlock(&swap_lock);
 =09mutex_unlock(&swapon_mutex);
 =09error =3D 0;
@@ -2189,6 +2213,10 @@ int valid_swaphandles(swp_entry_t entry,
 =09=09base++;
=20
 =09spin_lock(&swap_lock);
+=09if (frontswap_test(si, target)) {
+=09=09spin_unlock(&swap_lock);
+=09=09return 0;
+=09}
 =09if (end > si->max)=09/* don't go beyond end of map */
 =09=09end =3D si->max;
=20
@@ -2199,6 +2227,9 @@ int valid_swaphandles(swp_entry_t entry,
 =09=09=09break;
 =09=09if (swap_count(si->swap_map[toff]) =3D=3D SWAP_MAP_BAD)
 =09=09=09break;
+=09=09/* Don't read in frontswap pages */
+=09=09if (frontswap_test(si, toff))
+=09=09=09break;
 =09}
 =09/* Count contiguous allocated slots below our target */
 =09for (toff =3D target; --toff >=3D base; nr_pages++) {
--- linux-2.6.32/include/linux/swap.h=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/include/linux/swap.h=092009-12-17 14:00:37.000000000 =
-0700
@@ -8,6 +8,7 @@
 #include <linux/memcontrol.h>
 #include <linux/sched.h>
 #include <linux/node.h>
+#include <linux/vmalloc.h>
=20
 #include <asm/atomic.h>
 #include <asm/page.h>
@@ -177,8 +178,56 @@ struct swap_info_struct {
 =09unsigned int max;
 =09unsigned int inuse_pages;
 =09unsigned int old_block_size;
+#ifdef CONFIG_FRONTSWAP
+=09unsigned long *frontswap_map;
+=09unsigned int frontswap_pages;
+#endif
 };
=20
+#ifdef CONFIG_FRONTSWAP
+extern void frontswap_shrink(unsigned long);
+extern int frontswap_test(struct swap_info_struct *, unsigned long);
+extern void frontswap_init(unsigned);
+extern int frontswap_put(struct page *);
+extern int frontswap_get(struct page *);
+extern void frontswap_flush(unsigned, unsigned long);
+extern void frontswap_flush_area(unsigned);
+/* in swapfile.c */
+extern int try_to_unuse(unsigned int, unsigned int, unsigned long);
+#else
+static inline void frontswap_shrink(unsigned long target_pages)
+{
+}
+
+static inline int frontswap_test(struct swap_info_struct *sis,
+=09unsigned long offset)
+{
+=09return 0;
+}
+
+static inline void frontswap_init(unsigned type)
+{
+}
+
+static inline int frontswap_put(struct page *page)
+{
+=09return 0;
+}
+
+static inline int frontswap_get(struct page *page)
+{
+=09return 0;
+}
+
+static inline void frontswap_flush(unsigned type, unsigned long offset)
+{
+}
+
+static inline void frontswap_flush_area(unsigned type)
+{
+}
+#endif /* CONFIG_FRONTSWAP */
+
 struct swap_list_t {
 =09int head;=09/* head of priority-ordered swapfile list */
 =09int next;=09/* swapfile to be used next */
@@ -323,6 +372,8 @@ extern struct swap_info_struct *get_swap
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
+extern struct swap_list_t swap_list;
+extern spinlock_t swap_lock;
=20
 /* linux/mm/thrash.c */
 extern struct mm_struct *swap_token_mm;
--- linux-2.6.32/mm/frontswap.c=091969-12-31 17:00:00.000000000 -0700
+++ linux-2.6.32-tmem/mm/frontswap.c=092009-12-17 15:31:24.000000000 -0700
@@ -0,0 +1,319 @@
+/*
+ * linux/mm/frontswap.c
+ *
+ * Implements a fast "frontswap" on top of the transcendent memory ("tmem"=
) API.
+ * When a swapdisk is enabled (with swapon), a "private persistent tmem po=
ol"
+ * is created along with a bit-per-page frontswap_map.  When swapping occu=
rs
+ * and a page is about to be written to disk, a "put" into the pool may fi=
rst
+ * be attempted by passing the pageframe to be swapped, along with a "hand=
le"
+ * consisting of a pool_id, an object id, and an index.  Since the pool is=
 of
+ * indeterminate size, the "put" may be rejected, in which case the page
+ * is swapped to disk as normal.  If the "put" is successful, the page is
+ * copied to tmem and the frontswap_map records the success.  Later, when
+ * the page needs to be swapped in, the frontswap_map is checked and, if s=
et,
+ * the page may be obtained with a "get" operation.  Note that the swap
+ * subsystem is responsible for: maintaining coherency between the swapcac=
he,
+ * frontswap, and the swapdisk; for evicting stale pages from frontswap; a=
nd for
+ * emptying frontswap when swapoff is performed. The "flush page" and "flu=
sh
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
+static u32 frontswap_poolid =3D -1; /* if negative, frontswap never calls =
tmem */
+
+static unsigned long frontswap_succ_puts;
+static unsigned long frontswap_failed_puts;
+static unsigned long frontswap_gets;
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
+ * frontswap_map test/set/clear operations (must be atomic)
+ */
+
+int frontswap_test(struct swap_info_struct *sis, unsigned long offset)
+{
+=09if (!sis->frontswap_map)
+=09=09return 0;
+=09return test_bit(offset % BITS_PER_LONG,
+=09=09&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void frontswap_set(struct swap_info_struct *sis,
+=09=09=09=09unsigned long offset)
+{
+=09if (!sis->frontswap_map)
+=09=09return;
+=09set_bit(offset % BITS_PER_LONG,
+=09=09&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+static inline void frontswap_clear(struct swap_info_struct *sis,
+=09=09=09=09unsigned long offset)
+{
+=09if (!sis->frontswap_map)
+=09=09return;
+=09clear_bit(offset % BITS_PER_LONG,
+=09=09&sis->frontswap_map[offset/BITS_PER_LONG]);
+}
+
+/*
+ * frontswap tmem operations
+ */
+
+/* returns 1 if the page was successfully put into frontswap, 0 if the pag=
e
+ * was declined, and -ERRNO for a specific error */
+int frontswap_put(struct page *page)
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
+=09if ((s32)frontswap_poolid < 0)
+=09=09return 0;
+=09if (ind64 !=3D ind)
+=09=09return 0;
+=09if (frontswap_test(sis, offset))
+=09=09dup =3D 1;
+=09mb(); /* ensure page is quiescent; tmem may address it with an alias */
+=09ret =3D tmem_put_page(frontswap_poolid, oswiz(type, ind),
+=09=09iswiz(ind), pfn);
+=09if (ret =3D=3D 1) {
+=09=09frontswap_set(sis, offset);
+=09=09frontswap_succ_puts++;
+=09=09if (!dup)
+=09=09=09sis->frontswap_pages++;
+=09} else if (dup) {
+=09=09/* failed dup put always results in an automatic flush of
+=09=09 * the (older) page from frontswap */
+=09=09frontswap_clear(sis, offset);
+=09=09sis->frontswap_pages--;
+=09=09frontswap_failed_puts++;
+=09} else
+=09=09frontswap_failed_puts++;
+=09return ret;
+}
+
+/* returns 1 if the page was successfully gotten from frontswap, 0 if the =
page
+ * was not present (should never happen!), and -ERRNO for a specific error=
 */
+int frontswap_get(struct page *page)
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
+=09if ((s32)frontswap_poolid < 0)
+=09=09return 0;
+=09if (ind64 !=3D ind)
+=09=09return 0;
+=09if (!frontswap_test(sis, offset))
+=09=09return 0;
+=09ret =3D tmem_get_page(frontswap_poolid, oswiz(type, ind),
+=09=09iswiz(ind), pfn);
+=09if (ret)
+=09=09frontswap_gets++;
+=09return ret;
+}
+
+/* flush a single page from frontswap */
+void frontswap_flush(unsigned type, unsigned long offset)
+{
+=09u64 ind64 =3D (u64)offset;
+=09u32 ind =3D (u32)offset;
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int ret =3D 1;
+
+=09if ((s32)frontswap_poolid < 0)
+=09=09return;
+=09if (ind64 !=3D ind)
+=09=09return;
+=09if (frontswap_test(sis, offset)) {
+=09=09ret =3D tmem_flush_page(frontswap_poolid,
+=09=09=09oswiz(type, ind), iswiz(ind));
+=09=09sis->frontswap_pages--;
+=09=09frontswap_clear(sis, offset);
+=09}
+}
+
+/* flush all pages from the passed swaptype */
+void frontswap_flush_area(unsigned type)
+{
+=09struct swap_info_struct *sis =3D get_swap_info_struct(type);
+=09int ind;
+
+=09if ((s32)frontswap_poolid < 0)
+=09=09return;
+=09for (ind =3D SWIZ_MASK; ind >=3D 0; ind--)
+=09=09(void)tmem_flush_object(frontswap_poolid, oswiz(type, ind));
+=09sis->frontswap_pages =3D 0;
+}
+
+void frontswap_init(unsigned type)
+{
+=09struct tmem_pool_uuid private =3D TMEM_POOL_PRIVATE_UUID;
+
+=09/* only need one tmem pool for all swap types */
+=09if ((s32)frontswap_poolid >=3D 0)
+=09=09return;
+=09frontswap_poolid =3D tmem_new_pool(private, TMEM_POOL_PERSIST);
+}
+
+/*
+ * frontswap infrastructure functions
+ */
+
+/* code structure leveraged from sys_swapoff */
+void frontswap_shrink(unsigned long target_pages)
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
+=09=09=09total_pages +=3D si->frontswap_pages;
+=09=09}
+=09=09if (total_pages <=3D target_pages) {
+=09=09=09spin_unlock(&swap_lock);
+=09=09=09return;
+=09=09}
+=09=09total_pages_to_unuse =3D total_pages - target_pages;
+=09=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
+=09=09=09si =3D get_swap_info_struct(type);
+=09=09=09if (total_pages_to_unuse < si->frontswap_pages)
+=09=09=09=09pages =3D unuse_pages =3D total_pages_to_unuse;
+=09=09=09else {
+=09=09=09=09pages =3D si->frontswap_pages;
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
+=09=09current->flags |=3D PF_OOM_ORIGIN;
+=09=09(void)try_to_unuse(type, 1, unuse_pages);
+=09=09current->flags &=3D ~PF_OOM_ORIGIN;
+=09=09wrapped++;
+=09} while (wrapped <=3D 3);
+}
+
+
+#ifdef CONFIG_SYSCTL
+
+#include <linux/sysctl.h>
+
+static const unsigned long frontswap_zero =3D 0, frontswap_infinity =3D ~0=
UL;
+
+/* cat /sys/vm/tmem/frontswap/curr_pages provides total number of pages in
+ * frontswap across all swaptypes.  echo N > /sys/proc/vm/frontswap attemp=
ts
+ * to shrink frontswap page usage to N (usually 0) */
+static int frontswap_curr_pages_ctl(ctl_table *table, int write,
+=09void __user *buffer, size_t *length, loff_t *ppos)
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
+=09=09=09totalpages +=3D si->frontswap_pages;
+=09=09}
+=09=09spin_unlock(&swap_lock);
+=09=09npages =3D totalpages;
+=09}
+=09table->data =3D &npages;
+=09table->maxlen =3D sizeof(unsigned long);
+=09proc_doulongvec_minmax(table, write, buffer, length, ppos);
+
+=09if (write)
+=09=09frontswap_shrink(npages);
+
+=09return 0;
+}
+
+ctl_table frontswap_table[] =3D {
+=09{
+=09=09.procname=09=3D "curr_pages",
+=09=09.data=09=09=3D NULL,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0644,
+=09=09.proc_handler=09=3D &frontswap_curr_pages_ctl,
+=09=09.extra1=09=09=3D (void *)&frontswap_zero,
+=09=09.extra2=09=09=3D (void *)&frontswap_infinity,
+=09},
+=09{
+=09=09.procname=09=3D "succ_puts",
+=09=09.data=09=09=3D &frontswap_succ_puts,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{
+=09=09.procname=09=3D "failed_puts",
+=09=09.data=09=09=3D &frontswap_failed_puts,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{
+=09=09.procname=09=3D "gets",
+=09=09.data=09=09=3D &frontswap_gets,
+=09=09.maxlen=09=09=3D sizeof(unsigned long),
+=09=09.mode=09=09=3D 0444,
+=09=09.proc_handler=09=3D &proc_doulongvec_minmax,
+=09},
+=09{ .ctl_name =3D 0 }
+};
+#endif /* CONFIG_SYSCTL */
--- linux-2.6.32/include/linux/sysctl.h=092009-12-02 20:51:21.000000000 -07=
00
+++ linux-2.6.32-tmem/include/linux/sysctl.h=092009-12-17 15:30:00.00000000=
0 -0700
@@ -206,7 +206,6 @@ enum
 =09VM_MIN_SLAB=3D35,=09=09 /* Percent pages ignored by zone reclaim */
 };
=20
-
 /* CTL_NET names: */
 enum
 {
--- linux-2.6.32/kernel/sysctl.c=092009-12-02 20:51:21.000000000 -0700
+++ linux-2.6.32-tmem/kernel/sysctl.c=092009-12-17 11:25:25.000000000 -0700
@@ -195,6 +195,9 @@ extern struct ctl_table inotify_table[];
 #ifdef CONFIG_EPOLL
 extern struct ctl_table epoll_table[];
 #endif
+#ifdef CONFIG_TMEM
+extern struct ctl_table tmem_table[];
+#endif
=20
 #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
 int sysctl_legacy_va_layout;
@@ -1422,6 +1425,14 @@ static struct ctl_table vm_table[] =3D {
 =09=09.extra2=09=09=3D &one,
 =09},
 #endif
+#ifdef CONFIG_TMEM
+=09{
+=09=09.ctl_name=09=3D CTL_UNNUMBERED,
+=09=09.procname=09=3D "tmem",
+=09=09.mode=09=09=3D 0555,
+=09=09.child=09=09=3D tmem_table,
+=09},
+#endif
=20
 /*
  * NOTE: do not add new entries to this table unless you have read

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
