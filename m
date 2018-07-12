Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A14666B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:32:06 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u8-v6so11208168pfn.18
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 07:32:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3-v6sor5663442pgr.176.2018.07.12.07.32.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 07:32:04 -0700 (PDT)
Date: Thu, 12 Jul 2018 17:31:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: general protection fault in _vm_normal_page
Message-ID: <20180712143158.7d5njt37x2bvq2xr@kshutemo-mobl1>
References: <00000000000010c9390570bc0643@google.com>
 <20180711140449.3702358d7e8898017e34dcfd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711140449.3702358d7e8898017e34dcfd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com>, jglisse@redhat.com, kirill.shutemov@linux.intel.com, ldufour@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, minchan@kernel.org, ross.zwisler@linux.intel.com, sfr@canb.auug.org.au, syzkaller-bugs@googlegroups.com, ying.huang@intel.com

On Wed, Jul 11, 2018 at 02:04:49PM -0700, Andrew Morton wrote:
> On Wed, 11 Jul 2018 09:49:01 -0700 syzbot <syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com> wrote:
> 
> > Hello,
> > 
> > syzbot found the following crash on:
> > 
> > HEAD commit:    98be45067040 Add linux-next specific files for 20180711
> > git tree:       linux-next
> > console output: https://syzkaller.appspot.com/x/log.txt?x=12496ac2400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=3f3b3673fec35d01
> > dashboard link: https://syzkaller.appspot.com/bug?extid=120abb1c3f7bfdc523f7
> > compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> > syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=12a46568400000
> 
> Handy.  /dev/ion from drivers/staging/android/ion/ion.c
> 
> > 
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+120abb1c3f7bfdc523f7@syzkaller.appspotmail.com
> > 
> > R10: 0000000004000812 R11: 0000000000000246 R12: 0000000000000005
> > R13: 00000000004c0565 R14: 00000000004cffb0 R15: 0000000000000005
> > ion_mmap: failure mapping buffer to userspace
> > kasan: CONFIG_KASAN_INLINE enabled
> > kasan: GPF could be caused by NULL-ptr deref or user memory access
> > general protection fault: 0000 [#1] SMP KASAN
> > CPU: 0 PID: 4785 Comm: syz-executor0 Not tainted 4.18.0-rc4-next-20180711+  
> > #4
> > Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
> > Google 01/01/2011
> > RIP: 0010:_vm_normal_page+0x1e5/0x330 mm/memory.c:828
> 
> Presumably has a NULL vma->vm_ops.  Probably one of the now-removed
> checks in mm-drop-unneeded-vm_ops-checks.patch would have avoided
> this.
> 
> Something for Kirill to think about ;)
> 

Okay. Looks like we need vm_ops in the error path too :P

Here's the fixup which should help.

I'll post the new version of the patchset once figure out nommu issues.

diff --git a/mm/mmap.c b/mm/mmap.c
index 74d4d2a8fe08..eedac20735c1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1776,6 +1776,11 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		vma->vm_file = get_file(file);
 		error = call_mmap(file, vma);
+
+		/* All mappings must have ->vm_ops set */
+		if (!vma->vm_ops)
+			vma->vm_ops = &dummy_vm_ops;
+
 		if (error)
 			goto unmap_and_free_vma;
 
@@ -1788,10 +1793,6 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		WARN_ON_ONCE(addr != vma->vm_start);
 
-		/* All mappings must have ->vm_ops set */
-		if (!vma->vm_ops)
-			vma->vm_ops = &dummy_vm_ops;
-
 		addr = vma->vm_start;
 		vm_flags = vma->vm_flags;
 	} else if (vm_flags & VM_SHARED) {
-- 
 Kirill A. Shutemov
