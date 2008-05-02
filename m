Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m421pqt5031670
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:51:52 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m421pqx7265426
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:51:52 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m421ppAM020544
	for <linux-mm@kvack.org>; Thu, 1 May 2008 21:51:51 -0400
Subject: [RFC][PATCH 2/2] Add huge page backed stack support
From: Eric B Munson <ebmunson@us.ibm.com>
Reply-To: ebmunson@us.ibm.com
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1YpyVUA6P1hwR7SZY0bk"
Date: Thu, 01 May 2008 18:51:49 -0700
Message-Id: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-1YpyVUA6P1hwR7SZY0bk
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

This patch allows a process's stack to be backed by huge pages on request. =
As
the stack is setup at exec() time, a personality flag is added to indicate=20
the use of a hugepage-backed stack. =EF=BB=BFThe personality flag is inheri=
ted across=20
exec().

Huge page stacks require stack randomization to be disabled because huge
ptes are not movable, so the HUGE_PAGE_STACK personality flag implies
ADDR_NO_RANDOMIZE.  When the hugetlb file is setup to back the stack, it is
sized to fit the ulimit for stack size or 256 MB if ulimit is unlimited.
The GROWSUP and GROWSDOWN VM flags are turned off because a hugetlb backed
vma is not resizable, so it will be appropriately sized when created.  When
a process exceeds stack size it recieves a segfault exactly as it would if =
it
exceeded the ulimit.

Based on 2.6.25

Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

---

 fs/exec.c                   |   87 ++++++++++++++++++++++++++++++++++++++-=
---
 include/linux/personality.h |    3 +
 2 files changed, 81 insertions(+), 9 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index b152029..d38ddf0 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -51,6 +51,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
+#include <linux/hugetlb.h>
=20
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -60,6 +61,8 @@
 #include <linux/kmod.h>
 #endif
=20
+#define MB (1024*1024)
+
 int core_uses_pid;
 char core_pattern[CORENAME_MAX_SIZE] =3D "core";
 int suid_dumpable =3D 0;
@@ -152,6 +155,13 @@ exit:
 	goto out;
 }
=20
+static unsigned long personality_page_align(unsigned long addr)
+{
+	if (get_personality & HUGE_PAGE_STACK)
+		return HPAGE_ALIGN(addr);
+	return PAGE_ALIGN(addr);
+}
+
 #ifdef CONFIG_MMU
=20
 static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long =
pos,
@@ -173,7 +183,12 @@ static struct page *get_arg_page(struct linux_binprm *=
bprm, unsigned long pos,
 		return NULL;
=20
 	if (write) {
-		unsigned long size =3D bprm->vma->vm_end - bprm->vma->vm_start;
+		/*
+		 * Args are always placed at the high end of the stack space
+		 * so this calculation will give the proper size and it is
+		 * compatible with huge page stacks.
+		 */
+		unsigned long size =3D bprm->vma->vm_end - pos;
 		struct rlimit *rlim;
=20
 		/*
@@ -219,16 +234,57 @@ static void flush_arg_page(struct linux_binprm *bprm,=
 unsigned long pos,
 	flush_cache_page(bprm->vma, pos, page_to_pfn(page));
 }
=20
+static struct file *hugetlb_stack_file(int stack_hpages)
+{
+	struct file *hugefile =3D NULL;
+
+	if (!stack_hpages) {
+		set_personality(get_personality & (~HUGE_PAGE_STACK));
+		printk(KERN_DEBUG
+			"Stack rlimit set too low for huge page backed stack.\n");
+		return NULL;
+	}
+
+	hugefile =3D hugetlb_file_setup(HUGETLB_STACK_FILE,
+					HPAGE_SIZE * stack_hpages, 0);
+	if (unlikely(IS_ERR_VALUE(hugefile))) {
+		/*
+		 * If huge pages are not available for this stack fall
+		 * fall back to normal pages for execution instead of
+		 * failing.
+		 */
+		printk(KERN_DEBUG
+			"Huge page backed stack unavailable for process %lu.\n",
+			(unsigned long)current->pid);
+		set_personality(get_personality & (~HUGE_PAGE_STACK));
+		return NULL;
+	}
+	return hugefile;
+}
+
 static int __bprm_mm_init(struct linux_binprm *bprm)
 {
 	int err =3D -ENOMEM;
 	struct vm_area_struct *vma =3D NULL;
 	struct mm_struct *mm =3D bprm->mm;
+	struct file *hugefile =3D NULL;
+	struct rlimit *rlim;
+	int stack_hpages =3D 0;
=20
 	bprm->vma =3D vma =3D kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
 	if (!vma)
 		goto err;
=20
+	if (get_personality & HUGE_PAGE_STACK) {
+		rlim =3D current->signal->rlim;
+		if (rlim[RLIMIT_STACK].rlim_cur =3D=3D _STK_LIM_MAX)
+			stack_hpages =3D (256 * MB) / HPAGE_SIZE;
+		else
+			stack_hpages =3D rlim[RLIMIT_STACK].rlim_cur / HPAGE_SIZE;
+
+		hugefile =3D hugetlb_stack_file(stack_hpages);
+	}
+
 	down_write(&mm->mmap_sem);
 	vma->vm_mm =3D mm;
=20
@@ -239,9 +295,20 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	 * configured yet.
 	 */
 	vma->vm_end =3D STACK_TOP_MAX;
-	vma->vm_start =3D vma->vm_end - PAGE_SIZE;
=20
 	vma->vm_flags =3D VM_STACK_FLAGS;
+
+	if (hugefile) {
+		vma->vm_flags &=3D ~(VM_GROWSUP|VM_GROWSDOWN);
+		vma->vm_file =3D hugefile;
+		vma->vm_flags |=3D VM_HUGETLB;
+		/* Stack randomization is not supported on huge pages */
+		set_personality(get_personality | ADDR_NO_RANDOMIZE);
+		vma->vm_start =3D vma->vm_end - (HPAGE_SIZE * stack_hpages);
+	} else {
+		vma->vm_start =3D vma->vm_end - PAGE_SIZE;
+	}
+
 	vma->vm_page_prot =3D vm_get_page_prot(vma->vm_flags);
 	err =3D insert_vm_struct(mm, vma);
 	if (err) {
@@ -593,13 +660,12 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	bprm->p =3D vma->vm_end - stack_shift;
 #else
 	stack_top =3D arch_align_stack(stack_top);
-	stack_top =3D PAGE_ALIGN(stack_top);
+	stack_top =3D personality_page_align(stack_top);
 	stack_shift =3D vma->vm_end - stack_top;
=20
 	bprm->p -=3D stack_shift;
 	mm->arg_start =3D bprm->p;
 #endif
-
 	if (bprm->loader)
 		bprm->loader -=3D stack_shift;
 	bprm->exec -=3D stack_shift;
@@ -633,14 +699,17 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		}
 	}
=20
+	if (!(get_personality & HUGE_PAGE_STACK)) {
 #ifdef CONFIG_STACK_GROWSUP
-	stack_base =3D vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
+		stack_base =3D vma->vm_end + EXTRA_STACK_VM_PAGES * PAGE_SIZE;
 #else
-	stack_base =3D vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
+		stack_base =3D vma->vm_start - EXTRA_STACK_VM_PAGES * PAGE_SIZE;
 #endif
-	ret =3D expand_stack(vma, stack_base);
-	if (ret)
-		ret =3D -EFAULT;
+
+		ret =3D expand_stack(vma, stack_base);
+		if (ret)
+			ret =3D -EFAULT;
+	}
=20
 out_unlock:
 	up_write(&mm->mmap_sem);
diff --git a/include/linux/personality.h b/include/linux/personality.h
index 012cd55..6ecebdf 100644
--- a/include/linux/personality.h
+++ b/include/linux/personality.h
@@ -22,6 +22,9 @@ extern int		__set_personality(unsigned long);
  * These occupy the top three bytes.
  */
 enum {
+	HUGE_PAGE_STACK =3D 	0x0020000,	/* Attempt to use a huge page
+						 * for the process stack
+						 */
 	ADDR_NO_RANDOMIZE =3D 	0x0040000,	/* disable randomization of VA space */
 	FDPIC_FUNCPTRS =3D	0x0080000,	/* userspace function ptrs point to descrip=
tors
 						 * (signal handling)


--=-1YpyVUA6P1hwR7SZY0bk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBIGnO1snv9E83jkzoRAoEoAKCVHgZDcGSziR+pvilWMEFsCWhdMgCg9YiP
Nnwn9dZIix/nxSc4H/nvv5I=
=GENL
-----END PGP SIGNATURE-----

--=-1YpyVUA6P1hwR7SZY0bk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
