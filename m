Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EA56E6B00D8
	for <linux-mm@kvack.org>; Tue,  6 May 2014 07:41:22 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so2702654pde.1
        for <linux-mm@kvack.org>; Tue, 06 May 2014 04:41:22 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ln8si11813668pab.285.2014.05.06.04.41.21
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 04:41:21 -0700 (PDT)
Date: Tue, 06 May 2014 19:39:39 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [next:master 183/372] mm/gup.c:531:53: sparse: implicit cast to
 nocast type
Message-ID: <5368c9fb.s1CMchptQlr44pT6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   7df9f89cbcffc4f7bd8feea287af7b8d32b9ed96
commit: b28f3d3d605378f4d5b4b037033ebfeee74be1c2 [183/372] mm: move get_user_pages()-related code to separate file
reproduce: make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/gup.c:531:53: sparse: implicit cast to nocast type

vim +531 mm/gup.c

   515	 * such architectures, gup() will not be enough to make a subsequent access
   516	 * succeed.
   517	 *
   518	 * This should be called with the mm_sem held for read.
   519	 */
   520	int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
   521			     unsigned long address, unsigned int fault_flags)
   522	{
   523		struct vm_area_struct *vma;
   524		vm_flags_t vm_flags;
   525		int ret;
   526	
   527		vma = find_extend_vma(mm, address);
   528		if (!vma || address < vma->vm_start)
   529			return -EFAULT;
   530	
 > 531		vm_flags = (fault_flags & FAULT_FLAG_WRITE) ? VM_WRITE : VM_READ;
   532		if (!(vm_flags & vma->vm_flags))
   533			return -EFAULT;
   534	
   535		ret = handle_mm_fault(mm, vma, address, fault_flags);
   536		if (ret & VM_FAULT_ERROR) {
   537			if (ret & VM_FAULT_OOM)
   538				return -ENOMEM;
   539			if (ret & (VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE))

---
0-DAY kernel build testing backend              Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
