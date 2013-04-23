Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id E37736B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 18:26:39 -0400 (EDT)
Date: Tue, 23 Apr 2013 18:26:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366755995-no3omuhl-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com

On Tue, Apr 23, 2013 at 01:25:22PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 20 Apr 2013 03:00:30 +0000 (UTC) bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=56881
> > 
> >            Summary: MAP_HUGETLB mmap fails for certain sizes
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 3.5.0-27
> 
> Thanks.
> 
> It's a post-3.4 regression, testcase included.  Does someone want to
> take a look, please?

Let me try it.

  static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
  {                                                                            
          struct inode *inode = file->f_path.dentry->d_inode;
          loff_t len, vma_len;                               
          int ret;                                           
          struct hstate *h = hstate_file(file);              
          ...                                                                               
          if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))              
                  return -EINVAL;                                              

This code checks only whether a given hugetlb vma covers (1 << order)
pages, not whether it's exactly hugepage aligned.
Before 2b37c35e6552 "fs/hugetlbfs/inode.c: fix pgoff alignment
checking on 32-bit", it was

  if (vma->vm_pgoff & ~(huge_page_mask(h) >> PAGE_SHIFT))

, but this made no sense because ~(huge_page_mask(h) >> PAGE_SHIFT) is
0xff for 2M hugepage.
I think the reported problem is not a bug because the behavior before
this change was wrong or not as expected.

If we want to make sure that a given address range fits hugepage size,
something like below can be useful.

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 78bde32..a98304b 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -113,11 +113,11 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 	vma->vm_flags |= VM_HUGETLB | VM_DONTEXPAND | VM_DONTDUMP;
 	vma->vm_ops = &hugetlb_vm_ops;
 
-	if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
-		return -EINVAL;
-
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
+	if (vma->len & ~huge_page_mask(h))
+		return -EINVAL;
+
 	mutex_lock(&inode->i_mutex);
 	file_accessed(file);
 

Thanks,
Naoya Horiguchi

> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >         AssignedTo: akpm@linux-foundation.org
> >         ReportedBy: iceman_dvd@yahoo.com
> >         Regression: No
> > 
> > 
> > This is on an Ubuntu 12.10 desktop, but the same issue has been found on 12.04
> > with 3.5.0 kernel.
> > See the sample program. An allocation with MAP_HUGETLB consistently fails with
> > certain sizes, while it succeeds with others.
> > The allocation sizes are well below the number of free huge pages.
> > 
> > $ uname -a Linux davide-lnx2 3.5.0-27-generic #46-Ubuntu SMP Mon Mar 25
> > 19:58:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
> > 
> > 
> > # echo 100 > /proc/sys/vm/nr_hugepages
> > 
> > # cat /proc/meminfo
> > ...
> > AnonHugePages:         0 kB
> > HugePages_Total:     100
> > HugePages_Free:      100
> > HugePages_Rsvd:        0
> > HugePages_Surp:        0
> > Hugepagesize:       2048 kB
> > 
> > 
> > $ ./mmappu $((5 * 2 * 1024 * 1024 - 4096))
> > size=10481664    0x9ff000
> > hugepage mmap: Invalid argument
> > 
> > 
> > $ ./mmappu $((5 * 2 * 1024 * 1024 - 4095))
> > size=10481665    0x9ff001
> > OK!
> > 
> > 
> > It seems the trigger point is a normal page size.
> > The same binary works flawlessly in previous kernels.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
