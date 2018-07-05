Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 779706B000A
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 08:30:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f13-v6so4268021wmb.4
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 05:30:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8-v6sor2828245wrs.76.2018.07.05.05.30.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Jul 2018 05:30:19 -0700 (PDT)
Date: Thu, 5 Jul 2018 14:30:17 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180705123017.GA31959@techadventures.net>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
 <20180704151529.GA23317@techadventures.net>
 <20180705064335.GA32658@dhcp22.suse.cz>
 <20180705071839.GB30187@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705071839.GB30187@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Thu, Jul 05, 2018 at 09:18:39AM +0200, Oscar Salvador wrote:
>  
> > This is more than unexpected. The patch merely move the alignment check
> > up. I will try to investigate some more but I am off for next four days
> > and won't be online most of the time.
> > 
> > Btw. does the same happen if you keep do_brk helper and add the length
> > sanitization there as well?

I took another look.
The problem was that while deleting the check in do_brk_flags(), this left then "len"
local variable with an unset value, but we need it to contain the request value
because we do use it in further calls in do_brk_flags(), like:

while (find_vma_links(mm, addr, addr + len, &prev, &rb_link,
                              &rb_parent)) {
	if (do_munmap(mm, addr, len, uf))
		return -ENOMEM;
}

or

if (!may_expand_vm(mm, flags, len >> PAGE_SHIFT))

and so on.

This boots and works with the reproducer:

diff --git a/mm/mmap.c b/mm/mmap.c
index 9859cd4e19b9..e4c9e995870f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -186,8 +186,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	return next;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf);
-
+static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags,
+								struct list_head *uf);
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
 	unsigned long retval;
@@ -245,7 +245,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		goto out;
 
 	/* Ok, looks good - let it rip. */
-	if (do_brk(oldbrk, newbrk-oldbrk, &uf) < 0)
+	if (do_brk_flags(oldbrk, newbrk-oldbrk, 0, &uf) < 0)
 		goto out;
 
 set_brk:
@@ -2934,17 +2934,11 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
-	unsigned long len;
+	unsigned long len = request;
 	struct rb_node **rb_link, *rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
-	len = PAGE_ALIGN(request);
-	if (len < request)
-		return -ENOMEM;
-	if (!len)
-		return 0;
-
 	/* Until we need other flags, refuse anything except VM_EXEC. */
 	if ((flags & (~VM_EXEC)) != 0)
 		return -EINVAL;
@@ -3016,18 +3010,20 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	return 0;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf)
-{
-	return do_brk_flags(addr, len, 0, uf);
-}
-
-int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
+int vm_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	unsigned long len;
 	bool populate;
 	LIST_HEAD(uf);
 
+	len = PAGE_ALIGN(request);
+	if (len < request)
+		return -ENOMEM;
+	if (!len)
+		return 0;
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;


But I think that we should also add:

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 0ac456b52bdd..6c7e005ae12d 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1259,9 +1259,9 @@ static int load_elf_library(struct file *file)
 		goto out_free_ph;
 	}
 
-	len = ELF_PAGESTART(eppnt->p_filesz + eppnt->p_vaddr +
-			    ELF_MIN_ALIGN - 1);
-	bss = eppnt->p_memsz + eppnt->p_vaddr;
+
+	len = ELF_PAGEALIGN(eppnt->p_filesz + eppnt->p_vaddr);
+	bss = ELF_PAGEALIGN(eppnt->p_memsz + eppnt->p_vaddr);
 	if (bss > len) {
 		error = vm_brk(len, bss - len);
 		if (error)

-- 
Oscar Salvador
SUSE L3
