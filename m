Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E2E626B0008
	for <linux-mm@kvack.org>; Mon, 21 May 2018 16:22:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e3-v6so9834527pfe.15
        for <linux-mm@kvack.org>; Mon, 21 May 2018 13:22:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w17-v6sor5552367pfa.61.2018.05.21.13.21.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 13:21:59 -0700 (PDT)
Date: Tue, 22 May 2018 01:54:10 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: shmem: Adding new return type vm_fault_t
Message-ID: <20180521202410.GA17912@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, willy@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Use new return type vm_fault_t for fault handler. For
now, this is just documenting that the function returns
a VM_FAULT value rather than an errno. Once all instances
are converted, vm_fault_t will become a distinct type.

Ref-> commit 1c8f422059ae ("mm: change return type to
vm_fault_t")

vmf_error() is the newly introduce inline function
in 4.17-rc6.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/shmem.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 9d6c7e5..6207c82 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1931,14 +1931,14 @@ static int synchronous_wake_function(wait_queue_entry_t *wait, unsigned mode, in
 	return ret;
 }
 
-static int shmem_fault(struct vm_fault *vmf)
+static vm_fault_t shmem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = file_inode(vma->vm_file);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	enum sgp_type sgp;
-	int error;
-	int ret = VM_FAULT_LOCKED;
+	int err;
+	vm_fault_t ret = VM_FAULT_LOCKED;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
@@ -2006,10 +2006,10 @@ static int shmem_fault(struct vm_fault *vmf)
 	else if (vma->vm_flags & VM_HUGEPAGE)
 		sgp = SGP_HUGE;
 
-	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
+	err = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
 				  gfp, vma, vmf, &ret);
-	if (error)
-		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
+	if (err)
+		return vmf_error(err);
 	return ret;
 }
 
-- 
1.9.1
