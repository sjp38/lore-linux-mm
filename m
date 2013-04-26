Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 7C6D26B0002
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 00:35:29 -0400 (EDT)
Date: Fri, 26 Apr 2013 00:35:12 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366950912-u5c1huyl-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1366923617-dvp2vbsx-mutt-n-horiguchi@ah.jp.nec.com>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
 <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424153951.GQ2018@cmpxchg.org>
 <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
 <20130424232600.GB18686@cmpxchg.org>
 <1366923617-dvp2vbsx-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] hugetlbfs: fix mmap failure in unaligned size request
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>, Jianguo Wu <wujianguo@huawei.com>

Here is a revised patch.
Thank you for the nice feedback, Johannes, Jianguo.
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 26 Apr 2013 00:31:18 -0400
Subject: [PATCH v2] hugetlbfs: fix mmap failure in unaligned size request

As reported in https://bugzilla.kernel.org/show_bug.cgi?id=56881, current
kernel returns -EINVAL unless a given mmap length is "almost" hugepage
aligned. This is because in sys_mmap_pgoff() the given length is passed to
vm_mmap_pgoff() as it is without being aligned with hugepage boundary.

This is a regression introduced in commit 40716e29243d "hugetlbfs: fix
alignment of huge page requests", where alignment code is pushed into
hugetlb_file_setup() and the variable len in caller side is not changed.

To fix this, this patch partially reverts that commit, and adds alignment
code in caller side. And it also introduces hstate_sizelog() in order to
get proper hstate to specified hugepage size.

ChangeLog v2:
 - introduce hstate_sizelog to calculate alignment in caller side
 - add ALIGN also in file mmap path.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/hugetlbfs/inode.c    | 24 ++++++++++--------------
 include/linux/hugetlb.h | 19 +++++++++++++------
 ipc/shm.c               |  6 +++++-
 mm/mmap.c               |  7 ++++++-
 4 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 523464e..a3f868a 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -909,11 +909,8 @@ static int can_do_hugetlb_shm(void)
 
 static int get_hstate_idx(int page_size_log)
 {
-	struct hstate *h;
+	struct hstate *h = hstate_sizelog(page_size_log);
 
-	if (!page_size_log)
-		return default_hstate_idx;
-	h = size_to_hstate(1 << page_size_log);
 	if (!h)
 		return -1;
 	return h - hstates;
@@ -929,9 +926,12 @@ static struct dentry_operations anon_ops = {
 	.d_dname = hugetlb_dname
 };
 
-struct file *hugetlb_file_setup(const char *name, unsigned long addr,
-				size_t size, vm_flags_t acctflag,
-				struct user_struct **user,
+/*
+ * Note that size should be aligned to proper hugepage size in caller side,
+ * otherwise hugetlb_reserve_pages reserves one less hugepages than intended.
+ */
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				vm_flags_t acctflag, struct user_struct **user,
 				int creat_flags, int page_size_log)
 {
 	struct file *file = ERR_PTR(-ENOMEM);
@@ -939,8 +939,6 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 	struct path path;
 	struct super_block *sb;
 	struct qstr quick_string;
-	struct hstate *hstate;
-	unsigned long num_pages;
 	int hstate_idx;
 
 	hstate_idx = get_hstate_idx(page_size_log);
@@ -980,12 +978,10 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
 	if (!inode)
 		goto out_dentry;
 
-	hstate = hstate_inode(inode);
-	size += addr & ~huge_page_mask(hstate);
-	num_pages = ALIGN(size, huge_page_size(hstate)) >>
-			huge_page_shift(hstate);
 	file = ERR_PTR(-ENOMEM);
-	if (hugetlb_reserve_pages(inode, 0, num_pages, NULL, acctflag))
+	if (hugetlb_reserve_pages(inode, 0,
+			size >> huge_page_shift(hstate_inode(inode)), NULL,
+			acctflag))
 		goto out_inode;
 
 	d_instantiate(path.dentry, inode);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8220a8a..c78f5a2 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -193,8 +193,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 
 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, unsigned long addr,
-				size_t size, vm_flags_t acct,
+struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
 				struct user_struct **user, int creat_flags,
 				int page_size_log);
 
@@ -213,8 +212,8 @@ static inline int is_file_hugepages(struct file *file)
 
 #define is_file_hugepages(file)			0
 static inline struct file *
-hugetlb_file_setup(const char *name, unsigned long addr, size_t size,
-		vm_flags_t acctflag, struct user_struct **user, int creat_flags,
+hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
+		struct user_struct **user, int creat_flags,
 		int page_size_log)
 {
 	return ERR_PTR(-ENOSYS);
@@ -294,6 +293,13 @@ static inline struct hstate *hstate_file(struct file *f)
 	return hstate_inode(file_inode(f));
 }
 
+static inline struct hstate *hstate_sizelog(int page_size_log)
+{
+	if (!page_size_log)
+		return &default_hstate;
+	return size_to_hstate(1 << page_size_log);
+}
+
 static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
 {
 	return hstate_file(vma->vm_file);
@@ -361,12 +367,13 @@ static inline int hstate_index(struct hstate *h)
 extern void dissolve_free_huge_pages(unsigned long start_pfn,
 				     unsigned long end_pfn);
 
-#else
+#else /* !CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page(v, a, r) NULL
 #define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
+#define hstate_sizelog(s) NULL
 #define hstate_vma(v) NULL
 #define hstate_inode(i) NULL
 #define huge_page_size(h) PAGE_SIZE
@@ -382,6 +389,6 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 #define hstate_index_to_shift(index) 0
 #define hstate_index(h) 0
 #define dissolve_free_huge_pages(s, e) 0
-#endif
+#endif /* !CONFIG_HUGETLB_PAGE */
 
 #endif /* _LINUX_HUGETLB_H */
diff --git a/ipc/shm.c b/ipc/shm.c
index cb858df..e316cb9 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -491,10 +491,14 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 
 	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
+		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
+						& SHM_HUGE_MASK);
+		size_t hugesize = ALIGN(size, huge_page_size(hs));
+
 		/* hugetlb_file_setup applies strict accounting */
 		if (shmflg & SHM_NORESERVE)
 			acctflag = VM_NORESERVE;
-		file = hugetlb_file_setup(name, 0, size, acctflag,
+		file = hugetlb_file_setup(name, hugesize, acctflag,
 				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
 				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
 	} else {
diff --git a/mm/mmap.c b/mm/mmap.c
index 2664a47..212721f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1325,15 +1325,20 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		file = fget(fd);
 		if (!file)
 			goto out;
+		if (is_file_hugepages(file))
+			len = ALIGN(len, huge_page_size(hstate_file(file)));
 	} else if (flags & MAP_HUGETLB) {
 		struct user_struct *user = NULL;
+		struct hstate *hs = hstate_sizelog((flags >> MAP_HUGE_SHIFT)
+						& MAP_HUGE_MASK);
+		len = ALIGN(len, huge_page_size(hs));
 		/*
 		 * VM_NORESERVE is used because the reservations will be
 		 * taken when vm_ops->mmap() is called
 		 * A dummy user value is used because we are not locking
 		 * memory so no accounting is necessary
 		 */
-		file = hugetlb_file_setup(HUGETLB_ANON_FILE, addr, len,
+		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len,
 				VM_NORESERVE,
 				&user, HUGETLB_ANONHUGE_INODE,
 				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
