Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6FAB6B0005
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 02:16:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s8so962687pgf.16
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 23:16:22 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o12si1378053pgc.381.2018.03.13.23.16.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 23:16:21 -0700 (PDT)
Date: Wed, 14 Mar 2018 14:15:26 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 8/285] fs//hugetlbfs/inode.c:142:22: note: in
 expansion of macro 'PGOFF_LOFFT_MAX'
Message-ID: <201803141423.WZYJTFEz%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   ead058c4ec49752a4e0323368f1d695385c66020
commit: af7abfba1161d2814301844fe11adac16910ea80 [8/285] hugetlbfs-check-for-pgoff-value-overflow-v3
config: sh-defconfig (attached as .config)
compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout af7abfba1161d2814301844fe11adac16910ea80
        # save the attached .config to linux build tree
        make.cross ARCH=sh 

All warnings (new ones prefixed by >>):

   fs//hugetlbfs/inode.c: In function 'hugetlbfs_file_mmap':
>> fs//hugetlbfs/inode.c:118:36: warning: left shift count is negative [-Wshift-count-negative]
    #define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
                                       ^
>> fs//hugetlbfs/inode.c:142:22: note: in expansion of macro 'PGOFF_LOFFT_MAX'
     if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
                         ^~~~~~~~~~~~~~~

vim +/PGOFF_LOFFT_MAX +142 fs//hugetlbfs/inode.c

   110	
   111	/*
   112	 * Mask used when checking the page offset value passed in via system
   113	 * calls.  This value will be converted to a loff_t which is signed.
   114	 * Therefore, we want to check the upper PAGE_SHIFT + 1 bits of the
   115	 * value.  The extra bit (- 1 in the shift value) is to take the sign
   116	 * bit into account.
   117	 */
 > 118	#define PGOFF_LOFFT_MAX (PAGE_MASK << (BITS_PER_LONG - (2 * PAGE_SHIFT) - 1))
   119	
   120	static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
   121	{
   122		struct inode *inode = file_inode(file);
   123		loff_t len, vma_len;
   124		int ret;
   125		struct hstate *h = hstate_file(file);
   126	
   127		/*
   128		 * vma address alignment (but not the pgoff alignment) has
   129		 * already been checked by prepare_hugepage_range.  If you add
   130		 * any error returns here, do so after setting VM_HUGETLB, so
   131		 * is_vm_hugetlb_page tests below unmap_region go the right
   132		 * way when do_mmap_pgoff unwinds (may be important on powerpc
   133		 * and ia64).
   134		 */
   135		vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND;
   136		vma->vm_ops = &hugetlb_vm_ops;
   137	
   138		/*
   139		 * page based offset in vm_pgoff could be sufficiently large to
   140		 * overflow a (l)off_t when converted to byte offset.
   141		 */
 > 142		if (vma->vm_pgoff & PGOFF_LOFFT_MAX)
   143			return -EINVAL;
   144	
   145		/* must be huge page aligned */
   146		if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
   147			return -EINVAL;
   148	
   149		vma_len = (loff_t)(vma->vm_end - vma->vm_start);
   150		len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
   151		/* check for overflow */
   152		if (len < vma_len)
   153			return -EINVAL;
   154	
   155		inode_lock(inode);
   156		file_accessed(file);
   157	
   158		ret = -ENOMEM;
   159		if (hugetlb_reserve_pages(inode,
   160					vma->vm_pgoff >> huge_page_order(h),
   161					len >> huge_page_shift(h), vma,
   162					vma->vm_flags))
   163			goto out;
   164	
   165		ret = 0;
   166		if (vma->vm_flags & VM_WRITE && inode->i_size < len)
   167			i_size_write(inode, len);
   168	out:
   169		inode_unlock(inode);
   170	
   171		return ret;
   172	}
   173	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BXVAT5kNtrzKuDFl
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--BXVAT5kNtrzKuDFl--
