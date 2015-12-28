Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 84F3C6B0289
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 18:10:04 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so93477403pac.1
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 15:10:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l11si5441172pfb.172.2015.12.28.15.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Dec 2015 15:10:03 -0800 (PST)
Date: Mon, 28 Dec 2015 15:10:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC] mm: Rework virtual memory accounting
Message-Id: <20151228151002.0a8e44199d31f7a4fa7fc414@linux-foundation.org>
In-Reply-To: <20151228211015.GL2194@uranus>
References: <20151228211015.GL2194@uranus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linuxfoundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 29 Dec 2015 00:10:15 +0300 Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> When inspecting a vague code inside prctl(PR_SET_MM_MEM)
> call (which testing the RLIMIT_DATA value to figure out
> if we're allowed to assign new @start_brk, @brk, @start_data,
> @end_data from mm_struct) it's been commited that RLIMIT_DATA
> in a form it's implemented now doesn't do anything useful
> because most of user-space libraries use mmap() syscall
> for dynamic memory allocations.
> 
> Linus suggested to convert RLIMIT_DATA rlimit into something
> suitable for anonymous memory accounting. But in this patch
> we go further, and the changes are bundled together as:
> 
>  * keep vma counting if CONFIG_PROC_FS=n, will be used for limits
>  * replace mm->shared_vm with better defined mm->data_vm
>  * account anonymous executable areas as executable
>  * account file-backed growsdown/up areas as stack
>  * drop struct file* argument from vm_stat_account
>  * enforce RLIMIT_DATA for size of data areas
> 
> This way code looks cleaner: now code/stack/data
> classification depends only on vm_flags state:
> 
>  VM_EXEC & ~VM_WRITE            -> code  (VmExe + VmLib in proc)
>  VM_GROWSUP | VM_GROWSDOWN      -> stack (VmStk)
>  VM_WRITE & ~VM_SHARED & !stack -> data  (VmData)
> 
> The rest (VmSize - VmData - VmStk - VmExe - VmLib) could be
> called "shared", but that might be strange beast like
> readonly-private or VM_IO area.
> 
>  - RLIMIT_AS            limits whole address space "VmSize"
>  - RLIMIT_STACK         limits stack "VmStk" (but each vma individually)
>  - RLIMIT_DATA          now limits "VmData"

This clashes with
mm-mmapc-remove-redundant-local-variables-for-may_expand_vm.patch,
below.  I resolved it thusly:

bool may_expand_vm(struct mm_struct *mm, vm_flags_t flags, unsigned long npages)
{
	if (mm->total_vm + npages > rlimit(RLIMIT_AS) >> PAGE_SHIFT)
		return false;

	if ((flags & (VM_WRITE | VM_SHARED | (VM_STACK_FLAGS &
				(VM_GROWSUP | VM_GROWSDOWN)))) == VM_WRITE)
		return mm->data_vm + npages <= rlimit(RLIMIT_DATA);

	return true;
}



From: Chen Gang <gang.chen.5i5j@gmail.com>
Subject: mm/mmap.c: remove redundant local variables for may_expand_vm()

Simplify may_expand_vm()

[akpm@linux-foundation.org: further simplification, per Naoya Horiguchi]
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mmap.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff -puN mm/mmap.c~mm-mmapc-remove-redundant-local-variables-for-may_expand_vm mm/mmap.c
--- a/mm/mmap.c~mm-mmapc-remove-redundant-local-variables-for-may_expand_vm
+++ a/mm/mmap.c
@@ -2988,14 +2988,7 @@ out:
  */
 int may_expand_vm(struct mm_struct *mm, unsigned long npages)
 {
-	unsigned long cur = mm->total_vm;	/* pages */
-	unsigned long lim;
-
-	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
-
-	if (cur + npages > lim)
-		return 0;
-	return 1;
+	return mm->total_vm + npages <= rlimit(RLIMIT_AS) >> PAGE_SHIFT;
 }
 
 static int special_mapping_fault(struct vm_area_struct *vma,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
