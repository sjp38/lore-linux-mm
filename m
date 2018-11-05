Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 771EC6B027A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:45 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id i13-v6so7875955ybe.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:45 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q9-v6si6436234ywq.282.2018.11.05.08.56.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:44 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 09/13] vfio: relieve mmap_sem reader cacheline bouncing by holding it longer
Date: Mon,  5 Nov 2018 11:55:54 -0500
Message-Id: <20181105165558.11698-10-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Profiling shows significant time being spent on atomic ops in mmap_sem
reader acquisition.  mmap_sem is taken and dropped for every single base
page during pinning, so this is not surprising.

Reduce the number of times mmap_sem is taken by holding for longer,
which relieves atomic cacheline bouncing.

Results for all VFIO page pinning patches
-----------------------------------------

The test measures the time from qemu invocation to the start of guest
boot.  The guest uses kvm with 320G memory backed with THP.  320G fits
in a node on the test machine used here, so there was no thrashing in
reclaim because of __GFP_THISNODE in THP allocations[1].

CPU:              2 nodes * 24 cores/node * 2 threads/core = 96 CPUs
                  Intel(R) Xeon(R) Platinum 8160 CPU @ 2.10GHz
memory:           754G split evenly between nodes
scaling_governor: performance

     patch 6                  patch 8                   patch 9 (this one)
     -----------------------  ------------------------  ------------------------
thr  speedup     average sec  speedup      average sec  speedup      average sec
  1            65.0 (A+- 0.6%)             65.2 (A+- 0.5%)             65.5 (A+- 0.4%)
  2     1.5x   42.8 (A+- 5.8%)     1.8x    36.0 (A+- 0.9%)     1.9x    34.4 (A+- 0.3%)
  3     1.9x   35.0 (A+-11.3%)     2.5x    26.4 (A+- 4.2%)     2.8x    23.7 (A+- 0.2%)
  4     2.3x   28.5 (A+- 1.3%)     3.1x    21.2 (A+- 2.8%)     3.6x    18.3 (A+- 0.3%)
  5     2.5x   26.2 (A+- 1.5%)     3.6x    17.9 (A+- 0.9%)     4.3x    15.1 (A+- 0.3%)
  6     2.7x   24.5 (A+- 1.8%)     4.0x    16.5 (A+- 3.0%)     5.1x    12.9 (A+- 0.1%)
  7     2.8x   23.5 (A+- 4.9%)     4.2x    15.4 (A+- 2.7%)     5.7x    11.5 (A+- 0.6%)
  8     2.8x   22.8 (A+- 1.8%)     4.2x    15.5 (A+- 4.7%)     6.4x    10.3 (A+- 0.8%)
 12     3.2x   20.2 (A+- 1.4%)     4.4x    14.7 (A+- 2.9%)     8.6x     7.6 (A+- 0.6%)
 16     3.3x   20.0 (A+- 0.7%)     4.3x    15.4 (A+- 1.3%)    10.2x     6.4 (A+- 0.6%)

At patch 6, lock_stat showed long reader wait time on mmap_sem writers,
leading to patch 8.

At patch 8, profiling revealed the issue with mmap_sem described above.

Across all three patches, performance consistently improves as the
thread count increases.  The one exception is the antiscaling with
nthr=16 in patch 8: those mmap_sem atomics are really bouncing around
the machine.

The performance with patch 9 looks pretty good overall.  I'm working on
finding the next bottleneck, and this is where it stopped:  When
nthr=16, the obvious issue profiling showed was contention on the split
PMD page table lock when pages are faulted in during the pinning (>2% of
the time).

A split PMD lock protects a PUD_SIZE-ed amount of page table mappings
(1G on x86), so if threads were operating on smaller chunks and
contending in the same PUD_SIZE range, this could be the source of
contention.  However, when nthr=16, threads operate on 5G chunks (320G /
16 threads / (1<<KTASK_LOAD_BAL_SHIFT)), so this wasn't the cause, and
aligning the chunks on PUD_SIZE boundaries didn't help either.

The time is short (6.4 seconds), so the next theory was threads
finishing at different times, but probes showed the threads all returned
within less than a millisecond of each other.

Kernel probes turned up a few smaller VFIO page pin calls besides the
heavy 320G call.  The chunk size given (PMD_SIZE) could affect thread
count and chunk size for these, so chunk size was increased from 2M to
1G.  This caused the split PMD contention to disappear, but with little
change in the runtime.  More digging required.

[1] lkml.kernel.org/r/20180925120326.24392-1-mhocko@kernel.org

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 drivers/vfio/vfio_iommu_type1.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 9e52a24eb45b..0d6ec0369de5 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -331,7 +331,7 @@ static int put_pfn(unsigned long pfn, int prot)
 }
 
 static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
-			 int prot, unsigned long *pfn)
+			 int prot, unsigned long *pfn, bool handle_mmap_sem)
 {
 	struct page *page[1];
 	struct vm_area_struct *vma;
@@ -342,7 +342,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 	if (prot & IOMMU_WRITE)
 		flags |= FOLL_WRITE;
 
-	down_read(&mm->mmap_sem);
+	if (handle_mmap_sem)
+		down_read(&mm->mmap_sem);
 	if (mm == current->mm) {
 		ret = get_user_pages_longterm(vaddr, 1, flags, page, vmas);
 	} else {
@@ -360,14 +361,16 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			put_page(page[0]);
 		}
 	}
-	up_read(&mm->mmap_sem);
+	if (handle_mmap_sem)
+		up_read(&mm->mmap_sem);
 
 	if (ret == 1) {
 		*pfn = page_to_pfn(page[0]);
 		return 0;
 	}
 
-	down_read(&mm->mmap_sem);
+	if (handle_mmap_sem)
+		down_read(&mm->mmap_sem);
 
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
@@ -377,7 +380,8 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			ret = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	if (handle_mmap_sem)
+		up_read(&mm->mmap_sem);
 	return ret;
 }
 
@@ -399,9 +403,12 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	if (!mm)
 		return -ENODEV;
 
-	ret = vaddr_get_pfn(mm, vaddr, dma->prot, pfn_base);
-	if (ret)
+	down_read(&mm->mmap_sem);
+	ret = vaddr_get_pfn(mm, vaddr, dma->prot, pfn_base, false);
+	if (ret) {
+		up_read(&mm->mmap_sem);
 		return ret;
+	}
 
 	pinned++;
 	rsvd = is_invalid_reserved_pfn(*pfn_base);
@@ -416,6 +423,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 			put_pfn(*pfn_base, dma->prot);
 			pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n", __func__,
 					limit << PAGE_SHIFT);
+			up_read(&mm->mmap_sem);
 			return -ENOMEM;
 		}
 		lock_acct++;
@@ -427,7 +435,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	/* Lock all the consecutive pages from pfn_base */
 	for (vaddr += PAGE_SIZE, iova += PAGE_SIZE; pinned < npage;
 	     pinned++, vaddr += PAGE_SIZE, iova += PAGE_SIZE) {
-		ret = vaddr_get_pfn(mm, vaddr, dma->prot, &pfn);
+		ret = vaddr_get_pfn(mm, vaddr, dma->prot, &pfn, false);
 		if (ret)
 			break;
 
@@ -444,6 +452,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 				pr_warn("%s: RLIMIT_MEMLOCK (%ld) exceeded\n",
 					__func__, limit << PAGE_SHIFT);
 				ret = -ENOMEM;
+				up_read(&mm->mmap_sem);
 				goto unpin_out;
 			}
 			lock_acct++;
@@ -451,6 +460,7 @@ static long vfio_pin_pages_remote(struct vfio_dma *dma, unsigned long vaddr,
 	}
 
 out:
+	up_read(&mm->mmap_sem);
 	ret = vfio_lock_acct(dma, lock_acct, false);
 
 unpin_out:
@@ -497,7 +507,7 @@ static int vfio_pin_page_external(struct vfio_dma *dma, unsigned long vaddr,
 	if (!mm)
 		return -ENODEV;
 
-	ret = vaddr_get_pfn(mm, vaddr, dma->prot, pfn_base);
+	ret = vaddr_get_pfn(mm, vaddr, dma->prot, pfn_base, true);
 	if (!ret && do_accounting && !is_invalid_reserved_pfn(*pfn_base)) {
 		ret = vfio_lock_acct(dma, 1, true);
 		if (ret) {
-- 
2.19.1
