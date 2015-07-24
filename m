Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id B7FDB6B0254
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 20:22:00 -0400 (EDT)
Received: by ykfw194 with SMTP id w194so7578734ykf.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 17:22:00 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id s65si4772094yks.15.2015.07.23.17.21.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 17:21:59 -0700 (PDT)
Message-ID: <55B18518.4090404@oracle.com>
Date: Thu, 23 Jul 2015 17:21:44 -0700
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
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

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

Oops, didn't realize that vm_policy is NUMA only and obviously did
not build/test without CONFIG_NUMA.

What is the preferred coding style to address this this type of
issue?  I could:
1) Put the few calls manipulating policy behind
	if (IS_ENABLED(CONFIG_NUMA))
2) Create wrappers for the code that manipulates policy like
    the diff below.
3) Same as #2, but move the wrappers to a header file.

Also, Andrew would you like a patch on top of the patch series
or a new series/individual patch.

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 6e565a4..696991d 100644
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
@@ -574,10 +597,8 @@ static long hugetlbfs_fallocate(struct file *file, 
int mode, loff_t offset,
  			break;
  		}

-		/* Get policy based on index */
-		pseudo_vma.vm_policy =
-			mpol_shared_policy_lookup(&HUGETLBFS_I(inode)->policy,
-							index);
+		/* Set policy based on index */
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
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
