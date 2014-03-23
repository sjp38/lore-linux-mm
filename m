Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id BCC966B00E4
	for <linux-mm@kvack.org>; Sat, 22 Mar 2014 22:54:05 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so3978700pbb.22
        for <linux-mm@kvack.org>; Sat, 22 Mar 2014 19:54:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id tm9si6556151pab.223.2014.03.22.19.54.02
        for <linux-mm@kvack.org>;
        Sat, 22 Mar 2014 19:54:02 -0700 (PDT)
Date: Sun, 23 Mar 2014 10:53:53 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 463/499] mm/mprotect.c:46:14: sparse: context
 imbalance in 'lock_pte_protection' - different lock contexts for basic
 block
Message-ID: <532e4cc1.umGiNE2YJiL9Z2iq%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   4ddd4bc6e081ef29f7adaacb357b77052fefcd7e
commit: 6a9ad050c521ac607a30a691042f2a5d24109b07 [463/499] percpu: add raw_cpu_ops
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/mprotect.c:46:14: sparse: context imbalance in 'lock_pte_protection' - different lock contexts for basic block
>> arch/x86/include/asm/paravirt.h:699:9: sparse: context imbalance in 'change_pte_range' - unexpected unlock
--
>> fs/ntfs/super.c:3100:1: sparse: directive in argument list
>> fs/ntfs/super.c:3102:1: sparse: directive in argument list
>> fs/ntfs/super.c:3104:1: sparse: directive in argument list
>> fs/ntfs/super.c:3105:1: sparse: directive in argument list
>> fs/ntfs/super.c:3107:1: sparse: directive in argument list
>> fs/ntfs/super.c:3108:1: sparse: directive in argument list
>> fs/ntfs/super.c:3110:1: sparse: directive in argument list

vim +/lock_pte_protection +46 mm/mprotect.c

^1da177e Linus Torvalds  2005-04-16  30  #include <asm/tlbflush.h>
^1da177e Linus Torvalds  2005-04-16  31  
1c12c4cf Venki Pallipadi 2008-05-14  32  #ifndef pgprot_modify
1c12c4cf Venki Pallipadi 2008-05-14  33  static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
1c12c4cf Venki Pallipadi 2008-05-14  34  {
1c12c4cf Venki Pallipadi 2008-05-14  35  	return newprot;
1c12c4cf Venki Pallipadi 2008-05-14  36  }
1c12c4cf Venki Pallipadi 2008-05-14  37  #endif
1c12c4cf Venki Pallipadi 2008-05-14  38  
af79e8ed Mel Gorman      2014-03-22  39  /*
af79e8ed Mel Gorman      2014-03-22  40   * For a prot_numa update we only hold mmap_sem for read so there is a
af79e8ed Mel Gorman      2014-03-22  41   * potential race with faulting where a pmd was temporarily none. This
af79e8ed Mel Gorman      2014-03-22  42   * function checks for a transhuge pmd under the appropriate lock. It
af79e8ed Mel Gorman      2014-03-22  43   * returns a pte if it was successfully locked or NULL if it raced with
af79e8ed Mel Gorman      2014-03-22  44   * a transhuge insertion.
af79e8ed Mel Gorman      2014-03-22  45   */
af79e8ed Mel Gorman      2014-03-22 @46  static pte_t *lock_pte_protection(struct vm_area_struct *vma, pmd_t *pmd,
af79e8ed Mel Gorman      2014-03-22  47  			unsigned long addr, int prot_numa, spinlock_t **ptl)
af79e8ed Mel Gorman      2014-03-22  48  {
af79e8ed Mel Gorman      2014-03-22  49  	pte_t *pte;
af79e8ed Mel Gorman      2014-03-22  50  	spinlock_t *pmdl;
af79e8ed Mel Gorman      2014-03-22  51  
af79e8ed Mel Gorman      2014-03-22  52  	/* !prot_numa is protected by mmap_sem held for write */
af79e8ed Mel Gorman      2014-03-22  53  	if (!prot_numa)
af79e8ed Mel Gorman      2014-03-22  54  		return pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);

:::::: The code at line 46 was first introduced by commit
:::::: af79e8edd17efee942ddfd277d0b3e8fc1ea7fe1 mm-numa-recheck-for-transhuge-pages-under-lock-during-protection-changes-fix

:::::: TO: Mel Gorman <mgorman@suse.de>
:::::: CC: Johannes Weiner <hannes@cmpxchg.org>

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
