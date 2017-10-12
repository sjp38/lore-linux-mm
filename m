Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 053A76B0069
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 21:46:35 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e195so2742710itc.20
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 18:46:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t22si7022894ioi.199.2017.10.11.18.46.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 18:46:33 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 1/3] mm/map_contig: Add VM_CONTIG flag to vma struct
Date: Wed, 11 Oct 2017 18:46:09 -0700
Message-Id: <20171012014611.18725-2-mike.kravetz@oracle.com>
In-Reply-To: <20171012014611.18725-1-mike.kravetz@oracle.com>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Christoph Lameter <cl@linux.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

Add the flag VM_CONTIG to vma structure to identify vmas which are
backed by contiguous memory allocations.  This flag is not propogated
to child processes, so be sure to clear at fork time.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 include/linux/mm.h | 1 +
 kernel/fork.c      | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065d99deb847..db82f172fbd1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -189,6 +189,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
+#define VM_CONTIG	0x00800000	/* Contiguous page backing */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
 #define VM_WIPEONFORK	0x02000000	/* Wipe VMA contents in child. */
 #define VM_DONTDUMP	0x04000000	/* Do not include in the core dump */
diff --git a/kernel/fork.c b/kernel/fork.c
index e702cb9ffbd8..d93b022e4909 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -665,7 +665,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 				goto fail_nomem_anon_vma_fork;
 		} else if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
+		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT | VM_CONTIG);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
