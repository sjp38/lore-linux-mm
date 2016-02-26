Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id C8C116B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 15:21:02 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id a4so84285713wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:21:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s125si5949188wmd.74.2016.02.26.12.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 12:21:01 -0800 (PST)
Date: Fri, 26 Feb 2016 12:20:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/mprotect.c: don't imply PROT_EXEC on non-exec fs
Message-Id: <20160226122032.5806c626cd4acb0ea1afbb4a@linux-foundation.org>
In-Reply-To: <1453912177-16424-1-git-send-email-kwapulinski.piotr@gmail.com>
References: <CALYGNiMKK4B_z+=CiMxoDmkYUZkayAhbg2dOOTi9-Bic+FEK2w@mail.gmail.com>
	<1453912177-16424-1-git-send-email-kwapulinski.piotr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: mgorman@suse.de, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gorcunov@openvz.org, aarcange@redhat.com, koct9i@gmail.com, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>

On Wed, 27 Jan 2016 17:29:37 +0100 Piotr Kwapulinski <kwapulinski.piotr@gmail.com> wrote:

> The mprotect(PROT_READ) fails when called by the READ_IMPLIES_EXEC binary
> on a memory mapped file located on non-exec fs. The mprotect does not
> check whether fs is _executable_ or not. The PROT_EXEC flag is set
> automatically even if a memory mapped file is located on non-exec fs.
> Fix it by checking whether a memory mapped file is located on a non-exec
> fs. If so the PROT_EXEC is not implied by the PROT_READ.
> The implementation uses the VM_MAYEXEC flag set properly in mmap.
> Now it is consistent with mmap.
> 
> I did the isolated tests (PT_GNU_STACK X/NX, multiple VMAs, X/NX fs).
> I also patched the official 3.19.0-47-generic Ubuntu 14.04 kernel
> and it seems to work.

sys_mprotect() just took a mangling in linux-next due to 

commit 62b5f7d013fc455b8db26cf01e421f4c0d264b92
Author:     Dave Hansen <dave.hansen@linux.intel.com>
AuthorDate: Fri Feb 12 13:02:40 2016 -0800
Commit:     Ingo Molnar <mingo@kernel.org>
CommitDate: Thu Feb 18 19:46:33 2016 +0100

    mm/core, x86/mm/pkeys: Add execute-only protection keys support


Here is my rework of your "mm/mprotect.c: don't imply PROT_EXEC on
non-exec fs" to handle this.  Please check very carefully.


From: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Subject: mm/mprotect.c: don't imply PROT_EXEC on non-exec fs

The mprotect(PROT_READ) fails when called by the READ_IMPLIES_EXEC binary
on a memory mapped file located on non-exec fs.  The mprotect does not
check whether fs is _executable_ or not.  The PROT_EXEC flag is set
automatically even if a memory mapped file is located on non-exec fs.  Fix
it by checking whether a memory mapped file is located on a non-exec fs. 
If so the PROT_EXEC is not implied by the PROT_READ.  The implementation
uses the VM_MAYEXEC flag set properly in mmap.  Now it is consistent with
mmap.

I did the isolated tests (PT_GNU_STACK X/NX, multiple VMAs, X/NX fs).  I
also patched the official 3.19.0-47-generic Ubuntu 14.04 kernel and it
seems to work.

Signed-off-by: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mprotect.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff -puN mm/mprotect.c~mm-mprotectc-dont-imply-prot_exec-on-non-exec-fs mm/mprotect.c
--- a/mm/mprotect.c~mm-mprotectc-dont-imply-prot_exec-on-non-exec-fs
+++ a/mm/mprotect.c
@@ -359,6 +359,9 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
+	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
+				(prot & PROT_READ);
+
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
@@ -375,11 +378,6 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 		return -EINVAL;
 
 	reqprot = prot;
-	/*
-	 * Does the application expect PROT_READ to imply PROT_EXEC:
-	 */
-	if ((prot & PROT_READ) && (current->personality & READ_IMPLIES_EXEC))
-		prot |= PROT_EXEC;
 
 	down_write(&current->mm->mmap_sem);
 
@@ -414,6 +412,10 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 
 		/* Here we know that vma->vm_start <= nstart < vma->vm_end. */
 
+		/* Does the application expect PROT_READ to imply PROT_EXEC */
+		if (rier && (vma->vm_flags & VM_MAYEXEC))
+			prot |= PROT_EXEC;
+
 		newflags = calc_vm_prot_bits(prot, pkey);
 		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
 
@@ -445,6 +447,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long,
 			error = -ENOMEM;
 			goto out;
 		}
+		prot = reqprot;
 	}
 out:
 	up_write(&current->mm->mmap_sem);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
