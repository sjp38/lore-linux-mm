Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9ED856B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 13:46:42 -0400 (EDT)
Date: Thu, 30 Apr 2009 20:46:24 +0300
From: Izik Eidus <ieidus@redhat.com>
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
Message-ID: <20090430204624.358c4a2e@woof.tlv.redhat.com>
In-Reply-To: <49F63BC0.9090804@redhat.com>
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>
	<1240191366-10029-2-git-send-email-ieidus@redhat.com>
	<1240191366-10029-3-git-send-email-ieidus@redhat.com>
	<1240191366-10029-4-git-send-email-ieidus@redhat.com>
	<1240191366-10029-5-git-send-email-ieidus@redhat.com>
	<1240191366-10029-6-git-send-email-ieidus@redhat.com>
	<20090427153421.2682291f.akpm@linux-foundation.org>
	<49F63BC0.9090804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 28 Apr 2009 02:12:00 +0300
Izik Eidus <ieidus@redhat.com> wrote:

> Andrew Morton wrote:

> > Breaks sparc64 and probably lots of other architectures:
> >
> > mm/ksm.c: In function `try_to_merge_two_pages_alloc':
> > mm/ksm.c:697: error: `_PAGE_RW' undeclared (first use in this
> > function)
> >
> > there should be an official arch-independent way of manipulating
> > vma->vm_page_prot, but I'm not immediately finding it.
> >  =20
> Hi,
>=20
> vm_get_page_prot() will probably do the work.
>=20
> I will send you patch that fix it,
> but first i am waiting for Andrea and Chris to say they are happy
> with small changes that i made to the api after conversation i had
> with them (about checking if this api is robust enough so we wont
> have to change it later)
>=20
> When i will get their acks, i will send you patch against this
> togather with the api (until then it is ok to just leave it only for
> x86)
>=20
> changes are:
> 1) limiting the number of memory regions registered per file
> descriptor=20
> - so while (1){ (ioctl(KSM_REGISTER_MEMORY_REGION()) ) wont omm the
> host
>=20
> 2) checking if memory is overlap in registration (more effective to=20
> ignore such cases)
>=20
> 3) allow removing specific memoy regions inside fd.
>=20
> Thanks.
>=20

Hi,

Following patchs change the api to be more robust, the result change of
the api came after conversation i had with Andrea and Chris about how
to make the api as stable as we can,

In addition i hope this patchset fix the cross compilation problems, i
compiled it on itanium (doesnt have _PAGE_RW) and it seems to work.

Thanks.
=46rom 108b720636d1e679e8d5378469fa1220ce1e6963 Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Thu, 30 Apr 2009 20:36:57 +0300
Subject: [PATCH 09/13] ksm: limiting the num of mem regions user can regist=
er per fd.

Right now user can open /dev/ksm fd and register unlimited number of
regions, such behavior may allocate unlimited amount of kernel memory
and get the whole host into out of memory situation.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 6165276..d58db6b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -48,6 +48,9 @@ static int rmap_hash_size;
 module_param(rmap_hash_size, int, 0);
 MODULE_PARM_DESC(rmap_hash_size, "Hash table size for the reverse mapping"=
);
=20
+static int regions_per_fd;
+module_param(regions_per_fd, int, 0);
+
 /*
  * ksm_mem_slot - hold information for an userspace scanning range
  * (the scanning for this region will be from addr untill addr +
@@ -67,6 +70,7 @@ struct ksm_mem_slot {
  */
 struct ksm_sma {
 	struct list_head sma_slots;
+	int nregions;
 };
=20
 /**
@@ -453,6 +457,11 @@ static int ksm_sma_ioctl_register_memory_region(struct=
 ksm_sma *ksm_sma,
 	struct ksm_mem_slot *slot;
 	int ret =3D -EPERM;
=20
+	if ((ksm_sma->nregions + 1) > regions_per_fd) {
+		ret =3D -EBUSY;
+		goto out;
+	}
+
 	slot =3D kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
 	if (!slot) {
 		ret =3D -ENOMEM;
@@ -473,6 +482,7 @@ static int ksm_sma_ioctl_register_memory_region(struct =
ksm_sma *ksm_sma,
=20
 	list_add_tail(&slot->link, &slots);
 	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
+	ksm_sma->nregions++;
=20
 	up_write(&slots_lock);
 	return 0;
@@ -511,6 +521,7 @@ static int ksm_sma_ioctl_remove_memory_region(struct ks=
m_sma *ksm_sma)
 		mmput(slot->mm);
 		list_del(&slot->sma_link);
 		kfree(slot);
+		ksm_sma->nregions--;
 	}
 	up_write(&slots_lock);
 	return 0;
@@ -1389,6 +1400,7 @@ static int ksm_dev_ioctl_create_shared_memory_area(vo=
id)
 	}
=20
 	INIT_LIST_HEAD(&ksm_sma->sma_slots);
+	ksm_sma->nregions =3D 0;
=20
 	fd =3D anon_inode_getfd("ksm-sma", &ksm_sma_fops, ksm_sma, 0);
 	if (fd < 0)
@@ -1631,6 +1643,9 @@ static int __init ksm_init(void)
 	if (r)
 		goto out_free1;
=20
+	if (!regions_per_fd)
+		regions_per_fd =3D 1024;
+
 	ksm_thread =3D kthread_run(ksm_scan_thread, NULL, "kksmd");
 	if (IS_ERR(ksm_thread)) {
 		printk(KERN_ERR "ksm: creating kthread failed\n");
--=20
1.5.6.5

=46rom f24a9aa8c049c951a33613909951d115be5f84cd Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Thu, 30 Apr 2009 20:37:17 +0300
Subject: [PATCH 10/13] ksm: dont allow overlap memory addresses registratio=
ns.

subjects say it all.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index d58db6b..982dfff 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -451,21 +451,71 @@ static void remove_page_from_tree(struct mm_struct *m=
m,
 	remove_rmap_item_from_tree(rmap_item);
 }
=20
+static inline int is_intersecting_address(unsigned long addr,
+					  unsigned long begin,
+					  unsigned long end)
+{
+	if (addr >=3D begin && addr < end)
+		return 1;
+	return 0;
+}
+
+/*
+ * is_overlap_mem - check if there is overlapping with memory that was alr=
eady
+ * registred.
+ *
+ * note - this function must to be called under slots_lock
+ */
+static int is_overlap_mem(struct ksm_memory_region *mem)
+{
+	struct ksm_mem_slot *slot;
+
+	list_for_each_entry(slot, &slots, link) {
+		unsigned long mem_end;
+		unsigned long slot_end;
+
+		cond_resched();
+
+		if (current->mm !=3D slot->mm)
+			continue;
+
+		mem_end =3D mem->addr + (unsigned long)mem->npages * PAGE_SIZE;
+		slot_end =3D slot->addr + (unsigned long)slot->npages * PAGE_SIZE;
+
+		if (is_intersecting_address(mem->addr, slot->addr, slot_end) ||
+		    is_intersecting_address(mem_end - 1, slot->addr, slot_end))
+			return 1;
+		if (is_intersecting_address(slot->addr, mem->addr, mem_end) ||
+		    is_intersecting_address(slot_end - 1, mem->addr, mem_end))
+			return 1;
+	}
+
+	return 0;
+}
+
 static int ksm_sma_ioctl_register_memory_region(struct ksm_sma *ksm_sma,
 						struct ksm_memory_region *mem)
 {
 	struct ksm_mem_slot *slot;
 	int ret =3D -EPERM;
=20
+	if (!mem->npages)
+		goto out;
+
+	down_write(&slots_lock);
+
 	if ((ksm_sma->nregions + 1) > regions_per_fd) {
 		ret =3D -EBUSY;
-		goto out;
+		goto out_unlock;
 	}
=20
+	if (is_overlap_mem(mem))
+		goto out_unlock;
+
 	slot =3D kzalloc(sizeof(struct ksm_mem_slot), GFP_KERNEL);
 	if (!slot) {
 		ret =3D -ENOMEM;
-		goto out;
+		goto out_unlock;
 	}
=20
 	/*
@@ -478,8 +528,6 @@ static int ksm_sma_ioctl_register_memory_region(struct =
ksm_sma *ksm_sma,
 	slot->addr =3D mem->addr;
 	slot->npages =3D mem->npages;
=20
-	down_write(&slots_lock);
-
 	list_add_tail(&slot->link, &slots);
 	list_add_tail(&slot->sma_link, &ksm_sma->sma_slots);
 	ksm_sma->nregions++;
@@ -489,6 +537,8 @@ static int ksm_sma_ioctl_register_memory_region(struct =
ksm_sma *ksm_sma,
=20
 out_free:
 	kfree(slot);
+out_unlock:
+	up_write(&slots_lock);
 out:
 	return ret;
 }
--=20
1.5.6.5

=46rom 57807f89d1f2842de69511e10643a48976ebc22e Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Thu, 30 Apr 2009 20:37:39 +0300
Subject: [PATCH 11/13] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.

This patch change the KSM_REMOVE_MEMORY_REGION ioctl to be specific per
memory region (instead of flushing all the registred memory regions inside
the file descriptor like it happen now)

The previoes api was:
user register memory regions using KSM_REGISTER_MEMORY_REGION inside the fd,
and then when he wanted to remove just one memory region, he had to remove =
them
all using KSM_REMOVE_MEMORY_REGION.

This patch change this beahivor by chaning the KSM_REMOVE_MEMORY_REGION
ioctl to recive another paramter that it is the begining of the virtual
address that is wanted to be removed.

(user can still remove all the memory regions all at once, by just closing
the file descriptor)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 982dfff..c14019f 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -561,17 +561,20 @@ static void remove_mm_from_hash_and_tree(struct mm_st=
ruct *mm)
 	list_del(&slot->link);
 }
=20
-static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma)
+static int ksm_sma_ioctl_remove_memory_region(struct ksm_sma *ksm_sma,
+					      unsigned long addr)
 {
 	struct ksm_mem_slot *slot, *node;
=20
 	down_write(&slots_lock);
 	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
-		remove_mm_from_hash_and_tree(slot->mm);
-		mmput(slot->mm);
-		list_del(&slot->sma_link);
-		kfree(slot);
-		ksm_sma->nregions--;
+		if (addr =3D=3D slot->addr) {
+			remove_mm_from_hash_and_tree(slot->mm);
+			mmput(slot->mm);
+			list_del(&slot->sma_link);
+			kfree(slot);
+			ksm_sma->nregions--;
+		}
 	}
 	up_write(&slots_lock);
 	return 0;
@@ -579,12 +582,20 @@ static int ksm_sma_ioctl_remove_memory_region(struct =
ksm_sma *ksm_sma)
=20
 static int ksm_sma_release(struct inode *inode, struct file *filp)
 {
+	struct ksm_mem_slot *slot, *node;
 	struct ksm_sma *ksm_sma =3D filp->private_data;
-	int r;
=20
-	r =3D ksm_sma_ioctl_remove_memory_region(ksm_sma);
+	down_write(&slots_lock);
+	list_for_each_entry_safe(slot, node, &ksm_sma->sma_slots, sma_link) {
+		remove_mm_from_hash_and_tree(slot->mm);
+		mmput(slot->mm);
+		list_del(&slot->sma_link);
+		kfree(slot);
+	}
+	up_write(&slots_lock);
+
 	kfree(ksm_sma);
-	return r;
+	return 0;
 }
=20
 static long ksm_sma_ioctl(struct file *filp,
@@ -607,7 +618,7 @@ static long ksm_sma_ioctl(struct file *filp,
 		break;
 	}
 	case KSM_REMOVE_MEMORY_REGION:
-		r =3D ksm_sma_ioctl_remove_memory_region(sma);
+		r =3D ksm_sma_ioctl_remove_memory_region(sma, arg);
 		break;
 	}
=20
--=20
1.5.6.5

=46rom 146ecd222f59460548dafbd3c322030251c33b8d Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Thu, 30 Apr 2009 20:38:05 +0300
Subject: [PATCH 12/13] ksm: change the prot handling to use the generic hel=
per functions

This is needed to avoid breaking some architectures.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/ksm.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index c14019f..bfbbe1d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -766,8 +766,8 @@ static int try_to_merge_two_pages_alloc(struct mm_struc=
t *mm1,
 		up_read(&mm1->mmap_sem);
 		return ret;
 	}
-	prot =3D vma->vm_page_prot;
-	pgprot_val(prot) &=3D ~_PAGE_RW;
+
+	prot =3D vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
=20
 	copy_user_highpage(kpage, page1, addr1, vma);
 	ret =3D try_to_merge_one_page(mm1, vma, page1, kpage, prot);
@@ -784,8 +784,7 @@ static int try_to_merge_two_pages_alloc(struct mm_struc=
t *mm1,
 			return ret;
 		}
=20
-		prot =3D vma->vm_page_prot;
-		pgprot_val(prot) &=3D ~_PAGE_RW;
+		prot =3D vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
=20
 		ret =3D try_to_merge_one_page(mm2, vma, page2, kpage,
 					    prot);
@@ -831,8 +830,9 @@ static int try_to_merge_two_pages_noalloc(struct mm_str=
uct *mm1,
 		up_read(&mm1->mmap_sem);
 		return ret;
 	}
-	prot =3D vma->vm_page_prot;
-	pgprot_val(prot) &=3D ~_PAGE_RW;
+
+	prot =3D vm_get_page_prot(vma->vm_flags & ~VM_WRITE);
+
 	ret =3D try_to_merge_one_page(mm1, vma, page1, page2, prot);
 	up_read(&mm1->mmap_sem);
 	if (!ret)
--=20
1.5.6.5

=46rom 3b437cac1890999191cca6c76da5e71ceec487e4 Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Thu, 30 Apr 2009 20:38:33 +0300
Subject: [PATCH 13/13] ksm: build system make it compile for all archs

The known issues with cross platform support were fixed,
so we return it back to compile on all archs.

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 mm/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index f59b1e4..fb8ac63 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -228,7 +228,6 @@ config MMU_NOTIFIER
=20
 config KSM
 	tristate "Enable KSM for page sharing"
-	depends on X86
 	help
 	  Enable the KSM kernel module to allow page sharing of equal pages
 	  among different tasks.
--=20
1.5.6.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
