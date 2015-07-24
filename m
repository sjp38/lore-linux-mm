Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6FEDA6B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 13:27:19 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so16739807pdj.3
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 10:27:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u3si19294121pds.41.2015.07.24.10.27.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 10:27:18 -0700 (PDT)
Message-ID: <55B27566.1050202@oracle.com>
Date: Fri, 24 Jul 2015 10:27:02 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [mmotm:master 229/385] fs/hugetlbfs/inode.c:578:13: error: 'struct
 vm_area_struct' has no member named 'vm_policy'
References: <201507240615.1plto0Cp%fengguang.wu@intel.com>
In-Reply-To: <201507240615.1plto0Cp%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On 07/23/2015 03:18 PM, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   61f5f835b6f06fbc233481b5d3c0afd71ecf54e8
> commit: 0c5e1e8ed55974975bb829e4b93cf19aa0dfcafc [229/385] hugetlbfs: add hugetlbfs_fallocate()
> config: i386-randconfig-r0-201529 (attached as .config)
> reproduce:
>    git checkout 0c5e1e8ed55974975bb829e4b93cf19aa0dfcafc
>    # save the attached .config to linux build tree
>    make ARCH=i386
>
> All error/warnings (new ones prefixed by >>):
>
>     fs/hugetlbfs/inode.c: In function 'hugetlbfs_fallocate':
>>> fs/hugetlbfs/inode.c:578:13: error: 'struct vm_area_struct' has no member named 'vm_policy'
>        pseudo_vma.vm_policy =
>                  ^
>>> fs/hugetlbfs/inode.c:579:4: error: implicit declaration of function 'mpol_shared_policy_lookup' [-Werror=implicit-function-declaration]
>         mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>         ^
>     fs/hugetlbfs/inode.c:595:28: error: 'struct vm_area_struct' has no member named 'vm_policy'
>         mpol_cond_put(pseudo_vma.vm_policy);
>                                 ^
>     fs/hugetlbfs/inode.c:601:27: error: 'struct vm_area_struct' has no member named 'vm_policy'
>        mpol_cond_put(pseudo_vma.vm_policy);
>                                ^
>     cc1: some warnings being treated as errors
>
> vim +578 fs/hugetlbfs/inode.c
>
>     572			if (signal_pending(current)) {
>     573				error = -EINTR;
>     574				break;
>     575			}
>     576	
>     577			/* Get policy based on index */
>   > 578			pseudo_vma.vm_policy =
>   > 579				mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
>     580								index);
>     581	
>     582			/* addr is the offset within the file (zero based) */
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>

Michal already added a patch to mmotm.  The patch below is functionally
equivalent but moves the #ifdef out of the executable code path, and
modifies a comment.  This has been functional/stress tested in a kernel
without CONFIG_NUMA defined.

hugetlbfs: build fix fallocate if not CONFIG_NUMA

When fallocate preallocation allocates pages, it will use the
defined numa policy.  However, if numa is not defined there is
no such policy and no code should reference numa policy.  Create
wrappers to isolate policy manipulation code that are NOOP in
the non-NUMA case.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
  fs/hugetlbfs/inode.c | 39 ++++++++++++++++++++++++++++++---------
  1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index d977cae..4bae359 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -85,6 +85,29 @@ static const match_table_t tokens = {
  	{Opt_err,	NULL},
  };

+#ifdef CONFIG_NUMA
+static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
+					struct inode *inode, pgoff_t index)
+{
+	vma->vm_policy = mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
+							index);
+}
+
+static inline void hugetlb_vma_mpol_cond_put(struct vm_area_struct *vma)
+{
+	mpol_cond_put(vma->vm_policy);
+}
+#else
+static inline void hugetlb_set_vma_policy(struct vm_area_struct *vma,
+					struct inode *inode, pgoff_t index)
+{
+}
+
+static inline void hugetlb_vma_mpol_cond_put(struct vm_area_struct *vma)
+{
+}
+#endif
+
  static void huge_pagevec_release(struct pagevec *pvec)
  {
  	int i;
@@ -546,9 +569,9 @@ static long hugetlbfs_fallocate(struct file *file, 
int mode, loff_t offset,
  		goto out;

  	/*
-	 * Initialize a pseudo vma that just contains the policy used
-	 * when allocating the huge pages.  The actual policy field
-	 * (vm_policy) is determined based on the index in the loop below.
+	 * Initialize a pseudo vma as this is required by the huge page
+	 * allocation routines.  If NUMA is configured, use page index
+	 * as input to create an allocation policy.
  	 */
  	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
  	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
@@ -574,10 +597,8 @@ static long hugetlbfs_fallocate(struct file *file, 
int mode, loff_t offset,
  			break;
  		}

-		/* Get policy based on index */
-		pseudo_vma.vm_policy =
-			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
-							index);
+		/* Set numa allocation policy based on index */
+		hugetlb_set_vma_policy(&pseudo_vma, inode, index);

  		/* addr is the offset within the file (zero based) */
  		addr = index * hpage_size;
@@ -592,13 +613,13 @@ static long hugetlbfs_fallocate(struct file *file, 
int mode, loff_t offset,
  		if (page) {
  			put_page(page);
  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
-			mpol_cond_put(pseudo_vma.vm_policy);
+			hugetlb_vma_mpol_cond_put(&pseudo_vma);
  			continue;
  		}

  		/* Allocate page and add to page cache */
  		page = alloc_huge_page(&pseudo_vma, addr, avoid_reserve);
-		mpol_cond_put(pseudo_vma.vm_policy);
+		hugetlb_vma_mpol_cond_put(&pseudo_vma);
  		if (IS_ERR(page)) {
  			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
  			error = PTR_ERR(page);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
