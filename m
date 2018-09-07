Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B63668E0001
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 18:36:45 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w18-v6so7663148plp.3
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 15:36:45 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g10-v6si9010950pgl.425.2018.09.07.15.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 15:36:44 -0700 (PDT)
Date: Fri, 7 Sep 2018 15:37:25 -0700
From: Alison Schofield <alison.schofield@intel.com>
Subject: [RFC 08/12] mm: Track VMA's in use for each memory encryption keyid
Message-ID: <3c891d076a376c8cff04403e90d04cf98b203960.1536356108.git.alison.schofield@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1536356108.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhowells@redhat.com, tglx@linutronix.de
Cc: Kai Huang <kai.huang@intel.com>, Jun Nakajima <jun.nakajima@intel.com>, Kirill Shutemov <kirill.shutemov@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, jmorris@namei.org, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org

Keep track of the VMA's oustanding for each memory encryption keyid.
The count is used by the MKTME (Multi-Key Total Memory Encryption)
Key Service to determine when it is safe to reprogram a hardware
encryption key.

Approach here is to do gets and puts on the encryption reference
wherever kmem_cache_alloc/free's of vma_area_cachep's are executed.
A couple of these locations will not be hit until cgroup support is
added. One of these locations should never hit, so use a VM_WARN_ON.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
---
 arch/x86/mm/mktme.c |  2 ++
 kernel/fork.c       |  2 ++
 mm/mmap.c           | 12 ++++++++++++
 mm/nommu.c          |  4 ++++
 4 files changed, 20 insertions(+)

diff --git a/arch/x86/mm/mktme.c b/arch/x86/mm/mktme.c
index 5690ef51a79a..8a7c326d4546 100644
--- a/arch/x86/mm/mktme.c
+++ b/arch/x86/mm/mktme.c
@@ -72,10 +72,12 @@ void mprotect_set_encrypt(struct vm_area_struct *vma, int newkeyid)
 	if (newkeyid == oldkeyid)
 		return;
 
+	vma_put_encrypt_ref(vma);
 	newprot = pgprot_val(vma->vm_page_prot);
 	newprot &= ~mktme_keyid_mask;
 	newprot |= (unsigned long)newkeyid << mktme_keyid_shift;
 	vma->vm_page_prot = __pgprot(newprot);
+	vma_get_encrypt_ref(vma);
 }
 
 /*
diff --git a/kernel/fork.c b/kernel/fork.c
index e5e7a220a124..2d0e507bde7c 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -459,6 +459,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (!tmp)
 			goto fail_nomem;
 		*tmp = *mpnt;
+		vma_get_encrypt_ref(tmp);	/* Track encrypted vma's */
 		INIT_LIST_HEAD(&tmp->anon_vma_chain);
 		retval = vma_dup_policy(mpnt, tmp);
 		if (retval)
@@ -539,6 +540,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 fail_nomem_anon_vma_fork:
 	mpol_put(vma_policy(tmp));
 fail_nomem_policy:
+	vma_put_encrypt_ref(tmp);		/* Track encrypted vma's */
 	kmem_cache_free(vm_area_cachep, tmp);
 fail_nomem:
 	retval = -ENOMEM;
diff --git a/mm/mmap.c b/mm/mmap.c
index 4c604eb644b4..7390b8b69fd6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -182,6 +182,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	mpol_put(vma_policy(vma));
+	vma_put_encrypt_ref(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
 }
@@ -913,6 +914,7 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 			anon_vma_merge(vma, next);
 		mm->map_count--;
 		mpol_put(vma_policy(next));
+		vma_put_encrypt_ref(next);
 		kmem_cache_free(vm_area_cachep, next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
@@ -1744,6 +1746,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		goto unacct_error;
 	}
 
+	vma_get_encrypt_ref(vma);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
@@ -1839,6 +1842,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 unmap_and_free_vma:
 	vma->vm_file = NULL;
 	fput(file);
+	vma_put_encrypt_ref(vma);
 
 	/* Undo any partial mapping done by a device driver. */
 	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
@@ -2653,6 +2657,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		new->vm_pgoff += ((addr - vma->vm_start) >> PAGE_SHIFT);
 	}
 
+	vma_get_encrypt_ref(new);
 	err = vma_dup_policy(vma, new);
 	if (err)
 		goto out_free_vma;
@@ -2686,6 +2691,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
  out_free_mpol:
 	mpol_put(vma_policy(new));
  out_free_vma:
+	vma_put_encrypt_ref(new);
 	kmem_cache_free(vm_area_cachep, new);
 	return err;
 }
@@ -3007,6 +3013,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 		return -ENOMEM;
 	}
 
+	vma_get_encrypt_ref(vma);
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
 	vma->vm_ops = &anon_vm_ops;
@@ -3229,6 +3236,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		new_vma->vm_pgoff = pgoff;
 		if (vma_dup_policy(vma, new_vma))
 			goto out_free_vma;
+		vma_get_encrypt_ref(new_vma);
 		INIT_LIST_HEAD(&new_vma->anon_vma_chain);
 		if (anon_vma_clone(new_vma, vma))
 			goto out_free_mempol;
@@ -3243,6 +3251,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 
 out_free_mempol:
 	mpol_put(vma_policy(new_vma));
+	vma_put_encrypt_ref(new_vma);
 out_free_vma:
 	kmem_cache_free(vm_area_cachep, new_vma);
 out:
@@ -3372,6 +3381,9 @@ static struct vm_area_struct *__install_special_mapping(
 	if (unlikely(vma == NULL))
 		return ERR_PTR(-ENOMEM);
 
+	/* Do not expect a memory encrypted vma here */
+	VM_WARN_ON(vma_keyid(vma));
+
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
diff --git a/mm/nommu.c b/mm/nommu.c
index 73f66e81cfb0..85f04c174638 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -769,6 +769,7 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 	if (vma->vm_file)
 		fput(vma->vm_file);
 	put_nommu_region(vma->vm_region);
+	vma_put_encrypt_ref(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 }
 
@@ -1215,6 +1216,7 @@ unsigned long do_mmap(struct file *file,
 	if (!vma)
 		goto error_getting_vma;
 
+	vma_get_encrypt_ref(vma);
 	region->vm_usage = 1;
 	region->vm_flags = vm_flags;
 	region->vm_pgoff = pgoff;
@@ -1375,6 +1377,7 @@ unsigned long do_mmap(struct file *file,
 	kmem_cache_free(vm_region_jar, region);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	vma_put_encrypt_ref(vma);
 	kmem_cache_free(vm_area_cachep, vma);
 	return ret;
 
@@ -1486,6 +1489,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	*new = *vma;
 	*region = *vma->vm_region;
 	new->vm_region = region;
+	vma_get_encrypt_ref(new);
 
 	npages = (addr - vma->vm_start) >> PAGE_SHIFT;
 
-- 
2.14.1
