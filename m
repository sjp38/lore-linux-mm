Message-Id: <20080603100938.725204678@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:00 +1000
From: npiggin@suse.de
Subject: [patch 04/21] hugetlbfs: per mount hstates
Content-Disposition: inline; filename=hugetlbfs-per-mount-hstate.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Add support to have individual hstates for each hugetlbfs mount

- Add a new pagesize= option to the hugetlbfs mount that allows setting
the page size
- Set up pointers to a suitable hstate for the set page size option
to the super block and the inode and the vma.
- Change the hstate accessors to use this information
- Add code to the hstate init function to set parsed_hstate for command
line processing
- Handle duplicated hstate registrations to the make command line user proof

[np: take hstate out of hugetlbfs inode and vma->vm_private_data]

Acked-by: Adam Litke <agl@us.ibm.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 fs/hugetlbfs/inode.c    |   48 ++++++++++++++++++++++++++++++++++++++----------
 include/linux/hugetlb.h |   14 +++++++++-----
 mm/hugetlb.c            |   16 +++-------------
 mm/memory.c             |   18 ++++++++++++++++--
 4 files changed, 66 insertions(+), 30 deletions(-)

Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h	2008-06-03 19:55:17.000000000 +1000
+++ linux-2.6/include/linux/hugetlb.h	2008-06-03 19:56:16.000000000 +1000
@@ -100,6 +100,7 @@ struct hugetlbfs_config {
 	umode_t mode;
 	long	nr_blocks;
 	long	nr_inodes;
+	struct hstate *hstate;
 };
 
 struct hugetlbfs_sb_info {
@@ -108,6 +109,7 @@ struct hugetlbfs_sb_info {
 	long	max_inodes;   /* inodes allowed */
 	long	free_inodes;  /* inodes free */
 	spinlock_t	stat_lock;
+	struct hstate *hstate;
 };
 
 
@@ -191,19 +193,21 @@ extern unsigned int default_hstate_idx;
 
 #define default_hstate (hstates[default_hstate_idx])
 
-static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
+static inline struct hstate *hstate_inode(struct inode *i)
 {
-	return &default_hstate;
+	struct hugetlbfs_sb_info *hsb;
+	hsb = HUGETLBFS_SB(i->i_sb);
+	return hsb->hstate;
 }
 
 static inline struct hstate *hstate_file(struct file *f)
 {
-	return &default_hstate;
+	return hstate_inode(f->f_dentry->d_inode);
 }
 
-static inline struct hstate *hstate_inode(struct inode *i)
+static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
 {
-	return &default_hstate;
+	return hstate_file(vma->vm_file);
 }
 
 static inline unsigned long huge_page_size(struct hstate *h)
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2008-06-03 19:54:53.000000000 +1000
+++ linux-2.6/fs/hugetlbfs/inode.c	2008-06-03 19:56:16.000000000 +1000
@@ -53,6 +53,7 @@ int sysctl_hugetlb_shm_group;
 enum {
 	Opt_size, Opt_nr_inodes,
 	Opt_mode, Opt_uid, Opt_gid,
+	Opt_pagesize,
 	Opt_err,
 };
 
@@ -62,6 +63,7 @@ static match_table_t tokens = {
 	{Opt_mode,	"mode=%o"},
 	{Opt_uid,	"uid=%u"},
 	{Opt_gid,	"gid=%u"},
+	{Opt_pagesize,	"pagesize=%s"},
 	{Opt_err,	NULL},
 };
 
@@ -750,6 +752,8 @@ hugetlbfs_parse_options(char *options, s
 	char *p, *rest;
 	substring_t args[MAX_OPT_ARGS];
 	int option;
+	unsigned long long size = 0;
+	enum { NO_SIZE, SIZE_STD, SIZE_PERCENT } setsize = NO_SIZE;
 
 	if (!options)
 		return 0;
@@ -780,17 +784,13 @@ hugetlbfs_parse_options(char *options, s
 			break;
 
 		case Opt_size: {
- 			unsigned long long size;
 			/* memparse() will accept a K/M/G without a digit */
 			if (!isdigit(*args[0].from))
 				goto bad_val;
 			size = memparse(args[0].from, &rest);
-			if (*rest == '%') {
-				size <<= HPAGE_SHIFT;
-				size *= max_huge_pages;
-				do_div(size, 100);
-			}
-			pconfig->nr_blocks = (size >> HPAGE_SHIFT);
+			setsize = SIZE_STD;
+			if (*rest == '%')
+				setsize = SIZE_PERCENT;
 			break;
 		}
 
@@ -801,6 +801,19 @@ hugetlbfs_parse_options(char *options, s
 			pconfig->nr_inodes = memparse(args[0].from, &rest);
 			break;
 
+		case Opt_pagesize: {
+			unsigned long ps;
+			ps = memparse(args[0].from, &rest);
+			pconfig->hstate = size_to_hstate(ps);
+			if (!pconfig->hstate) {
+				printk(KERN_ERR
+				"hugetlbfs: Unsupported page size %lu MB\n",
+					ps >> 20);
+				return -EINVAL;
+			}
+			break;
+		}
+
 		default:
 			printk(KERN_ERR "hugetlbfs: Bad mount option: \"%s\"\n",
 				 p);
@@ -808,6 +821,18 @@ hugetlbfs_parse_options(char *options, s
 			break;
 		}
 	}
+
+	/* Do size after hstate is set up */
+	if (setsize > NO_SIZE) {
+		struct hstate *h = pconfig->hstate;
+		if (setsize == SIZE_PERCENT) {
+			size <<= huge_page_shift(h);
+			size *= h->max_huge_pages;
+			do_div(size, 100);
+		}
+		pconfig->nr_blocks = (size >> huge_page_shift(h));
+	}
+
 	return 0;
 
 bad_val:
@@ -832,6 +857,7 @@ hugetlbfs_fill_super(struct super_block 
 	config.uid = current->fsuid;
 	config.gid = current->fsgid;
 	config.mode = 0755;
+	config.hstate = &default_hstate;
 	ret = hugetlbfs_parse_options(data, &config);
 	if (ret)
 		return ret;
@@ -840,14 +866,15 @@ hugetlbfs_fill_super(struct super_block 
 	if (!sbinfo)
 		return -ENOMEM;
 	sb->s_fs_info = sbinfo;
+	sbinfo->hstate = config.hstate;
 	spin_lock_init(&sbinfo->stat_lock);
 	sbinfo->max_blocks = config.nr_blocks;
 	sbinfo->free_blocks = config.nr_blocks;
 	sbinfo->max_inodes = config.nr_inodes;
 	sbinfo->free_inodes = config.nr_inodes;
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
-	sb->s_blocksize = HPAGE_SIZE;
-	sb->s_blocksize_bits = HPAGE_SHIFT;
+	sb->s_blocksize = huge_page_size(config.hstate);
+	sb->s_blocksize_bits = huge_page_shift(config.hstate);
 	sb->s_magic = HUGETLBFS_MAGIC;
 	sb->s_op = &hugetlbfs_ops;
 	sb->s_time_gran = 1;
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-03 19:55:41.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-03 19:56:16.000000000 +1000
@@ -1334,19 +1334,9 @@ void __unmap_hugepage_range(struct vm_ar
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end, struct page *ref_page)
 {
-	/*
-	 * It is undesirable to test vma->vm_file as it should be non-null
-	 * for valid hugetlb area. However, vm_file will be NULL in the error
-	 * cleanup path of do_mmap_pgoff. When hugetlbfs ->mmap method fails,
-	 * do_mmap_pgoff() nullifies vma->vm_file before calling this function
-	 * to clean up. Since no pte has actually been setup, it is safe to
-	 * do nothing in this case.
-	 */
-	if (vma->vm_file) {
-		spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
-		__unmap_hugepage_range(vma, start, end, ref_page);
-		spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
-	}
+	spin_lock(&vma->vm_file->f_mapping->i_mmap_lock);
+	__unmap_hugepage_range(vma, start, end, ref_page);
+	spin_unlock(&vma->vm_file->f_mapping->i_mmap_lock);
 }
 
 /*
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2008-06-03 19:53:30.000000000 +1000
+++ linux-2.6/mm/memory.c	2008-06-03 19:56:16.000000000 +1000
@@ -902,9 +902,23 @@ unsigned long unmap_vmas(struct mmu_gath
 			}
 
 			if (unlikely(is_vm_hugetlb_page(vma))) {
-				unmap_hugepage_range(vma, start, end, NULL);
-				zap_work -= (end - start) /
+				/*
+				 * It is undesirable to test vma->vm_file as it
+				 * should be non-null for valid hugetlb area.
+				 * However, vm_file will be NULL in the error
+				 * cleanup path of do_mmap_pgoff. When
+				 * hugetlbfs ->mmap method fails,
+				 * do_mmap_pgoff() nullifies vma->vm_file
+				 * before calling this function to clean up.
+				 * Since no pte has actually been setup, it is
+				 * safe to do nothing in this case.
+				 */
+				if (vma->vm_file) {
+					unmap_hugepage_range(vma, start, end, NULL);
+					zap_work -= (end - start) /
 					pages_per_huge_page(hstate_vma(vma));
+				}
+
 				start = end;
 			} else
 				start = unmap_page_range(*tlbp, vma,

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
