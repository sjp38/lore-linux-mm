Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 927BD6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 17:36:08 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so7672633pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 14:36:08 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id km1si28826615pab.155.2015.04.28.14.36.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 14:36:07 -0700 (PDT)
Date: Tue, 28 Apr 2015 14:36:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 97321] New: WARNING at untrack_pfn+0x 99/0xa0()
Message-Id: <20150428143606.ba343c2f828f5cec615aa366@linux-foundation.org>
In-Reply-To: <bug-97321-27@https.bugzilla.kernel.org/>
References: <bug-97321-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stsp@list.ru
Cc: bugzilla-daemon@bugzilla.kernel.org, Suresh Siddha <sbsiddha@gmail.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, linux-mm@kvack.org


I'm switching this to email - we don't handle patches via bugzilla.

Suresh, could you please take a look?


On Sun, 26 Apr 2015 21:09:07 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=97321
> 
>             Bug ID: 97321
>            Summary: WARNING at untrack_pfn+0x 99/0xa0()
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.0.0-rc6+ git
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: stsp@list.ru
>         Regression: No
> 
> Created attachment 175121
>   --> https://bugzilla.kernel.org/attachment.cgi?id=175121&action=edit
> possible fix
> 
> Hello.
> 
> I have a program that AFAIK does mremap() on previously
> mmap()ed /dev/mem. This results in the following stack trace:
> 
> [   67.887346] WARNING: CPU: 3 PID: 5144 at arch/x86/mm/pat.c:904
> untrack_pfn+0x
> 99/0xa0()
> 
> [   67.892540] Call Trace:
> [   67.892623]  [<ffffffff81541bcd>] dump_stack+0x4f/0x7b
> [   67.892706]  [<ffffffff810533fb>] warn_slowpath_common+0x8b/0xd0
> [   67.892788]  [<ffffffff810534e5>] warn_slowpath_null+0x15/0x20
> [   67.892870]  [<ffffffff8104b309>] untrack_pfn+0x99/0xa0
> [   67.892952]  [<ffffffff81138f3c>] unmap_single_vma+0x73c/0x750
> [   67.893035]  [<ffffffff8115879d>] ? alloc_pages_current+0x10d/0x1c0
> [   67.893118]  [<ffffffff81096846>] ? lockdep_init_map+0x66/0x7f0
> [   67.893200]  [<ffffffff81139b5c>] unmap_vmas+0x4c/0xb0
> [   67.893282]  [<ffffffff8113f1a3>] unmap_region+0xa3/0x110
> [   67.893364]  [<ffffffff8113f5d9>] ? vma_rb_erase+0x129/0x250
> [   67.893446]  [<ffffffff811413b0>] do_munmap+0x1f0/0x460
> [   67.893560]  [<ffffffff811444bd>] move_vma+0x14d/0x280
> [   67.893641]  [<ffffffff81144992>] SyS_mremap+0x3a2/0x510
> [   67.893724]  [<ffffffff8154b689>] system_call_fastpath+0x12/0x17
> 
> 
> The problem happens because __follow_pte() returns
> -EINVAL after !pte_present(*ptep) check, and so
> follow_phys() fails.
> I think if the page is not present, it is simply not
> needed to do free_pfn_range(). So I made a naive patch
> (attached) that seem to fix the problem.

patch:

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 7ac6869..2df97f6 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -900,14 +900,12 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
 	/* free the chunk starting from pfn or the whole chunk */
 	paddr = (resource_size_t)pfn << PAGE_SHIFT;
 	if (!paddr && !size) {
-		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
-			WARN_ON_ONCE(1);
-			return;
-		}
-
-		size = vma->vm_end - vma->vm_start;
+		int err = follow_phys(vma, vma->vm_start, 0, &prot, &paddr);
+		if (!err)
+			size = vma->vm_end - vma->vm_start;
 	}
-	free_pfn_range(paddr, size);
+	if (size)
+		free_pfn_range(paddr, size);
 	vma->vm_flags &= ~VM_PAT;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
