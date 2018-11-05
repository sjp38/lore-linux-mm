Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7186B0277
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:44 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id a62-v6so7834645ywf.16
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:44 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r4-v6si23252143yba.429.2018.11.05.08.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:43 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 08/13] vfio: remove unnecessary mmap_sem writer acquisition around locked_vm
Date: Mon,  5 Nov 2018 11:55:53 -0500
Message-Id: <20181105165558.11698-9-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Now that mmap_sem is no longer required for modifying locked_vm, remove
it in the VFIO code.

[XXX Can be sent separately, along with similar conversions in the other
places mmap_sem was taken for locked_vm.  While at it, could make
similar changes to pinned_vm.]

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 drivers/vfio/vfio_iommu_type1.c | 26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index f307dc9d5e19..9e52a24eb45b 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -258,7 +258,8 @@ static int vfio_iova_put_vfio_pfn(struct vfio_dma *dma, struct vfio_pfn *vpfn)
 static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 {
 	struct mm_struct *mm;
-	int ret;
+	long locked_vm;
+	int ret = 0;
 
 	if (!npage)
 		return 0;
@@ -267,24 +268,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
 	if (!mm)
 		return -ESRCH; /* process exited */
 
-	ret = down_write_killable(&mm->mmap_sem);
-	if (!ret) {
-		if (npage > 0) {
-			if (!dma->lock_cap) {
-				unsigned long limit;
-
-				limit = task_rlimit(dma->task,
-						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	locked_vm = atomic_long_add_return(npage, &mm->locked_vm);
 
-				if (atomic_long_read(&mm->locked_vm) + npage > limit)
-					ret = -ENOMEM;
-			}
+	if (npage > 0 && !dma->lock_cap) {
+		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
+					  PAGE_SHIFT;
+		if (locked_vm > limit) {
+			atomic_long_sub(npage, &mm->locked_vm);
+			ret = -ENOMEM;
 		}
-
-		if (!ret)
-			atomic_long_add(npage, &mm->locked_vm);
-
-		up_write(&mm->mmap_sem);
 	}
 
 	if (async)
-- 
2.19.1
