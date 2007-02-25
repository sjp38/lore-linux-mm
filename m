Date: Sat, 24 Feb 2007 22:36:26 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] SLUB v2
Message-ID: <Pine.LNX.4.64.0702242234060.20557@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-595485047-1172385386=:20557"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---1700579579-595485047-1172385386=:20557
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

V1->V2
- Fix up various issues. Tested on i386 UP, X86_64 SMP, ia64 NUMA.
- Provide NUMA support by splitting partial lists per node.
- Better Slabcache merge support (now at around 50% of slabs)
- List slabcache aliases if slabcaches are merged.
- Updated descriptions /proc/slabinfo output

This is a new slab allocator which was motivated by the complexity of the
existing code in mm/slab.c. It attempts to address a variety of concerns
with the existing implementation.

A. Management of object queues

   A particular concern was the complex management of the numerous object
   queues in SLAB. SLUB has no such queues. Instead we dedicate a slab for
   each cpus allocating and use a slab directly instead of objects
   from queues.

B. Storage overhead of object queues

   SLAB Object queues exist per node, per cpu. The alien cache queue even
   has a queue array that contain a queue for each processor on each
   node. For very large systems the number of queues and the number of
   objects that may be caught in those queues grows exponentially. On our
   systems with 1k nodes / processors we have several gigabytes just tied u=
p
   for storing references to objects for those queues  This does not includ=
e
   the objects that could be on those queues. One fears that the whole
   memory of the machine could one day be consumed by those queues.

C. SLAB metadata overhead

   SLAB has overhead at the beginning of each slab. This means that data
   cannot be naturally aligned at the beginning of a slab block. SLUB keeps
   all metadata in the corresponding page_struct. Objects can be naturally
   aligned in the slab. F.e. a 128 byte object will be aligned at 128 byte
   boundaries and can fit tightly into a 4k page with no bytes left over.
   SLAB cannot do this.

D. SLAB has a complex cache reaper

   SLUB does not need a cache reaper for UP systems. On SMP systems
   the per cpu slab may be pushed back into partial list but that
   operation is simple and does not require an iteration over a list
   of objects. SLAB expires per cpu, shared and alien object queues
   during cache reaping which may cause strange holdoffs.

E. SLAB's has a complex NUMA policy layer support.

   SLUB pushes NUMA policy handling into the page allocator. This means tha=
t
   allocation is coarser (SLUB does interleave on a page level) but that
   situation was also present before 2.6.13. SLABs application of
   policies to individual slab objects allocated in SLAB is
   certainly a performance concern due to the frequent references to
   memory policies which may lead a sequence of objects to come from
   one node after another. SLUB will get a slab full of objects
   from one node and then will switch to the next.

F. Reduction of the size of partial slab lists

   SLAB has per node partial lists. This means that over time a large
   number of partial slabs may accumulate on those lists. These can
   only be reused if allocator occur on specific nodes. SLUB has a global
   pool of partial slabs and will consume slabs from that pool to
   decrease fragmentation.

G. Tunables

   SLAB has sophisticated tuning abilities for each slab cache. One can
   manipulate the queue sizes in detail. However, filling the queues still
   requires the uses of the spinlock to check out slabs. SLUB has a global
   parameter (min_slab_order) for tuning. Increasing the minimum slab
   order can decrease the locking overhead. The bigger the slab order the
   less motions of pages between per cpu and partial lists occur and the
   better SLUB will be scaling.

G. Slab merging

   We often have slab caches with similar parameters. SLUB detects those
   on bootup and merges them into the corresponding general caches. This
   leads to more effective memory use. About 50% of all caches can
   be eliminated through slab merging. This will also decrease
   slab fragmentation because partial allocated slabs can be filled
   up again. Slab merging can be switched off by specifying
   slub_nomerge on bootup.

To use SLUB: Apply this patch and then select SLUB as the default slab
allocator. The output of /proc/slabinfo will then change. Here is a
sample (this is an UP/SMP format. The NUMA display will show on which nodes
the slabs were allocated):

slubinfo - version: 1.0
# name            <objects> <order> <objsize> <slabs>/<partial>/<cpu> <flag=
s> <nodes>
TCPv6                      2 0    1792        2/2/0     a N1=3D2 N2=3D2
mqueue_inode_cache         1 0     896        1/1/0    Ca N0=3D2
xfs_inode               8013 0     640      324/4/1   Sra N0=3D289 N1=3D10 =
N2=3D10 N3=3D8 N4=3D7 N5=3D5
xfs_efd_item               0 0     360        0/0/0       xfs_efi_item
xfs_acl                    0 0     304        0/0/0
xfs_da_state               0 0     488        1/0/1       N0=3D2
xfs_trans                  2 0     832        1/1/0       N0=3D2
xfs_btree_cur            211 0     192      10/10/0       N0=3D8 N1=3D2 N2=
=3D2 N3=3D4 N4=3D4 xfs_buf_item xfs_ili
xfs_vnode               8010 0     768      386/6/1  CSra N0=3D349 N1=3D13 =
N2=3D9 N3=3D11 N4=3D6 N5=3D5
isofs_inode_cache          0 0     656        0/0/0   CSr
fat_inode_cache            1 0     688        1/1/0   CSr N0=3D2
fat_cache                  0 0      40        0/0/0   CSr
hugetlbfs_inode_cache      1 0     624        1/1/0     C N5=3D2
ext2_inode_cache           0 0     776        0/0/0   CSr
ext2_xattr                 0 0      88        0/0/0    Sr
journal_head             128 0      96        1/1/0       N5=3D2 xfs_ioend
ext3_inode_cache           0 0     824        0/0/0   CSr
ext3_xattr                 0 0      88        0/0/0    Sr
reiser_inode_cache         0 0     768        0/0/0   CSr
dquot                      0 0     256        0/0/0  SrPa
shmem_inode_cache        871 0     816      48/10/0     C N0=3D9 N1=3D25 N2=
=3D6 N3=3D6 N4=3D7 N5=3D5
posix_timers_cache         0 0     144        0/0/0
ip_dst_cache              61 0     384        8/7/1    Pa N0=3D6 N1=3D2 N2=
=3D6 N3=3D2 xfrm_dst_cache kioctx xfs_buf sas_task ip6_dst_cache
UDP                        8 0     896        3/3/0     a N0=3D2 N1=3D2 N2=
=3D2 UDP-Lite
TCP                       12 0    1664        3/2/0     a N0=3D1 N1=3D2 N2=
=3D2
scsi_io_context            0 0     112        0/0/0
blkdev_queue              30 0    1488        4/2/0     P N0=3D1 N2=3D1 N4=
=3D2 N5=3D2
blkdev_requests           20 0     280        3/1/2     P N0=3D2 N2=3D2 N4=
=3D2
sock_inode_cache         187 0     768       14/8/0  CSra N0=3D4 N1=3D2 N2=
=3D7 N3=3D4 N4=3D3 N5=3D2
file_lock_cache            2 0     184        2/2/0    CP N0=3D2 N2=3D2
proc_inode_cache        1076 0     640      50/22/1   CSr N0=3D51 N2=3D11 N=
3=3D2 N4=3D4 N5=3D5
sigqueue                   0 0     160        1/0/1     P N0=3D2 cfq_pool c=
fq_ioc_pool
radix_tree_node         2126 0     560       79/7/0    CP N0=3D50 N1=3D8 N2=
=3D7 N3=3D6 N4=3D8 N5=3D7
bdev_cache                50 0     896        8/6/0 CSrPa N0=3D3 N1=3D2 N2=
=3D4 N3=3D2 N5=3D3
sysfs_dir_cache         6219 0      80       35/9/0       N1=3D11 N2=3D5 N3=
=3D14 N4=3D2 N5=3D12 Acpi-State inotify_watch_cache eventpoll_pwq
inode_cache             3679 0     608     147/12/1  CSrP N0=3D36 N1=3D25 N=
2=3D42 N3=3D26 N4=3D8 N5=3D23
dentry_cache           15144 0     200     194/10/2   SrP N0=3D113 N1=3D20 =
N2=3D28 N3=3D17 N4=3D12 N5=3D16
idr_layer_cache           77 0     536        3/2/0     C N1=3D2 N2=3D1 N5=
=3D2
buffer_head             3855 0     112       29/8/0  CSrP N0=3D26 N1=3D2 N2=
=3D5 N4=3D2 N5=3D2
vm_area_struct          1744 0     176      24/19/2     P N0=3D14 N1=3D4 N2=
=3D8 N3=3D5 N4=3D6 N5=3D8
signal_cache             392 0     768      27/13/1    Pa N0=3D11 N1=3D5 N2=
=3D10 N3=3D6 N4=3D3 N5=3D6 files_cache RAW UNIX
sighand_cache            191 0    1664      29/11/1  CRPa N0=3D14 N1=3D13 N=
2=3D4 N3=3D3 N4=3D3 N5=3D4
anon_vma                 703 0      32      12/11/1   CRP N0=3D4 N1=3D4 N2=
=3D4 N3=3D4 N4=3D4 N5=3D4
shared_policy_node       848 0      48      11/11/0     P N0=3D2 N1=3D4 N2=
=3D4 N3=3D4 N4=3D4 N5=3D4 Acpi-Parse partial_page_cache inotify_event_cache=
 dnotify_cache xfs_chashlist dm_io
numa_policy             1119 0     264      42/35/5     P N0=3D31 N1=3D8 N2=
=3D19 N3=3D12 N4=3D6 N5=3D6 filp mnt_cache taskstats_cache skbuff_head_cach=
e biovec-16 sgpool-8 tw_sock_TCP arp_cache kiocb eventpoll_epi request_sock=
_TCPv6 tw_sock_TCPv6 ndisc_cache
kmalloc-262144             0 4  262144        0/0/0
kmalloc-131072             2 3  131072        2/0/0       N0=3D1 N2=3D1
kmalloc-65536              2 2   65536        2/0/0       N0=3D1 N4=3D1
kmalloc-32768             55 1   32768       55/0/0       N0=3D9 N1=3D5 N2=
=3D10 N3=3D8 N4=3D14 N5=3D9
kmalloc-16384             18 0   16384       18/0/0       N0=3D3 N1=3D3 N2=
=3D4 N3=3D2 N4=3D3 N5=3D3
kmalloc-8192              99 0    8192       50/1/0       N0=3D22 N1=3D1 N2=
=3D9 N3=3D2 N4=3D12 N5=3D5
kmalloc-4096              94 0    4096       32/9/7       N0=3D25 N1=3D4 N2=
=3D10 N4=3D6 N5=3D3 names_cache biovec-256 sgpool-128
kmalloc-2048             331 0    2048      50/15/2       N0=3D39 N1=3D7 N2=
=3D4 N3=3D11 N4=3D1 N5=3D5 biovec-128 sgpool-64
kmalloc-1024             861 0    1024      60/12/3       N0=3D13 N1=3D21 N=
2=3D8 N3=3D11 N4=3D8 N5=3D14 mm_struct biovec-64 sgpool-32 UDPv6 UDPLITEv6 =
RAWv6
kmalloc-512              209 0     512       11/4/4       N0=3D5 N1=3D2 N2=
=3D5 N4=3D5 N5=3D2 skbuff_fclone_cache sgpool-16 scsi_cmd_cache
kmalloc-256             2339 0     256       45/9/2       N0=3D8 N1=3D9 N2=
=3D18 N3=3D9 N4=3D6 N5=3D6
kmalloc-128             1811 0     128      24/11/3       N0=3D7 N1=3D10 N2=
=3D2 N3=3D6 N4=3D10 N5=3D3 fs_cache bio biovec-1 biovec-4 request_sock_TCP =
ip_fib_hash ip_fib_alias secpath_cache inet_peer_cache tcp_bind_bucket uid_=
cacheH=F8=D2 revoke_record qla2xxx_srbs flow_cache fib6_nodes
kmalloc-32               192 0      32        6/5/1       N0=3D2 N1=3D2 N2=
=3D2 N3=3D2 N4=3D2 N5=3D2 Acpi-Namespace fasync_cache journal_handle xfs_bm=
ap_free_item xfs_dabuf dm_tio
kmalloc-16              2990 0      16      13/10/2       N0=3D5 N1=3D6 N2=
=3D2 N3=3D4 N4=3D2 N5=3D6 revoke_table
kmalloc-8                238 0       8        3/2/1       N1=3D4 N3=3D2
kmalloc-64              3673 0      64      24/12/1       N0=3D6 N1=3D4 N2=
=3D6 N3=3D10 N4=3D3 N5=3D8 pid Acpi-ParseExt Acpi-Operand blkdev_ioc xfs_if=
ork

Still pending:
- Patch to add defragmentation support via callbacks.
- Performance tests
- Evaluate lockless partial list management.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc1/fs/proc/proc_misc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.21-rc1.orig/fs/proc/proc_misc.c=092007-02-24 19:39:14.0000000=
00 -0800
+++ linux-2.6.21-rc1/fs/proc/proc_misc.c=092007-02-24 19:39:29.000000000 -0=
800
@@ -397,7 +397,7 @@ static const struct file_operations proc
 };
 #endif
=20
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 extern struct seq_operations slabinfo_op;
 extern ssize_t slabinfo_write(struct file *, const char __user *, size_t, =
loff_t *);
 static int slabinfo_open(struct inode *inode, struct file *file)
@@ -407,7 +407,9 @@ static int slabinfo_open(struct inode *i
 static const struct file_operations proc_slabinfo_operations =3D {
 =09.open=09=09=3D slabinfo_open,
 =09.read=09=09=3D seq_read,
+#ifdef CONFIG_SLAB
 =09.write=09=09=3D slabinfo_write,
+#endif
 =09.llseek=09=09=3D seq_lseek,
 =09.release=09=3D seq_release,
 };
@@ -708,7 +710,7 @@ void __init proc_misc_init(void)
 #endif
 =09create_seq_entry("stat", 0, &proc_stat_operations);
 =09create_seq_entry("interrupts", 0, &proc_interrupts_operations);
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 =09create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 #ifdef CONFIG_DEBUG_SLAB_LEAK
 =09create_seq_entry("slab_allocators", 0 ,&proc_slabstats_operations);
Index: linux-2.6.21-rc1/include/linux/mm_types.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.21-rc1.orig/include/linux/mm_types.h=092007-02-24 19:39:14.00=
0000000 -0800
+++ linux-2.6.21-rc1/include/linux/mm_types.h=092007-02-24 19:39:29.0000000=
00 -0800
@@ -19,10 +19,16 @@ struct page {
 =09unsigned long flags;=09=09/* Atomic flags, some possibly
 =09=09=09=09=09 * updated asynchronously */
 =09atomic_t _count;=09=09/* Usage count, see below. */
-=09atomic_t _mapcount;=09=09/* Count of ptes mapped in mms,
+=09union {
+=09=09atomic_t _mapcount;=09/* Count of ptes mapped in mms,
 =09=09=09=09=09 * to show when page is mapped
 =09=09=09=09=09 * & limit reverse map searches.
 =09=09=09=09=09 */
+=09=09struct {=09/* SLUB uses */
+=09=09=09short unsigned int inuse;
+=09=09=09short unsigned int offset;
+=09=09};
+=09};
 =09union {
 =09    struct {
 =09=09unsigned long private;=09=09/* Mapping-private opaque data:
@@ -43,8 +49,15 @@ struct page {
 #if NR_CPUS >=3D CONFIG_SPLIT_PTLOCK_CPUS
 =09    spinlock_t ptl;
 #endif
+=09    struct {=09=09=09/* SLUB uses */
+=09=09struct page *first_page;=09/* Compound pages */
+=09=09struct kmem_cache *slab;=09/* Pointer to slab */
+=09    };
+=09};
+=09union {
+=09=09pgoff_t index;=09=09/* Our offset within mapping. */
+=09=09void *freelist;=09=09/* SLUB: pointer to free object */
 =09};
-=09pgoff_t index;=09=09=09/* Our offset within mapping. */
 =09struct list_head lru;=09=09/* Pageout list, eg. active_list
 =09=09=09=09=09 * protected by zone->lru_lock !
 =09=09=09=09=09 */
Index: linux-2.6.21-rc1/include/linux/slab.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.21-rc1.orig/include/linux/slab.h=092007-02-24 19:39:14.000000=
000 -0800
+++ linux-2.6.21-rc1/include/linux/slab.h=092007-02-24 19:39:29.000000000 -=
0800
@@ -94,9 +94,14 @@ static inline void *kcalloc(size_t n, si
  * the appropriate general cache at compile time.
  */
=20
-#ifdef CONFIG_SLAB
+#if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
+#ifdef CONFIG_SLUB
+#include <linux/slub_def.h>
+#else
 #include <linux/slab_def.h>
+#endif /* !CONFIG_SLUB */
 #else
+
 /*
  * Fallback definitions for an allocator not wanting to provide
  * its own optimized kmalloc definitions (like SLOB).
Index: linux-2.6.21-rc1/include/linux/slub_def.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null=091970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc1/include/linux/slub_def.h=092007-02-24 19:39:29.0000000=
00 -0800
@@ -0,0 +1,164 @@
+#ifndef _LINUX_SLUB_DEF_H
+#define _LINUX_SLUB_DEF_H
+
+/*
+ * SLUB : A Slab allocator without object queues.
+ *
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
+ */
+#include <linux/types.h>
+#include <linux/gfp.h>
+#include <linux/workqueue.h>
+
+struct kmem_cache_node {
+=09spinlock_t list_lock;=09/* Protect partial list and nr_partial */
+=09unsigned int nr_partial;
+=09atomic_long_t nr_slabs;
+=09struct list_head partial;
+};
+
+/*
+ * Slab cache management.
+ */
+struct kmem_cache {
+=09int offset;=09=09/* Free pointer offset. */
+=09unsigned int order;
+=09unsigned long flags;
+=09int size;=09=09/* Total size of an object */
+=09int objects;=09=09/* Number of objects in slab */
+=09atomic_t refcount;=09/* Refcount for destroy */
+=09void (*ctor)(void *, struct kmem_cache *, unsigned long);
+=09void (*dtor)(void *, struct kmem_cache *, unsigned long);
+
+=09int objsize;=09=09/* The size of an object that is in a chunk */
+=09int inuse;=09=09/* Used portion of the chunk */
+=09const char *name;=09/* Name (only for display!) */
+=09char *aliases;=09=09/* Slabs merged into this one */
+=09struct list_head list;=09/* List of slabs */
+#ifdef CONFIG_SMP
+=09struct mutex flushing;
+=09atomic_t cpu_slabs;=09/* if >0 then flusher is scheduled */
+=09struct delayed_work flush;
+#endif
+=09struct kmem_cache_node *node[MAX_NUMNODES];
+=09struct page *cpu_slab[NR_CPUS];
+};
+
+/*
+ * Kmalloc subsystem.
+ */
+#define KMALLOC_SHIFT_LOW 3
+
+#define KMALLOC_SHIFT_HIGH 18
+
+#if L1_CACHE_BYTES <=3D 64
+#define KMALLOC_EXTRAS 2
+#define KMALLOC_EXTRA
+#else
+#define KMALLOC_EXTRAS 0
+#endif
+
+#define KMALLOC_NR_CACHES (KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW \
+=09=09=09 + 1 + KMALLOC_EXTRAS)
+/*
+ * We keep the general caches in an array of slab caches that are used for
+ * 2^x bytes of allocations. For each size we generate a DMA and a
+ * non DMA cache (DMA simply means memory for legacy I/O. The regular
+ * caches can be used for devices that can DMA to all of memory).
+ */
+extern struct kmem_cache kmalloc_caches[KMALLOC_NR_CACHES];
+
+/*
+ * Sorry that the following has to be that ugly but GCC has trouble
+ * with constant propagation and loops.
+ */
+static inline int kmalloc_index(int size)
+{
+=09if (size <=3D    8) return 3;
+=09if (size <=3D   16) return 4;
+=09if (size <=3D   32) return 5;
+=09if (size <=3D   64) return 6;
+#ifdef KMALLOC_EXTRA
+=09if (size <=3D   96) return KMALLOC_SHIFT_HIGH + 1;
+#endif
+=09if (size <=3D  128) return 7;
+#ifdef KMALLOC_EXTRA
+=09if (size <=3D  192) return KMALLOC_SHIFT_HIGH + 2;
+#endif
+=09if (size <=3D  256) return 8;
+=09if (size <=3D  512) return 9;
+=09if (size <=3D 1024) return 10;
+=09if (size <=3D 2048) return 11;
+=09if (size <=3D 4096) return 12;
+=09if (size <=3D   8 * 1024) return 13;
+=09if (size <=3D  16 * 1024) return 14;
+=09if (size <=3D  32 * 1024) return 15;
+=09if (size <=3D  64 * 1024) return 16;
+=09if (size <=3D 128 * 1024) return 17;
+=09if (size <=3D 256 * 1024) return 18;
+=09return -1;
+}
+
+/*
+ * Find the slab cache for a given combination of allocation flags and siz=
e.
+ *
+ * This ought to end up with a global pointer to the right cache
+ * in kmalloc_caches.
+ */
+static inline struct kmem_cache *kmalloc_slab(size_t size)
+{
+=09int index =3D kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+
+=09if (index < 0) {
+=09=09/*
+=09=09 * Generate a link failure. Would be great if we could
+=09=09 * do something to stop the compile here.
+=09=09 */
+=09=09extern void __kmalloc_size_too_large(void);
+=09=09__kmalloc_size_too_large();
+=09}
+=09return &kmalloc_caches[index];
+}
+
+#ifdef CONFIG_ZONE_DMA
+#define SLUB_DMA __GFP_DMA
+#else
+/* Disable SLAB functionality */
+#define SLUB_DMA 0
+#endif
+
+static inline void *kmalloc(size_t size, gfp_t flags)
+{
+=09if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+=09=09struct kmem_cache *s =3D kmalloc_slab(size);
+
+=09=09return kmem_cache_alloc(s, flags);
+=09} else
+=09=09return __kmalloc(size, flags);
+}
+
+static inline void *kzalloc(size_t size, gfp_t flags)
+{
+=09if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+=09=09struct kmem_cache *s =3D kmalloc_slab(size);
+
+=09=09return kmem_cache_zalloc(s, flags);
+=09} else
+=09=09return __kzalloc(size, flags);
+}
+
+#ifdef CONFIG_NUMA
+extern void *__kmalloc_node(size_t size, gfp_t flags, int node);
+
+static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
+{
+=09if (__builtin_constant_p(size) && !(flags & SLUB_DMA)) {
+=09=09struct kmem_cache *s =3D kmalloc_slab(size);
+
+=09=09return kmem_cache_alloc_node(s, flags, node);
+=09} else
+=09=09return __kmalloc_node(size, flags, node);
+}
+#endif
+
+#endif /* _LINUX_SLUB_DEF_H */
Index: linux-2.6.21-rc1/init/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.21-rc1.orig/init/Kconfig=092007-02-24 19:39:14.000000000 -080=
0
+++ linux-2.6.21-rc1/init/Kconfig=092007-02-24 19:39:29.000000000 -0800
@@ -458,15 +458,6 @@ config SHMEM
 =09  option replaces shmem and tmpfs with the much simpler ramfs code,
 =09  which may be appropriate on small systems without swap.
=20
-config SLAB
-=09default y
-=09bool "Use full SLAB allocator" if (EMBEDDED && !SMP && !SPARSEMEM)
-=09help
-=09  Disabling this replaces the advanced SLAB allocator and
-=09  kmalloc support with the drastically simpler SLOB allocator.
-=09  SLOB is more space efficient but does not scale well and is
-=09  more susceptible to fragmentation.
-
 config VM_EVENT_COUNTERS
 =09default y
 =09bool "Enable VM event counters for /proc/vmstat" if EMBEDDED
@@ -476,6 +467,45 @@ config VM_EVENT_COUNTERS
 =09  on EMBEDDED systems.  /proc/vmstat will only show page counts
 =09  if VM event counters are disabled.
=20
+choice
+=09prompt "Choose SLAB allocator"
+=09default SLAB
+=09help
+=09   This option allows the selection of a Slab allocator.
+
+config SLAB
+=09bool "SLAB Allocator"
+=09help
+=09  The regular slab allocator that is established and known to work
+=09  well in all environments. It organizes chache hot objects in
+=09  per cpu and per node queues. SLAB has advanced debugging
+=09  capabilities. SLAB is the default choice for slab allocator.
+
+config SLUB
+=09depends on EXPERIMENTAL
+=09bool "SLUB (EXPERIMENTAL Unqueued Allocator)"
+=09help
+=09   SLUB is a slab allocator that minimizes cache line usage
+=09   instead of managing queues of cached objects (SLAB approach).
+=09   Per cpu caching is realized using slabs of objects instead
+=09   of queues of objects. SLUB can use memory in the most efficient
+=09   way.
+
+config SLOB
+#
+#=09SLOB does not support SMP because SLAB_DESTROY_BY_RCU is not support.
+#
+=09depends on EMBEDDED && !SMP
+=09bool "SLOB (Simple Allocator)"
+=09help
+=09   SLOB replaces the SLAB allocator with a drastically simpler
+=09   allocator.  SLOB is more space efficient that SLAB but does not
+=09   scale well (single lock for all operations) and is more susceptible
+=09   to fragmentation. SLOB it is a great choice to reduce
+=09   memory usage and code size.
+
+endchoice
+
 endmenu=09=09# General setup
=20
 config RT_MUTEXES
@@ -491,10 +521,6 @@ config BASE_SMALL
 =09default 0 if BASE_FULL
 =09default 1 if !BASE_FULL
=20
-config SLOB
-=09default !SLAB
-=09bool
-
 menu "Loadable module support"
=20
 config MODULES
Index: linux-2.6.21-rc1/mm/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.21-rc1.orig/mm/Makefile=092007-02-24 19:39:14.000000000 -0800
+++ linux-2.6.21-rc1/mm/Makefile=092007-02-24 19:39:29.000000000 -0800
@@ -25,6 +25,7 @@ obj-$(CONFIG_TMPFS_POSIX_ACL) +=3D shmem_a
 obj-$(CONFIG_TINY_SHMEM) +=3D tiny-shmem.o
 obj-$(CONFIG_SLOB) +=3D slob.o
 obj-$(CONFIG_SLAB) +=3D slab.o
+obj-$(CONFIG_SLUB) +=3D slub.o
 obj-$(CONFIG_MEMORY_HOTPLUG) +=3D memory_hotplug.o
 obj-$(CONFIG_FS_XIP) +=3D filemap_xip.o
 obj-$(CONFIG_MIGRATION) +=3D migrate.o
Index: linux-2.6.21-rc1/mm/slub.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null=091970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc1/mm/slub.c=092007-02-24 22:19:49.000000000 -0800
@@ -0,0 +1,1743 @@
+/*
+ * SLUB: A slab allocator that limits cache line use instead of queuing
+ * objects in per cpu and per node lists.
+ *
+ * The allocator synchronizes using per slab locks and only
+ * uses a centralized lock to manage a pool of partial slabs.
+ *
+ * (C) 2007 SGI, Christoph Lameter <clameter@sgi.com>
+ *
+ * Pending pieces:
+ *
+ * =09A. Slab defragmentation support
+ * =09B. Lockless allocs via separate freelists for cpu slabs
+ * =09C. Lockless partial list handling
+ *
+ *  Further issues to solve:
+ *
+ * =091. Support the Slab debugging options
+ * =092. Move logic for draining page allocator queues
+ * =09   into the page allocator.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/bit_spinlock.h>
+#include <linux/interrupt.h>
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/seq_file.h>
+#include <linux/cpu.h>
+#include <linux/cpuset.h>
+#include <linux/mempolicy.h>
+
+/*
+ * Overloading of page flags that are otherwise used for LRU management.
+ *
+ * PageActive =09=09The slab is used as a cpu cache. Allocations
+ * =09=09=09may be performed from the slab. The slab is not
+ * =09=09=09on a partial list.
+ *
+ * PageReferenced=09The per cpu slab was used recently. This is used
+ * =09=09=09to push back per cpu slabs if they are unused
+ * =09=09=09for a longer time period.
+ *
+ * PagePrivate=09=09Only a single object exists per slab. Objects are not
+ * =09=09=09cached instead we use the page allocator for
+ * =09=09=09object allocation and freeing.
+ */
+
+/*
+ * Flags from the regular SLAB that we have not implemented:
+ */
+#define SLUB_UNIMPLEMENTED (SLAB_DEBUG_FREE | SLAB_DEBUG_INITIAL | \
+=09SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
+
+/*
+ * Enabling SLUB_DEBUG results in internal consistency checks.
+ */
+#define SLUB_DEBUG
+
+/*
+ * SLUB_DEBUG_KFREE enables checking for double frees. In order to do this
+ * we have to look through the free lists of object in a slab on kfree whi=
ch
+ * may slightly reduce performance.
+ */
+#ifdef SLUB_DEBUG
+#define SLUB_DEBUG_KFREE
+#endif
+
+/*
+ * Set of flags that will prevent slab merging
+ */
+#define SLUB_NEVER_MERGE (SLAB_DEBUG_FREE | SLAB_DEBUG_INITIAL | \
+=09SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
+=09SLAB_DESTROY_BY_RCU | SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA)
+
+#ifndef ARCH_KMALLOC_MINALIGN
+#define ARCH_KMALLOC_MINALIGN sizeof(void *)
+#endif
+
+#ifndef ARCH_SLAB_MINALIGN
+#define ARCH_SLAB_MINALIGN sizeof(void *)
+#endif
+
+/*
+ * Forward declarations
+ */
+static void register_slab(struct kmem_cache *s);
+static void unregister_slab(struct kmem_cache *s);
+
+#ifdef CONFIG_SMP
+static struct notifier_block slab_notifier;
+#endif
+
+static enum {
+=09DOWN,=09=09/* No slab functionality available */
+=09PARTIAL,=09/* kmem_cache_open() works but kmalloc does not */
+=09UP=09=09/* Everything works */
+} slab_state =3D DOWN;
+
+/* A list of all slab caches on the system */
+static DECLARE_RWSEM(slabstat_sem);
+LIST_HEAD(slab_caches);
+
+/********************************************************************
+ * =09=09=09Core slab cache functions
+ *******************************************************************/
+
+/*
+ * Lock order:
+ *   1. slab_lock(page)
+ *   2. slab->list_lock
+ *
+ * SLUB assigns one slab for allocation to each processor.
+ * Allocations only occur from these slabs called cpu slabs.
+ *
+ * If a cpu slab exists then a workqueue thread checks every 10
+ * seconds if the cpu slab is still in use. The cpu slab is pushed back
+ * to the list if inactive [only needed for SMP].
+ *
+ * Slabs with free elements are kept on a partial list.
+ * There is no list for full slabs. If an object in a full slab is
+ * freed then the slab will show up again on the partial lists.
+ * Otherwise there is no need to track full slabs (but we keep a counter).
+ *
+ * Slabs are freed when they become empty. Teardown and setup is
+ * minimal so we rely on the page allocators per cpu caches for
+ * fast frees and allocs.
+ */
+
+static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int n=
ode)
+{
+=09struct page * page;
+=09int pages =3D 1 << s->order;
+
+=09if (s->order)
+=09=09flags |=3D __GFP_COMP;
+
+=09if (s->flags & SLUB_DMA)
+=09=09flags |=3D GFP_DMA;
+
+=09if (node =3D=3D -1)
+=09=09page =3D alloc_pages(flags, s->order);
+=09else
+=09=09page =3D alloc_pages_node(node, flags, s->order);
+
+=09if (!page)
+=09=09return NULL;
+
+=09mod_zone_page_state(page_zone(page),
+=09=09(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+=09=09NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+=09=09pages);
+
+=09if (unlikely(s->ctor)) {
+=09=09void *start =3D page_address(page);
+=09=09void *end =3D start + (pages << PAGE_SHIFT);
+=09=09void *p;
+=09=09int mode =3D 1;
+
+=09=09if (!(flags & __GFP_WAIT))
+=09=09=09mode |=3D SLAB_CTOR_ATOMIC;
+
+=09=09for (p =3D start; p <=3D end - s->size; p +=3D s->size)
+=09=09=09s->ctor(p, s, mode);
+=09}
+=09return page;
+}
+
+static void __free_slab(struct kmem_cache *s, struct page *page)
+{
+=09int pages =3D 1 << s->order;
+
+=09if (unlikely(s->dtor)) {
+=09=09void *start =3D page_address(page);
+=09=09void *end =3D start + (pages << PAGE_SHIFT);
+=09=09void *p;
+
+=09=09for (p =3D start; p <=3D end - s->size; p +=3D s->size)
+=09=09=09s->dtor(p, s, 0);
+=09}
+
+=09mod_zone_page_state(page_zone(page),
+=09=09(s->flags & SLAB_RECLAIM_ACCOUNT) ?
+=09=09NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
+=09=09- pages);
+
+=09__free_pages(page, s->order);
+}
+
+static void rcu_free_slab(struct rcu_head *h)
+{
+=09struct page *page;
+=09struct kmem_cache *s;
+
+=09page =3D container_of((struct list_head *)h, struct page, lru);
+=09s =3D (struct kmem_cache *)page->mapping;
+=09page->mapping =3D NULL;
+=09__free_slab(s, page);
+}
+
+static void free_slab(struct kmem_cache *s, struct page *page)
+{
+=09if (unlikely(s->flags & SLAB_DESTROY_BY_RCU)) {
+=09=09/*
+=09=09 * RCU free overloads the RCU head over the LRU
+=09=09 */
+=09=09struct rcu_head *head =3D (void *)&page->lru;
+
+=09=09page->mapping =3D (void *)s;
+=09=09call_rcu(head, rcu_free_slab);
+=09} else
+=09=09__free_slab(s, page);
+}
+
+/*
+ * Locking for each individual slab using the pagelock
+ */
+static __always_inline void slab_lock(struct page *page)
+{
+#ifdef CONFIG_SMP
+=09bit_spin_lock(PG_locked, &page->flags);
+#endif
+}
+
+static __always_inline void slab_unlock(struct page *page)
+{
+#ifdef CONFIG_SMP
+=09bit_spin_unlock(PG_locked, &page->flags);
+#endif
+}
+
+static __always_inline int slab_trylock(struct page *page)
+{
+=09int rc =3D 1;
+#ifdef CONFIG_SMP
+=09rc =3D bit_spin_trylock(PG_locked, &page->flags);
+#endif
+=09return rc;
+}
+
+/*
+ * Management of partially allocated slabs
+ */
+static void __always_inline add_partial(struct kmem_cache *s, struct page =
*page)
+{
+=09int node =3D page_to_nid(page);
+=09struct kmem_cache_node *n =3D s->node[node];
+
+=09spin_lock(&n->list_lock);
+=09n->nr_partial++;
+=09list_add_tail(&page->lru, &n->partial);
+=09spin_unlock(&n->list_lock);
+}
+
+static void __always_inline remove_partial(struct kmem_cache *s,
+=09=09=09=09=09=09struct page *page)
+{
+=09int node =3D page_to_nid(page);
+=09struct kmem_cache_node *n =3D s->node[node];
+
+=09spin_lock(&n->list_lock);
+=09list_del(&page->lru);
+=09n->nr_partial--;
+=09spin_unlock(&n->list_lock);
+}
+
+/*
+ * Lock page and remove it from the partial list
+ *
+ * Must hold list_lock
+ */
+static __always_inline int lock_and_del_slab(struct kmem_cache_node *n,
+=09=09=09=09=09=09struct page *page)
+{
+=09if (slab_trylock(page)) {
+=09=09list_del(&page->lru);
+=09=09n->nr_partial--;
+=09=09return 1;
+=09}
+=09return 0;
+}
+
+/*
+ * Try to get a partial slab from the indicated node
+ */
+static struct page *get_partial_node(struct kmem_cache_node *n)
+{
+=09struct page *page;
+
+=09/*
+=09 * Racy check. If we mistakenly see no partial slabs then we
+=09 * just allocate an empty slab. If we mistakenly try to get a
+=09 * partial slab then get_partials() will return NULL.
+=09 */
+=09if (!n || !n->nr_partial)
+=09=09return NULL;
+
+=09spin_lock(&n->list_lock);
+=09list_for_each_entry(page, &n->partial, lru)
+=09=09if (lock_and_del_slab(n, page))
+=09=09=09goto out;
+=09page =3D NULL;
+out:
+=09spin_unlock(&n->list_lock);
+=09return page;
+}
+
+static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
+{
+#ifdef CONFIG_NUMA
+=09struct zonelist *zonelist =3D &NODE_DATA(slab_node(current->mempolicy))
+=09=09=09=09=09->node_zonelists[gfp_zone(flags)];
+=09struct zone **z;
+=09struct page *page;
+=09int nid;
+
+=09/*
+=09 * Look through allowed nodes for objects available
+=09 * from existing per node queues.
+=09 */
+=09for (z =3D zonelist->zones; *z; z++) {
+=09=09struct kmem_cache_node *n;
+
+=09=09nid =3D zone_to_nid(*z);
+=09=09n =3D s->node[nid];
+
+=09=09if (n && cpuset_zone_allowed_hardwall(*z, flags) &&
+=09=09=09=09n->nr_partial) {
+=09=09=09page =3D get_partial_node(n);
+=09=09=09if (page)
+=09=09=09=09return page;
+=09=09}
+=09}
+#endif
+=09return NULL;
+}
+
+/*
+ * Get a partial page, lock it and return it.
+ */
+static struct page *get_partial(struct kmem_cache *s, gfp_t flags, int nod=
e)
+{
+=09struct page *page;
+=09int searchnode =3D (node =3D=3D -1) ? numa_node_id() : node;
+
+=09page =3D get_partial_node(s->node[searchnode]);
+=09if (page || (flags & __GFP_THISNODE))
+=09=09return page;
+
+=09return get_any_partial(s, flags);
+}
+
+#if defined(SLUB_DEBUG) || defined(SLUB_DEBUG_KFREE)
+static int check_valid_pointer(struct kmem_cache *s, struct page *page,
+=09=09=09=09=09 void *object, void *origin)
+{
+=09void *base =3D page_address(page);
+
+=09if (object < base || object >=3D base + s->objects * s->size) {
+=09=09printk(KERN_CRIT "slab %s size %d: pointer %p->%p not in"
+=09=09=09" range (%p-%p) in page %p\n", s->name, s->size,
+=09=09=09origin, object, base, base + s->objects * s->size,
+=09=09=09page);
+=09=09return 0;
+=09}
+
+=09if ((object - base) % s->size) {
+=09=09printk(KERN_CRIT "slab %s size %d: pointer %p->%p\n"
+=09=09=09"does not properly point"
+=09=09=09"to an object in page %p\n",
+=09=09=09s->name, s->size, origin, object, page);
+=09=09return 0;
+=09}
+=09return 1;
+}
+
+/*
+ * Debugging checks
+ */
+static void check_slab(struct page *page)
+{
+=09if (!PageSlab(page)) {
+=09=09printk(KERN_CRIT "Not a valid slab page @%p flags=3D%lx"
+=09=09=09" mapping=3D%p count=3D%d \n",
+=09=09=09page, page->flags, page->mapping, page_count(page));
+=09=09BUG();
+=09}
+}
+
+/*
+ * Determine if a certain object on a page is on the freelist and
+ * therefore free. Must hold the slab lock for cpu slabs to
+ * guarantee that the chains are consistent.
+ */
+static int on_freelist(struct kmem_cache *s, struct page *page, void *sear=
ch)
+{
+=09int nr =3D 0;
+=09void **object =3D page->freelist;
+=09void *origin =3D &page->lru;
+
+=09if (PagePrivate(page))
+=09=09return 0;
+
+=09check_slab(page);
+
+=09while (object && nr <=3D s->objects) {
+=09=09if (object =3D=3D search)
+=09=09=09return 1;
+=09=09if (!check_valid_pointer(s, page, object, origin))
+=09=09=09goto try_recover;
+=09=09origin =3D object;
+=09=09object =3D object[s->offset];
+=09=09nr++;
+=09}
+
+=09if (page->inuse !=3D s->objects - nr) {
+=09=09printk(KERN_CRIT "slab %s: page %p wrong object count."
+=09=09=09" counter is %d but counted were %d\n",
+=09=09=09s->name, page, page->inuse,
+=09=09=09s->objects - nr);
+try_recover:
+=09=09printk(KERN_CRIT "****** Trying to continue by marking "
+=09=09=09"all objects in the slab used (memory leak!)\n");
+=09=09page->inuse =3D s->objects;
+=09=09page->freelist =3D  NULL;
+=09}
+=09return 0;
+}
+
+static void check_free_chain(struct kmem_cache *s, struct page *page)
+{
+=09on_freelist(s, page, NULL);
+}
+#else
+static void check_free_chain(struct kmem_cache *s, struct page *page)
+{
+}
+#endif
+
+static void discard_slab(struct kmem_cache *s, struct page *page)
+{
+=09int node =3D page_to_nid(page);
+=09struct kmem_cache_node *n =3D s->node[node];
+
+=09atomic_long_dec(&n->nr_slabs);
+
+=09page->mapping =3D NULL;
+=09reset_page_mapcount(page);
+=09__ClearPageSlab(page);
+=09__ClearPagePrivate(page);
+
+=09free_slab(s, page);
+}
+
+static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
+{
+=09struct page *page;
+=09struct kmem_cache_node *n;
+
+=09BUG_ON(flags & ~(GFP_DMA | GFP_LEVEL_MASK | __GFP_NO_GROW));
+=09if (flags & __GFP_NO_GROW)
+=09=09return NULL;
+
+=09if (flags & __GFP_WAIT)
+=09=09local_irq_enable();
+
+=09page =3D allocate_slab(s, flags & GFP_LEVEL_MASK, node);
+=09if (!page)
+=09=09goto out;
+
+=09node =3D page_to_nid(page);
+=09n =3D s->node[node];
+=09if (n)
+=09=09atomic_long_inc(&n->nr_slabs);
+=09page->offset =3D s->offset;
+=09page->slab =3D s;
+=09__SetPageSlab(page);
+
+=09if (s->objects > 1) {
+=09=09void *start =3D page_address(page);
+=09=09void *end =3D start + s->objects * s->size;
+=09=09void **last =3D start;
+=09=09void *p =3D start + s->size;
+
+=09=09while (p < end) {
+=09=09=09last[s->offset] =3D p;
+=09=09=09last =3D p;
+=09=09=09p +=3D s->size;
+=09=09}
+=09=09last[s->offset] =3D NULL;
+=09=09page->freelist =3D start;
+=09=09page->inuse =3D 0;
+=09=09check_free_chain(s, page);
+=09} else
+=09=09__SetPagePrivate(page);
+
+out:
+=09if (flags & __GFP_WAIT)
+=09=09local_irq_disable();
+=09return page;
+}
+
+/*
+ * Move a page back to the lists.
+ *
+ * Must be called with the slab lock held.
+ *
+ * On exit the slab lock will have been dropped.
+ */
+static void __always_inline putback_slab(struct kmem_cache *s, struct page=
 *page)
+{
+=09if (page->inuse) {
+=09=09if (page->inuse < s->objects)
+=09=09=09add_partial(s, page);
+=09=09slab_unlock(page);
+=09} else {
+=09=09slab_unlock(page);
+=09=09discard_slab(s, page);
+=09}
+}
+
+/*
+ * Remove the cpu slab
+ */
+static void __always_inline deactivate_slab(struct kmem_cache *s,
+=09=09=09=09=09=09struct page *page, int cpu)
+{
+=09s->cpu_slab[cpu] =3D NULL;
+=09ClearPageActive(page);
+=09ClearPageReferenced(page);
+
+=09putback_slab(s, page);
+}
+
+/*
+ * Flush cpu slab.
+ * Called from IPI handler with interrupts disabled.
+ */
+static void __flush_cpu_slab(struct kmem_cache *s, int cpu)
+{
+=09struct page *page =3D s->cpu_slab[cpu];
+
+=09if (likely(page)) {
+=09=09slab_lock(page);
+=09=09deactivate_slab(s, page, cpu);
+=09}
+}
+
+static void flush_cpu_slab(void *d)
+{
+=09struct kmem_cache *s =3D d;
+=09int cpu =3D smp_processor_id();
+
+=09__flush_cpu_slab(s, cpu);
+}
+
+#ifdef CONFIG_SMP
+/*
+ * Called from IPI to check and flush cpu slabs.
+ */
+static void check_flush_cpu_slab(void *d)
+{
+=09struct kmem_cache *s =3D d;
+=09int cpu =3D smp_processor_id();
+=09struct page *page =3D s->cpu_slab[cpu];
+
+=09if (!page)
+=09=09return;
+
+=09if (PageReferenced(page)) {
+=09=09ClearPageReferenced(page);
+=09=09atomic_inc(&s->cpu_slabs);
+=09} else {
+=09=09slab_lock(page);
+=09=09deactivate_slab(s, page, cpu);
+=09}
+}
+
+/*
+ * Called from eventd
+ */
+static void flusher(struct work_struct *w)
+{
+=09struct kmem_cache *s =3D container_of(w, struct kmem_cache, flush.work)=
;
+
+=09if (!mutex_trylock(&s->flushing))
+=09=09return;
+
+=09atomic_set(&s->cpu_slabs, num_online_cpus());
+=09on_each_cpu(check_flush_cpu_slab, s, 1, 1);
+=09if (atomic_read(&s->cpu_slabs))
+=09=09schedule_delayed_work(&s->flush, 2 * HZ);
+=09mutex_unlock(&s->flushing);
+}
+
+static void flush_all(struct kmem_cache *s)
+{
+=09if (atomic_read(&s->cpu_slabs)) {
+=09=09mutex_lock(&s->flushing);
+=09=09cancel_delayed_work(&s->flush);
+=09=09atomic_set(&s->cpu_slabs, 0);
+=09=09on_each_cpu(flush_cpu_slab, s, 1, 1);
+=09=09mutex_unlock(&s->flushing);
+=09}
+}
+#else
+static void flush_all(struct kmem_cache *s)
+{
+=09unsigned long flags;
+
+=09local_irq_save(flags);
+=09flush_cpu_slab(s);
+=09local_irq_restore(flags);
+}
+#endif
+
+static __always_inline void *__slab_alloc(struct kmem_cache *s,
+=09=09=09=09=09gfp_t gfpflags, int node)
+{
+=09struct page *page;
+=09void **object;
+=09void *next_object;
+=09unsigned long flags;
+=09int cpu;
+
+=09local_irq_save(flags);
+=09cpu =3D smp_processor_id();
+=09page =3D s->cpu_slab[cpu];
+=09if (!page)
+=09=09goto new_slab;
+
+=09slab_lock(page);
+=09check_free_chain(s, page);
+=09if (unlikely(!page->freelist))
+=09=09goto another_slab;
+
+=09if (unlikely(node !=3D -1 && page_to_nid(page) !=3D node))
+=09=09goto another_slab;
+redo:
+=09page->inuse++;
+=09object =3D page->freelist;
+=09page->freelist =3D next_object =3D object[page->offset];
+=09SetPageReferenced(page);
+=09slab_unlock(page);
+=09local_irq_restore(flags);
+=09return object;
+
+another_slab:
+=09deactivate_slab(s, page, cpu);
+
+new_slab:
+=09page =3D get_partial(s, gfpflags, node);
+=09if (page)
+=09=09goto gotpage;
+
+=09page =3D new_slab(s, gfpflags, node);
+=09if (!page) {
+=09=09local_irq_restore(flags);
+=09=09return NULL;
+=09}
+
+=09/*
+=09 * There is no point in putting single object slabs
+=09 * on a partial list.
+=09 */
+=09if (unlikely(s->objects =3D=3D 1)) {
+=09=09local_irq_restore(flags);
+=09=09return page_address(page);
+=09}
+
+=09slab_lock(page);
+
+gotpage:
+=09if (s->cpu_slab[cpu]) {
+=09=09slab_unlock(page);
+=09=09discard_slab(s, page);
+=09=09page =3D s->cpu_slab[cpu];
+=09=09slab_lock(page);
+=09} else
+=09=09s->cpu_slab[cpu] =3D page;
+
+=09SetPageActive(page);
+=09check_free_chain(s, page);
+
+#ifdef CONFIG_SMP
+=09if (keventd_up() && !atomic_read(&s->cpu_slabs)) {
+=09=09atomic_inc(&s->cpu_slabs);
+=09=09schedule_delayed_work(&s->flush, 2 * HZ);
+=09}
+#endif
+=09goto redo;
+}
+
+void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
+{
+=09return __slab_alloc(s, gfpflags, -1);
+}
+EXPORT_SYMBOL(kmem_cache_alloc);
+
+#ifdef CONFIG_NUMA
+void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node=
)
+{
+=09return __slab_alloc(s, gfpflags, node);
+}
+EXPORT_SYMBOL(kmem_cache_alloc_node);
+#endif
+
+void kmem_cache_free(struct kmem_cache *s, void *x)
+{
+=09struct page * page;
+=09void *prior;
+=09void **object =3D (void *)x;
+=09unsigned long flags;
+
+=09if (!object)
+=09=09return;
+
+=09page =3D virt_to_page(x);
+
+=09if (unlikely(PageCompound(page)))
+=09=09page =3D page->first_page;
+
+=09if (!s)
+=09=09s =3D page->slab;
+
+#ifdef SLUB_DEBUG
+=09if (unlikely(s !=3D page->slab))
+=09=09goto slab_mismatch;
+=09if (unlikely(!check_valid_pointer(s, page, object, NULL)))
+=09=09goto dumpret;
+#endif
+
+=09local_irq_save(flags);
+=09if (unlikely(PagePrivate(page)))
+=09=09goto single_object_slab;
+=09slab_lock(page);
+
+#ifdef SLUB_DEBUG_KFREE
+=09if (on_freelist(s, page, object))
+=09=09goto double_free;
+#endif
+
+=09prior =3D object[page->offset] =3D page->freelist;
+=09page->freelist =3D object;
+=09page->inuse--;
+
+=09if (likely(PageActive(page) || (page->inuse && prior))) {
+out_unlock:
+=09=09slab_unlock(page);
+=09=09local_irq_restore(flags);
+=09=09return;
+=09}
+
+=09if (!prior) {
+=09=09/*
+=09=09 * The slab was full before. It will have one free
+=09=09 * object now. So move to the partial list.
+=09=09 */
+=09=09add_partial(s, page);
+=09=09goto out_unlock;
+=09}
+
+=09/*
+=09 * All object have been freed.
+=09 */
+=09remove_partial(s, page);
+=09slab_unlock(page);
+single_object_slab:
+=09discard_slab(s, page);
+=09local_irq_restore(flags);
+=09return;
+
+#ifdef SLUB_DEBUG_KFREE
+double_free:
+=09printk(KERN_CRIT "slab_free %s: object %p already free.\n",
+=09=09=09=09=09s->name, object);
+=09dump_stack();
+=09goto out_unlock;
+#endif
+
+#ifdef SLUB_DEBUG
+slab_mismatch:
+=09if (!PageSlab(page)) {
+=09=09printk(KERN_CRIT "slab_free %s size %d: attempt to free "
+=09=09=09"object(%p) outside of slab.\n",
+=09=09=09s->name, s->size, object);
+=09=09goto dumpret;
+=09}
+
+=09if (!page->slab) {
+=09=09printk(KERN_CRIT
+=09=09=09"slab_free : no slab(NULL) for object %p.\n",
+=09=09=09=09=09object);
+=09=09=09goto dumpret;
+=09}
+
+=09printk(KERN_CRIT "slab_free %s(%d): object at %p"
+=09=09=09" belongs to slab %s(%d)\n",
+=09=09=09s->name, s->size, object,
+=09=09=09page->slab->name, page->slab->size);
+
+dumpret:
+=09dump_stack();
+=09printk(KERN_CRIT "***** Trying to continue by not "
+=09=09=09"freeing object.\n");
+=09return;
+#endif
+}
+EXPORT_SYMBOL(kmem_cache_free);
+
+/* Figure out on which slab object the object resides */
+static __always_inline struct page *get_object_page(const void *x)
+{
+=09struct page * page =3D virt_to_page(x);
+
+=09if (unlikely(PageCompound(page)))
+=09=09page =3D page->first_page;
+
+=09if (!PageSlab(page))
+=09=09return NULL;
+
+=09return page;
+}
+
+/*
+ * kmem_cache_open produces objects aligned at "size" and the first object
+ * is placed at offset 0 in the slab (We have no metainformation on the
+ * slab, all slabs are in essence "off slab").
+ *
+ * In order to get the desired alignment one just needs to align the
+ * size.
+ *
+ * Notice that the allocation order determines the sizes of the per cpu
+ * caches. Each processor has always one slab available for allocations.
+ * Increasing the allocation order reduces the number of times that slabs
+ * must be moved on and off the partial lists and therefore may influence
+ * locking overhead.
+ *
+ * The offset is used to relocate the free list link in each object. It is
+ * therefore possible to move the free list link behind the object. This
+ * is necessary for RCU to work properly and also useful for debugging.
+ *
+ * No freelists are necessary if there is only one element per slab.
+ */
+
+/*
+ * Mininum order of slab pages. This influences locking overhead and slab
+ * fragmentation. A higher order reduces the number of partial slabs
+ * and increases the number of allocations possible without having to
+ * take the list_lock.
+ */
+static int slub_min_order =3D 0;
+
+/*
+ * Merge control. If this is set then no merging of slab caches into the
+ * general caches will occur.
+ */
+static int slub_nomerge =3D 0;
+
+static int calculate_order(int size)
+{
+=09int order;
+=09int rem;
+
+=09if ((size & (size -1)) =3D=3D 0) {
+=09=09/*
+=09=09 * We can use the page allocator if the requested size
+=09=09 * is compatible with the page sizes supported.
+=09=09 */
+=09=09int order =3D fls(size) -1 - PAGE_SHIFT;
+
+=09=09if (order >=3D 0)
+=09=09=09return order;
+=09}
+
+=09for (order =3D max(slub_min_order, fls(size - 1) - PAGE_SHIFT);
+=09=09=09order < MAX_ORDER; order++) {
+=09=09unsigned long slab_size =3D PAGE_SIZE << order;
+
+=09=09if (slab_size < size)
+=09=09=09continue;
+
+=09=09rem =3D slab_size % size;
+
+=09=09if (rem * 8 <=3D PAGE_SIZE << order)
+=09=09=09break;
+
+=09}
+=09if (order >=3D MAX_ORDER)
+=09=09return -E2BIG;
+=09return order;
+}
+
+static unsigned long calculate_alignment(unsigned long flags,
+=09=09unsigned long align)
+{
+=09if (flags & (SLAB_MUST_HWCACHE_ALIGN|SLAB_HWCACHE_ALIGN))
+=09=09return L1_CACHE_BYTES;
+
+=09if (align < ARCH_SLAB_MINALIGN)
+=09=09return ARCH_SLAB_MINALIGN;
+
+=09return ALIGN(align, sizeof(void *));
+}
+
+static void init_kmem_cache_node(struct kmem_cache_node *n)
+{
+=09memset(n, 0, sizeof(struct kmem_cache_node));
+=09atomic_long_set(&n->nr_slabs, 0);
+=09spin_lock_init(&n->list_lock);
+=09INIT_LIST_HEAD(&n->partial);
+}
+
+int kmem_cache_open(struct kmem_cache *s, gfp_t gfpflags,
+=09=09const char *name, size_t size,
+=09=09size_t align, unsigned long flags,
+=09=09void (*ctor)(void *, struct kmem_cache *, unsigned long),
+=09=09void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+=09int node;
+
+=09BUG_ON(flags & SLUB_UNIMPLEMENTED);
+=09memset(s, 0, sizeof(struct kmem_cache));
+=09s->name =3D name;
+=09s->ctor =3D ctor;
+=09s->dtor =3D dtor;
+=09s->objsize =3D size;
+=09s->flags =3D flags;
+
+=09/*
+=09 * Here is the place to add other management type information
+=09 * to the end of the object F.e. debug info
+=09 */
+=09size =3D ALIGN(size, sizeof(void *));
+=09s->inuse =3D size;
+
+=09if (size * 2 < (PAGE_SIZE << calculate_order(size)) &&
+=09=09((flags & SLAB_DESTROY_BY_RCU) || ctor || dtor)) {
+=09=09/*
+=09=09 * Relocate free pointer after the object if it is not
+=09=09 * permitted to overwrite the first word of the object on
+=09=09 * kmem_cache_free.
+=09=09 *
+=09=09 * This is the case if we do RCU, have a constructor or
+=09=09 * destructor.
+=09=09*/
+=09=09s->offset =3D size / sizeof(void *);
+=09=09size +=3D sizeof(void *);
+=09}
+
+=09align =3D calculate_alignment(flags, align);
+
+=09size =3D ALIGN(size, align);
+=09s->size =3D size;
+
+=09s->order =3D calculate_order(size);
+=09if (s->order < 0)
+=09=09goto error;
+
+=09s->objects =3D (PAGE_SIZE << s->order) / size;
+=09if (!s->objects || s->objects > 65535)
+=09=09goto error;
+
+=09atomic_set(&s->refcount, 1);
+
+#ifdef CONFIG_SMP
+=09mutex_init(&s->flushing);
+=09atomic_set(&s->cpu_slabs, 0);
+=09INIT_DELAYED_WORK(&s->flush, flusher);
+#endif
+
+=09for_each_online_node(node) {
+=09=09struct kmem_cache_node *n;
+
+=09=09if (slab_state =3D=3D DOWN) {
+=09=09=09/*
+=09=09=09 * No kmalloc_node yet so do it by hand.
+=09=09=09 * We know that this is the first slab on the
+=09=09=09 * node for this slabcache. There are no concurrent
+=09=09=09 * accesses possible. Which simplifies things.
+=09=09=09 */
+=09=09=09unsigned long flags;
+=09=09=09struct page *page;
+
+=09=09=09local_irq_save(flags);
+=09=09=09page =3D new_slab(s, gfpflags, node);
+
+=09=09=09BUG_ON(!page);
+=09=09=09n =3D page->freelist;
+=09=09=09page->freelist =3D *(void **)page->freelist;
+=09=09=09page->inuse++;
+=09=09=09local_irq_restore(flags);
+=09=09} else
+=09=09=09n =3D kmalloc_node(sizeof(struct kmem_cache_node),
+=09=09=09=09gfpflags, node);
+
+=09=09if (!n)
+=09=09=09goto undo_alloc_err;
+
+=09=09s->node[node] =3D n;
+=09=09init_kmem_cache_node(n);
+
+=09=09if (slab_state =3D=3D DOWN)
+=09=09=09atomic_long_inc(&n->nr_slabs);
+=09}
+=09register_slab(s);
+=09return 1;
+
+undo_alloc_err:
+=09for_each_online_node(node)
+=09=09kfree(s->node[node]);
+
+error:
+=09if (flags & SLAB_PANIC)
+=09=09panic("Cannot create slab %s size=3D%ld realsize=3D%d "
+=09=09=09"order=3D%d offset=3D%d flags=3D%lx\n",
+=09=09=09s->name, (unsigned long)size, s->size, s->order,
+=09=09=09s->offset, flags);
+=09return 0;
+}
+EXPORT_SYMBOL(kmem_cache_open);
+
+/*
+ * Check if a given pointer is valid
+ */
+int kmem_ptr_validate(struct kmem_cache *s, const void *object)
+{
+=09struct page * page;
+=09void *addr;
+
+=09page =3D get_object_page(object);
+
+=09if (!page || s !=3D page->slab)
+=09=09/* No slab or wrong slab */
+=09=09return 0;
+
+=09addr =3D page_address(page);
+=09if (object < addr || object >=3D addr + s->objects * s->size)
+=09=09/* Out of bounds */
+=09=09return 0;
+
+=09if ((object - addr) & s->size)
+=09=09/* Improperly aligned */
+=09=09return 0;
+
+=09/*
+=09 * We could also check here if the object is on the slabs freelist.
+=09 * But this would be too expensive and it seems that the main
+=09 * purpose of kmem_ptr_valid is to check if the object belongs
+=09 * to a certain slab.
+=09 */
+=09return 1;
+}
+EXPORT_SYMBOL(kmem_ptr_validate);
+
+/*
+ * Determine the size of a slab object
+ */
+unsigned int kmem_cache_size(struct kmem_cache *s)
+{
+=09return s->objsize;
+}
+EXPORT_SYMBOL(kmem_cache_size);
+
+const char *kmem_cache_name(struct kmem_cache *s)
+{
+=09return s->name;
+}
+EXPORT_SYMBOL(kmem_cache_name);
+
+static int free_list(struct kmem_cache *s, struct kmem_cache_node *n,
+=09=09=09struct list_head *list)
+{
+=09int slabs_inuse =3D 0;
+=09unsigned long flags;
+=09struct page *page, *h;
+
+=09spin_lock_irqsave(&n->list_lock, flags);
+=09list_for_each_entry_safe(page, h, list, lru)
+=09=09if (!page->inuse) {
+=09=09=09list_del(&page->lru);
+=09=09=09discard_slab(s, page);
+=09=09} else
+=09=09=09slabs_inuse++;
+=09spin_unlock_irqrestore(&n->list_lock, flags);
+=09return slabs_inuse;
+}
+
+/*
+ * Release all resources used by slab cache
+ * (if possible...)
+ */
+int kmem_cache_close(struct kmem_cache *s)
+{
+=09int node;
+
+=09flush_all(s);
+
+=09/* Attempt to free all objects */
+=09for_each_online_node(node) {
+=09=09struct kmem_cache_node *n =3D s->node[node];
+
+=09=09free_list(s, n, &n->partial);
+=09=09if (atomic_long_read(&n->nr_slabs))
+=09=09=09return 1;
+=09}
+
+=09/* Free allocated metadata */
+=09for_each_online_node(node) {
+=09=09kfree(s->node[node]);
+=09=09s->node[node] =3D NULL;
+=09}
+=09unregister_slab(s);
+=09return 0;
+}
+EXPORT_SYMBOL(kmem_cache_close);
+
+/*
+ * Close a cache and release the kmem_cache structure
+ * (must be used for caches created using kmem_cache_create)
+ */
+void kmem_cache_destroy(struct kmem_cache *s)
+{
+=09if (!atomic_dec_and_test(&s->refcount))
+=09=09return;
+
+=09BUG_ON(kmem_cache_close(s));
+=09kfree(s);
+}
+EXPORT_SYMBOL(kmem_cache_destroy);
+
+static unsigned long slab_objects(struct kmem_cache *s,
+=09unsigned long *p_total, unsigned long *p_cpu_slabs,
+=09unsigned long *p_partial, unsigned long *nodes)
+{
+=09int nr_slabs =3D 0;
+=09int nr_partial_slabs =3D 0;
+=09int nr_cpu_slabs =3D 0;
+=09int in_cpu_slabs =3D 0;
+=09int in_partial_slabs =3D 0;
+=09int cpu;
+=09int node;
+=09unsigned long flags;
+=09struct page *page;
+
+=09for_each_online_node(node) {
+=09=09struct kmem_cache_node *n =3D s->node[node];
+
+=09=09nr_slabs +=3D atomic_read(&n->nr_slabs);
+=09=09nr_partial_slabs +=3D n->nr_partial;
+
+=09=09nodes[node] =3D atomic_read(&n->nr_slabs) +
+=09=09=09=09n->nr_partial;
+
+=09=09spin_lock_irqsave(&n->list_lock, flags);
+=09=09list_for_each_entry(page, &n->partial, lru)
+=09=09=09in_partial_slabs +=3D page->inuse;
+=09=09spin_unlock_irqrestore(&n->list_lock, flags);
+=09}
+
+=09for_each_possible_cpu(cpu) {
+=09=09page =3D s->cpu_slab[cpu];
+=09=09if (page) {
+=09=09=09nr_cpu_slabs++;
+=09=09=09in_cpu_slabs +=3D page->inuse;
+=09=09=09nodes[page_to_nid(page)]++;
+=09=09}
+=09}
+
+=09if (p_partial)
+=09=09*p_partial =3D nr_partial_slabs;
+
+=09if (p_cpu_slabs)
+=09=09*p_cpu_slabs =3D nr_cpu_slabs;
+
+=09if (p_total)
+=09=09*p_total =3D nr_slabs;
+
+=09return in_partial_slabs + in_cpu_slabs +
+=09=09(nr_slabs - nr_partial_slabs - nr_cpu_slabs) * s->objects;
+}
+
+/********************************************************************
+ *=09=09Kmalloc subsystem
+ *******************************************************************/
+
+struct kmem_cache kmalloc_caches[KMALLOC_NR_CACHES] __cacheline_aligned;
+EXPORT_SYMBOL(kmalloc_caches);
+
+#ifdef CONFIG_ZONE_DMA
+static struct kmem_cache *kmalloc_caches_dma[KMALLOC_NR_CACHES];
+#endif
+
+static int __init setup_slub_min_order(char *str)
+{
+=09get_option (&str, &slub_min_order);
+
+=09return 1;
+}
+
+__setup("slub_min_order=3D", setup_slub_min_order);
+
+static int __init setup_slub_nomerge(char *str)
+{
+=09slub_nomerge =3D 1;
+=09return 1;
+}
+
+__setup("slub_nomerge", setup_slub_nomerge);
+
+static struct kmem_cache *create_kmalloc_cache(struct kmem_cache *s,
+=09=09const char *name, int size, gfp_t flags)
+{
+
+=09if (!kmem_cache_open(s, flags, name, size, ARCH_KMALLOC_MINALIGN,
+=09=09=090, NULL, NULL))
+=09=09panic("Creation of kmalloc slab %s size=3D%d failed.\n",
+=09=09=09name, size);
+=09return s;
+}
+
+static struct kmem_cache *get_slab(size_t size, gfp_t flags)
+{
+=09int index =3D kmalloc_index(size) - KMALLOC_SHIFT_LOW;
+
+=09/* SLAB allows allocations with zero size. So warn on those */
+=09WARN_ON(size =3D=3D 0);
+=09/* Allocation too large? */
+=09BUG_ON(index < 0);
+
+#ifdef CONFIG_ZONE_DMA
+=09if ((flags & SLUB_DMA)) {
+=09=09struct kmem_cache *s;
+=09=09struct kmem_cache *x;
+=09=09char *text;
+=09=09size_t realsize;
+
+=09=09s =3D kmalloc_caches_dma[index];
+=09=09if (s)
+=09=09=09return s;
+
+=09=09/* The control structures do not have to be in the DMA zone */
+=09=09flags &=3D ~__GFP_DMA;
+
+=09=09/* Dynamically create dma cache */
+=09=09x =3D kmalloc(sizeof(struct kmem_cache), flags);
+=09=09if (!x)
+=09=09=09panic("Unable to allocate memory for dma cache\n");
+
+#ifdef KMALLOC_EXTRA
+=09=09if (index <=3D KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW)
+#endif
+=09=09=09realsize =3D 1 << (index + KMALLOC_SHIFT_LOW);
+#ifdef KMALLOC_EXTRA
+=09=09else {
+=09=09=09index -=3D KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW +1;
+=09=09=09if (!index)
+=09=09=09=09realsize =3D 96;
+=09=09=09else
+=09=09=09=09realsize =3D 192;
+=09=09}
+#endif
+
+=09=09text =3D kasprintf(flags, "kmalloc_dma-%ld", realsize);
+=09=09s =3D create_kmalloc_cache(x, text, realsize, flags);
+=09=09kfree(text);
+=09=09kmalloc_caches_dma[index] =3D s;
+=09=09return s;
+=09}
+#endif
+=09return &kmalloc_caches[index];
+}
+
+void *__kmalloc(size_t size, gfp_t flags)
+{
+=09return kmem_cache_alloc(get_slab(size, flags), flags);
+}
+EXPORT_SYMBOL(__kmalloc);
+
+#ifdef CONFIG_NUMA
+void *__kmalloc_node(size_t size, gfp_t flags, int node)
+{
+=09return kmem_cache_alloc_node(get_slab(size, flags),
+=09=09=09=09=09=09=09flags, node);
+}
+EXPORT_SYMBOL(__kmalloc_node);
+#endif
+
+unsigned int ksize(const void *object)
+{
+=09struct page *page =3D get_object_page(object);
+=09struct kmem_cache *s;
+
+=09BUG_ON(!page);
+=09s =3D page->slab;
+=09BUG_ON(!s);
+=09return s->size;
+}
+EXPORT_SYMBOL(ksize);
+
+void kfree(const void *object)
+{
+=09kmem_cache_free(NULL, (void *)object);
+}
+EXPORT_SYMBOL(kfree);
+
+/********************************************************************
+ *=09=09=09Basic setup of slabs
+ *******************************************************************/
+
+#define SLAB_MAX_ORDER 4
+
+int slab_is_available(void) {
+=09return slab_state =3D=3D UP;
+}
+
+void __init kmem_cache_init(void)
+{
+=09int i;
+=09int kmem_cache_node_cache =3D
+=09=09kmalloc_index(sizeof(struct kmem_cache_node));
+
+=09BUG_ON(kmem_cache_node_cache < 0 ||
+=09=09kmem_cache_node_cache > KMALLOC_SHIFT_HIGH);
+
+=09/*
+=09 * Must first have the slab cache available for the allocations of the
+=09 * struct kmalloc_cache_node's. There is special bootstrap code in
+=09 * kmem_cache_open for the situation when slab_state =3D=3D DOWN.
+=09 */
+=09create_kmalloc_cache(&kmalloc_caches[kmem_cache_node_cache
+=09=09=09- KMALLOC_SHIFT_LOW],
+=09=09=09"kmalloc",
+=09=09=091 << kmem_cache_node_cache,
+=09=09=09GFP_KERNEL);
+
+=09/* Now we are able to allocate the per node structures */
+=09slab_state =3D PARTIAL;
+
+=09for (i =3D  KMALLOC_SHIFT_LOW; i <=3D KMALLOC_SHIFT_HIGH; i++) {
+=09=09if (i =3D=3D kmem_cache_node_cache)
+=09=09=09continue;
+
+=09=09create_kmalloc_cache(
+=09=09=09&kmalloc_caches[i - KMALLOC_SHIFT_LOW],
+=09=09=09"kmalloc", 1 << i, GFP_KERNEL);
+=09}
+
+#ifdef KMALLOC_EXTRA
+=09/* Caches that are not of the two-to-the-power-of size */
+=09create_kmalloc_cache(&kmalloc_caches
+=09=09[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 1],
+=09=09=09=09"kmalloc-96", 96, GFP_KERNEL);
+=09create_kmalloc_cache(&kmalloc_caches
+=09=09[KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW + 2],
+=09=09=09=09"kmalloc-192", 192, GFP_KERNEL);
+#endif
+=09slab_state =3D UP;
+
+=09/* Provide the correct kmalloc names now that the caches are up */
+=09for (i =3D 0; i <=3D KMALLOC_SHIFT_HIGH - KMALLOC_SHIFT_LOW; i++) {
+=09=09char *name =3D kasprintf(GFP_KERNEL, "kmalloc-%d",
+=09=09=09=09=09kmalloc_caches[i].size);
+=09=09BUG_ON(!name);
+=09=09kmalloc_caches[i].name =3D name;
+=09};
+
+#ifdef CONFIG_SMP
+=09register_cpu_notifier(&slab_notifier);
+#endif
+}
+
+static struct kmem_cache *kmem_cache_dup(struct kmem_cache *s,
+=09=09=09=09gfp_t flags, const char *name)
+{
+=09char *x;
+
+=09atomic_inc(&s->refcount);
+
+=09if (!s->aliases)
+=09=09s->aliases =3D kstrdup(name, flags);
+=09else {
+=09=09x =3D kmalloc(strlen(s->aliases) + strlen(name) + 1,
+=09=09=09=09=09=09flags);
+=09=09strcpy(x, s->aliases);
+=09=09strcat(x, " ");
+=09=09strcat(x, name);
+=09=09kfree(s->aliases);
+=09=09s->aliases =3D x;
+=09}
+=09return s;
+}
+
+
+/*
+ * Find a mergeable slab cache
+ */
+static struct kmem_cache *find_mergeable(unsigned long size, unsigned long=
 flags)
+{
+=09struct list_head *h;
+
+=09if (slub_nomerge || (flags & SLUB_NEVER_MERGE))
+=09=09return NULL;
+
+=09down_read(&slabstat_sem);
+=09list_for_each(h, &slab_caches) {
+=09=09struct kmem_cache *s =3D
+=09=09=09container_of(h, struct kmem_cache, list);
+
+=09=09if (s->size >=3D size &&
+=09=09=09=09!(s->flags & SLUB_NEVER_MERGE) &&
+=09=09=09=09s->size - size <=3D sizeof(void *)) {
+=09=09=09up_read(&slabstat_sem);
+=09=09=09return s;
+=09=09}
+=09}
+=09up_read(&slabstat_sem);
+=09return NULL;
+}
+
+struct kmem_cache *kmem_cache_create(const char *name, size_t size,
+=09=09size_t align, unsigned long flags,
+=09=09void (*ctor)(void *, struct kmem_cache *, unsigned long),
+=09=09void (*dtor)(void *, struct kmem_cache *, unsigned long))
+{
+=09struct kmem_cache *s =3D NULL;
+
+=09if (!ctor && !dtor)
+=09=09s =3D find_mergeable(
+=09=09=09ALIGN(size, calculate_alignment(flags, align)),
+=09=09=09flags);
+
+=09if (s) {
+=09=09printk(KERN_INFO "SLUB: Merging slab_cache %s size %d"
+=09=09=09" with slab_cache %s\n",
+=09=09=09name, (int)size, s->name);
+=09=09return kmem_cache_dup(s, GFP_KERNEL, name);
+=09}
+
+=09s =3D kmalloc(sizeof(struct kmem_cache), GFP_KERNEL);
+=09if (!s)
+=09=09return NULL;
+
+=09if (!kmem_cache_open(s, GFP_KERNEL, name, size, align,
+=09=09=09=09=09flags, ctor, dtor)) {
+=09=09kfree(s);
+=09=09return NULL;
+=09}
+=09return s;
+}
+EXPORT_SYMBOL(kmem_cache_create);
+
+void *kmem_cache_zalloc(struct kmem_cache *s, gfp_t flags)
+{
+=09void *x;
+
+=09x =3D kmem_cache_alloc(s, flags);
+=09if (x)
+=09=09memset(x, 0, s->objsize);
+=09return x;
+}
+EXPORT_SYMBOL(kmem_cache_zalloc);
+
+/********************************************************************
+ *=09=09=09Slab proc interface
+ *******************************************************************/
+
+static void for_all_slabs(void (*func)(struct kmem_cache *, int), int cpu)
+{
+=09struct list_head *h;
+
+=09down_read(&slabstat_sem);
+=09list_for_each(h, &slab_caches) {
+=09=09struct kmem_cache *s =3D
+=09=09=09container_of(h, struct kmem_cache, list);
+
+=09=09func(s, cpu);
+=09}
+=09up_read(&slabstat_sem);
+}
+
+
+static void register_slab(struct kmem_cache *s)
+{
+=09down_write(&slabstat_sem);
+=09list_add(&s->list, &slab_caches);
+=09up_write(&slabstat_sem);
+}
+
+static void unregister_slab(struct kmem_cache *s)
+{
+=09down_write(&slabstat_sem);
+=09list_add(&s->list, &slab_caches);
+=09up_write(&slabstat_sem);
+}
+
+static void print_slabinfo_header(struct seq_file *m)
+{
+=09/*
+=09 * Output format version, so at least we can change it
+=09 * without _too_ many complaints.
+=09 */
+=09seq_puts(m, "slubinfo - version: 1.0\n");
+=09seq_puts(m, "# name            <objects> <order> <objsize>"
+=09=09" <slabs>/<partial>/<cpu> <flags>");
+#ifdef CONFIG_NUMA
+=09seq_puts(m, " <nodes>");
+#endif
+=09seq_putc(m, '\n');
+}
+
+static void *s_start(struct seq_file *m, loff_t *pos)
+{
+=09loff_t n =3D *pos;
+=09struct list_head *p;
+
+=09down_read(&slabstat_sem);
+=09if (!n)
+=09=09print_slabinfo_header(m);
+=09p =3D slab_caches.next;
+=09while (n--) {
+=09=09p =3D p->next;
+=09=09if (p =3D=3D &slab_caches)
+=09=09=09return NULL;
+=09}
+=09return list_entry(p, struct kmem_cache, list);
+}
+
+static void *s_next(struct seq_file *m, void *p, loff_t *pos)
+{
+=09struct kmem_cache *s =3D p;
+=09++*pos;
+=09return s->list.next =3D=3D &slab_caches ?
+=09=09NULL : list_entry(s->list.next, struct kmem_cache, list);
+}
+
+static void s_stop(struct seq_file *m, void *p)
+{
+=09up_read(&slabstat_sem);
+}
+
+static void display_nodes(struct seq_file *m, unsigned long *nodes)
+{
+#ifdef CONFIG_NUMA
+=09int node;
+
+=09for_each_online_node(node)
+=09=09if (nodes[node])
+=09=09=09seq_printf(m, " N%d=3D%lu", node, nodes[node]);
+#endif
+}
+
+static int s_show(struct seq_file *m, void *p)
+{
+=09struct kmem_cache *s =3D p;
+=09unsigned long total_slabs;
+=09unsigned long cpu_slabs;
+=09unsigned long partial_slabs;
+=09unsigned long objects;
+=09unsigned char options[13];
+=09char *d =3D options;
+=09char *x;
+=09unsigned long nodes[nr_node_ids];
+
+=09objects =3D slab_objects(s, &total_slabs, &cpu_slabs,
+=09=09=09=09=09&partial_slabs, nodes);
+=09if (s->ctor)
+=09=09*d++ =3D 'C';
+=09if (s->dtor)
+=09=09*d++ =3D 'D';
+=09if (s->flags & SLAB_DESTROY_BY_RCU)
+=09=09*d++ =3D 'R';
+=09if (s->flags & SLAB_MEM_SPREAD)
+=09=09*d++ =3D 'S';
+=09if (s->flags & SLAB_CACHE_DMA)
+=09=09*d++ =3D 'd';
+=09if (s->flags & SLAB_RECLAIM_ACCOUNT)
+=09=09*d++ =3D 'r';
+=09if (s->flags & SLAB_PANIC)
+=09=09*d++ =3D 'P';
+=09if (s->flags & SLAB_HWCACHE_ALIGN)
+=09=09*d++ =3D 'a';
+=09if (s->flags & SLAB_MUST_HWCACHE_ALIGN)
+=09=09*d++ =3D 'A';
+=09if (s->flags & SLAB_DEBUG_FREE)
+=09=09*d++ =3D 'F';
+=09if (s->flags & SLAB_DEBUG_INITIAL)
+=09=09*d++ =3D 'I';
+=09if (s->flags & SLAB_STORE_USER)
+=09=09*d++ =3D 'U';
+
+=09*d =3D 0;
+
+=09x =3D kasprintf(GFP_KERNEL, "%lu/%lu/%lu", total_slabs, partial_slabs,
+=09=09=09=09=09=09cpu_slabs);
+
+=09seq_printf(m, "%-21s %6lu %1d %7u %12s %5s",
+=09=09s->name, objects, s->order, s->size, x, options);
+
+=09kfree(x);
+=09display_nodes(m, nodes);
+=09if (s->aliases) {
+=09=09seq_putc(m, ' ');
+=09=09seq_puts(m, s->aliases);
+=09}
+=09seq_putc(m, '\n');
+=09return 0;
+}
+
+/*
+ * slabinfo_op - iterator that generates /proc/slabinfo
+ */
+struct seq_operations slabinfo_op =3D {
+=09.start =3D s_start,
+=09.next =3D s_next,
+=09.stop =3D s_stop,
+=09.show =3D s_show,
+};
+
+#ifdef CONFIG_SMP
+
+/*
+ * Use the cpu notifier to insure that the thresholds are recalculated
+ * when necessary.
+ */
+static int __cpuinit slab_cpuup_callback(struct notifier_block *nfb,
+=09=09unsigned long action, void *hcpu)
+{
+=09long cpu =3D (long)hcpu;
+
+=09switch (action) {
+=09case CPU_UP_CANCELED:
+=09case CPU_DEAD:
+=09=09for_all_slabs(__flush_cpu_slab, cpu);
+=09=09break;
+=09default:
+=09=09break;
+=09}
+=09return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata slab_notifier =3D
+=09{ &slab_cpuup_callback, NULL, 0 };
+
+#endif
+
+/***************************************************************
+ *=09Compatiblility definitions
+ **************************************************************/
+
+int kmem_cache_shrink(struct kmem_cache *s)
+{
+=09flush_all(s);
+=09return 0;
+}
+EXPORT_SYMBOL(kmem_cache_shrink);
+
+#ifdef CONFIG_NUMA
+
+/*****************************************************************
+ * Generic reaper used to support the page allocator
+ * (the cpu slabs are reaped by a per slab workqueue).
+ *
+ * Maybe move this to the page allocator?
+ ****************************************************************/
+
+static DEFINE_PER_CPU(unsigned long, reap_node);
+
+static void init_reap_node(int cpu)
+{
+=09int node;
+
+=09node =3D next_node(cpu_to_node(cpu), node_online_map);
+=09if (node =3D=3D MAX_NUMNODES)
+=09=09node =3D first_node(node_online_map);
+
+=09__get_cpu_var(reap_node) =3D node;
+}
+
+static void next_reap_node(void)
+{
+=09int node =3D __get_cpu_var(reap_node);
+
+=09/*
+=09 * Also drain per cpu pages on remote zones
+=09 */
+=09if (node !=3D numa_node_id())
+=09=09drain_node_pages(node);
+
+=09node =3D next_node(node, node_online_map);
+=09if (unlikely(node >=3D MAX_NUMNODES))
+=09=09node =3D first_node(node_online_map);
+=09__get_cpu_var(reap_node) =3D node;
+}
+#else
+#define init_reap_node(cpu) do { } while (0)
+#define next_reap_node(void) do { } while (0)
+#endif
+
+#define REAPTIMEOUT_CPUC=09(2*HZ)
+
+#ifdef CONFIG_SMP
+static DEFINE_PER_CPU(struct delayed_work, reap_work);
+
+static void cache_reap(struct work_struct *unused)
+{
+=09next_reap_node();
+=09refresh_cpu_vm_stats(smp_processor_id());
+=09schedule_delayed_work(&__get_cpu_var(reap_work),
+=09=09=09=09      REAPTIMEOUT_CPUC);
+}
+
+static void __devinit start_cpu_timer(int cpu)
+{
+=09struct delayed_work *reap_work =3D &per_cpu(reap_work, cpu);
+
+=09/*
+=09 * When this gets called from do_initcalls via cpucache_init(),
+=09 * init_workqueues() has already run, so keventd will be setup
+=09 * at that time.
+=09 */
+=09if (keventd_up() && reap_work->work.func =3D=3D NULL) {
+=09=09init_reap_node(cpu);
+=09=09INIT_DELAYED_WORK(reap_work, cache_reap);
+=09=09schedule_delayed_work_on(cpu, reap_work, HZ + 3 * cpu);
+=09}
+}
+
+static int __init cpucache_init(void)
+{
+=09int cpu;
+
+=09/*
+=09 * Register the timers that drain pcp pages and update vm statistics
+=09 */
+=09for_each_online_cpu(cpu)
+=09=09start_cpu_timer(cpu);
+=09return 0;
+}
+__initcall(cpucache_init);
+#endif
+
---1700579579-595485047-1172385386=:20557--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
