Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB57E6B03A9
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:15:10 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y51so47506080wry.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:15:10 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 11/13] mm/vas: Introduce VAS segments - shareable address space regions
Date: Mon, 13 Mar 2017 15:14:13 -0700
Message-Id: <20170313221415.9375-12-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

VAS segments are an extension to first class virtual address spaces that
can be used to share specific memory regions between multiple first class
virtual address spaces. VAS segments have a specific size and position in a
virtual address space and can thereby be used to share in-memory pointer
based data structures between multiple address spaces as well as other
in-memory data without the need to represent them in mmap-able files or
use shmem.

Similar to first class virtual address spaces, VAS segments must be created
and destroyed explicitly by a user. The system will never automatically
destroy or create a virtual segment. Via attaching a VAS segment to a first
class virtual address space, the memory that is contained in the VAS
segment can be accessed and changed.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |    7 +
 arch/x86/entry/syscalls/syscall_64.tbl |    7 +
 include/linux/syscalls.h               |   10 +
 include/linux/vas.h                    |  114 +++
 include/linux/vas_types.h              |   91 ++-
 include/uapi/asm-generic/unistd.h      |   16 +-
 include/uapi/linux/vas.h               |   12 +
 kernel/sys_ni.c                        |    7 +
 mm/vas.c                               | 1234 ++++++++++++++++++++++++++++++--
 9 files changed, 1451 insertions(+), 47 deletions(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 8c553eef8c44..a4f91d14a856 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -398,3 +398,10 @@
 389	i386	active_vas		sys_active_vas
 390	i386	vas_getattr		sys_vas_getattr
 391	i386	vas_setattr		sys_vas_setattr
+392	i386	vas_seg_create		sys_vas_seg_create
+393	i386	vas_seg_delete		sys_vas_seg_delete
+394	i386	vas_seg_find		sys_vas_seg_find
+395	i386	vas_seg_attach		sys_vas_seg_attach
+396	i386	vas_seg_detach		sys_vas_seg_detach
+397	i386	vas_seg_getattr		sys_vas_seg_getattr
+398	i386	vas_seg_setattr		sys_vas_seg_setattr
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 72f1f0495710..a0f9503c3d28 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -347,6 +347,13 @@
 338	common	active_vas		sys_active_vas
 339	common	vas_getattr		sys_vas_getattr
 340	common	vas_setattr		sys_vas_setattr
+341	common	vas_seg_create		sys_vas_seg_create
+342	common	vas_seg_delete		sys_vas_seg_delete
+343	common	vas_seg_find		sys_vas_seg_find
+344	common	vas_seg_attach		sys_vas_seg_attach
+345	common	vas_seg_detach		sys_vas_seg_detach
+346	common	vas_seg_getattr		sys_vas_seg_getattr
+347	common	vas_seg_setattr		sys_vas_seg_setattr
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index fdea27d37c96..7380dcdc4bc1 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -66,6 +66,7 @@ struct perf_event_attr;
 struct file_handle;
 struct sigaltstack;
 struct vas_attr;
+struct vas_seg_attr;
 union bpf_attr;
 
 #include <linux/types.h>
@@ -914,4 +915,13 @@ asmlinkage long sys_active_vas(void);
 asmlinkage long sys_vas_getattr(int vid, struct vas_attr __user *attr);
 asmlinkage long sys_vas_setattr(int vid, struct vas_attr __user *attr);
 
+asmlinkage long sys_vas_seg_create(const char __user *name, unsigned long start,
+				   unsigned long end, umode_t mode);
+asmlinkage long sys_vas_seg_delete(int sid);
+asmlinkage long sys_vas_seg_find(const char __user *name);
+asmlinkage long sys_vas_seg_attach(int vid, int sid, int type);
+asmlinkage long sys_vas_seg_detach(int vid, int sid);
+asmlinkage long sys_vas_seg_getattr(int sid, struct vas_seg_attr __user *attr);
+asmlinkage long sys_vas_seg_setattr(int sid, struct vas_seg_attr __user *attr);
+
 #endif
diff --git a/include/linux/vas.h b/include/linux/vas.h
index 6a72e42f96d2..376b9fa1ee27 100644
--- a/include/linux/vas.h
+++ b/include/linux/vas.h
@@ -138,6 +138,120 @@ extern int vas_setattr(int vid, struct vas_attr *attr);
 
 
 /***
+ * Management of VAS segments
+ ***/
+
+/**
+ * Lock and unlock helper for VAS segments.
+ **/
+#define vas_seg_lock(seg) mutex_lock(&(seg)->mtx)
+#define vas_seg_unlock(seg) mutex_unlock(&(seg)->mtx)
+
+/**
+ * Create a new VAS segment.
+ *
+ * @param[in] name:		The name of the new VAS segment.
+ * @param[in] start:		The address where the VAS segment begins.
+ * @param[in] end:		The address where the VAS segment ends.
+ * @param[in] mode:		The access rights for the VAS segment.
+ *
+ * @returns:			The VAS segment ID on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_create(const char *name, unsigned long start,
+			  unsigned long end, umode_t mode);
+
+/**
+ * Get a pointer to a VAS segment data structure.
+ *
+ * @param[in] sid:		The ID of the VAS segment whose data structure
+ *				should be returned.
+ *
+ * @returns:			The pointer to the VAS segment data structure
+ *				on success, or NULL otherwise.
+ **/
+extern struct vas_seg *vas_seg_get(int sid);
+
+/**
+ * Return a pointer to a VAS segment data structure again.
+ *
+ * @param[in] seg:		The pointer to the VAS segment data structure
+ *				that should be returned.
+ **/
+extern void vas_seg_put(struct vas_seg *seg);
+
+/**
+ * Get ID of the VAS segment belonging to a given name.
+ *
+ * @param[in] name:		The name of the VAS segment for which the ID
+ *				should be returned.
+ *
+ * @returns:			The VAS segment ID on success, -ERRNO
+ *				otherwise.
+ **/
+extern int vas_seg_find(const char *name);
+
+/**
+ * Delete the given VAS segment again.
+ *
+ * @param[in] id:		The ID of the VAS segment which should be
+ *				deleted.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_delete(int id);
+
+/**
+ * Attach a VAS segment to a VAS.
+ *
+ * @param[in] vid:		The ID of the VAS to which the VAS segment
+ *				should be attached.
+ * @param[in] sid:		The ID of the VAS segment which should be
+ *				attached.
+ * @param[in] type:		The type how the VAS segment should be
+ *				attached.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_attach(int vid, int sid, int type);
+
+/**
+ * Detach a VAS segment from a VAS.
+ *
+ * @param[in] vid:		The ID of the VAS from which the VAS segment
+ *				should be detached.
+ * @param[in] sid:		The ID of the VAS segment which should be
+ *				detached.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_detach(int vid, int sid);
+
+/**
+ * Get attributes of a VAS segment.
+ *
+ * @param[in] sid:		The ID of the VAS segment for which the
+ *				attributes should be returned.
+ * @param[out] attr:		The pointer to the struct where the attributes
+ *				should be saved.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_getattr(int sid, struct vas_seg_attr *attr);
+
+/**
+ * Set attributes of a VAS segment.
+ *
+ * @param[in] sid:		The ID of the VAS segment for which the
+ *				attributes should be updated.
+ * @param[in] attr:		The pointer to the struct containing the new
+ *				attributes.
+ *
+ * @returns:			0 on success, -ERRNO otherwise.
+ **/
+extern int vas_seg_setattr(int sid, struct vas_seg_attr *attr);
+
+
+/***
  * Management of the VAS subsystem
  ***/
 
diff --git a/include/linux/vas_types.h b/include/linux/vas_types.h
index f06bfa9ef729..a5291a18ea07 100644
--- a/include/linux/vas_types.h
+++ b/include/linux/vas_types.h
@@ -24,8 +24,8 @@ struct task_struct;
  * The struct representing a Virtual Address Space (VAS).
  *
  * This data structure contains all the necessary information of a VAS such as
- * its name, ID. It also contains access rights and other management
- * information.
+ * its name, ID, as well as the list of all the VAS segments which are attached
+ * to it. It also contains access rights and other management information.
  **/
 struct vas {
 	struct kobject kobj;		/* < the internal kobject that we use *
@@ -38,7 +38,8 @@ struct vas {
 	struct mutex mtx;		/* < lock for parallel access.        */
 
 	struct mm_struct *mm;		/* < a partial memory map containing  *
-					 *   all mappings of this VAS.        */
+					 *   all mappings of this VAS and all *
+					 *   of its attached VAS segments.    */
 
 	struct list_head link;		/* < the link in the global VAS list. */
 	struct rcu_head rcu;		/* < the RCU helper used for          *
@@ -54,6 +55,11 @@ struct vas {
 					 *   of the current sharing state of  *
 					 *   the VAS.                         */
 
+	struct list_head segments;	/* < the list of attached VAS         *
+					 *   segments.                        */
+	u32 nr_segments;		/* < the number of VAS segments       *
+					 *   attached to this VAS.            */
+
 	umode_t mode;			/* < the access rights to this VAS.   */
 	kuid_t uid;			/* < the UID of the owning user of    *
 					 *   this VAS.                        */
@@ -85,4 +91,83 @@ struct att_vas {
 	int type;			/* < the type of attaching (RO/RW).   */
 };
 
+/**
+ * The struct representing a VAS segment.
+ *
+ * A VAS segment is a region in memory. Accordingly, it is very similar to a
+ * vm_area. However, instead of a vm_area it can only represent a memory region
+ * and not a file and also knows where it is mapped. In addition VAS segments
+ * also have an ID, a name, access rights and a lock managing the way it can be
+ * shared between multiple VAS.
+ **/
+struct vas_seg {
+	struct kobject kobj;		/* < the internal kobject that we use *
+					 *   for reference counting and sysfs *
+					 *   handling.                        */
+
+	int id;				/* < ID                               */
+	char name[VAS_MAX_NAME_LENGTH];	/* < name                             */
+
+	struct mutex mtx;		/* < lock for parallel access.        */
+
+	unsigned long start;		/* < the virtual address where the    *
+					 *   VAS segment starts.              */
+	unsigned long end;		/* < the virtual address where the    *
+					 *   VAS segment ends.                */
+	unsigned long length;		/* < the size of the VAS segment in   *
+					 *   bytes.                           */
+
+	struct mm_struct *mm;		/* < a partial memory map containing  *
+					 *   all the mappings for this VAS    *
+					 *   segment.                         */
+
+	struct list_head link;		/* < the link in the global VAS       *
+					 *   segment list.                    */
+	struct rcu_head rcu;		/* < the RCU helper used for          *
+					 *   asynchronous VAS segment         *
+					 *   deletion.                        */
+
+	u16 refcount;			/* < how often is the VAS segment     *
+					 *   attached.                        */
+	struct list_head attaches;	/* < the list of VASes which have     *
+					 *   this VAS segment attached.       */
+
+	spinlock_t share_lock;		/* < lock for protecting sharing      *
+					 *   state.                           */
+	u32 sharing;			/* < the variable used to keep track  *
+					 *   of the current sharing state of  *
+					 *   the VAS segment.                 */
+
+	umode_t mode;			/* < the access rights to this VAS    *
+					 *   segment.                         */
+	kuid_t uid;			/* < the UID of the owning user of    *
+					 *   this VAS segment.                */
+	kgid_t gid;			/* < the GID of the owning group of   *
+					 *   this VAS segment.                */
+};
+
+/**
+ * The struct representing a VAS segment being attached to a VAS.
+ *
+ * Since a VAS segment can be attached to a multiple VAS this data structure is
+ * necessary. It forms the connection between the VAS and the VAS segment
+ * itself.
+ **/
+struct att_vas_seg {
+	struct vas_seg *seg;            /* < the reference to the actual VAS  *
+					 *   segment containing all the       *
+					 *   information.                     */
+
+	struct vas *vas;		/* < the reference to the VAS to      *
+					 *   which the VAS segment is         *
+					 *   attached to.                     */
+
+	struct list_head vas_link;	/* < the link in the list managed     *
+					 *   inside the VAS.                  */
+	struct list_head seg_link;	/* < the link in the list managed     *
+					 *   inside the VAS segment.          */
+
+	int type;			/* < the type of attaching (RO/RW).   */
+};
+
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 35df7d40a443..4014b4bd2f18 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -748,9 +748,23 @@ __SYSCALL(__NR_active_vas, sys_active_vas)
 __SYSCALL(__NR_vas_getattr, sys_vas_getattr)
 #define __NR_vas_setattr 299
 __SYSCALL(__NR_vas_setattr, sys_vas_setattr)
+#define __NR_vas_seg_create 300
+__SYSCALL(__NR_vas_seg_create, sys_vas_seg_create)
+#define __NR_vas_seg_delete 301
+__SYSCALL(__NR_vas_seg_delete, sys_vas_seg_delete)
+#define __NR_vas_seg_find 302
+__SYSCALL(__NR_vas_seg_find, sys_vas_seg_find)
+#define __NR_vas_seg_attach 303
+__SYSCALL(__NR_vas_seg_attach, sys_vas_seg_attach)
+#define __NR_vas_seg_detach 304
+__SYSCALL(__NR_vas_seg_detach, sys_vas_seg_detach)
+#define __NR_vas_seg_getattr 305
+__SYSCALL(__NR_vas_seg_getattr, sys_vas_seg_getattr)
+#define __NR_vas_seg_setattr 306
+__SYSCALL(__NR_vas_seg_setattr, sys_vas_seg_setattr)
 
 #undef __NR_syscalls
-#define __NR_syscalls 300
+#define __NR_syscalls 307
 
 /*
  * All syscalls below here should go away really,
diff --git a/include/uapi/linux/vas.h b/include/uapi/linux/vas.h
index 02f70f88bdcb..a8858b013a44 100644
--- a/include/uapi/linux/vas.h
+++ b/include/uapi/linux/vas.h
@@ -13,4 +13,16 @@ struct vas_attr {
 	__kernel_gid_t group;		/* < the owning group of the VAS.     */
 };
 
+/**
+ * The struct containing attributes of a VAS segment.
+ **/
+struct vas_seg_attr {
+	__kernel_mode_t mode;		/* < the access rights to the VAS     *
+					 *   segment.                         */
+	__kernel_uid_t user;		/* < the owning user of the VAS       *
+					 *   segment.                         */
+	__kernel_gid_t group;		/* < the owning group of the VAS      *
+					 *   segment.                         */
+};
+
 #endif
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index f6f83c5ec1a1..659fe96afcfa 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -269,3 +269,10 @@ cond_syscall(sys_vas_switch);
 cond_syscall(sys_active_vas);
 cond_syscall(sys_vas_getattr);
 cond_syscall(sys_vas_setattr);
+cond_syscall(sys_segment_create);
+cond_syscall(sys_segment_delete);
+cond_syscall(sys_segment_find);
+cond_syscall(sys_segment_attach);
+cond_syscall(sys_segment_detach);
+cond_syscall(sys_segment_getattr);
+cond_syscall(sys_segment_setattr);
diff --git a/mm/vas.c b/mm/vas.c
index 447d61e1da79..345b023c21aa 100644
--- a/mm/vas.c
+++ b/mm/vas.c
@@ -61,7 +61,7 @@
 #define VAS_MAX_ID INT_MAX
 
 /**
- * Masks and bits to implement sharing of VAS.
+ * Masks and bits to implement sharing of VAS and VAS segments.
  **/
 #define VAS_SHARE_READABLE (1 << 0)
 #define VAS_SHARE_WRITABLE (1 << 16)
@@ -194,6 +194,8 @@ static void __dump_memory_map(const char *title, struct mm_struct *mm)
 static struct kmem_cache *vas_cachep;
 static struct kmem_cache *att_vas_cachep;
 static struct kmem_cache *vas_context_cachep;
+static struct kmem_cache *seg_cachep;
+static struct kmem_cache *att_seg_cachep;
 
 /**
  * Global management data structures and their associated locks.
@@ -201,16 +203,21 @@ static struct kmem_cache *vas_context_cachep;
 static struct idr vases;
 static spinlock_t vases_lock;
 
+static struct idr vas_segs;
+static spinlock_t vas_segs_lock;
+
 /**
  * The place holder variables that are used to identify to-be-deleted items in
  * our global management data structures.
  **/
 static struct vas *INVALID_VAS;
+static struct vas_seg *INVALID_VAS_SEG;
 
 /**
  * Kernel 'ksets' where all objects will be managed.
  **/
 static struct kset *vases_kset;
+static struct kset *vas_segs_kset;
 
 
 /***
@@ -273,6 +280,40 @@ static inline void __delete_vas_context(struct vas_context *ctx)
 	kmem_cache_free(vas_context_cachep, ctx);
 }
 
+static inline struct vas_seg *__new_vas_seg(void)
+{
+	return kmem_cache_zalloc(seg_cachep, GFP_KERNEL);
+}
+
+static inline void __delete_vas_seg(struct vas_seg *seg)
+{
+	WARN_ON(seg->refcount != 0);
+
+	mutex_destroy(&seg->mtx);
+
+	if (seg->mm)
+		mmput_async(seg->mm);
+	kmem_cache_free(seg_cachep, seg);
+}
+
+static inline void __delete_vas_seg_rcu(struct rcu_head *rp)
+{
+	struct vas_seg *seg = container_of(rp, struct vas_seg, rcu);
+
+	__delete_vas_seg(seg);
+}
+
+static inline struct att_vas_seg *__new_att_vas_seg(void)
+{
+	return kmem_cache_zalloc(att_seg_cachep, GFP_ATOMIC);
+}
+
+static inline void __delete_att_vas_seg(struct att_vas_seg *aseg)
+{
+	kmem_cache_free(att_seg_cachep, aseg);
+}
+
+
 /***
  * Kobject management of data structures
  ***/
@@ -418,6 +459,161 @@ static struct kobj_type vas_ktype = {
 	.default_attrs = vas_default_attr,
 };
 
+/**
+ * Correctly get and put VAS segments.
+ **/
+static inline struct vas_seg *__vas_seg_get(struct vas_seg *seg)
+{
+	return container_of(kobject_get(&seg->kobj), struct vas_seg, kobj);
+}
+
+static inline void __vas_seg_put(struct vas_seg *seg)
+{
+	kobject_put(&seg->kobj);
+}
+
+/**
+ * The sysfs structure we need to handle attributes of a VAS segment.
+ **/
+struct vas_seg_sysfs_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct vas_seg *seg, struct vas_seg_sysfs_attr *ssattr,
+			char *buf);
+	ssize_t (*store)(struct vas_seg *seg, struct vas_seg_sysfs_attr *ssattr,
+			 const char *buf, ssize_t count);
+};
+
+#define VAS_SEG_SYSFS_ATTR(NAME, MODE, SHOW, STORE)			\
+static struct vas_seg_sysfs_attr vas_seg_sysfs_attr_##NAME =		\
+	__ATTR(NAME, MODE, SHOW, STORE)
+
+/**
+ * Functions for all the sysfs operations for VAS segments.
+ **/
+static ssize_t __vas_seg_sysfs_attr_show(struct kobject *kobj,
+					 struct attribute *attr,
+					 char *buf)
+{
+	struct vas_seg *seg;
+	struct vas_seg_sysfs_attr *ssattr;
+
+	seg = container_of(kobj, struct vas_seg, kobj);
+	ssattr = container_of(attr, struct vas_seg_sysfs_attr, attr);
+
+	if (!ssattr->show)
+		return -EIO;
+
+	return ssattr->show(seg, ssattr, buf);
+}
+
+static ssize_t __vas_seg_sysfs_attr_store(struct kobject *kobj,
+					  struct attribute *attr,
+					  const char *buf, size_t count)
+{
+	struct vas_seg *seg;
+	struct vas_seg_sysfs_attr *ssattr;
+
+	seg = container_of(kobj, struct vas_seg, kobj);
+	ssattr = container_of(attr, struct vas_seg_sysfs_attr, attr);
+
+	if (!ssattr->store)
+		return -EIO;
+
+	return ssattr->store(seg, ssattr, buf, count);
+}
+
+/**
+ * The sysfs operations structure for a VAS segment.
+ **/
+static const struct sysfs_ops vas_seg_sysfs_ops = {
+	.show = __vas_seg_sysfs_attr_show,
+	.store = __vas_seg_sysfs_attr_store,
+};
+
+/**
+ * Default attributes of a VAS segment.
+ **/
+static ssize_t __show_vas_seg_name(struct vas_seg *seg,
+				   struct vas_seg_sysfs_attr *ssattr,
+				   char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%s", seg->name);
+}
+VAS_SEG_SYSFS_ATTR(name, 0444, __show_vas_seg_name, NULL);
+
+static ssize_t __show_vas_seg_mode(struct vas_seg *seg,
+				   struct vas_seg_sysfs_attr *ssattr,
+				   char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%#03o", seg->mode);
+}
+VAS_SEG_SYSFS_ATTR(mode, 0444, __show_vas_seg_mode, NULL);
+
+static ssize_t __show_vas_seg_user(struct vas_seg *seg,
+				   struct vas_seg_sysfs_attr *ssattr,
+				   char *buf)
+{
+	struct user_namespace *ns = current_user_ns();
+
+	return scnprintf(buf, PAGE_SIZE, "%d", from_kuid(ns, seg->uid));
+}
+VAS_SEG_SYSFS_ATTR(user, 0444, __show_vas_seg_user, NULL);
+
+static ssize_t __show_vas_seg_group(struct vas_seg *seg,
+				    struct vas_seg_sysfs_attr *ssattr,
+				    char *buf)
+{
+	struct user_namespace *ns = current_user_ns();
+
+	return scnprintf(buf, PAGE_SIZE, "%d", from_kgid(ns, seg->gid));
+}
+VAS_SEG_SYSFS_ATTR(group, 0444, __show_vas_seg_group, NULL);
+
+static ssize_t __show_vas_seg_region(struct vas_seg *seg,
+				     struct vas_seg_sysfs_attr *ssattr,
+				     char *buf)
+{
+	return scnprintf(buf, PAGE_SIZE, "%lx-%lx", seg->start, seg->end);
+}
+VAS_SEG_SYSFS_ATTR(region, 0444, __show_vas_seg_region, NULL);
+
+static struct attribute *vas_seg_default_attr[] = {
+	&vas_seg_sysfs_attr_name.attr,
+	&vas_seg_sysfs_attr_mode.attr,
+	&vas_seg_sysfs_attr_user.attr,
+	&vas_seg_sysfs_attr_group.attr,
+	&vas_seg_sysfs_attr_region.attr,
+	NULL
+};
+
+/**
+ * Function to release the VAS segment after its kobject is gone.
+ **/
+static void __vas_seg_release(struct kobject *kobj)
+{
+	struct vas_seg *seg = container_of(kobj, struct vas_seg, kobj);
+
+	/* Give up the ID in the IDR that was occupied by this VAS segment. */
+	spin_lock(&vas_segs_lock);
+	idr_remove(&vas_segs, seg->id);
+	spin_unlock(&vas_segs_lock);
+
+	/*
+	 * Wait a full RCU grace period before actually deleting the VAS segment
+	 * data structure since we haven't done it earlier.
+	 */
+	call_rcu(&seg->rcu, __delete_vas_seg_rcu);
+}
+
+/**
+ * The ktype data structure representing a VAS segment.
+ **/
+static struct kobj_type vas_seg_ktype = {
+	.sysfs_ops = &vas_seg_sysfs_ops,
+	.release = __vas_seg_release,
+	.default_attrs = vas_seg_default_attr,
+};
+
 
 /***
  * Internally visible functions
@@ -526,8 +722,99 @@ static inline struct vas *vas_lookup_by_name(const char *name)
 	return vas;
 }
 
+/**
+ * Working with the global VAS segments list.
+ **/
+static inline void vas_seg_remove(struct vas_seg *seg)
+{
+	spin_lock(&vas_segs_lock);
+
+	/*
+	 * We only put a to-be-deleted place holder in the IDR at this point.
+	 * See @vas_remove for more details.
+	 */
+	idr_replace(&vas_segs, INVALID_VAS_SEG, seg->id);
+	spin_unlock(&vas_segs_lock);
+
+	/* No need to wait for grace period. See @vas_remove why. */
+	__vas_seg_put(seg);
+}
+
+static inline int vas_seg_insert(struct vas_seg *seg)
+{
+	int ret;
+
+	/* Add the VAS segment in the IDR cache. */
+	spin_lock(&vas_segs_lock);
+
+	ret = idr_alloc(&vas_segs, seg, 1, VAS_MAX_ID, GFP_KERNEL);
+
+	spin_unlock(&vas_segs_lock);
+
+	if (ret < 0) {
+		__delete_vas_seg(seg);
+		return ret;
+	}
+
+	/* Add the remaining data to the VAS segment's data structure. */
+	seg->id = ret;
+	seg->kobj.kset = vas_segs_kset;
+
+	/* Initialize the kobject and add it to the sysfs. */
+	ret = kobject_init_and_add(&seg->kobj, &vas_seg_ktype, NULL,
+				   "%d", seg->id);
+	if (ret != 0) {
+		vas_seg_remove(seg);
+		return ret;
+	}
+
+	kobject_uevent(&seg->kobj, KOBJ_ADD);
+
+	return 0;
+}
+
+static inline struct vas_seg *vas_seg_lookup(int id)
+{
+	struct vas_seg *seg;
+
+	rcu_read_lock();
+
+	seg = idr_find(&vas_segs, id);
+	if (seg == INVALID_VAS_SEG)
+		seg = NULL;
+	if (seg)
+		seg = __vas_seg_get(seg);
+
+	rcu_read_unlock();
+
+	return seg;
+}
+
+static inline struct vas_seg *vas_seg_lookup_by_name(const char *name)
+{
+	struct vas_seg *seg;
+	int id;
+
+	rcu_read_lock();
+
+	idr_for_each_entry(&vas_segs, seg, id) {
+		if (seg == INVALID_VAS_SEG)
+			continue;
+
+		if (strcmp(seg->name, name) == 0)
+			break;
+	}
+
+	if (seg)
+		seg = __vas_seg_get(seg);
+
+	rcu_read_unlock();
+
+	return seg;
+}
+
  /**
-  * Management of the sharing of VAS.
+  * Management of the sharing of VAS and VAS segments.
   **/
 static inline int vas_take_share(int type, struct vas *vas)
 {
@@ -562,6 +849,39 @@ static inline void vas_put_share(int type, struct vas *vas)
 	spin_unlock(&vas->share_lock);
 }
 
+static inline int vas_seg_take_share(int type, struct vas_seg *seg)
+{
+	int ret;
+
+	spin_lock(&seg->share_lock);
+	if (type & MAY_WRITE) {
+		if ((seg->sharing & VAS_SHARE_READ_WRITE_MASK) == 0) {
+			seg->sharing += VAS_SHARE_WRITABLE;
+			ret = 1;
+		} else
+			ret = 0;
+	} else {
+		if ((seg->sharing & VAS_SHARE_WRITE_MASK) == 0) {
+			seg->sharing += VAS_SHARE_READABLE;
+			ret = 1;
+		} else
+			ret = 0;
+	}
+	spin_unlock(&seg->share_lock);
+
+	return ret;
+}
+
+static inline void vas_seg_put_share(int type, struct vas_seg *seg)
+{
+	spin_lock(&seg->share_lock);
+	if (type & MAY_WRITE)
+		seg->sharing -= VAS_SHARE_WRITABLE;
+	else
+		seg->sharing -= VAS_SHARE_READABLE;
+	spin_unlock(&seg->share_lock);
+}
+
 /**
  * Management of the memory maps.
  **/
@@ -609,6 +929,59 @@ static int init_att_vas_mm(struct att_vas *avas, struct task_struct *owner)
 	return 0;
 }
 
+static int init_vas_seg_mm(struct vas_seg *seg)
+{
+	struct mm_struct *mm;
+	unsigned long map_flags, page_prot_flags;
+	vm_flags_t vm_flags;
+	unsigned long map_addr;
+	int ret;
+
+	mm = mm_alloc();
+	if (!mm)
+		return -ENOMEM;
+
+	mm = mm_setup(mm);
+	if (!mm)
+		return -ENOMEM;
+
+	arch_pick_mmap_layout(mm);
+
+	map_flags = MAP_ANONYMOUS | MAP_FIXED;
+	page_prot_flags = PROT_READ | PROT_WRITE;
+	vm_flags = calc_vm_prot_bits(page_prot_flags, 0) |
+		calc_vm_flag_bits(map_flags) | mm->def_flags |
+		VM_DONTEXPAND | VM_DONTCOPY;
+
+	/* Find the possible mapping address for the VAS segment. */
+	map_addr = get_unmapped_area(mm, NULL, seg->start, seg->length,
+				     0, map_flags);
+	if (map_addr != seg->start) {
+		ret = -EFAULT;
+		goto out_free;
+	}
+
+	/* Insert the mapping into the mm_struct of the VAS segment. */
+	map_addr = mmap_region(mm, NULL, seg->start, seg->length,
+			       vm_flags, 0);
+	if (map_addr != seg->start) {
+		ret = -EFAULT;
+		goto out_free;
+	}
+
+	/* Populate the VAS segments memory region. */
+	mm_populate(mm, seg->start, seg->length);
+
+	/* The mm_struct is properly setup. We are done here. */
+	seg->mm = mm;
+
+	return 0;
+
+out_free:
+	mmput(mm);
+	return ret;
+}
+
 /**
  * Lookup the corresponding vm_area in the referenced memory map.
  *
@@ -1126,61 +1499,200 @@ static int task_unmerge(struct att_vas *avas, struct task_struct *tsk)
 }
 
 /**
- * Attach a VAS to a task -- update internal information ONLY
+ * Merge a VAS segment's memory map into a VAS memory map.
  *
- * Requires that the VAS is already locked.
+ * Requires that the VAS and the VAS segment is already locked.
  *
- * @param[in] avas:	The pointer to the attached-VAS data structure
- *			containing all the information of this attaching.
- * @param[in] tsk:	The pointer to the task to which the VAS should be
- *			attached.
- * @param[in] vas:	The pointer to the VAS which should be attached.
+ * @param[in] vas:	The pointer to the VAS into which the VAS segment should
+ *			be merged.
+ * @param[in] seg:	The pointer to the VAS segment that should be merged.
+ * @param[in] type:	The type of attaching (see attach_segment for more
+ *			information).
  *
- * @returns:		0 on succes, -ERRNO otherwise.
+ * @returns:		0 on success, -ERRNO otherwise.
  **/
-static int __vas_attach(struct att_vas *avas, struct task_struct *tsk,
-			struct vas *vas)
+static int vas_seg_merge(struct vas *vas, struct vas_seg *seg, int type)
 {
+	struct vm_area_struct *vma, *new_vma;
+	struct mm_struct *vas_mm, *seg_mm;
 	int ret;
 
-	/* Before doing anything, synchronize the RSS-stat of the task. */
-	sync_mm_rss(tsk->mm);
+	vas_mm = vas->mm;
+	seg_mm = seg->mm;
 
-	/*
-	 * Try to acquire the VAS share with the proper type. This will ensure
-	 * that the different sharing possibilities of VAS are respected.
-	 */
-	if (!vas_take_share(avas->type, vas)) {
-		pr_vas_debug("VAS is already attached exclusively\n");
-		return -EBUSY;
-	}
+	dump_memory_map("Before VAS MM", vas_mm);
+	dump_memory_map("Before VAS segment MM", seg_mm);
 
-	ret = vas_merge(avas, vas, avas->type);
-	if (ret != 0)
-		goto out_put_share;
+	if (down_write_killable(&vas_mm->mmap_sem))
+		return -EINTR;
+	down_read_nested(&seg_mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
-	ret = task_merge(avas, tsk);
-	if (ret != 0)
-		goto out_put_share;
+	/* Try to copy all VMAs of the VAS into the AS of the attached-VAS. */
+	for (vma = seg_mm->mmap; vma; vma = vma->vm_next) {
+		unsigned long merged_vm_flags = vma->vm_flags;
 
-	vas->refcount++;
+		pr_vas_debug("Merging a VAS segment memory region (%#lx - %#lx)\n",
+			     vma->vm_start, vma->vm_end);
 
-	return 0;
+		/*
+		 * Remove the writable bit from the vm_flags if the VAS segment
+		 * is attached only readable.
+		 */
+		if (!(type & MAY_WRITE))
+			merged_vm_flags &= ~(VM_WRITE | VM_MAYWRITE);
 
-out_put_share:
-	vas_put_share(avas->type, vas);
-	return ret;
-}
+		new_vma = __copy_vm_area(seg_mm, vma, vas_mm, merged_vm_flags);
+		if (!new_vma) {
+			pr_vas_debug("Failed to merge a VAS segment memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+			ret = -EFAULT;
+			goto out_unlock;
+		}
 
-/**
- * Detach a VAS from a task -- update internal information ONLY
- *
- * Requires that the VAS is already locked.
- *
- * @param[in] avas:	The pointer to the attached-VAS data structure
- *			containing all the information of this attaching.
- * @param[in] tsk:	The pointer to the task from which the VAS should be
- *			detached.
+		/*
+		 * Remember for the VMA that we just added it to the VAS that it
+		 * actually belongs to the VAS segment.
+		 */
+		new_vma->vas_reference = seg_mm;
+	}
+
+	ret = 0;
+
+out_unlock:
+	up_read(&seg_mm->mmap_sem);
+	up_write(&vas_mm->mmap_sem);
+
+	dump_memory_map("After VAS MM", vas_mm);
+	dump_memory_map("After VAS segment MM", seg_mm);
+
+	return ret;
+}
+
+/**
+ * Unmerge the VAS segment-related parts of a VAS' memory map back into the
+ * VAS segment's memory map.
+ *
+ * Requires that the VAS and the VAS segment are already locked.
+ *
+ * @param[in] vas:	The pointer to the VAS from which the VAS segment
+ *			related data should be taken.
+ * @param[in] seg:	The pointer to the VAS segment for which the memory map
+ *			should be updated again.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int vas_seg_unmerge(struct vas *vas, struct vas_seg *seg)
+{
+	struct vm_area_struct *vma, *next;
+	struct mm_struct *vas_mm, *seg_mm;
+	int ret;
+
+	vas_mm = vas->mm;
+	seg_mm = seg->mm;
+
+	dump_memory_map("Before VAS MM", vas_mm);
+	dump_memory_map("Before VAS segment MM", seg_mm);
+
+	if (down_write_killable(&vas_mm->mmap_sem))
+		return -EINTR;
+	down_write_nested(&seg_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	/* Update all memory regions which belonged to the VAS segment. */
+	for (vma = vas_mm->mmap, next = next_vma_safe(vma); vma;
+	     vma = next, next = next_vma_safe(next)) {
+		struct mm_struct *ref_mm = vma->vas_reference;
+
+		if (ref_mm != seg_mm) {
+			pr_vas_debug("Skipping memory region (%#lx - %#lx) during VAS segment unmerging\n",
+				     vma->vm_start, vma->vm_end);
+			continue;
+		} else {
+			struct vm_area_struct *upd_vma;
+
+			pr_vas_debug("Unmerging a VAS segment memory region (%#lx - %#lx)\n",
+				     vma->vm_start, vma->vm_end);
+
+			upd_vma = __update_vm_area(vas_mm, vma, seg_mm, NULL);
+			if (!upd_vma) {
+				pr_vas_debug("Failed to unmerge a VAS segment memory region (%#lx - %#lx)\n",
+					     vma->vm_start, vma->vm_end);
+				ret = -EFAULT;
+				goto out_unlock;
+			}
+		}
+
+		/* Remove the current VMA from the VAS memory map. */
+		__remove_vm_area(vas_mm, vma);
+	}
+
+	ret = 0;
+
+out_unlock:
+	up_write(&seg_mm->mmap_sem);
+	up_write(&vas_mm->mmap_sem);
+
+	dump_memory_map("After VAS MM", vas_mm);
+	dump_memory_map("After VAS segment MM", seg_mm);
+
+	return ret;
+}
+
+/**
+ * Attach a VAS to a task -- update internal information ONLY
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure
+ *			containing all the information of this attaching.
+ * @param[in] tsk:	The pointer to the task to which the VAS should be
+ *			attached.
+ * @param[in] vas:	The pointer to the VAS which should be attached.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int __vas_attach(struct att_vas *avas, struct task_struct *tsk,
+			struct vas *vas)
+{
+	int ret;
+
+	/* Before doing anything, synchronize the RSS-stat of the task. */
+	sync_mm_rss(tsk->mm);
+
+	/*
+	 * Try to acquire the VAS share with the proper type. This will ensure
+	 * that the different sharing possibilities of VAS are respected.
+	 */
+	if (!vas_take_share(avas->type, vas)) {
+		pr_vas_debug("VAS is already attached exclusively\n");
+		return -EBUSY;
+	}
+
+	ret = vas_merge(avas, vas, avas->type);
+	if (ret != 0)
+		goto out_put_share;
+
+	ret = task_merge(avas, tsk);
+	if (ret != 0)
+		goto out_put_share;
+
+	vas->refcount++;
+
+	return 0;
+
+out_put_share:
+	vas_put_share(avas->type, vas);
+	return ret;
+}
+
+/**
+ * Detach a VAS from a task -- update internal information ONLY
+ *
+ * Requires that the VAS is already locked.
+ *
+ * @param[in] avas:	The pointer to the attached-VAS data structure
+ *			containing all the information of this attaching.
+ * @param[in] tsk:	The pointer to the task from which the VAS should be
+ *			detached.
  * @param[in] vas:	The pointer to the VAS which should be detached.
  *
  * @returns:		0 on success, -ERRNO otherwise.
@@ -1209,6 +1721,83 @@ static int __vas_detach(struct att_vas *avas, struct task_struct *tsk,
 	return 0;
 }
 
+/**
+ * Attach a VAS segment to a VAS -- update internal information ONLY
+ *
+ * Requires that the VAS segment and the VAS are already locked.
+ *
+ * @param aseg:		The pointer tot he attached VAS segment data structure
+ *			containing all the information of this attaching.
+ * @param vas:		The pointer to the VAS to which the VAS segment should
+ *			be attached.
+ * @param seg:		The pointer to the VAS segment which should be attached.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int __vas_seg_attach(struct att_vas_seg *aseg, struct vas *vas,
+			   struct vas_seg *seg)
+{
+	int ret;
+
+	/*
+	 * Try to acquire the VAS segment share with the proper type. This will
+	 * ensure that the different sharing possibilities of VAS segments are
+	 * respected.
+	 */
+	if (!vas_seg_take_share(aseg->type, seg)) {
+		pr_vas_debug("VAS segment is already attached to a VAS writable\n");
+		return -EBUSY;
+	}
+
+	/* Update the memory map of the VAS. */
+	ret = vas_seg_merge(vas, seg, aseg->type);
+	if (ret != 0)
+		goto out_put_share;
+
+	seg->refcount++;
+	vas->nr_segments++;
+
+	return 0;
+
+out_put_share:
+	vas_seg_put_share(aseg->type, seg);
+	return ret;
+}
+
+/**
+ * Detach a VAS segment from a VAS -- update internal information ONLY
+ *
+ * Requires that the VAS segment and the VAS are already locked.
+ *
+ * @param aseg:		The pointer to the attached VAS segment data structure
+ *			containing all the information of this attaching.
+ * @param vas:		The pointer to the VAS from which the VAS segment should
+ *			be detached.
+ * @param seg:		The pointer to the VAS segment which should be detached.
+ *
+ * @returns:		0 on success, -ERRNO otherwise.
+ **/
+static int __vas_seg_detach(struct att_vas_seg *aseg, struct vas *vas,
+			    struct vas_seg *seg)
+{
+	int ret;
+
+	/* Update the memory maps of the VAS segment and the VAS. */
+	ret = vas_seg_unmerge(vas, seg);
+	if (ret != 0)
+		return ret;
+
+	seg->refcount--;
+	vas->nr_segments--;
+
+	/*
+	 * We unlock the VAS segment here to ensure our sharing properties.
+	 */
+	vas_seg_put_share(aseg->type, seg);
+
+	return 0;
+}
+
 static int __sync_from_task(struct mm_struct *avas_mm, struct mm_struct *tsk_mm)
 {
 	struct vm_area_struct *vma;
@@ -1542,6 +2131,9 @@ int vas_create(const char *name, umode_t mode)
 	spin_lock_init(&vas->share_lock);
 	vas->sharing = 0;
 
+	INIT_LIST_HEAD(&vas->segments);
+	vas->nr_segments = 0;
+
 	vas->mode = mode & 0666;
 	vas->uid = current_uid();
 	vas->gid = current_gid();
@@ -1596,6 +2188,7 @@ EXPORT_SYMBOL(vas_find);
 int vas_delete(int vid)
 {
 	struct vas *vas;
+	struct att_vas_seg *aseg, *s_aseg;
 	int ret;
 
 	vas = vas_get(vid);
@@ -1618,6 +2211,39 @@ int vas_delete(int vid)
 		goto out_unlock;
 	}
 
+	/* Detach all still attached VAS segments. */
+	list_for_each_entry_safe(aseg, s_aseg, &vas->segments, vas_link) {
+		struct vas_seg *seg = aseg->seg;
+		int error;
+
+		pr_vas_debug("Detaching VAS segment - name: %s - from to-be-deleted VAS - name: %s\n",
+			     seg->name, vas->name);
+
+		/*
+		 * Make sure that our VAS segment reference is not removed while
+		 * we work with it.
+		 */
+		__vas_seg_get(seg);
+
+		/*
+		 * Since the VAS from which we detach this VAS segment is going
+		 * to be deleted anyways we can shorten the detaching process.
+		 */
+		vas_seg_lock(seg);
+
+		error = __vas_seg_detach(aseg, vas, seg);
+		if (error != 0)
+			pr_alert("Detaching VAS segment from VAS failed with %d\n",
+				 error);
+
+		list_del(&aseg->seg_link);
+		list_del(&aseg->vas_link);
+		__delete_att_vas_seg(aseg);
+
+		vas_seg_unlock(seg);
+		__vas_seg_put(seg);
+	}
+
 	vas_unlock(vas);
 
 	vas_remove(vas);
@@ -1908,19 +2534,433 @@ int vas_setattr(int vid, struct vas_attr *attr)
 }
 EXPORT_SYMBOL(vas_setattr);
 
+int vas_seg_create(const char *name, unsigned long start, unsigned long end,
+		   umode_t mode)
+{
+	struct vas_seg *seg;
+	int ret;
+
+	if (!name || !PAGE_ALIGNED(start) || !PAGE_ALIGNED(end) ||
+	    (end <= start))
+		return -EINVAL;
+
+	if (vas_seg_find(name) > 0)
+		return -EEXIST;
+
+	pr_vas_debug("Creating a new VAS segment - name: %s start: %#lx end: %#lx\n",
+		     name, start, end);
+
+	/* Allocate and initialize the VAS segment. */
+	seg = __new_vas_seg();
+	if (!seg)
+		return -ENOMEM;
+
+	if (strscpy(seg->name, name, VAS_MAX_NAME_LENGTH) < 0) {
+		ret = -EINVAL;
+		goto out_free;
+	}
+
+	mutex_init(&seg->mtx);
+
+	seg->start = start;
+	seg->end = end;
+	seg->length = end - start;
+
+	ret = init_vas_seg_mm(seg);
+	if (ret != 0)
+		goto out_free;
+
+	seg->refcount = 0;
+
+	INIT_LIST_HEAD(&seg->attaches);
+	spin_lock_init(&seg->share_lock);
+	seg->sharing = 0;
+
+	seg->mode = mode & 0666;
+	seg->uid = current_uid();
+	seg->gid = current_gid();
+
+	ret = vas_seg_insert(seg);
+	if (ret != 0)
+		/*
+		 * We don't need to free anything here. @vas_seg_insert will
+		 * care for the deletion if something went wrong.
+		 */
+		return ret;
+
+	return seg->id;
+
+out_free:
+	__delete_vas_seg(seg);
+	return ret;
+}
+EXPORT_SYMBOL(vas_seg_create);
+
+struct vas_seg *vas_seg_get(int sid)
+{
+	return vas_seg_lookup(sid);
+}
+EXPORT_SYMBOL(vas_seg_get);
+
+void vas_seg_put(struct vas_seg *seg)
+{
+	if (!seg)
+		return;
+
+	return __vas_seg_put(seg);
+}
+EXPORT_SYMBOL(vas_seg_put);
+
+int vas_seg_find(const char *name)
+{
+	struct vas_seg *seg;
+
+	seg = vas_seg_lookup_by_name(name);
+	if (seg) {
+		int sid = seg->id;
+
+		vas_seg_put(seg);
+		return sid;
+	}
+
+	return -ESRCH;
+}
+EXPORT_SYMBOL(vas_seg_find);
+
+int vas_seg_delete(int id)
+{
+	struct vas_seg *seg;
+	int ret;
+
+	seg = vas_seg_get(id);
+	if (!seg)
+		return -EINVAL;
+
+	pr_vas_debug("Deleting VAS segment - name: %s\n", seg->name);
+
+	vas_seg_lock(seg);
+
+	if (seg->refcount != 0) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/* The user needs write permission to the VAS segment to delete it. */
+	ret = __check_permission(seg->uid, seg->gid, seg->mode, MAY_WRITE);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to delete the VAS segment\n");
+		goto out_unlock;
+	}
+
+	vas_seg_unlock(seg);
+
+	vas_seg_remove(seg);
+	vas_seg_put(seg);
+
+	return 0;
+
+out_unlock:
+	vas_seg_unlock(seg);
+	vas_seg_put(seg);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_seg_delete);
+
+int vas_seg_attach(int vid, int sid, int type)
+{
+	struct vas *vas;
+	struct vas_seg *seg;
+	struct att_vas_seg *aseg;
+	int ret;
+
+	type &= (MAY_READ | MAY_WRITE);
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	seg = vas_seg_get(sid);
+	if (!seg) {
+		vas_put(vas);
+		return -EINVAL;
+	}
+
+	pr_vas_debug("Attaching VAS segment - name: %s - to VAS - name: %s - %s\n",
+		     seg->name, vas->name, access_type_str(type));
+
+	vas_lock(vas);
+	vas_seg_lock(seg);
+
+	/*
+	 * Before we can attach the VAS segment to the VAS we have to make some
+	 * sanity checks.
+	 */
+
+	/*
+	 * 1: Check that the user has adequate permissions to attach the VAS
+	 * segment in the given way.
+	 */
+	ret = __check_permission(seg->uid, seg->gid, seg->mode, type);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to attach the VAS segment\n");
+		goto out_unlock;
+	}
+
+	/*
+	 * 2: The user needs write permission to the VAS to attach a VAS segment
+	 * to it. Check that this requirement is fulfilled.
+	 */
+	ret = __check_permission(vas->uid, vas->gid, vas->mode, MAY_WRITE);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions on the VAS to attach the VAS segment\n");
+		goto out_unlock;
+	}
+
+
+	/*
+	 * 3: Check if the VAS is attached to a process. We do not support
+	 * changes to an attached VAS. A VAS must not be attached to a process
+	 * to be able to make changes to it. This ensures that the page tables
+	 * are always properly initialized.
+	 */
+	if (vas->refcount != 0) {
+		pr_vas_debug("VAS is attached to a process\n");
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * 4: Check if the VAS segment is already attached to this particular
+	 * VAS. Double-attaching would lead to unintended behavior.
+	 */
+	list_for_each_entry(aseg, &seg->attaches, seg_link) {
+		if (aseg->vas == vas) {
+			pr_vas_debug("VAS segment is already attached to the VAS\n");
+			ret = 0;
+			goto out_unlock;
+		}
+	}
+
+	/* 5: Check if we reached the maximum number of shares for this VAS. */
+	if (seg->refcount == VAS_MAX_SHARES) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * All sanity checks are done. It is safe to attach this VAS segment to
+	 * the VAS now.
+	 */
+
+	/* Allocate and initialize the attached VAS segment data structure. */
+	aseg = __new_att_vas_seg();
+	if (!aseg) {
+		ret = -ENOMEM;
+		goto out_unlock;
+	}
+
+	aseg->seg = seg;
+	aseg->vas = vas;
+	aseg->type = type;
+
+	ret = __vas_seg_attach(aseg, vas, seg);
+	if (ret != 0)
+		goto out_free_aseg;
+
+	list_add(&aseg->vas_link, &vas->segments);
+	list_add(&aseg->seg_link, &seg->attaches);
+
+	ret = 0;
+
+out_unlock:
+	vas_seg_unlock(seg);
+	vas_seg_put(seg);
+
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return ret;
+
+out_free_aseg:
+	__delete_att_vas_seg(aseg);
+	goto out_unlock;
+}
+EXPORT_SYMBOL(vas_seg_attach);
+
+int vas_seg_detach(int vid, int sid)
+{
+	struct vas *vas;
+	struct vas_seg *seg;
+	struct att_vas_seg *aseg;
+	bool is_attached;
+	int ret;
+
+	vas = vas_get(vid);
+	if (!vas)
+		return -EINVAL;
+
+	vas_lock(vas);
+
+	is_attached = false;
+	list_for_each_entry(aseg, &vas->segments, vas_link) {
+		if (aseg->seg->id == sid) {
+			is_attached = true;
+			break;
+		}
+	}
+	if (!is_attached) {
+		pr_vas_debug("VAS segment is not attached to the given VAS\n");
+		ret = -EINVAL;
+		goto out_unlock_vas;
+	}
+
+	seg = aseg->seg;
+
+	/*
+	 * Make sure that our reference to the VAS segment is not deleted while
+	 * we are working with it.
+	 */
+	__vas_seg_get(seg);
+
+	vas_seg_lock(seg);
+
+	pr_vas_debug("Detaching VAS segment - name: %s - from VAS - name: %s\n",
+		     seg->name, vas->name);
+
+	/*
+	 * Before we can detach the VAS segment from the VAS we have to do some
+	 * sanity checks.
+	 */
+
+	/*
+	 * 1: Check if the VAS is attached to a process. We do not support
+	 * changes to an attached VAS. A VAS must not be attached to a process
+	 * to be able to make changes to it. This ensures that the page tables
+	 * are always properly initialized.
+	 */
+	if (vas->refcount != 0) {
+		pr_vas_debug("VAS is attached to a process\n");
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * All sanity checks are done. It is safe to detach the VAS segment from
+	 * the VAS now.
+	 */
+	ret = __vas_seg_detach(aseg, vas, seg);
+	if (ret != 0)
+		goto out_unlock;
+
+	list_del(&aseg->seg_link);
+	list_del(&aseg->vas_link);
+	__delete_att_vas_seg(aseg);
+
+	ret = 0;
+
+out_unlock:
+	vas_seg_unlock(seg);
+	__vas_seg_put(seg);
+
+out_unlock_vas:
+	vas_unlock(vas);
+	vas_put(vas);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_seg_detach);
+
+int vas_seg_getattr(int sid, struct vas_seg_attr *attr)
+{
+	struct vas_seg *seg;
+	struct user_namespace *ns = current_user_ns();
+
+	if (!attr)
+		return -EINVAL;
+
+	seg = vas_seg_get(sid);
+	if (!seg)
+		return -EINVAL;
+
+	pr_vas_debug("Getting attributes for VAS segment - name: %s\n",
+		     seg->name);
+
+	vas_seg_lock(seg);
+
+	memset(attr, 0, sizeof(struct vas_seg_attr));
+	attr->mode = seg->mode;
+	attr->user = from_kuid(ns, seg->uid);
+	attr->group = from_kgid(ns, seg->gid);
+
+	vas_seg_unlock(seg);
+	vas_seg_put(seg);
+
+	return 0;
+}
+EXPORT_SYMBOL(vas_seg_getattr);
+
+int vas_seg_setattr(int sid, struct vas_seg_attr *attr)
+{
+	struct vas_seg *seg;
+	struct user_namespace *ns = current_user_ns();
+	int ret;
+
+	if (!attr)
+		return -EINVAL;
+
+	seg = vas_seg_get(sid);
+	if (!seg)
+		return -EINVAL;
+
+	pr_vas_debug("Setting attributes for VAS segment - name: %s\n",
+		     seg->name);
+
+	vas_seg_lock(seg);
+
+	/*
+	 * The user needs write permission to change attributes for the
+	 * VAS segment.
+	 */
+	ret = __check_permission(seg->uid, seg->gid, seg->mode, MAY_WRITE);
+	if (ret != 0) {
+		pr_vas_debug("User doesn't have the appropriate permissions to set attributes for the VAS segment\n");
+		goto out_unlock;
+	}
+
+	seg->mode = attr->mode & 0666;
+	seg->uid = make_kuid(ns, attr->user);
+	seg->gid = make_kgid(ns, attr->group);
+
+	ret = 0;
+
+out_unlock:
+	vas_seg_unlock(seg);
+	vas_seg_put(seg);
+
+	return ret;
+}
+EXPORT_SYMBOL(vas_seg_setattr);
+
 void __init vas_init(void)
 {
 	/* Create the SLAB caches for our data structures. */
 	vas_cachep = KMEM_CACHE(vas, SLAB_PANIC|SLAB_NOTRACK);
 	att_vas_cachep = KMEM_CACHE(att_vas, SLAB_PANIC|SLAB_NOTRACK);
 	vas_context_cachep = KMEM_CACHE(vas_context, SLAB_PANIC|SLAB_NOTRACK);
+	seg_cachep = KMEM_CACHE(vas_seg, SLAB_PANIC|SLAB_NOTRACK);
+	att_seg_cachep = KMEM_CACHE(att_vas_seg, SLAB_PANIC|SLAB_NOTRACK);
 
 	/* Initialize the internal management data structures. */
 	idr_init(&vases);
 	spin_lock_init(&vases_lock);
 
+	idr_init(&vas_segs);
+	spin_lock_init(&vas_segs_lock);
+
 	/* Initialize the place holder variables. */
 	INVALID_VAS = __new_vas();
+	INVALID_VAS_SEG = __new_vas_seg();
 
 	/* Initialize the VAS context of the init task. */
 	vas_clone(0, &init_task);
@@ -1941,6 +2981,12 @@ static int __init vas_sysfs_init(void)
 		return -ENOMEM;
 	}
 
+	vas_segs_kset = kset_create_and_add("vas_segs", NULL, kernel_kobj);
+	if (!vas_segs_kset) {
+		pr_err("Failed to initialize the VAS segment sysfs directory\n");
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 postcore_initcall(vas_sysfs_init);
@@ -2186,3 +3232,105 @@ SYSCALL_DEFINE2(vas_setattr, int, vid, struct vas_attr __user *, uattr)
 
 	return vas_setattr(vid, &attr);
 }
+
+SYSCALL_DEFINE4(vas_seg_create, const char __user *, name, unsigned long, begin,
+		unsigned long, end, umode_t, mode)
+{
+	char seg_name[VAS_MAX_NAME_LENGTH];
+	int len;
+
+	if (!name)
+		return -EINVAL;
+
+	len = strlen(name);
+	if (len >= VAS_MAX_NAME_LENGTH)
+		return -EINVAL;
+
+	if (copy_from_user(seg_name, name, len) != 0)
+		return -EFAULT;
+
+	seg_name[len] = '\0';
+
+	return vas_seg_create(seg_name, begin, end, mode);
+}
+
+SYSCALL_DEFINE1(vas_seg_delete, int, id)
+{
+	if (id < 0)
+		return -EINVAL;
+
+	return vas_seg_delete(id);
+}
+
+SYSCALL_DEFINE1(vas_seg_find, const char __user *, name)
+{
+	char seg_name[VAS_MAX_NAME_LENGTH];
+	int len;
+
+	if (!name)
+		return -EINVAL;
+
+	len = strlen(name);
+	if (len >= VAS_MAX_NAME_LENGTH)
+		return -EINVAL;
+
+	if (copy_from_user(seg_name, name, len) != 0)
+		return -EFAULT;
+
+	seg_name[len] = '\0';
+
+	return vas_seg_find(seg_name);
+}
+
+SYSCALL_DEFINE3(vas_seg_attach, int, vid, int, sid, int, type)
+{
+	int vas_acc_type;
+
+	if (vid < 0 || sid < 0)
+		return -EINVAL;
+
+	vas_acc_type = __build_vas_access_type(type);
+	if (vas_acc_type == -1)
+		return -EINVAL;
+
+	return vas_seg_attach(vid, sid, vas_acc_type);
+}
+
+SYSCALL_DEFINE2(vas_seg_detach, int, vid, int, sid)
+{
+	if (vid < 0 || sid < 0)
+		return -EINVAL;
+
+	return vas_seg_detach(vid, sid);
+}
+
+SYSCALL_DEFINE2(vas_seg_getattr, int, sid, struct vas_seg_attr __user *, uattr)
+{
+	struct vas_seg_attr attr;
+	int ret;
+
+	if (sid < 0 || !uattr)
+		return -EINVAL;
+
+	ret = vas_seg_getattr(sid, &attr);
+	if (ret != 0)
+		return ret;
+
+	if (copy_to_user(uattr, &attr, sizeof(struct vas_seg_attr)) != 0)
+		return -EFAULT;
+
+	return 0;
+}
+
+SYSCALL_DEFINE2(vas_seg_setattr, int, sid, struct vas_seg_attr __user *, uattr)
+{
+	struct vas_seg_attr attr;
+
+	if (sid < 0 || !uattr)
+		return -EINVAL;
+
+	if (copy_from_user(&attr, uattr, sizeof(struct vas_seg_attr)) != 0)
+		return -EFAULT;
+
+	return vas_seg_setattr(sid, &attr);
+}
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
