Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E724D6B0003
	for <linux-mm@kvack.org>; Fri,  4 May 2018 17:25:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w7so15151201pfd.9
        for <linux-mm@kvack.org>; Fri, 04 May 2018 14:25:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h16-v6si16792957pli.493.2018.05.04.14.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 14:25:30 -0700 (PDT)
Date: Fri, 4 May 2018 14:25:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 00/17] Rearrange struct page
Message-ID: <20180504212529.GE29829@bombadil.infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504135249.676650d27bb3959838119567@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504135249.676650d27bb3959838119567@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Fri, May 04, 2018 at 01:52:49PM -0700, Andrew Morton wrote:
> On Fri,  4 May 2018 11:33:01 -0700 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > As presented at LSFMM, this patch-set rearranges struct page to give
> > more contiguous usable space to users who have allocated a struct page
> > for their own purposes.
> 
> Are there such users?  Why is this considered useful? etc.

There are!  Several of them in this very patch-set.  For example, the
deferred_list in compound pages, the page tables, ZONE_DEVICE pages, and
vmalloc pages.  Sure, it would have been possible to do some of those
without this rearrangement, but each thing you added to the old struct
page blew up the complexity that someone would have to paw through next
time *they* wanted to add something to struct page.  Now they can look
through and see what each owner uses this storage for, and see where
bits are.

There are some other places in the kernel where we could benefit.
For example, here's a patch I suggested (against an earlier version
of this patchset).  Al demanded performance numbers, which I haven't
collected yet, so it's not part of this submission.


 fs/dcache.c              |    7 ---
 fs/namei.c               |  102 +++++++++++------------------------------------
 include/linux/fs.h       |   26 +++++------
 include/linux/mm_types.h |   12 ++++-
 kernel/auditsc.c         |    8 +--
 5 files changed, 51 insertions(+), 104 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 593079176123..749b82b8fa1c 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -3172,10 +3172,6 @@ static void __init dcache_init(void)
 	d_hash_shift = 32 - d_hash_shift;
 }
 
-/* SLAB cache for __getname() consumers */
-struct kmem_cache *names_cachep __read_mostly;
-EXPORT_SYMBOL(names_cachep);
-
 void __init vfs_caches_init_early(void)
 {
 	int i;
@@ -3189,9 +3185,6 @@ void __init vfs_caches_init_early(void)
 
 void __init vfs_caches_init(void)
 {
-	names_cachep = kmem_cache_create_usercopy("names_cache", PATH_MAX, 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, 0, PATH_MAX, NULL);
-
 	dcache_init();
 	inode_init();
 	files_init();
diff --git a/fs/namei.c b/fs/namei.c
index a09419379f5d..16fb4779d29f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -122,71 +122,46 @@
  * PATH_MAX includes the nul terminator --RR.
  */
 
-#define EMBEDDED_NAME_MAX	(PATH_MAX - offsetof(struct filename, iname))
+struct filename *alloc_filename(void)
+{
+	struct page *page = alloc_page(GFP_KERNEL);
+
+	page->filename.name = page_to_virt(page);
+	return &page->filename;
+}
+
+void putname(struct filename *name)
+{
+	__free_page(container_of(name, struct page, filename));
+}
+
+void filename_get(struct filename *name)
+{
+	page_ref_inc(container_of(name, struct page, filename));
+}
 
 struct filename *
 getname_flags(const char __user *filename, int flags, int *empty)
 {
 	struct filename *result;
-	char *kname;
 	int len;
 
 	result = audit_reusename(filename);
 	if (result)
 		return result;
 
-	result = __getname();
+	result = alloc_filename();
 	if (unlikely(!result))
 		return ERR_PTR(-ENOMEM);
 
-	/*
-	 * First, try to embed the struct filename inside the names_cache
-	 * allocation
-	 */
-	kname = (char *)result->iname;
-	result->name = kname;
-
-	len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
+	len = strncpy_from_user((char *)result->name, filename, PATH_MAX);
+	if (unlikely(len == PATH_MAX))
+		len = -ENAMETOOLONG;
 	if (unlikely(len < 0)) {
-		__putname(result);
+		putname(result);
 		return ERR_PTR(len);
 	}
 
-	/*
-	 * Uh-oh. We have a name that's approaching PATH_MAX. Allocate a
-	 * separate struct filename so we can dedicate the entire
-	 * names_cache allocation for the pathname, and re-do the copy from
-	 * userland.
-	 */
-	if (unlikely(len == EMBEDDED_NAME_MAX)) {
-		const size_t size = offsetof(struct filename, iname[1]);
-		kname = (char *)result;
-
-		/*
-		 * size is chosen that way we to guarantee that
-		 * result->iname[0] is within the same object and that
-		 * kname can't be equal to result->iname, no matter what.
-		 */
-		result = kzalloc(size, GFP_KERNEL);
-		if (unlikely(!result)) {
-			__putname(kname);
-			return ERR_PTR(-ENOMEM);
-		}
-		result->name = kname;
-		len = strncpy_from_user(kname, filename, PATH_MAX);
-		if (unlikely(len < 0)) {
-			__putname(kname);
-			kfree(result);
-			return ERR_PTR(len);
-		}
-		if (unlikely(len == PATH_MAX)) {
-			__putname(kname);
-			kfree(result);
-			return ERR_PTR(-ENAMETOOLONG);
-		}
-	}
-
-	result->refcnt = 1;
 	/* The empty path is special. */
 	if (unlikely(!len)) {
 		if (empty)
@@ -215,49 +190,22 @@ getname_kernel(const char * filename)
 	struct filename *result;
 	int len = strlen(filename) + 1;
 
-	result = __getname();
+	result = alloc_filename();
 	if (unlikely(!result))
 		return ERR_PTR(-ENOMEM);
 
-	if (len <= EMBEDDED_NAME_MAX) {
-		result->name = (char *)result->iname;
-	} else if (len <= PATH_MAX) {
-		struct filename *tmp;
-
-		tmp = kmalloc(sizeof(*tmp), GFP_KERNEL);
-		if (unlikely(!tmp)) {
-			__putname(result);
-			return ERR_PTR(-ENOMEM);
-		}
-		tmp->name = (char *)result;
-		result = tmp;
-	} else {
-		__putname(result);
+	if (len > PATH_MAX) {
+		putname(result);
 		return ERR_PTR(-ENAMETOOLONG);
 	}
 	memcpy((char *)result->name, filename, len);
 	result->uptr = NULL;
 	result->aname = NULL;
-	result->refcnt = 1;
 	audit_getname(result);
 
 	return result;
 }
 
-void putname(struct filename *name)
-{
-	BUG_ON(name->refcnt <= 0);
-
-	if (--name->refcnt > 0)
-		return;
-
-	if (name->name != name->iname) {
-		__putname(name->name);
-		kfree(name);
-	} else
-		__putname(name);
-}
-
 static int check_acl(struct inode *inode, int mask)
 {
 #ifdef CONFIG_FS_POSIX_ACL
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ab44a19f2ddd..5c93ebc519fe 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2376,15 +2376,6 @@ static inline int break_layout(struct inode *inode, bool wait)
 #endif /* CONFIG_FILE_LOCKING */
 
 /* fs/open.c */
-struct audit_names;
-struct filename {
-	const char		*name;	/* pointer to actual string */
-	const __user char	*uptr;	/* original userland pointer */
-	struct audit_names	*aname;
-	int			refcnt;
-	const char		iname[];
-};
-
 extern long vfs_truncate(const struct path *, loff_t);
 extern int do_truncate(struct dentry *, loff_t start, unsigned int time_attrs,
 		       struct file *filp);
@@ -2399,6 +2390,18 @@ extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 extern struct file * dentry_open(const struct path *, int, const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
 
+/* fs/namei.c */
+static inline void *__getname(void)
+{
+	return (void *)__get_free_page(GFP_KERNEL);
+}
+
+static inline void __putname(const void *name)
+{
+	free_page((unsigned long)name);
+}
+
+void filename_get(struct filename *);
 extern struct filename *getname_flags(const char __user *, int, int *);
 extern struct filename *getname(const char __user *);
 extern struct filename *getname_kernel(const char *);
@@ -2421,11 +2424,6 @@ extern int ioctl_preallocate(struct file *filp, void __user *argp);
 extern void __init vfs_caches_init_early(void);
 extern void __init vfs_caches_init(void);
 
-extern struct kmem_cache *names_cachep;
-
-#define __getname()		kmem_cache_alloc(names_cachep, GFP_KERNEL)
-#define __putname(name)		kmem_cache_free(names_cachep, (void *)(name))
-
 #ifdef CONFIG_BLOCK
 extern int register_blkdev(unsigned int, const char *);
 extern void unregister_blkdev(unsigned int, const char *);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 97ceec1c6e21..a6ca28ef4277 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -25,6 +25,13 @@
 struct address_space;
 struct mem_cgroup;
 struct hmm;
+struct audit_names;
+
+struct filename {
+	const char		*name;	/* pointer to actual string */
+	const __user char	*uptr;	/* original userland pointer */
+	struct audit_names	*aname;
+};
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -188,6 +195,7 @@ struct page {
 			spinlock_t ptl;
 #endif
 		};
+		struct filename filename;
 	};
 
 #ifdef CONFIG_MEMCG
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index e80459f7e132..e539550f5983 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -1722,7 +1722,7 @@ __audit_reusename(const __user char *uptr)
 		if (!n->name)
 			continue;
 		if (n->name->uptr == uptr) {
-			n->name->refcnt++;
+			filename_get(n->name);
 			return n->name;
 		}
 	}
@@ -1751,7 +1751,7 @@ void __audit_getname(struct filename *name)
 	n->name = name;
 	n->name_len = AUDIT_NAME_FULL;
 	name->aname = n;
-	name->refcnt++;
+	filename_get(name);
 
 	if (!context->pwd.dentry)
 		get_fs_pwd(current->fs, &context->pwd);
@@ -1825,7 +1825,7 @@ void __audit_inode(struct filename *name, const struct dentry *dentry,
 		return;
 	if (name) {
 		n->name = name;
-		name->refcnt++;
+		filename_get(name);
 	}
 
 out:
@@ -1954,7 +1954,7 @@ void __audit_inode_child(struct inode *parent,
 		if (found_parent) {
 			found_child->name = found_parent->name;
 			found_child->name_len = AUDIT_NAME_FULL;
-			found_child->name->refcnt++;
+			filename_get(found_child->name);
 		}
 	}
 
