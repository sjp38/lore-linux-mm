Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 461536B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 11:30:22 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id dx2so8351370lbd.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:30:22 -0800 (PST)
Received: from mail-lb0-x241.google.com (mail-lb0-x241.google.com. [2a00:1450:4010:c04::241])
        by mx.google.com with ESMTPS id pc8si3500783lbc.210.2016.01.27.08.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 08:30:20 -0800 (PST)
Received: by mail-lb0-x241.google.com with SMTP id ad5so612131lbc.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 08:30:20 -0800 (PST)
From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: [PATCH v2] mm/mprotect.c: don't imply PROT_EXEC on non-exec fs
Date: Wed, 27 Jan 2016 17:29:37 +0100
Message-Id: <1453912177-16424-1-git-send-email-kwapulinski.piotr@gmail.com>
In-Reply-To: <CALYGNiMKK4B_z+=CiMxoDmkYUZkayAhbg2dOOTi9-Bic+FEK2w@mail.gmail.com>
References: <CALYGNiMKK4B_z+=CiMxoDmkYUZkayAhbg2dOOTi9-Bic+FEK2w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gorcunov@openvz.org, aarcange@redhat.com, koct9i@gmail.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>

The mprotect(PROT_READ) fails when called by the READ_IMPLIES_EXEC binary
on a memory mapped file located on non-exec fs. The mprotect does not
check whether fs is _executable_ or not. The PROT_EXEC flag is set
automatically even if a memory mapped file is located on non-exec fs.
Fix it by checking whether a memory mapped file is located on a non-exec
fs. If so the PROT_EXEC is not implied by the PROT_READ.
The implementation uses the VM_MAYEXEC flag set properly in mmap.
Now it is consistent with mmap.

I did the isolated tests (PT_GNU_STACK X/NX, multiple VMAs, X/NX fs).
I also patched the official 3.19.0-47-generic Ubuntu 14.04 kernel
and it seems to work.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
---
The difference between v1 is that the prot variable is reset to
 reqprot for each loop iteration (thanks to Konstantin Khlebnikov for
pointing this out).
rier means "(current->personality & [R]EAD_[I]MPLIES_[E]XEC) &&
(prot & PROT_[R]EAD)".

 mm/mprotect.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 8eb7bb4..1b9597f 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -352,10 +352,12 @@ fail:
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	unsigned long vm_flags, nstart, end, tmp, reqprot;
+	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
+	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
+				(prot & PROT_READ);
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
@@ -372,13 +374,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		return -EINVAL;
 
 	reqprot = prot;
-	/*
-	 * Does the application expect PROT_READ to imply PROT_EXEC:
-	 */
-	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
-		prot |= PROT_EXEC;
-
-	vm_flags = calc_vm_prot_bits(prot);
 
 	down_write(&current->mm->mmap_sem);
 
@@ -412,7 +407,11 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
-		newflags = vm_flags;
+		/* Does the application expect PROT_READ to imply PROT_EXEC */
+		if (rier && (vma->vm_flags & VM_MAYEXEC))
+			prot |= PROT_EXEC;
+
+		newflags = calc_vm_prot_bits(prot);
 		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
 
 		/* newflags >> 4 shift VM_MAY% in place of VM_% */
@@ -443,6 +442,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 			error = -ENOMEM;
 			goto out;
 		}
+		prot = reqprot;
 	}
 out:
 	up_write(&current->mm->mmap_sem);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
