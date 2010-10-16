Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7D81E6B0197
	for <linux-mm@kvack.org>; Sat, 16 Oct 2010 00:34:44 -0400 (EDT)
Received: by pvf33 with SMTP id 33so301795pvf.14
        for <linux-mm@kvack.org>; Fri, 15 Oct 2010 21:34:43 -0700 (PDT)
Date: Sat, 16 Oct 2010 12:34:55 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH 2/2] kvm: use vzalloc instead of vmalloc
Message-ID: <20101016043455.GB3177@darkstar>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kvm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Use vzalloc instead of vmalloc in kvm code.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
---
 arch/x86/kvm/x86.c  |    3 +--
 virt/kvm/kvm_main.c |   13 ++++---------
 2 files changed, 5 insertions(+), 11 deletions(-)

--- linux-2.6.orig/virt/kvm/kvm_main.c	2010-09-25 21:18:06.000000000 +0800
+++ linux-2.6/virt/kvm/kvm_main.c	2010-10-16 11:26:05.106672156 +0800
@@ -604,13 +604,11 @@ int __kvm_set_memory_region(struct kvm *
 	/* Allocate if a slot is being created */
 #ifndef CONFIG_S390
 	if (npages && !new.rmap) {
-		new.rmap = vmalloc(npages * sizeof(*new.rmap));
+		new.rmap = vzalloc(npages * sizeof(*new.rmap));
 
 		if (!new.rmap)
 			goto out_free;
 
-		memset(new.rmap, 0, npages * sizeof(*new.rmap));
-
 		new.user_alloc = user_alloc;
 		new.userspace_addr = mem->userspace_addr;
 	}
@@ -633,14 +631,12 @@ int __kvm_set_memory_region(struct kvm *
 			     >> KVM_HPAGE_GFN_SHIFT(level));
 		lpages -= base_gfn >> KVM_HPAGE_GFN_SHIFT(level);
 
-		new.lpage_info[i] = vmalloc(lpages * sizeof(*new.lpage_info[i]));
+		new.lpage_info[i] = vzalloc(lpages *
+					sizeof(*new.lpage_info[i]));
 
 		if (!new.lpage_info[i])
 			goto out_free;
 
-		memset(new.lpage_info[i], 0,
-		       lpages * sizeof(*new.lpage_info[i]));
-
 		if (base_gfn & (KVM_PAGES_PER_HPAGE(level) - 1))
 			new.lpage_info[i][0].write_count = 1;
 		if ((base_gfn+npages) & (KVM_PAGES_PER_HPAGE(level) - 1))
@@ -663,10 +659,9 @@ skip_lpage:
 	if ((new.flags & KVM_MEM_LOG_DIRTY_PAGES) && !new.dirty_bitmap) {
 		unsigned long dirty_bytes = kvm_dirty_bitmap_bytes(&new);
 
-		new.dirty_bitmap = vmalloc(dirty_bytes);
+		new.dirty_bitmap = vzalloc(dirty_bytes);
 		if (!new.dirty_bitmap)
 			goto out_free;
-		memset(new.dirty_bitmap, 0, dirty_bytes);
 		/* destroy any largepage mappings for dirty tracking */
 		if (old.npages)
 			flush_shadow = 1;
--- linux-2.6.orig/arch/x86/kvm/x86.c	2010-08-29 08:47:02.000000000 +0800
+++ linux-2.6/arch/x86/kvm/x86.c	2010-10-16 11:22:52.826666511 +0800
@@ -2917,10 +2917,9 @@ int kvm_vm_ioctl_get_dirty_log(struct kv
 		spin_unlock(&kvm->mmu_lock);
 
 		r = -ENOMEM;
-		dirty_bitmap = vmalloc(n);
+		dirty_bitmap = vzalloc(n);
 		if (!dirty_bitmap)
 			goto out;
-		memset(dirty_bitmap, 0, n);
 
 		r = -ENOMEM;
 		slots = kzalloc(sizeof(struct kvm_memslots), GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
