Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 92C6B6B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 01:52:31 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o365qHjQ028624
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 14:52:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D5DCB45DE51
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:52:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AA37C45DE4E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:52:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 89A2F1DB8040
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:52:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C2B91DB8038
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 14:52:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mprotect pgprot handling weirdness
In-Reply-To: <1270530566.13812.28.camel@pasglop>
References: <1270530566.13812.28.camel@pasglop>
Message-Id: <20100406143928.7E4B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  6 Apr 2010 14:52:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Hi folks !
> 
> While looking at untangling a bit some of the mess with vm_flags and
> pgprot (*), I notices a few things I can't quite explain... they may ..
> or may not be bugs, but I though it was worth mentioning:
> 
> - In mprotect_fixup() :
> 
> 	/*
> 	 * vm_flags and vm_page_prot are protected by the mmap_sem
> 	 * held in write mode.
> 	 */
> 	vma->vm_flags = newflags;
> 	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> 					  vm_get_page_prot(newflags));
> 
> 	if (vma_wants_writenotify(vma)) {
> 		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
> 		dirty_accountable = 1;
> 	}
> 
> So as you can see above, we take great care (using pgprot_modify) to avoid
> blasting away some PAT related flags on x86 (no other arch implements
> pgprot_modify() today).... but if we hit vma_wants_writenotify(), then
> we unconditionally override the entire vma->vm_page_prot field with some
> new prot bits born of the new vm_flags. That sounds odd...
> 
> - in sys_mprotect: 
> 
> 	newflags = vm_flags | (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
> 
> Do I read correctly that this means we cannot -remove- any flag than
> VM_READ, VM_WRITE or VM_EXEC ? That means that we cannot remove PROT_SAO
> which gets turned into VM_SAO on powerpc ... Yet another reason to take
> those arch specific mapping attributes out of the vm_flags.
> 
> (*) Right now it's near impossible to add arch specific PROT_* bits to
> mmap/mprotect for fancy things like cachability attributes, or other
> nifty things like reverse-endian mappings that we have on some embedded
> platforms, I'm investigating ways to better separate vm_page_prot from
> vm_flags so some PROT_* bits can go straight to the former without
> having to be mirrored in some way in the later.

This check was introduced the following commit. yes now we don't
consider arch specific PROT_xx flags. but I don't think it is odd.

Yeah, I can imagine at least embedded people certenary need arch
specific PROT_xx flags and they hope to change it. but I don't 
think mprotect() fit for your usage. I mean mprotect() is widely 
used glibc internally. then, If mprotec can change which flags, 
glibc might turn off such flags implictly.

So, Why can't we proper new syscall? It has no regression risk.



==========================================================
commit d5e066ae3c39b4036b5f5021c352af0b73c85568
Author: torvalds <torvalds>
Date:   Fri Sep 5 19:05:07 2003 +0000

    Fix mprotect() to do proper PROT_xxx -> VM_xxx translation.

    This also fixes the bug with MAP_SEM being potentially
    interpreted as VM_SHARED.

    BKrev: 3f58de63gvzz-PsxwnRPnXTpz7EOeg

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2c01579..699962e 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -224,7 +224,7 @@ fail:
 asmlinkage long
 sys_mprotect(unsigned long start, size_t len, unsigned long prot)
 {
-       unsigned long nstart, end, tmp;
+       unsigned long vm_flags, nstart, end, tmp;
        struct vm_area_struct * vma, * next, * prev;
        int error = -EINVAL;

@@ -239,6 +239,8 @@ sys_mprotect(unsigned long start, size_t len, unsigned long prot)
        if (end == start)
                return 0;

+       vm_flags = calc_vm_prot_bits(prot);
+
        down_write(&current->mm->mmap_sem);

        vma = find_vma_prev(current->mm, start, &prev);
@@ -257,7 +259,8 @@ sys_mprotect(unsigned long start, size_t len, unsigned long prot)
                        goto out;
                }

-               newflags = prot | (vma->vm_flags & ~(PROT_READ | PROT_WRITE | PROT_EXEC));
+               newflags = vm_flags | (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
+
                if ((newflags & ~(newflags >> 4)) & 0xf) {
                        error = -EACCES;
                        goto out;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
